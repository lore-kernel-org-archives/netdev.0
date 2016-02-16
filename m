From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/7] vxlan: keep flags and vni in network byte order
Date: Tue, 16 Feb 2016 21:58:58 +0100
Message-ID: <0da5fdea861c47bdb0e45415f6d0ac05564a6346.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbcBPU7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:33 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 03C2419CBE6
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:33 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxu018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:32 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent repeated conversions from and to network order in the fast path.

To achieve this, define all flag constants in big endian order and store VNI
as __be32. To prevent confusion between the actual VNI value and the VNI
field from the header (which contains additional reserved byte), strictly
distinguish between "vni" and "vni_field".

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 115 ++++++++++++++++++++++++++--------------------------
 include/net/vxlan.h |  70 +++++++++++++++++++++++++++-----
 2 files changed, 116 insertions(+), 69 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a1f1a5aed19a..58cc0942f39a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -197,9 +197,9 @@ static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
 #endif
 
 /* Virtual Network hash table head */
-static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
+static inline struct hlist_head *vni_head(struct vxlan_sock *vs, __be32 vni)
 {
-	return &vs->vni_list[hash_32(id, VNI_HASH_BITS)];
+	return &vs->vni_list[hash_32((__force u32)vni, VNI_HASH_BITS)];
 }
 
 /* Socket hash table head */
@@ -242,12 +242,12 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
 	return NULL;
 }
 
-static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
+static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
 {
 	struct vxlan_dev *vxlan;
 
-	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
-		if (vxlan->default_dst.remote_vni == id)
+	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
+		if (vxlan->default_dst.remote_vni == vni)
 			return vxlan;
 	}
 
@@ -255,7 +255,7 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
 }
 
 /* Look up VNI in a per net namespace table */
-static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id,
+static struct vxlan_dev *vxlan_find_vni(struct net *net, __be32 vni,
 					sa_family_t family, __be16 port,
 					u32 flags)
 {
@@ -265,7 +265,7 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id,
 	if (!vs)
 		return NULL;
 
-	return vxlan_vs_find_vni(vs, id);
+	return vxlan_vs_find_vni(vs, vni);
 }
 
 /* Fill in neighbour message in skbuff. */
@@ -315,7 +315,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
-	    nla_put_u32(skb, NDA_VNI, rdst->remote_vni))
+	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
 		goto nla_put_failure;
 	if (rdst->remote_ifindex &&
 	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
@@ -383,7 +383,7 @@ static void vxlan_ip_miss(struct net_device *dev, union vxlan_addr *ipa)
 	};
 	struct vxlan_rdst remote = {
 		.remote_ip = *ipa, /* goes to NDA_DST */
-		.remote_vni = VXLAN_N_VID,
+		.remote_vni = cpu_to_be32(VXLAN_N_VID),
 	};
 
 	vxlan_fdb_notify(vxlan, &f, &remote, RTM_GETNEIGH);
@@ -452,7 +452,7 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 /* caller should hold vxlan->hash_lock */
 static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
 					      union vxlan_addr *ip, __be16 port,
-					      __u32 vni, __u32 ifindex)
+					      __be32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
@@ -469,7 +469,8 @@ static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
 
 /* Replace destination of unicast mac */
 static int vxlan_fdb_replace(struct vxlan_fdb *f,
-			     union vxlan_addr *ip, __be16 port, __u32 vni, __u32 ifindex)
+			     union vxlan_addr *ip, __be16 port, __be32 vni,
+			     __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
@@ -489,7 +490,7 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    union vxlan_addr *ip, __be16 port, __u32 vni,
+			    union vxlan_addr *ip, __be16 port, __be32 vni,
 			    __u32 ifindex, struct vxlan_rdst **rdp)
 {
 	struct vxlan_rdst *rd;
@@ -515,7 +516,8 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 					  unsigned int off,
 					  struct vxlanhdr *vh, size_t hdrlen,
-					  u32 data, struct gro_remcsum *grc,
+					  __be32 vni_field,
+					  struct gro_remcsum *grc,
 					  bool nopartial)
 {
 	size_t start, offset;
@@ -526,10 +528,8 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
 
-	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
-	offset = start + ((data & VXLAN_RCO_UDP) ?
-			  offsetof(struct udphdr, check) :
-			  offsetof(struct tcphdr, check));
+	start = vxlan_rco_start(vni_field);
+	offset = start + vxlan_rco_offset(vni_field);
 
 	vh = skb_gro_remcsum_process(skb, (void *)vh, off, hdrlen,
 				     start, offset, grc, nopartial);
@@ -549,7 +549,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 	int flush = 1;
 	struct vxlan_sock *vs = container_of(uoff, struct vxlan_sock,
 					     udp_offloads);
-	u32 flags;
+	__be32 flags;
 	struct gro_remcsum grc;
 
 	skb_gro_remcsum_init(&grc);
@@ -565,11 +565,11 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 
 	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
 
-	flags = ntohl(vh->vx_flags);
+	flags = vh->vx_flags;
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
 		vh = vxlan_gro_remcsum(skb, off_vx, vh, sizeof(struct vxlanhdr),
-				       ntohl(vh->vx_vni), &grc,
+				       vh->vx_vni, &grc,
 				       !!(vs->flags &
 					  VXLAN_F_REMCSUM_NOPARTIAL));
 
@@ -660,7 +660,7 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, union vxlan_addr *ip,
 			    __u16 state, __u16 flags,
-			    __be16 port, __u32 vni, __u32 ifindex,
+			    __be16 port, __be32 vni, __u32 ifindex,
 			    __u8 ndm_flags)
 {
 	struct vxlan_rdst *rd = NULL;
@@ -767,7 +767,8 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 }
 
 static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
-			   union vxlan_addr *ip, __be16 *port, u32 *vni, u32 *ifindex)
+			   union vxlan_addr *ip, __be16 *port, __be32 *vni,
+			   u32 *ifindex)
 {
 	struct net *net = dev_net(vxlan->dev);
 	int err;
@@ -800,7 +801,7 @@ static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
 			return -EINVAL;
-		*vni = nla_get_u32(tb[NDA_VNI]);
+		*vni = cpu_to_be32(nla_get_u32(tb[NDA_VNI]));
 	} else {
 		*vni = vxlan->default_dst.remote_vni;
 	}
@@ -830,7 +831,8 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	/* struct net *net = dev_net(vxlan->dev); */
 	union vxlan_addr ip;
 	__be16 port;
-	u32 vni, ifindex;
+	__be32 vni;
+	u32 ifindex;
 	int err;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
@@ -867,7 +869,8 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	struct vxlan_rdst *rd = NULL;
 	union vxlan_addr ip;
 	__be16 port;
-	u32 vni, ifindex;
+	__be32 vni;
+	u32 ifindex;
 	int err;
 
 	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &vni, &ifindex);
@@ -1123,17 +1126,16 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 }
 
 static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
-				      size_t hdrlen, u32 data, bool nopartial)
+				      size_t hdrlen, __be32 vni_field,
+				      bool nopartial)
 {
 	size_t start, offset, plen;
 
 	if (skb->remcsum_offload)
 		return vh;
 
-	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
-	offset = start + ((data & VXLAN_RCO_UDP) ?
-			  offsetof(struct udphdr, check) :
-			  offsetof(struct tcphdr, check));
+	start = vxlan_rco_start(vni_field);
+	offset = start + vxlan_rco_offset(vni_field);
 
 	plen = hdrlen + offset + sizeof(u16);
 
@@ -1149,7 +1151,7 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 }
 
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md, u32 vni,
+		      struct vxlan_metadata *md, __be32 vni,
 		      struct metadata_dst *tun_dst)
 {
 	struct iphdr *oip = NULL;
@@ -1247,7 +1249,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst = NULL;
 	struct vxlan_sock *vs;
-	u32 flags, vni;
+	__be32 flags, vni_field;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 
@@ -1255,8 +1257,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	flags = ntohl(vxlan_hdr(skb)->vx_flags);
-	vni = ntohl(vxlan_hdr(skb)->vx_vni);
+	flags = vxlan_hdr(skb)->vx_flags;
+	vni_field = vxlan_hdr(skb)->vx_vni;
 
 	if (flags & VXLAN_HF_VNI) {
 		flags &= ~VXLAN_HF_VNI;
@@ -1273,17 +1275,18 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
-		if (!vxlan_remcsum(skb, vxlan_hdr(skb), sizeof(struct vxlanhdr), vni,
+		if (!vxlan_remcsum(skb, vxlan_hdr(skb), sizeof(struct vxlanhdr),
+				   vni_field,
 				   !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL)))
 			goto drop;
 
 		flags &= ~VXLAN_HF_RCO;
-		vni &= VXLAN_VNI_MASK;
+		vni_field &= VXLAN_VNI_MASK;
 	}
 
 	if (vxlan_collect_metadata(vs)) {
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
-					 cpu_to_be64(vni >> 8), sizeof(*md));
+					 vxlan_vni(vni_field), sizeof(*md));
 
 		if (!tun_dst)
 			goto drop;
@@ -1314,7 +1317,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
 
-	if (flags || vni & ~VXLAN_VNI_MASK) {
+	if (flags || vni_field & ~VXLAN_VNI_MASK) {
 		/* If there are any unprocessed flags remaining treat
 		 * this as a malformed packet. This behavior diverges from
 		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
@@ -1327,7 +1330,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	vxlan_rcv(vs, skb, md, vni >> 8, tun_dst);
+	vxlan_rcv(vs, skb, md, vxlan_vni(vni_field), tun_dst);
 	return 0;
 
 drop:
@@ -1670,7 +1673,7 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 		return;
 
 	gbp = (struct vxlanhdr_gbp *)vxh;
-	vxh->vx_flags |= htonl(VXLAN_HF_GBP);
+	vxh->vx_flags |= VXLAN_HF_GBP;
 
 	if (md->gbp & VXLAN_GBP_DONT_LEARN)
 		gbp->dont_learn = 1;
@@ -1690,7 +1693,6 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	int min_headroom;
 	int err;
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-	u16 hdrlen = sizeof(struct vxlanhdr);
 
 	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1723,18 +1725,15 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 		return PTR_ERR(skb);
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = vni;
+	vxh->vx_flags = VXLAN_HF_VNI;
+	vxh->vx_vni = vxlan_vni_field(vni);
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
-		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
-			   VXLAN_RCO_SHIFT;
+		unsigned int start;
 
-		if (skb->csum_offset == offsetof(struct udphdr, check))
-			data |= VXLAN_RCO_UDP;
-
-		vxh->vx_vni |= htonl(data);
-		vxh->vx_flags |= htonl(VXLAN_HF_RCO);
+		start = skb_checksum_start_offset(skb) - sizeof(struct vxlanhdr);
+		vxh->vx_vni |= vxlan_compute_rco(start, skb->csum_offset);
+		vxh->vx_flags |= VXLAN_HF_RCO;
 
 		if (!skb_is_gso(skb)) {
 			skb->ip_summed = CHECKSUM_NONE;
@@ -1856,7 +1855,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
-	u32 vni;
+	__be32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
@@ -1877,7 +1876,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		}
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
-		vni = be64_to_cpu(info->key.tun_id);
+		vni = vxlan_tun_id_to_vni(info->key.tun_id);
 		remote_ip.sa.sa_family = ip_tunnel_info_af(info);
 		if (remote_ip.sa.sa_family == AF_INET)
 			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
@@ -1968,7 +1967,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
-				      htonl(vni << 8), md, flags, udp_sum);
+				      vni, md, flags, udp_sum);
 		if (err < 0)
 			goto xmit_tx_error;
 
@@ -2025,7 +2024,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 		skb_scrub_packet(skb, xnet);
 		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
-				      htonl(vni << 8), md, flags, udp_sum);
+				      vni, md, flags, udp_sum);
 		if (err < 0) {
 			dst_release(ndst);
 			return;
@@ -2182,7 +2181,7 @@ static void vxlan_cleanup(unsigned long arg)
 static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 {
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
-	__u32 vni = vxlan->default_dst.remote_vni;
+	__be32 vni = vxlan->default_dst.remote_vni;
 
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
@@ -2797,7 +2796,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	memset(&conf, 0, sizeof(conf));
 
 	if (data[IFLA_VXLAN_ID])
-		conf.vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+		conf.vni = cpu_to_be32(nla_get_u32(data[IFLA_VXLAN_ID]));
 
 	if (data[IFLA_VXLAN_GROUP]) {
 		conf.remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
@@ -2901,7 +2900,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 		break;
 
 	case -EEXIST:
-		pr_info("duplicate VNI %u\n", conf.vni);
+		pr_info("duplicate VNI %u\n", be32_to_cpu(conf.vni));
 		break;
 	}
 
@@ -2959,7 +2958,7 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		.high = htons(vxlan->cfg.port_max),
 	};
 
-	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
+	if (nla_put_u32(skb, IFLA_VXLAN_ID, be32_to_cpu(dst->remote_vni)))
 		goto nla_put_failure;
 
 	if (!vxlan_addr_any(&dst->remote_ip)) {
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 3792e188e13d..8816f8984693 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -24,11 +24,11 @@ struct vxlanhdr {
 };
 
 /* VXLAN header flags. */
-#define VXLAN_HF_VNI BIT(27)
+#define VXLAN_HF_VNI	cpu_to_be32(BIT(27))
 
 #define VXLAN_N_VID     (1u << 24)
 #define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
-#define VXLAN_VNI_MASK  (VXLAN_VID_MASK << 8)
+#define VXLAN_VNI_MASK	cpu_to_be32(VXLAN_VID_MASK << 8)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VNI_HASH_BITS	10
@@ -55,14 +55,14 @@ struct vxlanhdr {
  */
 
 /* VXLAN-RCO header flags. */
-#define VXLAN_HF_RCO BIT(21)
+#define VXLAN_HF_RCO	cpu_to_be32(BIT(21))
 
 /* Remote checksum offload header option */
-#define VXLAN_RCO_MASK  0x7f    /* Last byte of vni field */
-#define VXLAN_RCO_UDP   0x80    /* Indicate UDP RCO (TCP when not set *) */
-#define VXLAN_RCO_SHIFT 1       /* Left shift of start */
+#define VXLAN_RCO_MASK	cpu_to_be32(0x7f)  /* Last byte of vni field */
+#define VXLAN_RCO_UDP	cpu_to_be32(0x80)  /* Indicate UDP RCO (TCP when not set *) */
+#define VXLAN_RCO_SHIFT	1		   /* Left shift of start */
 #define VXLAN_RCO_SHIFT_MASK ((1 << VXLAN_RCO_SHIFT) - 1)
-#define VXLAN_MAX_REMCSUM_START (VXLAN_RCO_MASK << VXLAN_RCO_SHIFT)
+#define VXLAN_MAX_REMCSUM_START (0x7f << VXLAN_RCO_SHIFT)
 
 /*
  * VXLAN Group Based Policy Extension (VXLAN_F_GBP):
@@ -105,9 +105,9 @@ struct vxlanhdr_gbp {
 };
 
 /* VXLAN-GBP header flags. */
-#define VXLAN_HF_GBP BIT(31)
+#define VXLAN_HF_GBP	cpu_to_be32(BIT(31))
 
-#define VXLAN_GBP_USED_BITS (VXLAN_HF_GBP | 0xFFFFFF)
+#define VXLAN_GBP_USED_BITS (VXLAN_HF_GBP | cpu_to_be32(0xFFFFFF))
 
 /* skb->mark mapping
  *
@@ -144,7 +144,7 @@ union vxlan_addr {
 struct vxlan_rdst {
 	union vxlan_addr	 remote_ip;
 	__be16			 remote_port;
-	u32			 remote_vni;
+	__be32			 remote_vni;
 	u32			 remote_ifindex;
 	struct list_head	 list;
 	struct rcu_head		 rcu;
@@ -153,7 +153,7 @@ struct vxlan_rdst {
 struct vxlan_config {
 	union vxlan_addr	remote_ip;
 	union vxlan_addr	saddr;
-	u32			vni;
+	__be32			vni;
 	int			remote_ifindex;
 	int			mtu;
 	__be16			dst_port;
@@ -266,6 +266,54 @@ static inline struct vxlanhdr *vxlan_hdr(struct sk_buff *skb)
 	return (struct vxlanhdr *)(udp_hdr(skb) + 1);
 }
 
+static inline __be32 vxlan_vni(__be32 vni_field)
+{
+#if defined(__BIG_ENDIAN)
+	return vni_field >> 8;
+#else
+	return (vni_field & VXLAN_VNI_MASK) << 8;
+#endif
+}
+
+static inline __be32 vxlan_vni_field(__be32 vni)
+{
+#if defined(__BIG_ENDIAN)
+	return vni << 8;
+#else
+	return vni >> 8;
+#endif
+}
+
+static inline __be32 vxlan_tun_id_to_vni(__be64 tun_id)
+{
+#if defined(__BIG_ENDIAN)
+	return tun_id;
+#else
+	return tun_id >> 32;
+#endif
+}
+
+static inline size_t vxlan_rco_start(__be32 vni_field)
+{
+	return be32_to_cpu(vni_field & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
+}
+
+static inline size_t vxlan_rco_offset(__be32 vni_field)
+{
+	return (vni_field & VXLAN_RCO_UDP) ?
+		offsetof(struct udphdr, check) :
+		offsetof(struct tcphdr, check);
+}
+
+static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
+{
+	__be32 vni_field = cpu_to_be32(start >> VXLAN_RCO_SHIFT);
+
+	if (offset == offsetof(struct udphdr, check))
+		vni_field |= VXLAN_RCO_UDP;
+	return vni_field;
+}
+
 #if IS_ENABLED(CONFIG_VXLAN)
 void vxlan_get_rx_port(struct net_device *netdev);
 #else
-- 
1.8.3.1

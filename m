From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 20/21] datapath: Use tun_key flags for id and csum settings on transmit
Date: Thu, 24 May 2012 18:09:13 +0900
Message-ID: <1337850554-10339-21-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46715 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab2EXJJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:30 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of these flags in the tnl_mutable_config structure
are no longer correct as a tunnel device may be used to
transmit packets for many different tunnels.

This change restores the checksum and out key behavior of
tunneling.

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-of-by: Simon Horman <horms@verge.net.au>
---
 datapath/tunnel.c       | 58 ++++++++++++++++++++++++-------------------------
 datapath/tunnel.h       | 12 +++-------
 datapath/vport-capwap.c | 28 ++++++++++++------------
 datapath/vport-gre.c    | 33 ++++++++++++++--------------
 4 files changed, 63 insertions(+), 68 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index a303d8d..982de25 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -500,7 +500,7 @@ bool ovs_tnl_frag_needed(struct vport *vport,
 
 static bool check_mtu(struct sk_buff *skb,
 		      struct vport *vport,
-		      const struct tnl_mutable_config *mutable,
+		      const struct tnl_mutable_config *mutable, int tun_hlen,
 		      const struct rtable *rt, __be16 *frag_offp)
 {
 	bool df_inherit = mutable->flags & TNL_F_DF_INHERIT;
@@ -524,10 +524,7 @@ static bool check_mtu(struct sk_buff *skb,
 		    eth_hdr(skb)->h_proto == htons(ETH_P_8021Q))
 			vlan_header = VLAN_HLEN;
 
-		mtu = dst_mtu(&rt_dst(rt))
-			- ETH_HLEN
-			- mutable->tunnel_hlen
-			- vlan_header;
+		mtu = dst_mtu(&rt_dst(rt)) - ETH_HLEN - tun_hlen - vlan_header;
 	}
 
 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -569,11 +566,10 @@ static bool check_mtu(struct sk_buff *skb,
 }
 
 static void create_tunnel_header(const struct vport *vport,
-				 const struct tnl_mutable_config *mutable,
-				 const struct rtable *rt, void *header)
+				 const struct rtable *rt, struct sk_buff *skb)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	struct iphdr *iph = header;
+	struct iphdr *iph = (struct iphdr *)skb->data;
 
 	iph->version	= 4;
 	iph->ihl	= sizeof(struct iphdr) >> 2;
@@ -584,7 +580,7 @@ static void create_tunnel_header(const struct vport *vport,
 	if (!iph->ttl)
 		iph->ttl = ip4_dst_hoplimit(&rt_dst(rt));
 
-	tnl_vport->tnl_ops->build_header(vport, mutable, iph + 1);
+	tnl_vport->tnl_ops->build_header(vport, skb);
 }
 
 #ifdef HAVE_RT_GENID
@@ -657,16 +653,14 @@ static bool need_linearize(const struct sk_buff *skb)
 	return false;
 }
 
-static struct sk_buff *handle_offloads(struct sk_buff *skb,
-				       const struct tnl_mutable_config *mutable,
+static struct sk_buff *handle_offloads(struct sk_buff *skb, int tun_hlen,
 				       const struct rtable *rt)
 {
 	int min_headroom;
 	int err;
 
 	min_headroom = LL_RESERVED_SPACE(rt_dst(rt).dev) + rt_dst(rt).header_len
-			+ mutable->tunnel_hlen
-			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+			+ tun_hlen + (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
 
 	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
 		int head_delta = SKB_DATA_ALIGN(min_headroom -
@@ -719,15 +713,14 @@ error:
 	return ERR_PTR(err);
 }
 
-static int send_frags(struct sk_buff *skb,
-		      const struct tnl_mutable_config *mutable)
+static int send_frags(struct sk_buff *skb, int tun_hlen)
 {
 	int sent_len;
 
 	sent_len = 0;
 	while (skb) {
 		struct sk_buff *next = skb->next;
-		int frag_len = skb->len - mutable->tunnel_hlen;
+		int frag_len = skb->len - tun_hlen;
 		int err;
 
 		skb->next = NULL;
@@ -752,6 +745,14 @@ free_frags:
 	return sent_len;
 }
 
+static int tunnel_hlen(struct tnl_vport *tnl_vport, struct sk_buff *skb)
+{
+	int tun_hlen = tnl_vport->tnl_ops->hdr_len(skb);
+	if (tun_hlen < 0)
+		return tun_hlen;
+	return tun_hlen + sizeof(struct iphdr);
+}
+
 int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
@@ -765,6 +766,7 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	u8 ttl;
 	u8 inner_tos;
 	u8 tos;
+	int tun_hlen;
 
 	if (!OVS_CB(skb)->tun_key)
 		goto error_free;
@@ -822,13 +824,17 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	skb_dst_drop(skb);
 	skb_clear_rxhash(skb);
 
+	tun_hlen = tunnel_hlen(tnl_vport, skb);
+	if (unlikely(tun_hlen < 0))
+		goto error;
+
 	/* Offloading */
-	skb = handle_offloads(skb, mutable, rt);
+	skb = handle_offloads(skb, tun_hlen, rt);
 	if (IS_ERR(skb))
 		goto error;
 
 	/* MTU */
-	if (unlikely(!check_mtu(skb, vport, mutable, rt, &frag_off))) {
+	if (unlikely(!check_mtu(skb, vport, mutable, tun_hlen, rt, &frag_off))) {
 		err = VPORT_E_TX_DROPPED;
 		goto error_free;
 	}
@@ -837,7 +843,7 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	 * If we are over the MTU, allow the IP stack to handle fragmentation.
 	 * Fragmentation is a slow path anyways.
 	 */
-	if (unlikely(skb->len + mutable->tunnel_hlen > dst_mtu(&rt_dst(rt)))) {
+	if (unlikely(skb->len + tun_hlen > dst_mtu(&rt_dst(rt)))) {
 		unattached_dst = &rt_dst(rt);
 		dst_hold(unattached_dst);
 	}
@@ -862,8 +868,8 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 		if (unlikely(vlan_deaccel_tag(skb)))
 			goto next;
 
-		skb_push(skb, mutable->tunnel_hlen);
-		create_tunnel_header(vport, mutable, rt, skb->data);
+		skb_push(skb, tun_hlen);
+		create_tunnel_header(vport, rt, skb);
 		skb_reset_network_header(skb);
 
 		if (next_skb)
@@ -880,12 +886,12 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 		iph->frag_off = frag_off;
 		ip_select_ident(iph, &rt_dst(rt), NULL);
 
-		skb = tnl_vport->tnl_ops->update_header(vport, mutable,
+		skb = tnl_vport->tnl_ops->update_header(vport, tun_hlen,
 							&rt_dst(rt), skb);
 		if (unlikely(!skb))
 			goto next;
 
-		sent_len += send_frags(skb, mutable);
+		sent_len += send_frags(skb, tun_hlen);
 next:
 		skb = next_skb;
 	}
@@ -917,12 +923,6 @@ static int tnl_set_config(struct net *net,
 	port_key_set_net(&mutable->key, net);
 	mutable->key.tunnel_type = tnl_ops->tunnel_type;
 
-	mutable->tunnel_hlen = tnl_ops->hdr_len(mutable);
-	if (mutable->tunnel_hlen < 0)
-		return mutable->tunnel_hlen;
-
-	mutable->tunnel_hlen += sizeof(struct iphdr);
-
 	old_vport = port_table_lookup(&mutable->key);
 	if (old_vport && old_vport != cur_vport)
 		return -EEXIST;
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index cddb88e..a32241f 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -84,10 +84,8 @@ static inline void port_key_set_net(struct port_lookup_key *key, struct net *net
  * attributes.
  * @rcu: RCU callback head for deferred destruction.
  * @seq: Sequence number for distinguishing configuration versions.
- * @tunnel_hlen: Tunnel header length.
  * @eth_addr: Source address for packets generated by tunnel itself
  * (e.g. ICMP fragmentation needed messages).
- * @out_key: Key to use on output, 0 if this tunnel has no fixed output key.
  * @flags: TNL_F_* flags.
  */
 struct tnl_mutable_config {
@@ -96,12 +94,9 @@ struct tnl_mutable_config {
 
 	unsigned seq;
 
-	unsigned tunnel_hlen;
-
 	unsigned char eth_addr[ETH_ALEN];
 
 	/* Configured via OVS_TUNNEL_ATTR_* attributes. */
-	__be64	out_key;
 	u32	flags;
 };
 
@@ -114,7 +109,7 @@ struct tnl_ops {
 	 * build_header() (i.e. excludes the IP header).  Returns a negative
 	 * error code if the configuration is invalid.
 	 */
-	int (*hdr_len)(const struct tnl_mutable_config *);
+	int (*hdr_len)(struct sk_buff *skb);
 
 	/*
 	 * Builds the static portion of the tunnel header, which is stored in
@@ -124,8 +119,7 @@ struct tnl_ops {
 	 * in some circumstances caching is disabled and this function will be
 	 * called for every packet, so try not to make it too slow.
 	 */
-	void (*build_header)(const struct vport *,
-			     const struct tnl_mutable_config *, void *header);
+	void (*build_header)(const struct vport *, struct sk_buff *);
 
 	/*
 	 * Updates the cached header of a packet to match the actual packet
@@ -136,7 +130,7 @@ struct tnl_ops {
 	 * of fragmentation).
 	 */
 	struct sk_buff *(*update_header)(const struct vport *,
-					 const struct tnl_mutable_config *,
+					 int tun_hlen,
 					 struct dst_entry *, struct sk_buff *);
 };
 
diff --git a/datapath/vport-capwap.c b/datapath/vport-capwap.c
index a180b87..102a207 100644
--- a/datapath/vport-capwap.c
+++ b/datapath/vport-capwap.c
@@ -155,16 +155,17 @@ static struct inet_frags frag_state = {
 	.secret_interval = CAPWAP_FRAG_SECRET_INTERVAL,
 };
 
-static int capwap_hdr_len(const struct tnl_mutable_config *mutable)
+static int capwap_hdr_len(struct sk_buff *skb)
 {
 	int size = CAPWAP_MIN_HLEN;
 
 	/* CAPWAP has no checksums. */
-	if (mutable->flags & TNL_F_CSUM)
+	if (OVS_CB(skb)->tun_key->tun_flags & TNL_F_CSUM) {
 		return -EINVAL;
 
 	/* if keys are specified, then add WSI field */
-	if (mutable->out_key || (mutable->flags & TNL_F_OUT_KEY_ACTION)) {
+	if (OVS_CB(skb)->tun_key->tun_id ||
+	    OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION)
 		size += sizeof(struct capwaphdr_wsi) +
 			sizeof(struct capwaphdr_wsi_key);
 	}
@@ -172,11 +173,10 @@ static int capwap_hdr_len(const struct tnl_mutable_config *mutable)
 	return size;
 }
 
-static void capwap_build_header(const struct vport *vport,
-				const struct tnl_mutable_config *mutable,
-				void *header)
+static void capwap_build_header(const struct vport *vport, struct sk_buff *skb)
 {
-	struct udphdr *udph = header;
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct udphdr *udph = (struct udphdr *)(iph + 1);
 	struct capwaphdr *cwh = (struct capwaphdr *)(udph + 1);
 
 	udph->source = htons(CAPWAP_SRC_PORT);
@@ -186,7 +186,8 @@ static void capwap_build_header(const struct vport *vport,
 	cwh->frag_id = 0;
 	cwh->frag_off = 0;
 
-	if (mutable->out_key || (mutable->flags & TNL_F_OUT_KEY_ACTION)) {
+	if (OVS_CB(skb)->tun_key->tun_id ||
+	    OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION) {
 		struct capwaphdr_wsi *wsi = (struct capwaphdr_wsi *)(cwh + 1);
 
 		cwh->begin = CAPWAP_KEYED;
@@ -197,9 +198,9 @@ static void capwap_build_header(const struct vport *vport,
 		wsi->flags = CAPWAP_WSI_F_KEY64;
 		wsi->reserved_padding = 0;
 
-		if (mutable->out_key) {
+		if (OVS_CB(skb)->tun_key->tun_id) {
 			struct capwaphdr_wsi_key *opt = (struct capwaphdr_wsi_key *)(wsi + 1);
-			opt->key = mutable->out_key;
+			opt->key = OVS_CB(skb)->tun_key->tun_id;
 		}
 	} else {
 		/* make packet readable by old capwap code */
@@ -208,13 +209,12 @@ static void capwap_build_header(const struct vport *vport,
 }
 
 static struct sk_buff *capwap_update_header(const struct vport *vport,
-					    const struct tnl_mutable_config *mutable,
-					    struct dst_entry *dst,
+					    int tun_hlen, struct dst_entry *dst,
 					    struct sk_buff *skb)
 {
 	struct udphdr *udph = udp_hdr(skb);
 
-	if (mutable->flags & TNL_F_OUT_KEY_ACTION) {
+	if (OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION) {
 		/* first field in WSI is key */
 		struct capwaphdr *cwh = (struct capwaphdr *)(udph + 1);
 		struct capwaphdr_wsi *wsi = (struct capwaphdr_wsi *)(cwh + 1);
@@ -226,7 +226,7 @@ static struct sk_buff *capwap_update_header(const struct vport *vport,
 	udph->len = htons(skb->len - skb_transport_offset(skb));
 
 	if (unlikely(skb->len - skb_network_offset(skb) > dst_mtu(dst))) {
-		unsigned int hlen = skb_transport_offset(skb) + capwap_hdr_len(mutable);
+		unsigned int hlen = skb_transport_offset(skb) + capwap_hdr_len(skb);
 		skb = fragment(skb, vport, dst, hlen);
 	}
 
diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
index 8fab193..b6a4308 100644
--- a/datapath/vport-gre.c
+++ b/datapath/vport-gre.c
@@ -45,16 +45,17 @@ struct gre_base_hdr {
 	__be16 protocol;
 };
 
-static int gre_hdr_len(const struct tnl_mutable_config *mutable)
+static int gre_hdr_len(struct sk_buff *skb)
 {
 	int len;
 
 	len = GRE_HEADER_SECTION;
 
-	if (mutable->flags & TNL_F_CSUM)
+	if (OVS_CB(skb)->tun_key->tun_flags & TNL_F_CSUM)
 		len += GRE_HEADER_SECTION;
 
-	if (mutable->out_key || mutable->flags & TNL_F_OUT_KEY_ACTION)
+	if (OVS_CB(skb)->tun_key->tun_id ||
+	    OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION)
 		len += GRE_HEADER_SECTION;
 
 	return len;
@@ -70,41 +71,41 @@ static __be32 be64_get_low32(__be64 x)
 #endif
 }
 
-static void gre_build_header(const struct vport *vport,
-			     const struct tnl_mutable_config *mutable,
-			     void *header)
+static void gre_build_header(const struct vport *vport, struct sk_buff *skb)
 {
-	struct gre_base_hdr *greh = header;
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)(iph + 1);
 	__be32 *options = (__be32 *)(greh + 1);
 
 	greh->protocol = htons(ETH_P_TEB);
 	greh->flags = 0;
 
-	if (mutable->flags & TNL_F_CSUM) {
+	if (OVS_CB(skb)->tun_key->tun_flags & TNL_F_CSUM) {
 		greh->flags |= GRE_CSUM;
 		*options = 0;
 		options++;
 	}
 
-	if (mutable->out_key || mutable->flags & TNL_F_OUT_KEY_ACTION)
+	if (OVS_CB(skb)->tun_key->tun_id ||
+	    OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION)
 		greh->flags |= GRE_KEY;
 
-	if (mutable->out_key)
-		*options = be64_get_low32(mutable->out_key);
+	if (OVS_CB(skb)->tun_key->tun_id)
+		*options = be64_get_low32(OVS_CB(skb)->tun_key->tun_id);
 }
 
 static struct sk_buff *gre_update_header(const struct vport *vport,
-					 const struct tnl_mutable_config *mutable,
-					 struct dst_entry *dst,
+					 int tun_hlen, struct dst_entry *dst,
 					 struct sk_buff *skb)
 {
-	__be32 *options = (__be32 *)(skb_network_header(skb) + mutable->tunnel_hlen
+	__be32 *options = (__be32 *)(skb_network_header(skb) + tun_hlen
 					       - GRE_HEADER_SECTION);
 
-	if (mutable->out_key || mutable->flags & TNL_F_OUT_KEY_ACTION)
+	if (OVS_CB(skb)->tun_key->tun_id ||
+	    OVS_CB(skb)->tun_key->tun_flags & TNL_F_OUT_KEY_ACTION)
 		options--;
 
-	if (mutable->flags & TNL_F_CSUM)
+	if (OVS_CB(skb)->tun_key->tun_flags & TNL_F_CSUM)
 		*(__sum16 *)options = csum_fold(skb_checksum(skb,
 						skb_transport_offset(skb),
 						skb->len - skb_transport_offset(skb),
-- 
1.7.10.2.484.gcd07cc5

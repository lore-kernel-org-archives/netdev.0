From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 13:26:18 +0100
Message-ID: <014606bb741d017675f7728a0bccc4cbed42af4b.1421064100.git.tgraf@suug.ch>
References: <cover.1421064100.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44569 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbbALM02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 07:26:28 -0500
In-Reply-To: <cover.1421064100.git.tgraf@suug.ch>
In-Reply-To: <cover.1421064100.git.tgraf@suug.ch>
References: <cover.1421064100.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements supports for the Group Policy VXLAN extension [0] to provide
a lightweight and simple security label mechanism across network peers
based on VXLAN. The security context and associated metadata is mapped
to/from skb->mark. This allows further mapping to a SELinux context
using SECMARK, to implement ACLs directly with nftables, iptables, OVS,
tc, etc.

The group membership is defined by the lower 16 bits of skb->mark, the
upper 16 bits are used for flags.

SELinux allows to manage label to secure local resources. However,
distributed applications require ACLs to implemented across hosts. This
is typically achieved by matching on L2-L4 fields to identify the
original sending host and process on the receiver. On top of that,
netlabel and specifically CIPSO [1] allow to map security contexts to
universal labels.  However, netlabel and CIPSO are relatively complex.
This patch provides a lightweight alternative for overlay network
environments with a trusted underlay. No additional control protocol
is required.

           Host 1:                       Host 2:

      Group A        Group B        Group B     Group A
      +-----+   +-------------+    +-------+   +-----+
      | lxc |   | SELinux CTX |    | httpd |   | VM  |
      +--+--+   +--+----------+    +---+---+   +--+--+
	  \---+---/                     \----+---/
	      |                              |
	  +---+---+                      +---+---+
	  | vxlan |                      | vxlan |
	  +---+---+                      +---+---+
	      +------------------------------+

Backwards compatibility:
A VXLAN-GBP socket can receive standard VXLAN frames and will assign
the default group 0x0000 to such frames. A Linux VXLAN socket will
drop VXLAN-GBP  frames. The extension is therefore disabled by default
and needs to be specifically enabled:

   ip link add [...] type vxlan [...] gbp

In a mixed environment with VXLAN and VXLAN-GBP sockets, the GBP socket
must run on a separate port number.

Examples:
 iptables:
  host1# iptables -I OUTPUT -m owner --uid-owner 101 -j MARK --set-mark 0x200
  host2# iptables -I INPUT -m mark --mark 0x200 -j DROP

 OVS:
  # ovs-ofctl add-flow br0 'in_port=1,actions=load:0x200->NXM_NX_TUN_GBP_ID[],NORMAL'
  # ovs-ofctl add-flow br0 'in_port=2,tun_gbp_id=0x200,actions=drop'

[0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
[1] http://lwn.net/Articles/204905/

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2->v3:
 - Removed empty struct vxlan_gbp as spotted by Alexei
v1->v2:
 - split GBP header definition into separate struct vxlanhdr_gbp as requested
   by Alexei

 drivers/net/vxlan.c           | 161 ++++++++++++++++++++++++++++++------------
 include/net/vxlan.h           |  70 ++++++++++++++++--
 include/uapi/linux/if_link.h  |   8 +++
 net/openvswitch/vport-vxlan.c |   9 ++-
 4 files changed, 195 insertions(+), 53 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4d52aa9..b148739 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -132,6 +132,7 @@ struct vxlan_dev {
 	__u8		  tos;		/* TOS override */
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* in vxlan.h */
+	u32		  exts;		/* Enabled extensions */
 
 	struct work_struct sock_work;
 	struct work_struct igmp_join;
@@ -568,7 +569,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
 			continue;
 
 		vh2 = (struct vxlanhdr *)(p->data + off_vx);
-		if (vh->vx_vni != vh2->vx_vni) {
+		if (vh->vx_flags != vh2->vx_flags ||
+		    vh->vx_vni != vh2->vx_vni) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
@@ -1095,6 +1097,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
+	struct vxlan_metadata md = {0};
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1113,6 +1116,22 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (vs->exts) {
 		if (!vxh->vni_present)
 			goto error_invalid_header;
+
+		if (vxh->gbp_present) {
+			struct vxlanhdr_gbp *gbp;
+
+			if (!(vs->exts & VXLAN_EXT_GBP))
+				goto error_invalid_header;
+
+			gbp = (struct vxlanhdr_gbp *)vxh;
+			md.gbp = ntohs(gbp->policy_id);
+
+			if (gbp->dont_learn)
+				md.gbp |= VXLAN_GBP_DONT_LEARN;
+
+			if (gbp->policy_applied)
+				md.gbp |= VXLAN_GBP_POLICY_APPLIED;
+		}
 	} else {
 		if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
 		    (vxh->vx_vni & htonl(0xff)))
@@ -1122,7 +1141,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
 
-	vs->rcv(vs, skb, vxh->vx_vni);
+	md.vni = vxh->vx_vni;
+	vs->rcv(vs, skb, &md);
 	return 0;
 
 drop:
@@ -1138,8 +1158,8 @@ error:
 	return 1;
 }
 
-static void vxlan_rcv(struct vxlan_sock *vs,
-		      struct sk_buff *skb, __be32 vx_vni)
+static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
+		      struct vxlan_metadata *md)
 {
 	struct iphdr *oip = NULL;
 	struct ipv6hdr *oip6 = NULL;
@@ -1150,7 +1170,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	int err = 0;
 	union vxlan_addr *remote_ip;
 
-	vni = ntohl(vx_vni) >> 8;
+	vni = ntohl(md->vni) >> 8;
 	/* Is this VNI defined? */
 	vxlan = vxlan_vs_find_vni(vs, vni);
 	if (!vxlan)
@@ -1184,6 +1204,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 		goto drop;
 
 	skb_reset_network_header(skb);
+	skb->mark = md->gbp;
 
 	if (oip6)
 		err = IP6_ECN_decapsulate(oip6, skb);
@@ -1533,15 +1554,57 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
+static int vxlan_build_hdr(struct sk_buff *skb, struct vxlan_sock *vs,
+			   int min_headroom, struct vxlan_metadata *md)
+{
+	struct vxlanhdr *vxh;
+	int err;
+
+	/* Need space for new headers (invalidates iph ptr) */
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	skb = vlan_hwaccel_push_inside(skb);
+	if (WARN_ON(!skb))
+		return -ENOMEM;
+
+	vxh = (struct vxlanhdr *)__skb_push(skb, sizeof(*vxh));
+	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_vni = md->vni;
+
+	if (vs->exts)  {
+		if (vs->exts & VXLAN_EXT_GBP) {
+			struct vxlanhdr_gbp *gbp;
+
+			gbp = (struct vxlanhdr_gbp *)vxh;
+			vxh->gbp_present = 1;
+
+			if (md->gbp & VXLAN_GBP_DONT_LEARN)
+				gbp->dont_learn = 1;
+
+			if (md->gbp & VXLAN_GBP_POLICY_APPLIED)
+				gbp->policy_applied = 1;
+
+			gbp->policy_id = htons(md->gbp & VXLAN_GBP_ID_MASK);
+		}
+	}
+
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+
+	return 0;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port, __be32 vni,
-			   bool xnet)
+			   __be16 src_port, __be16 dst_port,
+			   struct vxlan_metadata *md, bool xnet)
 {
-	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
 	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
@@ -1558,24 +1621,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
 			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
 
-	/* Need space for new headers (invalidates iph ptr) */
-	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
-		goto err;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (WARN_ON(!skb)) {
-		err = -ENOMEM;
+	err = vxlan_build_hdr(skb, vs, min_headroom, md);
+	if (err)
 		goto err;
-	}
-
-	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = vni;
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
 			     ttl, src_port, dst_port);
@@ -1589,9 +1637,9 @@ err:
 int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
+		   __be16 src_port, __be16 dst_port,
+		   struct vxlan_metadata *md, bool xnet)
 {
-	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
 	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
@@ -1604,22 +1652,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 			+ VXLAN_HLEN + sizeof(struct iphdr)
 			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
 
-	/* Need space for new headers (invalidates iph ptr) */
-	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
+	err = vxlan_build_hdr(skb, vs, min_headroom, md);
+	if (err)
 		return err;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (WARN_ON(!skb))
-		return -ENOMEM;
-
-	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = vni;
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
 				   ttl, df, src_port, dst_port, xnet);
@@ -1679,6 +1714,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	const struct iphdr *old_iph;
 	struct flowi4 fl4;
 	union vxlan_addr *dst;
+	struct vxlan_metadata md;
 	__be16 src_port = 0, dst_port;
 	u32 vni;
 	__be16 df = 0;
@@ -1749,11 +1785,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
+		md.vni = htonl(vni << 8);
+		md.gbp = skb->mark;
 
 		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
 				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8),
+				     tos, ttl, df, src_port, dst_port, &md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
 		if (err < 0) {
 			/* skb is already freed. */
@@ -1806,10 +1843,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
+		md.vni = htonl(vni << 8);
+		md.gbp = skb->mark;
 
 		err = vxlan6_xmit_skb(vxlan->vn_sock, ndst, skb,
 				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
-				      src_port, dst_port, htonl(vni << 8),
+				      src_port, dst_port, &md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)));
 #endif
 	}
@@ -2210,6 +2249,11 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_EXTENSION]	= { .type = NLA_NESTED },
+};
+
+static const struct nla_policy vxlan_ext_policy[IFLA_VXLAN_EXT_MAX + 1] = {
+	[IFLA_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2246,6 +2290,18 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		}
 	}
 
+	if (data[IFLA_VXLAN_EXTENSION]) {
+		int err;
+
+		err = nla_validate_nested(data[IFLA_VXLAN_EXTENSION],
+					  IFLA_VXLAN_EXT_MAX, vxlan_ext_policy);
+		if (err < 0) {
+			pr_debug("invalid VXLAN extension configuration: %d\n",
+				 err);
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
@@ -2400,6 +2456,18 @@ static void vxlan_sock_work(struct work_struct *work)
 	dev_put(vxlan->dev);
 }
 
+static void configure_vxlan_exts(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct nlattr *exts[IFLA_VXLAN_EXT_MAX+1];
+
+	/* Validated in vxlan_validate() */
+	if (nla_parse_nested(exts, IFLA_VXLAN_EXT_MAX, attr, NULL) < 0)
+		BUG();
+
+	if (exts[IFLA_VXLAN_EXT_GBP])
+		vxlan->exts |= VXLAN_EXT_GBP;
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
@@ -2525,6 +2593,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
 
+	if (data[IFLA_VXLAN_EXTENSION])
+		configure_vxlan_exts(vxlan, data[IFLA_VXLAN_EXTENSION]);
+
 	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 			   vxlan->dst_port)) {
 		pr_info("duplicate VNI %u\n", vni);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 3e98d31..66ec53c 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -11,13 +11,62 @@
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
+/*
+ * VXLAN Group Based Policy Extension:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |1|-|-|-|1|-|-|-|R|D|R|R|A|R|R|R|        Group Policy ID        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * D = Don't Learn bit. When set, this bit indicates that the egress
+ *     VTEP MUST NOT learn the source address of the encapsulated frame.
+ *
+ * A = Indicates that the group policy has already been applied to
+ *     this packet. Policies MUST NOT be applied by devices when the
+ *     A bit is set.
+ *
+ * [0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
+ */
+struct vxlanhdr_gbp {
+	__u8	vx_flags;
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	__u8	reserved_flags1:3,
+		policy_applied:1,
+		reserved_flags2:2,
+		dont_learn:1,
+		reserved_flags3:1;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__u8	reserved_flags1:1,
+		dont_learn:1,
+		reserved_flags2:2,
+		policy_applied:1,
+		reserved_flags3:3;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+	__be16	policy_id;
+	__be32	vx_vni;
+};
+
+/* skb->mark mapping
+ *
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|R|R|R|R|R|R|R|D|R|R|A|R|R|R|        Group Policy ID        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+#define VXLAN_GBP_DONT_LEARN		(BIT(6) << 16)
+#define VXLAN_GBP_POLICY_APPLIED	(BIT(3) << 16)
+#define VXLAN_GBP_ID_MASK		(0xFFFF)
+
 /* VXLAN protocol header:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * |R|R|R|R|I|R|R|R|               Reserved                        |
+ * |G|R|R|R|I|R|R|R|               Reserved                        |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  * |                VXLAN Network Identifier (VNI) |   Reserved    |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  *
+ * G = 1	Group Policy (VXLAN-GBP)
  * I = 1	VXLAN Network Identifier (VNI) present
  */
 struct vxlanhdr {
@@ -26,9 +75,11 @@ struct vxlanhdr {
 #ifdef __LITTLE_ENDIAN_BITFIELD
 			__u8	reserved_flags1:3,
 				vni_present:1,
-				reserved_flags2:4;
+				reserved_flags2:3,
+				gbp_present:1;
 #elif defined(__BIG_ENDIAN_BITFIELD)
-			__u8	reserved_flags2:4,
+			__u8	gbp_present:1,
+				reserved_flags2:3,
 				vni_present:1,
 				reserved_flags1:3;
 #else
@@ -42,8 +93,16 @@ struct vxlanhdr {
 	__be32	vx_vni;
 };
 
+struct vxlan_metadata {
+	__be32		vni;
+	u32		gbp;
+};
+
 struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
+typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb,
+			   struct vxlan_metadata *md);
+
+#define VXLAN_EXT_GBP			BIT(0)
 
 /* per UDP socket information */
 struct vxlan_sock {
@@ -78,7 +137,8 @@ void vxlan_sock_release(struct vxlan_sock *vs);
 int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet);
+		   __be16 src_port, __be16 dst_port, struct vxlan_metadata *md,
+		   bool xnet);
 
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 						     netdev_features_t features)
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7d0d2d..9f07bf5 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -370,10 +370,18 @@ enum {
 	IFLA_VXLAN_UDP_CSUM,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+	IFLA_VXLAN_EXTENSION,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+enum {
+	IFLA_VXLAN_EXT_UNSPEC,
+	IFLA_VXLAN_EXT_GBP,
+	__IFLA_VXLAN_EXT_MAX,
+};
+#define IFLA_VXLAN_EXT_MAX (__IFLA_VXLAN_EXT_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d7c46b3..dd68c97 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -59,7 +59,8 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 }
 
 /* Called with rcu_read_lock and BH disabled. */
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
+static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
+		      struct vxlan_metadata *md)
 {
 	struct ovs_tunnel_info tun_info;
 	struct vport *vport = vs->data;
@@ -68,7 +69,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
-	key = cpu_to_be64(ntohl(vx_vni) >> 8);
+	key = cpu_to_be64(ntohl(md->vni) >> 8);
 	ovs_flow_tun_info_init(&tun_info, iph,
 			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
 			       key, TUNNEL_KEY, NULL, 0);
@@ -146,6 +147,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
 	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
 	struct ovs_key_ipv4_tunnel *tun_key;
+	struct vxlan_metadata md;
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
@@ -178,12 +180,13 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	skb->ignore_df = 1;
 
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
+	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, tun_key->ipv4_dst,
 			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
-			     htonl(be64_to_cpu(tun_key->tun_id) << 8),
+			     &md,
 			     false);
 	if (err < 0)
 		ip_rt_put(rt);
-- 
1.9.3

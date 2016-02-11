From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next 2/2] vxlan: support GPE/NSH
Date: Thu, 11 Feb 2016 10:35:14 +0000
Message-ID: <1455186914-8952-4-git-send-email-brussell@brocade.com>
References: <1455186914-8952-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:25651 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782AbcBKKfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:35:36 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1BATo5Y013675
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:35 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 20wfbabxqd-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:35 -0800
In-Reply-To: <1455186914-8952-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the Generic Protocol Extension to VxLAN which extends VxLAN to
allow multi-protocol encapsulation. IPv4, IPv6, MPLS unicast and
NSH encapsulated packets can be sent and received in addition to ethernet
frames. As defined in:

https://tools.ietf.org/html/draft-ietf-nvo3-vxlan-gpe-01

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 drivers/net/vxlan.c          | 139 +++++++++++++++++++++++++++++++++++++++----
 include/net/vxlan.h          |  40 ++++++++++++-
 include/uapi/linux/if_link.h |   1 +
 3 files changed, 166 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 65f5247..92a4cdc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -50,6 +50,7 @@
 #include <net/ip6_checksum.h>
 #endif
 #include <net/dst_metadata.h>
+#include <net/nsh.h>
 
 #define VXLAN_VERSION	"0.1"
 
@@ -1168,14 +1169,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	if (!vxlan)
 		goto drop;
 
-	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
-	skb->protocol = eth_type_trans(skb, vxlan->dev);
-	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-
-	/* Ignore packet loops (and multicast echo) */
-	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
-		goto drop;
 
 	/* Get data from the outer IP header */
 	if (vxlan_get_sk_family(vs) == AF_INET) {
@@ -1195,13 +1189,57 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		tun_dst = NULL;
 	}
 
+	switch (md->gpe_np) {
+	case VXLAN_GPE_NP_IPv4:
+		skb->protocol = htons(ETH_P_IP);
+		goto skip_l2;
+#if IS_ENABLED(CONFIG_IPV6)
+	case VXLAN_GPE_NP_IPv6:
+		skb->protocol = htons(ETH_P_IPV6);
+		goto skip_l2;
+#endif
+#if IS_ENABLED(CONFIG_MPLS)
+	case VXLAN_GPE_NP_MPLS:
+		skb->protocol = htons(ETH_P_MPLS_UC);
+		goto skip_l2;
+#endif
+#if IS_ENABLED(CONFIG_NET_NSH)
+	case VXLAN_GPE_NP_NSH:
+		{
+			u_char next_proto;
+
+			if (nsh_decap(skb, NULL, NULL, &next_proto) < 0)
+				goto drop;
+
+			if (next_proto != NSH_NEXT_PROTO_ETH)
+				goto skip_l2;
+		}
+		break;
+#endif
+	case VXLAN_GPE_NP_ETH:
+		/* GPE with next proto eth is equivalent to vanilla vxlan. */
+	default:
+		break;
+	}
+
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_type_trans(skb, vxlan->dev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+
+	/* Ignore packet loops (and multicast echo) */
+	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
+		goto drop;
+
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
 		goto drop;
 
+skip_l2:
 	skb_reset_network_header(skb);
+
 	/* In flow-based mode, GBP is carried in dst_metadata */
-	if (!(vs->flags & VXLAN_F_COLLECT_METADATA))
+	if (!(vs->flags & VXLAN_F_COLLECT_METADATA) &&
+	    !(vs->flags & VXLAN_F_GPE))
 		skb->mark = md->gbp;
 
 	if (oip6)
@@ -1252,6 +1290,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 
+	vs = rcu_dereference_sk_user_data(sk);
+	if (!vs)
+		goto drop;
+
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
@@ -1267,14 +1309,13 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
+	/* If GPE, protocol will be set once next proto examined. */
+	if (iptunnel_pull_header(skb, VXLAN_HLEN,
+				 vs->flags & VXLAN_F_GPE ?
+				 htons(ETH_P_IP) : htons(ETH_P_TEB)))
 		goto drop;
 	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
-	vs = rcu_dereference_sk_user_data(sk);
-	if (!vs)
-		goto drop;
-
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
 		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni,
 				    !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL));
@@ -1318,6 +1359,16 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
 
+	if (vs->flags & VXLAN_F_GPE) {
+		/* Next protocol is required */
+		if (!(flags & VXLAN_HF_GPE_NP))
+			goto bad_flags;
+
+		md->gpe_np = flags & VXLAN_GPE_NP_MASK;
+
+		flags &= ~VXLAN_GPE_USED_BITS;
+	}
+
 	if (flags || vni & ~VXLAN_VNI_MASK) {
 		/* If there are any unprocessed flags remaining treat
 		 * this as a malformed packet. This behavior diverges from
@@ -1664,6 +1715,37 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
+static void vxlan_build_gpe_hdr(struct vxlanhdr *vxh, __be16 proto)
+{
+	u32 next_proto;
+
+	switch (proto) {
+#if IS_ENABLED(CONFIG_NET_NSH)
+	case htons(ETH_P_NSH):
+		next_proto = VXLAN_GPE_NP_NSH;
+		break;
+#endif
+	case htons(ETH_P_IP):
+		next_proto = VXLAN_GPE_NP_IPv4;
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case htons(ETH_P_IPV6):
+		next_proto = VXLAN_GPE_NP_IPv6;
+		break;
+#endif
+#if IS_ENABLED(CONFIG_MPLS)
+	case htons(ETH_P_MPLS_UC):
+		next_proto = VXLAN_GPE_NP_MPLS;
+		break;
+#endif
+	default:
+		next_proto = VXLAN_GPE_NP_ETH;
+		break;
+	}
+
+	vxh->vx_flags |= htonl(VXLAN_HF_GPE_NP | next_proto);
+}
+
 static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 				struct vxlan_metadata *md)
 {
@@ -1750,6 +1832,9 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	if (vxflags & VXLAN_F_GBP)
 		vxlan_build_gbp_hdr(vxh, vxflags, md);
 
+	if (vxflags & VXLAN_F_GPE)
+		vxlan_build_gpe_hdr(vxh, skb->protocol);
+
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
 }
@@ -2073,6 +2158,26 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
 
+	if (vxlan->flags & VXLAN_F_GPE) {
+		switch (skb->protocol) {
+#if IS_ENABLED(CONFIG_NET_NSH)
+		case htons(ETH_P_NSH):
+#endif
+#if IS_ENABLED(CONFIG_IPV6)
+		case htons(ETH_P_IPV6):
+#endif
+#if IS_ENABLED(CONFIG_MPLS)
+		case htons(ETH_P_MPLS_UC):
+#endif
+		case htons(ETH_P_IP):
+			vxlan_xmit_one(skb, dev, &vxlan->default_dst, false);
+			return NETDEV_TX_OK;
+		default:
+			/* Assume L2 and look for FDB entry */
+			break;
+		}
+	}
+
 	info = skb_tunnel_info(skb);
 
 	skb_reset_mac_header(skb);
@@ -2475,6 +2580,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_RX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_GBP]	= { .type = NLA_FLAG, },
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
+	[IFLA_VXLAN_GPE]	= { .type = NLA_FLAG, },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2895,6 +3001,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
 		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
 
+	if (data[IFLA_VXLAN_GPE])
+		conf.flags |= VXLAN_F_GPE;
+
 	err = vxlan_dev_configure(src_net, dev, &conf);
 	switch (err) {
 	case -ENODEV:
@@ -3037,6 +3146,10 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_flag(skb, IFLA_VXLAN_REMCSUM_NOPARTIAL))
 		goto nla_put_failure;
 
+	if (vxlan->flags & VXLAN_F_GPE &&
+	    nla_put_flag(skb, IFLA_VXLAN_GPE))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 25bd919..7886296 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -121,8 +121,44 @@ struct vxlanhdr_gbp {
 
 struct vxlan_metadata {
 	u32		gbp;
+	u8              gpe_np;
 };
 
+/*
+ * VXLAN Generic Protocol Extension:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|Ver|I|P|R|O|       Reserved                |Next Protocol  |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Ver            Version, initially 0
+ * I = 1	  VXLAN Network Identifier (VNI) present
+ * P = 1          Next Protocol field is present
+ * O = 1          OAM
+ * Next Protocol  Indicates the protocol header immediately following
+ *                the VXLAN GPE header.
+ *
+ * https://tools.ietf.org/html/draft-ietf-nvo3-vxlan-gpe-01
+ *
+ * Use struct vxlanhdr above with some extra defines:
+ */
+#define VXLAN_HF_GPE_OAM BIT(25) /* GPE OAM bit */
+#define VXLAN_HF_GPE_NP  BIT(26) /* GPE protocol bit */
+
+#define VXLAN_GPE_NP_MASK (0xFF)
+
+#define VXLAN_GPE_NP_IPv4 0x1
+#define VXLAN_GPE_NP_IPv6 0x2
+#define VXLAN_GPE_NP_ETH  0x3
+#define VXLAN_GPE_NP_NSH  0x4
+#define VXLAN_GPE_NP_MPLS  0x5
+
+#define VXLAN_GPE_USED_BITS (VXLAN_HF_GPE_NP  | \
+			     VXLAN_HF_GPE_OAM | \
+			     VXLAN_GPE_NP_MASK)
+
+
 /* per UDP socket information */
 struct vxlan_sock {
 	struct hlist_node hlist;
@@ -204,6 +240,7 @@ struct vxlan_dev {
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
+#define VXLAN_F_GPE			0x4000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -212,7 +249,8 @@ struct vxlan_dev {
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
 					 VXLAN_F_REMCSUM_RX |		\
 					 VXLAN_F_REMCSUM_NOPARTIAL |	\
-					 VXLAN_F_COLLECT_METADATA)
+					 VXLAN_F_COLLECT_METADATA |     \
+					 VXLAN_F_GPE)
 
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d452cea..e8d74a5 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -456,6 +456,7 @@ enum {
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_COLLECT_METADATA,
+	IFLA_VXLAN_GPE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.1.4

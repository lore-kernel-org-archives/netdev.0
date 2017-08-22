From: William Tu <u9012063@gmail.com>
Subject: [PATCHv4 net-next] gre: introduce native tunnel support for ERSPAN
Date: Tue, 22 Aug 2017 09:40:28 -0700
Message-ID: <1503420028-10791-1-git-send-email-u9012063@gmail.com>
Cc: Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35333 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751806AbdHVQks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 12:40:48 -0400
Received: by mail-pf0-f193.google.com with SMTP id k3so1487826pfc.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 09:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds ERSPAN type II tunnel support.  The implementation
is based on the draft at [1].  One of the purposes is for Linux
box to be able to receive ERSPAN monitoring traffic sent from
the Cisco switch, by creating a ERSPAN tunnel device.
In addition, the patch also adds ERSPAN TX, so Linux virtual
switch can redirect monitored traffic to the ERSPAN tunnel device.
The traffic will be encapsulated into ERSPAN and sent out.

The implementation reuses tunnel key as ERSPAN session ID, and
field 'erspan' as ERSPAN Index fields:
./ip link add dev ers11 type erspan seq key 100 erspan 123 \
			local 172.16.1.200 remote 172.16.1.100

To use the above device as ERSPAN receiver, configure
Nexus 5000 switch as below:

monitor session 100 type erspan-source
  erspan-id 123
  vrf default
  destination ip 172.16.1.200
  source interface Ethernet1/11 both
  source interface Ethernet1/12 both
  no shut
monitor erspan origin ip-address 172.16.1.100 global

[1] https://tools.ietf.org/html/draft-foschiano-erspan-01
[2] iproute2 patch: http://marc.info/?l=linux-netdev&m=150306086924951&w=2
[3] test script: http://marc.info/?l=linux-netdev&m=150231021807304&w=2

Signed-off-by: William Tu <u9012063@gmail.com>
Signed-off-by: Meenakshi Vohra <mvohra@vmware.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
---
v3->v4:
  fix skb_may_pull len
  fix local variable ordering
  fix commit message Nexus set-up
v2->v3:
  add skb_may_pull check at erspan_rcv
  a couple of minor fixes and checks for index value
v1->v2:
  Add missing erspan.h header
---
 include/net/erspan.h           |  61 ++++++++++
 include/net/ip_tunnels.h       |   3 +
 include/uapi/linux/if_ether.h  |   1 +
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/ip_gre.c              | 269 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 335 insertions(+)
 create mode 100644 include/net/erspan.h

diff --git a/include/net/erspan.h b/include/net/erspan.h
new file mode 100644
index 000000000000..ca94fc86865e
--- /dev/null
+++ b/include/net/erspan.h
@@ -0,0 +1,61 @@
+#ifndef __LINUX_ERSPAN_H
+#define __LINUX_ERSPAN_H
+
+/*
+ * GRE header for ERSPAN encapsulation (8 octets [34:41]) -- 8 bytes
+ *       0                   1                   2                   3
+ *      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *     |0|0|0|1|0|00000|000000000|00000|    Protocol Type for ERSPAN   |
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *     |      Sequence Number (increments per packet per session)      |
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ *  Note that in the above GRE header [RFC1701] out of the C, R, K, S,
+ *  s, Recur, Flags, Version fields only S (bit 03) is set to 1. The
+ *  other fields are set to zero, so only a sequence number follows.
+ *
+ *  ERSPAN Type II header (8 octets [42:49])
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |  Ver  |          VLAN         | COS | En|T|    Session ID     |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |      Reserved         |                  Index                |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * GRE proto ERSPAN type II = 0x88BE, type III = 0x22EB
+ */
+
+#define ERSPAN_VERSION	0x1
+
+#define VER_MASK	0xf000
+#define VLAN_MASK	0x0fff
+#define COS_MASK	0xe000
+#define EN_MASK		0x1800
+#define T_MASK		0x0400
+#define ID_MASK		0x03ff
+#define INDEX_MASK	0xfffff
+
+enum erspan_encap_type {
+	ERSPAN_ENCAP_NOVLAN = 0x0,	/* originally without VLAN tag */
+	ERSPAN_ENCAP_ISL = 0x1,		/* originally ISL encapsulated */
+	ERSPAN_ENCAP_8021Q = 0x2,	/* originally 802.1Q encapsulated */
+	ERSPAN_ENCAP_INFRAME = 0x3,	/* VLAN tag perserved in frame */
+};
+
+struct erspan_metadata {
+	__be32 index;   /* type II */
+};
+
+struct erspanhdr {
+	__be16 ver_vlan;
+#define VER_OFFSET  12
+	__be16 session_id;
+#define COS_OFFSET  13
+#define EN_OFFSET   11
+#define T_OFFSET    10
+	struct erspan_metadata md;
+};
+
+#endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 520809912f03..625c29329372 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -115,6 +115,9 @@ struct ip_tunnel {
 	u32		o_seqno;	/* The last output seqno */
 	int		tun_hlen;	/* Precalculated header length */
 
+	/* This field used only by ERSPAN */
+	u32		index;		/* ERSPAN type II index */
+
 	struct dst_cache dst_cache;
 
 	struct ip_tunnel_parm parms;
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd816b7..efeb1190c2ca 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -66,6 +66,7 @@
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
 #define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
+#define ETH_P_ERSPAN	0x88BE		/* ERSPAN type II		*/
 #define ETH_P_IPX	0x8137		/* IPX over DIX			*/
 #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
 #define ETH_P_PAUSE	0x8808		/* IEEE Pause frames. See 802.3 31B */
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 6792d1967d31..2e520883c054 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -134,6 +134,7 @@ enum {
 	IFLA_GRE_COLLECT_METADATA,
 	IFLA_GRE_IGNORE_DF,
 	IFLA_GRE_FWMARK,
+	IFLA_GRE_ERSPAN_INDEX,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7a7829e839c2..6e8a62289e03 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -48,6 +48,7 @@
 #include <net/rtnetlink.h>
 #include <net/gre.h>
 #include <net/dst_metadata.h>
+#include <net/erspan.h>
 
 /*
    Problems & solutions
@@ -115,6 +116,7 @@ static int ipgre_tunnel_init(struct net_device *dev);
 
 static unsigned int ipgre_net_id __read_mostly;
 static unsigned int gre_tap_net_id __read_mostly;
+static unsigned int erspan_net_id __read_mostly;
 
 static void ipgre_err(struct sk_buff *skb, u32 info,
 		      const struct tnl_ptk_info *tpi)
@@ -246,6 +248,56 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	ipgre_err(skb, info, &tpi);
 }
 
+static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+		      int gre_hdr_len)
+{
+	struct net *net = dev_net(skb->dev);
+	struct metadata_dst *tun_dst = NULL;
+	struct ip_tunnel_net *itn;
+	struct ip_tunnel *tunnel;
+	struct erspanhdr *ershdr;
+	const struct iphdr *iph;
+	__be32 session_id;
+	__be32 index;
+	int len;
+
+	itn = net_generic(net, erspan_net_id);
+	iph = ip_hdr(skb);
+	len = gre_hdr_len + sizeof(*ershdr);
+
+	if (unlikely(!pskb_may_pull(skb, len)))
+		return -ENOMEM;
+
+	iph = ip_hdr(skb);
+	ershdr = (struct erspanhdr *)(skb->data + gre_hdr_len);
+
+	/* The original GRE header does not have key field,
+	 * Use ERSPAN 10-bit session ID as key.
+	 */
+	session_id = cpu_to_be32(ntohs(ershdr->session_id));
+	tpi->key = session_id;
+	index = ershdr->md.index;
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex,
+				  tpi->flags | TUNNEL_KEY,
+				  iph->saddr, iph->daddr, tpi->key);
+
+	if (tunnel) {
+		if (__iptunnel_pull_header(skb,
+					   gre_hdr_len + sizeof(*ershdr),
+					   htons(ETH_P_TEB),
+					   false, false) < 0)
+			goto drop;
+
+		tunnel->index = ntohl(index);
+		skb_reset_mac_header(skb);
+		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
+		return PACKET_RCVD;
+	}
+drop:
+	kfree_skb(skb);
+	return PACKET_RCVD;
+}
+
 static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		       struct ip_tunnel_net *itn, int hdr_len, bool raw_proto)
 {
@@ -328,6 +380,11 @@ static int gre_rcv(struct sk_buff *skb)
 	if (hdr_len < 0)
 		goto drop;
 
+	if (unlikely(tpi.proto == htons(ETH_P_ERSPAN))) {
+		if (erspan_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
+			return 0;
+	}
+
 	if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
 		return 0;
 
@@ -503,6 +560,81 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static inline u8 tos_to_cos(u8 tos)
+{
+	u8 dscp, cos;
+
+	dscp = tos >> 2;
+	cos = dscp >> 3;
+	return cos;
+}
+
+static void erspan_build_header(struct sk_buff *skb,
+				__be32 id, u32 index, bool truncate)
+{
+	struct iphdr *iphdr = ip_hdr(skb);
+	struct ethhdr *eth = eth_hdr(skb);
+	enum erspan_encap_type enc_type;
+	struct erspanhdr *ershdr;
+	struct qtag_prefix {
+		__be16 eth_type;
+		__be16 tci;
+	} *qp;
+	u16 vlan_tci = 0;
+
+	enc_type = ERSPAN_ENCAP_NOVLAN;
+
+	/* If mirrored packet has vlan tag, extract tci and
+	 *  perserve vlan header in the mirrored frame.
+	 */
+	if (eth->h_proto == htons(ETH_P_8021Q)) {
+		qp = (struct qtag_prefix *)(skb->data + 2 * ETH_ALEN);
+		vlan_tci = ntohs(qp->tci);
+		enc_type = ERSPAN_ENCAP_INFRAME;
+	}
+
+	skb_push(skb, sizeof(*ershdr));
+	ershdr = (struct erspanhdr *)skb->data;
+	memset(ershdr, 0, sizeof(*ershdr));
+
+	ershdr->ver_vlan = htons((vlan_tci & VLAN_MASK) |
+				 (ERSPAN_VERSION << VER_OFFSET));
+	ershdr->session_id = htons((u16)(ntohl(id) & ID_MASK) |
+			   ((tos_to_cos(iphdr->tos) << COS_OFFSET) & COS_MASK) |
+			   (enc_type << EN_OFFSET & EN_MASK) |
+			   ((truncate << T_OFFSET) & T_MASK));
+	ershdr->md.index = htonl(index & INDEX_MASK);
+}
+
+static netdev_tx_t erspan_xmit(struct sk_buff *skb,
+			       struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	bool truncate = false;
+
+	if (gre_handle_offloads(skb, false))
+		goto free_skb;
+
+	if (skb_cow_head(skb, dev->needed_headroom))
+		goto free_skb;
+
+	if (skb->len > dev->mtu) {
+		pskb_trim(skb, dev->mtu);
+		truncate = true;
+	}
+
+	/* Push ERSPAN header */
+	erspan_build_header(skb, tunnel->parms.o_key, tunnel->index, truncate);
+	tunnel->parms.o_flags &= ~TUNNEL_KEY;
+	__gre_xmit(skb, dev, &tunnel->parms.iph, htons(ETH_P_ERSPAN));
+	return NETDEV_TX_OK;
+
+free_skb:
+	kfree_skb(skb);
+	dev->stats.tx_dropped++;
+	return NETDEV_TX_OK;
+}
+
 static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
@@ -828,6 +960,39 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
 	return ipgre_tunnel_validate(tb, data, extack);
 }
 
+static int erspan_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
+{
+	__be16 flags = 0;
+	int ret;
+
+	if (!data)
+		return 0;
+
+	ret = ipgre_tap_validate(tb, data, extack);
+	if (ret)
+		return ret;
+
+	/* ERSPAN should only have GRE sequence and key flag */
+	flags |= nla_get_be16(data[IFLA_GRE_OFLAGS]);
+	flags |= nla_get_be16(data[IFLA_GRE_IFLAGS]);
+	if (flags != (GRE_SEQ | GRE_KEY))
+		return -EINVAL;
+
+	/* ERSPAN Session ID only has 10-bit. Since we reuse
+	 * 32-bit key field as ID, check it's range.
+	 */
+	if (data[IFLA_GRE_IKEY] &&
+	    (ntohl(nla_get_be32(data[IFLA_GRE_IKEY])) & ~ID_MASK))
+		return -EINVAL;
+
+	if (data[IFLA_GRE_OKEY] &&
+	    (ntohl(nla_get_be32(data[IFLA_GRE_OKEY])) & ~ID_MASK))
+		return -EINVAL;
+
+	return 0;
+}
+
 static int ipgre_netlink_parms(struct net_device *dev,
 				struct nlattr *data[],
 				struct nlattr *tb[],
@@ -892,6 +1057,13 @@ static int ipgre_netlink_parms(struct net_device *dev,
 	if (data[IFLA_GRE_FWMARK])
 		*fwmark = nla_get_u32(data[IFLA_GRE_FWMARK]);
 
+	if (data[IFLA_GRE_ERSPAN_INDEX]) {
+		t->index = nla_get_u32(data[IFLA_GRE_ERSPAN_INDEX]);
+
+		if (t->index & ~INDEX_MASK)
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -949,6 +1121,36 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_fill_metadata_dst	= gre_fill_metadata_dst,
 };
 
+static int erspan_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int t_hlen;
+
+	tunnel->tun_hlen = 8;
+	tunnel->parms.iph.protocol = IPPROTO_GRE;
+	t_hlen = tunnel->hlen + sizeof(struct iphdr) + sizeof(struct erspanhdr);
+
+	dev->needed_headroom = LL_MAX_HEADER + t_hlen + 4;
+	dev->mtu = ETH_DATA_LEN - t_hlen - 4;
+	dev->features		|= GRE_FEATURES;
+	dev->hw_features	|= GRE_FEATURES;
+	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
+
+	return ip_tunnel_init(dev);
+}
+
+static const struct net_device_ops erspan_netdev_ops = {
+	.ndo_init		= erspan_tunnel_init,
+	.ndo_uninit		= ip_tunnel_uninit,
+	.ndo_start_xmit		= erspan_xmit,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_get_iflink		= ip_tunnel_get_iflink,
+	.ndo_fill_metadata_dst	= gre_fill_metadata_dst,
+};
+
 static void ipgre_tap_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -1041,6 +1243,8 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_GRE_FWMARK */
 		nla_total_size(4) +
+		/* IFLA_GRE_ERSPAN_INDEX */
+		nla_total_size(4) +
 		0;
 }
 
@@ -1083,12 +1287,25 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			goto nla_put_failure;
 	}
 
+	if (t->index)
+		if (nla_put_u32(skb, IFLA_GRE_ERSPAN_INDEX, t->index))
+			goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static void erspan_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->netdev_ops = &erspan_netdev_ops;
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	ip_tunnel_setup(dev, erspan_net_id);
+}
+
 static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_LINK]		= { .type = NLA_U32 },
 	[IFLA_GRE_IFLAGS]	= { .type = NLA_U16 },
@@ -1107,6 +1324,7 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_COLLECT_METADATA]	= { .type = NLA_FLAG },
 	[IFLA_GRE_IGNORE_DF]	= { .type = NLA_U8 },
 	[IFLA_GRE_FWMARK]	= { .type = NLA_U32 },
+	[IFLA_GRE_ERSPAN_INDEX]	= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
@@ -1139,6 +1357,21 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
+static struct rtnl_link_ops erspan_link_ops __read_mostly = {
+	.kind		= "erspan",
+	.maxtype	= IFLA_GRE_MAX,
+	.policy		= ipgre_policy,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.setup		= erspan_setup,
+	.validate	= erspan_validate,
+	.newlink	= ipgre_newlink,
+	.changelink	= ipgre_changelink,
+	.dellink	= ip_tunnel_dellink,
+	.get_size	= ipgre_get_size,
+	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
+};
+
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 					u8 name_assign_type)
 {
@@ -1202,6 +1435,26 @@ static struct pernet_operations ipgre_tap_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
+static int __net_init erspan_init_net(struct net *net)
+{
+	return ip_tunnel_init_net(net, erspan_net_id,
+				  &erspan_link_ops, "erspan0");
+}
+
+static void __net_exit erspan_exit_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, erspan_net_id);
+
+	ip_tunnel_delete_net(itn, &erspan_link_ops);
+}
+
+static struct pernet_operations erspan_net_ops = {
+	.init = erspan_init_net,
+	.exit = erspan_exit_net,
+	.id   = &erspan_net_id,
+	.size = sizeof(struct ip_tunnel_net),
+};
+
 static int __init ipgre_init(void)
 {
 	int err;
@@ -1216,6 +1469,10 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto pnet_tap_faied;
 
+	err = register_pernet_device(&erspan_net_ops);
+	if (err < 0)
+		goto pnet_erspan_failed;
+
 	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
@@ -1230,13 +1487,21 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
+	err = rtnl_link_register(&erspan_link_ops);
+	if (err < 0)
+		goto erspan_link_failed;
+
 	return 0;
 
+erspan_link_failed:
+	rtnl_link_unregister(&ipgre_tap_ops);
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
 	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 add_proto_failed:
+	unregister_pernet_device(&erspan_net_ops);
+pnet_erspan_failed:
 	unregister_pernet_device(&ipgre_tap_net_ops);
 pnet_tap_faied:
 	unregister_pernet_device(&ipgre_net_ops);
@@ -1247,9 +1512,11 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
+	rtnl_link_unregister(&erspan_link_ops);
 	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	unregister_pernet_device(&ipgre_tap_net_ops);
 	unregister_pernet_device(&ipgre_net_ops);
+	unregister_pernet_device(&erspan_net_ops);
 }
 
 module_init(ipgre_init);
@@ -1257,5 +1524,7 @@ module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("gre");
 MODULE_ALIAS_RTNL_LINK("gretap");
+MODULE_ALIAS_RTNL_LINK("erspan");
 MODULE_ALIAS_NETDEV("gre0");
 MODULE_ALIAS_NETDEV("gretap0");
+MODULE_ALIAS_NETDEV("erspan0");
-- 
2.7.4

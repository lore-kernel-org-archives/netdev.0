From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] vxlan: combine VXLAN_FLOWBASED into VXLAN_COLLECT_METADATA
Date: Tue,  4 Aug 2015 22:51:07 -0700
Message-ID: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
Cc: Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36155 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbHEFvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 01:51:17 -0400
Received: by pacgq8 with SMTP id gq8so26753372pac.3
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 22:51:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_VXLAN_FLOWBASED is useless without IFLA_VXLAN_COLLECT_METADATA,
so combine them into single IFLA_VXLAN_COLLECT_METADATA flag.
'flowbased' doesn't convey real meaning of the vxlan tunnel mode.
This mode can be used by routing, tc+bpf and ovs.
Only ovs is strictly flow based, so 'collect metadata' is a better
name for this tunnel mode.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
it's not too late to kill uapi IFLA_VXLAN_FLOWBASED, since it
was introduced two weeks ago.
Alternatively we could rename both into vxlan_accept_metadata
or something else, but imo collect_metadata is ok.

 drivers/net/vxlan.c           |   17 ++++++-----------
 include/net/vxlan.h           |    4 +---
 include/uapi/linux/if_link.h  |    1 -
 net/openvswitch/vport-vxlan.c |    2 +-
 4 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e90f7a484e1c..b6731fad19ba 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1141,7 +1141,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	union vxlan_addr *remote_ip;
 
 	/* For flow based devices, map all packets to VNI 0 */
-	if (vs->flags & VXLAN_F_FLOW_BASED)
+	if (vs->flags & VXLAN_F_COLLECT_METADATA)
 		vni = 0;
 
 	/* Is this VNI defined? */
@@ -1183,7 +1183,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 
 	skb_reset_network_header(skb);
 	/* In flow-based mode, GBP is carried in dst_metadata */
-	if (!(vs->flags & VXLAN_F_FLOW_BASED))
+	if (!(vs->flags & VXLAN_F_COLLECT_METADATA))
 		skb->mark = md->gbp;
 
 	if (oip6)
@@ -2129,7 +2129,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	}
 
-	if (vxlan->flags & VXLAN_F_FLOW_BASED &&
+	if (vxlan->flags & VXLAN_F_COLLECT_METADATA &&
 	    info && info->mode == IP_TUNNEL_INFO_TX) {
 		vxlan_xmit_one(skb, dev, NULL, false);
 		return NETDEV_TX_OK;
@@ -2462,7 +2462,6 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
-	[IFLA_VXLAN_FLOWBASED]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_COLLECT_METADATA]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
@@ -2814,10 +2813,6 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_LIMIT])
 		conf.addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
-	if (data[IFLA_VXLAN_FLOWBASED] &&
-	    nla_get_u8(data[IFLA_VXLAN_FLOWBASED]))
-		conf.flags |= VXLAN_F_FLOW_BASED;
-
 	if (data[IFLA_VXLAN_COLLECT_METADATA] &&
 	    nla_get_u8(data[IFLA_VXLAN_COLLECT_METADATA]))
 		conf.flags |= VXLAN_F_COLLECT_METADATA;
@@ -2903,7 +2898,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_RSC */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L2MISS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L3MISS */
-		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_FLOWBASED */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_COLLECT_METADATA */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
@@ -2970,8 +2965,8 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			!!(vxlan->flags & VXLAN_F_L2MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
-	    nla_put_u8(skb, IFLA_VXLAN_FLOWBASED,
-		       !!(vxlan->flags & VXLAN_F_FLOW_BASED)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_COLLECT_METADATA,
+		       !!(vxlan->flags & VXLAN_F_COLLECT_METADATA)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->cfg.age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->cfg.addrmax) ||
 	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->cfg.dst_port) ||
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index eb8d721cdb67..e4534f1b2d8c 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -181,7 +181,6 @@ struct vxlan_dev {
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
-#define VXLAN_F_FLOW_BASED		0x4000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -190,8 +189,7 @@ struct vxlan_dev {
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
 					 VXLAN_F_REMCSUM_RX |		\
 					 VXLAN_F_REMCSUM_NOPARTIAL |	\
-					 VXLAN_F_COLLECT_METADATA |	\
-					 VXLAN_F_FLOW_BASED)
+					 VXLAN_F_COLLECT_METADATA)
 
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ea047480a1f0..f24ec99a2262 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -382,7 +382,6 @@ enum {
 	IFLA_VXLAN_REMCSUM_RX,
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
-	IFLA_VXLAN_FLOWBASED,
 	IFLA_VXLAN_COLLECT_METADATA,
 	__IFLA_VXLAN_MAX
 };
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 547173336cd3..c6e937e36f8b 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	int err;
 	struct vxlan_config conf = {
 		.no_share = true,
-		.flags = VXLAN_F_FLOW_BASED | VXLAN_F_COLLECT_METADATA,
+		.flags = VXLAN_F_COLLECT_METADATA,
 	};
 
 	if (!options) {
-- 
1.7.9.5

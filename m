From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 5/6] net: vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 14:04:31 +0200
Message-ID: <1366373072-19621-6-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46106 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030220Ab3DSMEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:42 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad VLAN devices. This mainly consists of checking for
ETH_P_8021AD in addition to ETH_P_8021Q in a couple of places and check
offloading capabilities based on the used protocol.

Configuration is done using "ip link":

# ip link add link eth0 eth0.1000 \
	type vlan proto 802.1ad id 1000
# ip link add link eth0.1000 eth0.1000.1000 \
	type vlan proto 802.1q id 1000

52:54:00:12:34:56 > 92:b1:54:28:e4:8c, ethertype 802.1Q (0x8100), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 84)
    20.1.0.2 > 20.1.0.1: ICMP echo request, id 3003, seq 8, length 64
92:b1:54:28:e4:8c > 52:54:00:12:34:56, ethertype 802.1Q-QinQ (0x88a8), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 47944, offset 0, flags [none], proto ICMP (1), length 84)
    20.1.0.1 > 20.1.0.2: ICMP echo reply, id 3003, seq 8, length 64

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/if_vlan.h         |  6 ++++--
 include/linux/netdev_features.h |  6 ++++++
 include/uapi/linux/if_link.h    |  1 +
 net/8021q/Kconfig               |  2 +-
 net/8021q/vlan.h                |  3 +++
 net/8021q/vlan_core.c           | 18 ++++++++++++++----
 net/8021q/vlan_netlink.c        | 25 ++++++++++++++++++++++---
 net/core/dev.c                  | 16 ++++++++++------
 8 files changed, 61 insertions(+), 16 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8086ff9..a78f939 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -162,6 +162,8 @@ static inline bool vlan_hw_offload_capable(netdev_features_t features,
 {
 	if (proto == htons(ETH_P_8021Q) && features & NETIF_F_HW_VLAN_CTAG_TX)
 		return true;
+	if (proto == htons(ETH_P_8021AD) && features & NETIF_F_HW_VLAN_STAG_TX)
+		return true;
 	return false;
 }
 
@@ -271,9 +273,9 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
 
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto != htons(ETH_P_8021Q) &&
+	    veth->h_vlan_proto != htons(ETH_P_8021AD))
 		return -EINVAL;
-	}
 
 	*vlan_tci = ntohs(veth->h_vlan_TCI);
 	return 0;
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 785913b..cbaa027 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -25,6 +25,9 @@ enum {
 	NETIF_F_HW_VLAN_CTAG_TX_BIT,	/* Transmit VLAN CTAG HW acceleration */
 	NETIF_F_HW_VLAN_CTAG_RX_BIT,	/* Receive VLAN CTAG HW acceleration */
 	NETIF_F_HW_VLAN_CTAG_FILTER_BIT,/* Receive filtering on VLAN CTAGs */
+	NETIF_F_HW_VLAN_STAG_TX_BIT,	/* Transmit VLAN STAG HW acceleration */
+	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
+	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
 	NETIF_F_GSO_BIT,		/* Enable software GSO. */
 	NETIF_F_LLTX_BIT,		/* LockLess TX - deprecated. Please */
@@ -83,6 +86,9 @@ enum {
 #define NETIF_F_HW_VLAN_CTAG_FILTER __NETIF_F(HW_VLAN_CTAG_FILTER)
 #define NETIF_F_HW_VLAN_CTAG_RX	__NETIF_F(HW_VLAN_CTAG_RX)
 #define NETIF_F_HW_VLAN_CTAG_TX	__NETIF_F(HW_VLAN_CTAG_TX)
+#define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
+#define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
+#define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_IP_CSUM		__NETIF_F(IP_CSUM)
 #define NETIF_F_IPV6_CSUM	__NETIF_F(IPV6_CSUM)
 #define NETIF_F_LLTX		__NETIF_F(LLTX)
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9922704..e316354 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -250,6 +250,7 @@ enum {
 	IFLA_VLAN_FLAGS,
 	IFLA_VLAN_EGRESS_QOS,
 	IFLA_VLAN_INGRESS_QOS,
+	IFLA_VLAN_PROTOCOL,
 	__IFLA_VLAN_MAX,
 };
 
diff --git a/net/8021q/Kconfig b/net/8021q/Kconfig
index 8f7517d..b85a91f 100644
--- a/net/8021q/Kconfig
+++ b/net/8021q/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config VLAN_8021Q
-	tristate "802.1Q VLAN Support"
+	tristate "802.1Q/802.1ad VLAN Support"
 	---help---
 	  Select this and you will be able to create 802.1Q VLAN interfaces
 	  on your ethernet interfaces.  802.1Q VLAN supports almost
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 245de96..abc9cb6 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -91,6 +91,7 @@ static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
 
 enum vlan_protos {
 	VLAN_PROTO_8021Q	= 0,
+	VLAN_PROTO_8021AD,
 	VLAN_PROTO_NUM,
 };
 
@@ -116,6 +117,8 @@ static inline unsigned int vlan_proto_idx(__be16 proto)
 	switch (proto) {
 	case __constant_htons(ETH_P_8021Q):
 		return VLAN_PROTO_8021Q;
+	case __constant_htons(ETH_P_8021AD):
+		return VLAN_PROTO_8021AD;
 	default:
 		BUG();
 	}
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index bdb0b9d..ebfa2fc 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -194,6 +194,18 @@ struct vlan_vid_info {
 	int refcount;
 };
 
+static bool vlan_hw_filter_capable(const struct net_device *dev,
+				     const struct vlan_vid_info *vid_info)
+{
+	if (vid_info->proto == htons(ETH_P_8021Q) &&
+	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+		return true;
+	if (vid_info->proto == htons(ETH_P_8021AD) &&
+	    dev->features & NETIF_F_HW_VLAN_STAG_FILTER)
+		return true;
+	return false;
+}
+
 static struct vlan_vid_info *vlan_vid_info_get(struct vlan_info *vlan_info,
 					       __be16 proto, u16 vid)
 {
@@ -231,8 +243,7 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, __be16 proto, u16 vid,
 	if (!vid_info)
 		return -ENOMEM;
 
-	if (proto == htons(ETH_P_8021Q) &&
-	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
+	if (vlan_hw_filter_capable(dev, vid_info)) {
 		err =  ops->ndo_vlan_rx_add_vid(dev, proto, vid);
 		if (err) {
 			kfree(vid_info);
@@ -290,8 +301,7 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 	u16 vid = vid_info->vid;
 	int err;
 
-	if (proto == htons(ETH_P_8021Q) &&
-	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
+	if (vlan_hw_filter_capable(dev, vid_info)) {
 		err = ops->ndo_vlan_rx_kill_vid(dev, proto, vid);
 		if (err) {
 			pr_warn("failed to kill vid %04x/%d for device %s\n",
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index a1a956a..3091297 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -23,6 +23,7 @@ static const struct nla_policy vlan_policy[IFLA_VLAN_MAX + 1] = {
 	[IFLA_VLAN_FLAGS]	= { .len = sizeof(struct ifla_vlan_flags) },
 	[IFLA_VLAN_EGRESS_QOS]	= { .type = NLA_NESTED },
 	[IFLA_VLAN_INGRESS_QOS] = { .type = NLA_NESTED },
+	[IFLA_VLAN_PROTOCOL]	= { .type = NLA_U16 },
 };
 
 static const struct nla_policy vlan_map_policy[IFLA_VLAN_QOS_MAX + 1] = {
@@ -53,6 +54,16 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (!data)
 		return -EINVAL;
 
+	if (data[IFLA_VLAN_PROTOCOL]) {
+		switch (nla_get_be16(data[IFLA_VLAN_PROTOCOL])) {
+		case __constant_htons(ETH_P_8021Q):
+		case __constant_htons(ETH_P_8021AD):
+			break;
+		default:
+			return -EPROTONOSUPPORT;
+		}
+	}
+
 	if (data[IFLA_VLAN_ID]) {
 		id = nla_get_u16(data[IFLA_VLAN_ID]);
 		if (id >= VLAN_VID_MASK)
@@ -107,6 +118,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
+	__be16 proto;
 	int err;
 
 	if (!data[IFLA_VLAN_ID])
@@ -118,7 +130,12 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (!real_dev)
 		return -ENODEV;
 
-	vlan->vlan_proto = htons(ETH_P_8021Q);
+	if (data[IFLA_VLAN_PROTOCOL])
+		proto = nla_get_be16(data[IFLA_VLAN_PROTOCOL]);
+	else
+		proto = htons(ETH_P_8021Q);
+
+	vlan->vlan_proto = proto;
 	vlan->vlan_id	 = nla_get_u16(data[IFLA_VLAN_ID]);
 	vlan->real_dev	 = real_dev;
 	vlan->flags	 = VLAN_FLAG_REORDER_HDR;
@@ -152,7 +169,8 @@ static size_t vlan_get_size(const struct net_device *dev)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 
-	return nla_total_size(2) +	/* IFLA_VLAN_ID */
+	return nla_total_size(2) +	/* IFLA_VLAN_PROTOCOL */
+	       nla_total_size(2) +	/* IFLA_VLAN_ID */
 	       sizeof(struct ifla_vlan_flags) + /* IFLA_VLAN_FLAGS */
 	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
 	       vlan_qos_map_size(vlan->nr_egress_mappings);
@@ -167,7 +185,8 @@ static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct nlattr *nest;
 	unsigned int i;
 
-	if (nla_put_u16(skb, IFLA_VLAN_ID, vlan_dev_priv(dev)->vlan_id))
+	if (nla_put_be16(skb, IFLA_VLAN_PROTOCOL, vlan->vlan_proto) ||
+	    nla_put_u16(skb, IFLA_VLAN_ID, vlan->vlan_id))
 		goto nla_put_failure;
 	if (vlan->flags) {
 		f.flags = vlan->flags;
diff --git a/net/core/dev.c b/net/core/dev.c
index 3a12ee1..fad4c38 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2212,7 +2212,7 @@ __be16 skb_network_protocol(struct sk_buff *skb)
 	__be16 type = skb->protocol;
 	int vlan_depth = ETH_HLEN;
 
-	while (type == htons(ETH_P_8021Q)) {
+	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		struct vlan_hdr *vh;
 
 		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
@@ -2428,20 +2428,22 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
 		features &= ~NETIF_F_GSO_MASK;
 
-	if (protocol == htons(ETH_P_8021Q)) {
+	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
 	} else if (!vlan_tx_tag_present(skb)) {
 		return harmonize_features(skb, protocol, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX);
+	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
+					       NETIF_F_HW_VLAN_STAG_TX);
 
-	if (protocol != htons(ETH_P_8021Q)) {
+	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD)) {
 		return harmonize_features(skb, protocol, features);
 	} else {
 		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
-				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
+				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
+				NETIF_F_HW_VLAN_STAG_TX;
 		return harmonize_features(skb, protocol, features);
 	}
 }
@@ -3360,6 +3362,7 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	case __constant_htons(ETH_P_IP):
 	case __constant_htons(ETH_P_IPV6):
 	case __constant_htons(ETH_P_8021Q):
+	case __constant_htons(ETH_P_8021AD):
 		return true;
 	default:
 		return false;
@@ -3400,7 +3403,8 @@ another_round:
 
 	__this_cpu_inc(softnet_data.processed);
 
-	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
+	    skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
 		skb = vlan_untag(skb);
 		if (unlikely(!skb))
 			goto unlock;
-- 
1.8.1.4

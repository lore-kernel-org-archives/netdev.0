From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/2] net: Kill link between CSUM and SG features.
Date: Thu,  7 Mar 2013 11:28:01 -0800
Message-ID: <1362684481-1789-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:55684 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933225Ab3CGT0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 14:26:16 -0500
Received: by mail-oa0-f69.google.com with SMTP id k14so5248941oag.4
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 11:26:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier SG was unset if CSUM was not available for given device to
force skb copy to avoid sending inconsistent csum.
Commit c9af6db4c11c (net: Fix possible wrong checksum generation)
added explicit flag to force copy to fix this issue.  Therefore
there is no need to link SG and CSUM, following patch kills this
link between there two features.

This patch is also required following patch in series.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdevice.h |   13 +++++++++
 net/core/dev.c            |   63 +++++++++++++++++++++++---------------------
 net/core/skbuff.c         |   13 +++++++++
 net/ipv4/af_inet.c        |    3 --
 net/ipv6/ip6_offload.c    |    3 --
 5 files changed, 59 insertions(+), 36 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 896eb49..e1ebeff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2683,6 +2683,19 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
 {
 	return __skb_gso_segment(skb, features, true);
 }
+__be16 skb_network_protocol(struct sk_buff *skb);
+
+static inline bool can_checksum_protocol(netdev_features_t features,
+					 __be16 protocol)
+{
+	return ((features & NETIF_F_GEN_CSUM) ||
+		((features & NETIF_F_V4_CSUM) &&
+		 protocol == htons(ETH_P_IP)) ||
+		((features & NETIF_F_V6_CSUM) &&
+		 protocol == htons(ETH_P_IPV6)) ||
+		((features & NETIF_F_FCOE_CRC) &&
+		 protocol == htons(ETH_P_FCOE)));
+}
 
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9610389..bb99993 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2208,16 +2208,8 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
-/**
- *	skb_mac_gso_segment - mac layer segmentation handler.
- *	@skb: buffer to segment
- *	@features: features for the output path (see dev->features)
- */
-struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
-				    netdev_features_t features)
+__be16 skb_network_protocol(struct sk_buff *skb)
 {
-	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
-	struct packet_offload *ptype;
 	__be16 type = skb->protocol;
 
 	while (type == htons(ETH_P_8021Q)) {
@@ -2225,13 +2217,31 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 		struct vlan_hdr *vh;
 
 		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
-			return ERR_PTR(-EINVAL);
+			return 0;
 
 		vh = (struct vlan_hdr *)(skb->data + vlan_depth);
 		type = vh->h_vlan_encapsulated_proto;
 		vlan_depth += VLAN_HLEN;
 	}
 
+	return type;
+}
+
+/**
+ *	skb_mac_gso_segment - mac layer segmentation handler.
+ *	@skb: buffer to segment
+ *	@features: features for the output path (see dev->features)
+ */
+struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+				    netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
+	struct packet_offload *ptype;
+	__be16 type = skb_network_protocol(skb);
+
+	if (unlikely(!type))
+		return ERR_PTR(-EINVAL);
+
 	__skb_pull(skb, skb->mac_len);
 
 	rcu_read_lock();
@@ -2398,24 +2408,12 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 	return 0;
 }
 
-static bool can_checksum_protocol(netdev_features_t features, __be16 protocol)
-{
-	return ((features & NETIF_F_GEN_CSUM) ||
-		((features & NETIF_F_V4_CSUM) &&
-		 protocol == htons(ETH_P_IP)) ||
-		((features & NETIF_F_V6_CSUM) &&
-		 protocol == htons(ETH_P_IPV6)) ||
-		((features & NETIF_F_FCOE_CRC) &&
-		 protocol == htons(ETH_P_FCOE)));
-}
-
 static netdev_features_t harmonize_features(struct sk_buff *skb,
 	__be16 protocol, netdev_features_t features)
 {
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, protocol)) {
 		features &= ~NETIF_F_ALL_CSUM;
-		features &= ~NETIF_F_SG;
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
@@ -4921,20 +4919,25 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
 
-	/* Fix illegal SG+CSUM combinations. */
-	if ((features & NETIF_F_SG) &&
-	    !(features & NETIF_F_ALL_CSUM)) {
-		netdev_dbg(dev,
-			"Dropping NETIF_F_SG since no checksum feature.\n");
-		features &= ~NETIF_F_SG;
-	}
-
 	/* TSO requires that SG is present as well. */
 	if ((features & NETIF_F_ALL_TSO) && !(features & NETIF_F_SG)) {
 		netdev_dbg(dev, "Dropping TSO features since no SG feature.\n");
 		features &= ~NETIF_F_ALL_TSO;
 	}
 
+	if ((features & NETIF_F_TSO) && !(features & NETIF_F_HW_CSUM) &&
+					!(features & NETIF_F_IP_CSUM)) {
+		netdev_dbg(dev, "Dropping TSO features since no CSUM feature.\n");
+		features &= ~NETIF_F_TSO;
+		features &= ~NETIF_F_TSO_ECN;
+	}
+
+	if ((features & NETIF_F_TSO6) && !(features & NETIF_F_HW_CSUM) &&
+					 !(features & NETIF_F_IPV6_CSUM)) {
+		netdev_dbg(dev, "Dropping TSO6 features since no CSUM feature.\n");
+		features &= ~NETIF_F_TSO6;
+	}
+
 	/* TSO ECN requires that TSO is present as well. */
 	if ((features & NETIF_F_ALL_TSO) == NETIF_F_TSO_ECN)
 		features &= ~NETIF_F_TSO_ECN;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 33245ef..0a48ae2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2741,12 +2741,19 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	unsigned int tnl_hlen = skb_tnl_header_len(skb);
 	unsigned int headroom;
 	unsigned int len;
+	__be16 proto;
+	bool csum;
 	int sg = !!(features & NETIF_F_SG);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
 	int pos;
 
+	proto = skb_network_protocol(skb);
+	if (unlikely(!proto))
+		return ERR_PTR(-EINVAL);
+
+	csum = !!can_checksum_protocol(features, proto);
 	__skb_push(skb, doffset);
 	headroom = skb_headroom(skb);
 	pos = skb_headlen(skb);
@@ -2884,6 +2891,12 @@ skip_fraglist:
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
+
+		if (!csum) {
+			nskb->csum = skb_checksum(nskb, doffset,
+						  nskb->len - doffset, 0);
+			nskb->ip_summed = CHECKSUM_NONE;
+		}
 	} while ((offset += len) < skb->len);
 
 	return segs;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 68f6a94..dc3f677 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1284,9 +1284,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	int id;
 	unsigned int offset = 0;
 
-	if (!(features & NETIF_F_V4_CSUM))
-		features &= ~NETIF_F_SG;
-
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_TCPV4 |
 		       SKB_GSO_UDP |
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 8234c1d..7a0d25a 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -92,9 +92,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	u8 *prevhdr;
 	int offset = 0;
 
-	if (!(features & NETIF_F_V6_CSUM))
-		features &= ~NETIF_F_SG;
-
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
-- 
1.7.1

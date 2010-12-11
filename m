From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] rfc: ethtool: early-orphan control
Date: Sat, 11 Dec 2010 13:13:35 +0900
Message-ID: <1292040815-10439-1-git-send-email-horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37027 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627Ab0LKENx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 23:13:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Early orphaning is an optimisation which avoids unnecessary cache misses by
orphaning an skb just before it is handed to a device for transmit thus
avoiding the case where the orphaning occurs on a different CPU.

In the case of bonded devices this has the unfortunate side-effect of
breaking down flow control allowing a socket to send UDP packets as fast as
the CPU will allow. This is particularly undesirable in virtualised
network environments.

This patch introduces ethtool control of early orphaning.
It remains on by default by it now may be disabled on a per-interface basis.

I have implemented this as a generic flag.
As it seems to be the first generic flag that requires
no driver awareness I also supplied a default flag handler.
I am unsure if any aspect of this approach is acceptable.

I believe Eric has it in mind that some of the calls
to skb_orphan() in drivers can be removed with the addition
of this feature. I need to discuss that with him further.

A patch for the ethtool user-space utility accompanies this patch.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/ethtool.h   |    1 +
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   10 +++++++---
 net/core/ethtool.c        |   16 +++++++++++++---
 4 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 1908929..e444d1e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -314,6 +314,7 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 	ETH_FLAG_RXHASH		= (1 << 28),
+	ETH_FLAG_EARLY_ORPHAN	= (1 << 29),
 };
 
 /* The following structures are for supporting RX network flow
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d31bc3c..4aa85d6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -905,6 +905,7 @@ struct net_device {
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_EARLY_ORPHAN	(1 << 29) /* Early Orphaning of skbs */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..39e8c38 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1958,11 +1958,12 @@ static int dev_gso_segment(struct sk_buff *skb)
  * We cannot orphan skb if tx timestamp is requested or the sk-reference
  * is needed on driver level for other reasons, e.g. see net/can/raw.c
  */
-static inline void skb_orphan_try(struct sk_buff *skb)
+static inline void skb_orphan_try(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sock *sk = skb->sk;
 
-	if (sk && !skb_shinfo(skb)->tx_flags) {
+	if (dev->features & NETIF_F_EARLY_ORPHAN &&
+	    sk && !skb_shinfo(skb)->tx_flags) {
 		/* skb_tx_hash() wont be able to get sk.
 		 * We copy sk_hash into skb->rxhash
 		 */
@@ -2032,7 +2033,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
-		skb_orphan_try(skb);
+		skb_orphan_try(skb, dev);
 
 		if (vlan_tx_tag_present(skb) &&
 		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
@@ -5216,6 +5217,9 @@ int register_netdevice(struct net_device *dev)
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
+	/* Enable early orphaning - everything supports it */
+	dev->features |= NETIF_F_EARLY_ORPHAN;
+
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1774178..f63bdce 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -133,7 +133,7 @@ EXPORT_SYMBOL(ethtool_op_set_ufo);
  */
 static const u32 flags_dup_features =
 	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
-	 ETH_FLAG_RXHASH);
+	 ETH_FLAG_RXHASH | ETH_FLAG_EARLY_ORPHAN);
 
 u32 ethtool_op_get_flags(struct net_device *dev)
 {
@@ -148,7 +148,8 @@ EXPORT_SYMBOL(ethtool_op_get_flags);
 
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 {
-	if (data & ~supported)
+	/* Everything supports early orphan */
+	if (data & ~(supported | NETIF_F_EARLY_ORPHAN))
 		return -EINVAL;
 
 	dev->features = ((dev->features & ~flags_dup_features) |
@@ -157,6 +158,13 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 }
 EXPORT_SYMBOL(ethtool_op_set_flags);
 
+static int ethtool_op_set_flags_early_orphan(struct net_device *dev, u32 data)
+{
+	dev->features = ((dev->features & ~NETIF_F_EARLY_ORPHAN) |
+			 (data & NETIF_F_EARLY_ORPHAN));
+	return 0;
+}
+
 void ethtool_ntuple_flush(struct net_device *dev)
 {
 	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
@@ -1644,7 +1652,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		break;
 	case ETHTOOL_SFLAGS:
 		rc = ethtool_set_value(dev, useraddr,
-				       dev->ethtool_ops->set_flags);
+				       dev->ethtool_ops->set_flags ?
+				       dev->ethtool_ops->set_flags :
+				       ethtool_op_set_flags_early_orphan);
 		break;
 	case ETHTOOL_GPFLAGS:
 		rc = ethtool_get_value(dev, useraddr, ethcmd,
-- 
1.7.2.3


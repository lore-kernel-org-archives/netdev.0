From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv2 01/20] net-core: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Thu,  7 Apr 2011 08:00:08 -0700
Message-ID: <1302188408-20000-1-git-send-email-maheshb@google.com>
References: <1302050665-10460-2-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:30568 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013Ab1DGPAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 11:00:17 -0400
In-Reply-To: <1302050665-10460-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v1:
 Added NETIF_F_NUM_BITS.

 include/linux/netdevice.h |  111 +++++++++++++++++++++++++++++++-------------
 net/core/dev.c            |   51 +++++++++++----------
 net/core/ethtool.c        |   97 ++++++++++++++++++++-------------------
 net/core/net-sysfs.c      |    4 +-
 net/core/sock.c           |    2 +-
 5 files changed, 156 insertions(+), 109 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09d2624..e27daaf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -980,6 +980,43 @@ struct net_device_ops {
 						    u32 features);
 };
 
+enum netdev_features {
+	NETIF_F_SG_BIT,			/* Scatter/gather IO. */
+	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
+	NETIF_F_NO_CSUM_BIT,		/* Does not require checksum. F.e. loopack. */
+	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
+	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
+	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
+	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
+	NETIF_F_HW_VLAN_TX_BIT,		/* Transmit VLAN hw acceleration */
+	NETIF_F_HW_VLAN_RX_BIT,		/* Receive VLAN hw acceleration */
+	NETIF_F_HW_VLAN_FILTER_BIT,	/* Receive filtering on VLAN */
+	NETIF_F_VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
+	NETIF_F_GSO_BIT,		/* Enable software GSO. */
+	NETIF_F_LLTX_BIT,		/* LockLess TX - deprecated. Please */
+					/* do not use LLTX in new drivers */
+	NETIF_F_NETNS_LOCAL_BIT,	/* Does not change network namespaces */
+	NETIF_F_GRO_BIT,		/* Generic receive offload */
+	NETIF_F_LRO_BIT,		/* large receive offload */
+	/* the GSO_MASK reserves bits 16 through 23 */
+	RESERVED1_BIT,
+	RESERVED2_BIT,
+	RESERVED3_BIT,
+	RESERVED4_BIT,
+	RESERVED5_BIT,
+	RESERVED6_BIT,
+	RESERVED7_BIT,
+	RESERVED8_BIT,
+	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
+	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
+	NETIF_F_FCOE_MTU_BIT,		/* Supports max FCoE MTU, 2158 bytes*/
+	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
+	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
+	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
+	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
+	NETIF_F_NUM_BITS,		/* (LAST VALUE) Total bits in use */
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1029,44 +1066,51 @@ struct net_device {
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
 
+#define DEV_FEATURE_WORDS	BITS_TO_LONGS(NETIF_F_NUM_BITS)
+#define DEV_FEATURE_BITS	(DEV_FEATURE_WORDS*BITS_PER_LONG)
+#define LEGACY_FEATURE_WORD	0
+
 	/* currently active device features */
-	u32			features;
+	unsigned long 		features;
 	/* user-changeable features */
-	u32			hw_features;
+	DECLARE_BITMAP(hw_feature, DEV_FEATURE_BITS);
 	/* user-requested features */
-	u32			wanted_features;
+	DECLARE_BITMAP(wanted_feature, DEV_FEATURE_BITS);
 	/* VLAN feature mask */
-	u32			vlan_features;
+	unsigned long 		vlan_features;
+
+#define legacy_features		features
+#define legacy_hw_features	hw_feature[LEGACY_FEATURE_WORD]
+#define legacy_wanted_features	wanted_feature[LEGACY_FEATURE_WORD]
+#define legacy_vlan_features	vlan_features
 
 	/* Net device feature bits; if you change something,
 	 * also update netdev_features_strings[] in ethtool.c */
 
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
-					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
-
+#define NETIF_F_SG		(1 << NETIF_F_SG_BIT)
+#define NETIF_F_IP_CSUM		(1 << NETIF_F_IP_CSUM_BIT)
+#define NETIF_F_NO_CSUM		(1 << NETIF_F_NO_CSUM_BIT)
+#define NETIF_F_HW_CSUM		(1 << NETIF_F_HW_CSUM_BIT)
+#define NETIF_F_IPV6_CSUM	(1 << NETIF_F_IPV6_CSUM_BIT)
+#define NETIF_F_HIGHDMA		(1 << NETIF_F_HIGHDMA_BIT)
+#define NETIF_F_FRAGLIST	(1 << NETIF_F_FRAGLIST_BIT)
+#define NETIF_F_HW_VLAN_TX	(1 << NETIF_F_HW_VLAN_TX_BIT)
+#define NETIF_F_HW_VLAN_RX	(1 << NETIF_F_HW_VLAN_RX_BIT)
+#define NETIF_F_HW_VLAN_FILTER	(1 << NETIF_F_HW_VLAN_FILTER_BIT)
+#define NETIF_F_VLAN_CHALLENGED	(1 << NETIF_F_VLAN_CHALLENGED_BIT)
+#define NETIF_F_GSO		(1 << NETIF_F_GSO_BIT)
+#define NETIF_F_LLTX		(1 << NETIF_F_LLTX_BIT)
+#define NETIF_F_NETNS_LOCAL	(1 << NETIF_F_NETNS_LOCAL_BIT)
+#define NETIF_F_GRO		(1 << NETIF_F_GRO_BIT)
+#define NETIF_F_LRO		(1 << NETIF_F_LRO_BIT)
 /* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
+#define NETIF_F_FCOE_CRC	(1 << NETIF_F_FCOE_CRC_BIT)
+#define NETIF_F_SCTP_CSUM	(1 << NETIF_F_SCTP_CSUM_BIT)
+#define NETIF_F_FCOE_MTU	(1 << NETIF_F_FCOE_MTU_BIT)
+#define NETIF_F_NTUPLE		(1 << NETIF_F_NTUPLE_BIT)
+#define NETIF_F_RXHASH		(1 << NETIF_F_RXHASH_BIT)
+#define NETIF_F_RXCSUM		(1 << NETIF_F_RXCSUM_BIT)
+#define NETIF_F_NOCACHE_COPY	(1 << NETIF_F_NOCACHE_COPY_BIT)
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -2376,13 +2420,13 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 }
 
 #define HARD_TX_LOCK(dev, txq, cpu) {			\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
+	if ((dev->legacy_features & NETIF_F_LLTX) == 0) {	\
 		__netif_tx_lock(txq, cpu);		\
 	}						\
 }
 
 #define HARD_TX_UNLOCK(dev, txq) {			\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
+	if ((dev->legacy_features & NETIF_F_LLTX) == 0) {	\
 		__netif_tx_unlock(txq);			\
 	}						\
 }
@@ -2547,7 +2591,8 @@ extern void linkwatch_run_queue(void);
 
 static inline u32 netdev_get_wanted_features(struct net_device *dev)
 {
-	return (dev->features & ~dev->hw_features) | dev->wanted_features;
+	return (dev->legacy_features & ~dev->legacy_hw_features) |
+	    dev->legacy_wanted_features;
 }
 u32 netdev_increment_features(u32 all, u32 one, u32 mask);
 u32 netdev_fix_features(struct net_device *dev, u32 features);
@@ -2600,7 +2645,7 @@ static inline int dev_ethtool_get_settings(struct net_device *dev,
 
 static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
 {
-	if (dev->features & NETIF_F_RXCSUM)
+	if (dev->legacy_features & NETIF_F_RXCSUM)
 		return 1;
 	if (!dev->ethtool_ops || !dev->ethtool_ops->get_rx_csum)
 		return 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d0b4f6..8cad38d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1315,7 +1315,7 @@ void dev_disable_lro(struct net_device *dev)
 		return;
 
 	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
-	WARN_ON(dev->features & NETIF_F_LRO);
+	WARN_ON(dev->legacy_features & NETIF_F_LRO);
 }
 EXPORT_SYMBOL(dev_disable_lro);
 
@@ -1871,7 +1871,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features)
 			dev->ethtool_ops->get_drvinfo(dev, &info);
 
 		WARN(1, "%s: caps=(0x%lx, 0x%lx) len=%d data_len=%d ip_summed=%d\n",
-		     info.driver, dev ? dev->features : 0L,
+		     info.driver, dev ? dev->legacy_features : 0L,
 		     skb->sk ? skb->sk->sk_route_caps : 0L,
 		     skb->len, skb->data_len, skb->ip_summed);
 
@@ -1926,7 +1926,7 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
-	if (!(dev->features & NETIF_F_HIGHDMA)) {
+	if (!(dev->legacy_features & NETIF_F_HIGHDMA)) {
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			if (PageHighMem(skb_shinfo(skb)->frags[i].page))
 				return 1;
@@ -2043,7 +2043,7 @@ static u32 harmonize_features(struct sk_buff *skb, __be16 protocol, u32 features
 u32 netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol = skb->protocol;
-	u32 features = skb->dev->features;
+	u32 features = skb->dev->legacy_features;
 
 	if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
@@ -2052,7 +2052,7 @@ u32 netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, protocol, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);
+	features &= (skb->dev->legacy_vlan_features | NETIF_F_HW_VLAN_TX);
 
 	if (protocol != htons(ETH_P_8021Q)) {
 		return harmonize_features(skb, protocol, features);
@@ -2589,7 +2589,7 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 		/* Should we steer this flow to a different hardware queue? */
 		if (!skb_rx_queue_recorded(skb) || !dev->rx_cpu_rmap ||
-		    !(dev->features & NETIF_F_NTUPLE))
+		    !(dev->legacy_features & NETIF_F_NTUPLE))
 			goto out;
 		rxq_index = cpu_rmap_lookup_index(dev->rx_cpu_rmap, next_cpu);
 		if (rxq_index == skb_get_rx_queue(skb))
@@ -3350,7 +3350,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int mac_len;
 	enum gro_result ret;
 
-	if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
+	if (!(skb->dev->legacy_features & NETIF_F_GRO) || netpoll_rx_on(skb))
 		goto normal;
 
 	if (skb_is_gso(skb) || skb_has_frag_list(skb))
@@ -5249,11 +5249,11 @@ int __netdev_update_features(struct net_device *dev)
 	/* driver might be less strict about feature dependencies */
 	features = netdev_fix_features(dev, features);
 
-	if (dev->features == features)
+	if (dev->legacy_features == features)
 		return 0;
 
 	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
-		dev->features, features);
+		dev->legacy_features, features);
 
 	if (dev->netdev_ops->ndo_set_features)
 		err = dev->netdev_ops->ndo_set_features(dev, features);
@@ -5261,12 +5261,12 @@ int __netdev_update_features(struct net_device *dev)
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
 			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
-			err, features, dev->features);
+			err, features, dev->legacy_features);
 		return -1;
 	}
 
 	if (!err)
-		dev->features = features;
+		dev->legacy_features = features;
 
 	return 1;
 }
@@ -5415,29 +5415,30 @@ int register_netdevice(struct net_device *dev)
 	/* Transfer changeable features to wanted_features and enable
 	 * software offloads (GSO and GRO).
 	 */
-	dev->hw_features |= NETIF_F_SOFT_FEATURES;
-	dev->features |= NETIF_F_SOFT_FEATURES;
-	dev->wanted_features = dev->features & dev->hw_features;
+	dev->legacy_hw_features |= NETIF_F_SOFT_FEATURES;
+	dev->legacy_features |= NETIF_F_SOFT_FEATURES;
+	dev->legacy_wanted_features =
+		dev->legacy_features & dev->legacy_hw_features;
 
 	/* Avoid warning from netdev_fix_features() for GSO without SG */
-	if (!(dev->wanted_features & NETIF_F_SG)) {
-		dev->wanted_features &= ~NETIF_F_GSO;
-		dev->features &= ~NETIF_F_GSO;
+	if (!(dev->legacy_wanted_features & NETIF_F_SG)) {
+		dev->legacy_wanted_features &= ~NETIF_F_GSO;
+		dev->legacy_features &= ~NETIF_F_GSO;
 	}
 
 	/* Turn on no cache copy if HW is doing checksum */
-	dev->hw_features |= NETIF_F_NOCACHE_COPY;
-	if ((dev->features & NETIF_F_ALL_CSUM) &&
-	    !(dev->features & NETIF_F_NO_CSUM)) {
-		dev->wanted_features |= NETIF_F_NOCACHE_COPY;
-		dev->features |= NETIF_F_NOCACHE_COPY;
+	dev->legacy_hw_features |= NETIF_F_NOCACHE_COPY;
+	if ((dev->legacy_features & NETIF_F_ALL_CSUM) &&
+	    !(dev->legacy_features & NETIF_F_NO_CSUM)) {
+		dev->legacy_wanted_features |= NETIF_F_NOCACHE_COPY;
+		dev->legacy_features |= NETIF_F_NOCACHE_COPY;
 	}
 
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
 	 */
-	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
+	dev->legacy_vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
 
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
@@ -6019,7 +6020,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Don't allow namespace local devices to be moved. */
 	err = -EINVAL;
-	if (dev->features & NETIF_F_NETNS_LOCAL)
+	if (dev->legacy_features & NETIF_F_NETNS_LOCAL)
 		goto out;
 
 	/* Ensure the device has been registrered */
@@ -6352,7 +6353,7 @@ static void __net_exit default_device_exit(struct net *net)
 		char fb_name[IFNAMSIZ];
 
 		/* Ignore unmoveable devices (i.e. loopback) */
-		if (dev->features & NETIF_F_NETNS_LOCAL)
+		if (dev->legacy_features & NETIF_F_NETNS_LOCAL)
 			continue;
 
 		/* Leave virtual devices for the generic cleanup */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 719670a..fd03c53 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -36,16 +36,16 @@ EXPORT_SYMBOL(ethtool_op_get_link);
 
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
-	return (dev->features & NETIF_F_ALL_CSUM) != 0;
+	return (dev->legacy_features & NETIF_F_ALL_CSUM) != 0;
 }
 EXPORT_SYMBOL(ethtool_op_get_tx_csum);
 
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_IP_CSUM;
+		dev->legacy_features |= NETIF_F_IP_CSUM;
 	else
-		dev->features &= ~NETIF_F_IP_CSUM;
+		dev->legacy_features &= ~NETIF_F_IP_CSUM;
 
 	return 0;
 }
@@ -54,9 +54,9 @@ EXPORT_SYMBOL(ethtool_op_set_tx_csum);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_HW_CSUM;
+		dev->legacy_features |= NETIF_F_HW_CSUM;
 	else
-		dev->features &= ~NETIF_F_HW_CSUM;
+		dev->legacy_features &= ~NETIF_F_HW_CSUM;
 
 	return 0;
 }
@@ -65,9 +65,9 @@ EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
 int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+		dev->legacy_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	else
-		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+		dev->legacy_features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 
 	return 0;
 }
@@ -75,16 +75,16 @@ EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 
 u32 ethtool_op_get_sg(struct net_device *dev)
 {
-	return (dev->features & NETIF_F_SG) != 0;
+	return (dev->legacy_features & NETIF_F_SG) != 0;
 }
 EXPORT_SYMBOL(ethtool_op_get_sg);
 
 int ethtool_op_set_sg(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_SG;
+		dev->legacy_features |= NETIF_F_SG;
 	else
-		dev->features &= ~NETIF_F_SG;
+		dev->legacy_features &= ~NETIF_F_SG;
 
 	return 0;
 }
@@ -92,16 +92,16 @@ EXPORT_SYMBOL(ethtool_op_set_sg);
 
 u32 ethtool_op_get_tso(struct net_device *dev)
 {
-	return (dev->features & NETIF_F_TSO) != 0;
+	return (dev->legacy_features & NETIF_F_TSO) != 0;
 }
 EXPORT_SYMBOL(ethtool_op_get_tso);
 
 int ethtool_op_set_tso(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_TSO;
+		dev->legacy_features |= NETIF_F_TSO;
 	else
-		dev->features &= ~NETIF_F_TSO;
+		dev->legacy_features &= ~NETIF_F_TSO;
 
 	return 0;
 }
@@ -109,16 +109,16 @@ EXPORT_SYMBOL(ethtool_op_set_tso);
 
 u32 ethtool_op_get_ufo(struct net_device *dev)
 {
-	return (dev->features & NETIF_F_UFO) != 0;
+	return (dev->legacy_features & NETIF_F_UFO) != 0;
 }
 EXPORT_SYMBOL(ethtool_op_get_ufo);
 
 int ethtool_op_set_ufo(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= NETIF_F_UFO;
+		dev->legacy_features |= NETIF_F_UFO;
 	else
-		dev->features &= ~NETIF_F_UFO;
+		dev->legacy_features &= ~NETIF_F_UFO;
 	return 0;
 }
 EXPORT_SYMBOL(ethtool_op_set_ufo);
@@ -137,7 +137,7 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 	 * by a simple masking operation
 	 */
 
-	return dev->features & flags_dup_features;
+	return dev->legacy_features & flags_dup_features;
 }
 EXPORT_SYMBOL(ethtool_op_get_flags);
 
@@ -148,7 +148,7 @@ EXPORT_SYMBOL(ethtool_op_get_flags);
  */
 bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
 {
-	u32 features = dev->features & flags_dup_features;
+	u32 features = dev->legacy_features & flags_dup_features;
 	/* "data" can contain only flags_dup_features bits,
 	 * see __ethtool_set_flags */
 
@@ -161,7 +161,7 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 	if (ethtool_invalid_flags(dev, data, supported))
 		return -EINVAL;
 
-	dev->features = ((dev->features & ~flags_dup_features) |
+	dev->legacy_features = ((dev->legacy_features & ~flags_dup_features) |
 			 (data & flags_dup_features));
 	return 0;
 }
@@ -261,9 +261,9 @@ static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 	};
 	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS] = {
 		{
-			.available = dev->hw_features,
-			.requested = dev->wanted_features,
-			.active = dev->features,
+			.available = dev->legacy_hw_features,
+			.requested = dev->legacy_wanted_features,
+			.active = dev->legacy_features,
 			.never_changed = NETIF_F_NEVER_CHANGE,
 		},
 	};
@@ -310,16 +310,17 @@ static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
 	if (ethtool_set_features_compat(dev, features))
 		ret |= ETHTOOL_F_COMPAT;
 
-	if (features[0].valid & ~dev->hw_features) {
-		features[0].valid &= dev->hw_features;
+	if (features[0].valid & ~dev->legacy_hw_features) {
+		features[0].valid &= dev->legacy_hw_features;
 		ret |= ETHTOOL_F_UNSUPPORTED;
 	}
 
-	dev->wanted_features &= ~features[0].valid;
-	dev->wanted_features |= features[0].valid & features[0].requested;
+	dev->legacy_wanted_features &= ~features[0].valid;
+	dev->legacy_wanted_features |= features[0].valid & features[0].requested;
 	__netdev_update_features(dev);
 
-	if ((dev->wanted_features ^ dev->features) & features[0].valid)
+	if ((dev->legacy_wanted_features ^ dev->legacy_features)
+			& features[0].valid)
 		ret |= ETHTOOL_F_WISH;
 
 	return ret;
@@ -445,7 +446,7 @@ static void *__ethtool_get_one_feature_actor(struct net_device *dev, u32 ethcmd)
 
 static u32 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
 {
-	return !!(dev->features & NETIF_F_ALL_CSUM);
+	return !!(dev->legacy_features & NETIF_F_ALL_CSUM);
 }
 
 static int ethtool_get_one_feature(struct net_device *dev,
@@ -454,11 +455,11 @@ static int ethtool_get_one_feature(struct net_device *dev,
 	u32 mask = ethtool_get_feature_mask(ethcmd);
 	struct ethtool_value edata = {
 		.cmd = ethcmd,
-		.data = !!(dev->features & mask),
+		.data = !!(dev->legacy_features & mask),
 	};
 
 	/* compatibility with discrete get_ ops */
-	if (!(dev->hw_features & mask)) {
+	if (!(dev->legacy_hw_features & mask)) {
 		u32 (*actor)(struct net_device *);
 
 		actor = __ethtool_get_one_feature_actor(dev, ethcmd);
@@ -492,12 +493,12 @@ static int ethtool_set_one_feature(struct net_device *dev,
 		return -EFAULT;
 
 	mask = ethtool_get_feature_mask(ethcmd);
-	mask &= dev->hw_features;
+	mask &= dev->legacy_hw_features;
 	if (mask) {
 		if (edata.data)
-			dev->wanted_features |= mask;
+			dev->legacy_wanted_features |= mask;
 		else
-			dev->wanted_features &= ~mask;
+			dev->legacy_wanted_features &= ~mask;
 
 		__netdev_update_features(dev);
 		return 0;
@@ -537,19 +538,19 @@ int __ethtool_set_flags(struct net_device *dev, u32 data)
 
 	/* legacy set_flags() op */
 	if (dev->ethtool_ops->set_flags) {
-		if (unlikely(dev->hw_features & flags_dup_features))
+		if (unlikely(dev->legacy_hw_features & flags_dup_features))
 			netdev_warn(dev,
 				"driver BUG: mixed hw_features and set_flags()\n");
 		return dev->ethtool_ops->set_flags(dev, data);
 	}
 
 	/* allow changing only bits set in hw_features */
-	changed = (data ^ dev->wanted_features) & flags_dup_features;
-	if (changed & ~dev->hw_features)
-		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;
+	changed = (data ^ dev->legacy_wanted_features) & flags_dup_features;
+	if (changed & ~dev->legacy_hw_features)
+		return (changed & dev->legacy_hw_features) ? -EINVAL : -EOPNOTSUPP;
 
-	dev->wanted_features =
-		(dev->wanted_features & ~changed) | data;
+	dev->legacy_wanted_features =
+		(dev->legacy_wanted_features & ~changed) | data;
 
 	__netdev_update_features(dev);
 
@@ -908,7 +909,7 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
 	int ret;
 
-	if (!(dev->features & NETIF_F_NTUPLE))
+	if (!(dev->legacy_features & NETIF_F_NTUPLE))
 		return -EINVAL;
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
@@ -1475,7 +1476,7 @@ static int __ethtool_set_sg(struct net_device *dev, u32 data)
 	if (!dev->ethtool_ops->set_sg)
 		return -EOPNOTSUPP;
 
-	if (data && !(dev->features & NETIF_F_ALL_CSUM))
+	if (data && !(dev->legacy_features & NETIF_F_ALL_CSUM))
 		return -EINVAL;
 
 	if (!data && dev->ethtool_ops->set_tso) {
@@ -1514,7 +1515,7 @@ static int __ethtool_set_rx_csum(struct net_device *dev, u32 data)
 		return -EOPNOTSUPP;
 
 	if (!data)
-		dev->features &= ~NETIF_F_GRO;
+		dev->legacy_features &= ~NETIF_F_GRO;
 
 	return dev->ethtool_ops->set_rx_csum(dev, data);
 }
@@ -1524,7 +1525,7 @@ static int __ethtool_set_tso(struct net_device *dev, u32 data)
 	if (!dev->ethtool_ops->set_tso)
 		return -EOPNOTSUPP;
 
-	if (data && !(dev->features & NETIF_F_SG))
+	if (data && !(dev->legacy_features & NETIF_F_SG))
 		return -EINVAL;
 
 	return dev->ethtool_ops->set_tso(dev, data);
@@ -1534,10 +1535,10 @@ static int __ethtool_set_ufo(struct net_device *dev, u32 data)
 {
 	if (!dev->ethtool_ops->set_ufo)
 		return -EOPNOTSUPP;
-	if (data && !(dev->features & NETIF_F_SG))
+	if (data && !(dev->legacy_features & NETIF_F_SG))
 		return -EINVAL;
-	if (data && !((dev->features & NETIF_F_GEN_CSUM) ||
-		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
+	if (data && !((dev->legacy_features & NETIF_F_GEN_CSUM) ||
+		(dev->legacy_features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
 			== (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
 		return -EINVAL;
 	return dev->ethtool_ops->set_ufo(dev, data);
@@ -1805,7 +1806,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		if (rc  < 0)
 			return rc;
 	}
-	old_features = dev->features;
+	old_features = dev->legacy_features;
 
 	switch (ethcmd) {
 	case ETHTOOL_GSET:
@@ -1960,7 +1961,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	if (dev->ethtool_ops->complete)
 		dev->ethtool_ops->complete(dev);
 
-	if (old_features != dev->features)
+	if (old_features != dev->legacy_features)
 		netdev_features_change(dev);
 
 	return rc;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..088a2d4 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -99,7 +99,7 @@ NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
-NETDEVICE_SHOW(features, fmt_hex);
+NETDEVICE_SHOW(legacy_features, fmt_hex);
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
 
@@ -316,7 +316,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
-	__ATTR(features, S_IRUGO, show_features, NULL),
+	__ATTR(legacy_features, S_IRUGO, show_legacy_features, NULL),
 	__ATTR(type, S_IRUGO, show_type, NULL),
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
 	__ATTR(address, S_IRUGO, show_address, NULL),
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dfed79..4f067df 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1301,7 +1301,7 @@ EXPORT_SYMBOL_GPL(sk_clone);
 void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
 	__sk_dst_set(sk, dst);
-	sk->sk_route_caps = dst->dev->features;
+	sk->sk_route_caps = dst->dev->legacy_features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	sk->sk_route_caps &= ~sk->sk_route_nocaps;
-- 
1.7.3.1


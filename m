From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 11:52:42 -0700
Message-ID: <1306263162-2022-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:46235 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab1EXSwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 14:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define macros to set/clear/test bits for feature set usage. This will eliminate
the direct use of these fields and enable future ease in managing these fields.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/netdev_features.h |  137 +++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h       |   35 ++---------
 2 files changed, 142 insertions(+), 30 deletions(-)
 create mode 100644 include/linux/netdev_features.h

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
new file mode 100644
index 0000000..97bf8c4
--- /dev/null
+++ b/include/linux/netdev_features.h
@@ -0,0 +1,137 @@
+#ifndef	_NETDEV_FEATURES_H
+#define	_NETDEV_FEATURES_H
+
+/* Forward declarations */
+struct net_device;
+
+typedef	unsigned long *nd_feature_t;
+
+/* Net device feature bits; if you change something,
+ * also update netdev_features_strings[] in ethtool.c */
+enum netdev_features {
+	SG_BIT,			/* Scatter/gather IO. */
+	IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
+	NO_CSUM_BIT,		/* Does not require checksum. F.e. loopack. */
+	HW_CSUM_BIT,		/* Can checksum all the packets. */
+	IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
+	HIGHDMA_BIT,		/* Can DMA to high memory. */
+	FRAGLIST_BIT,		/* Scatter/gather IO. */
+	HW_VLAN_TX_BIT,		/* Transmit VLAN hw acceleration */
+	HW_VLAN_RX_BIT,		/* Receive VLAN hw acceleration */
+	HW_VLAN_FILTER_BIT,	/* Receive filtering on VLAN */
+	VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
+	GSO_BIT,		/* Enable software GSO. */
+	LLTX_BIT,		/* LockLess TX - deprecated. Please */
+				/* do not use LLTX in new drivers */
+	NETNS_LOCAL_BIT,	/* Does not change network namespaces */
+	GRO_BIT,		/* Generic receive offload */
+	LRO_BIT,		/* large receive offload */
+	RESERVED16_BIT,		/* the GSO_MASK reserved bit 16 */
+	RESERVED17_BIT,		/* the GSO_MASK reserved bit 17 */
+	RESERVED18_BIT,		/* the GSO_MASK reserved bit 18 */
+	RESERVED19_BIT,		/* the GSO_MASK reserved bit 19 */
+	RESERVED20_BIT,		/* the GSO_MASK reserved bit 20 */
+	RESERVED21_BIT,		/* the GSO_MASK reserved bit 21 */
+	RESERVED22_BIT,		/* the GSO_MASK reserved bit 22 */
+	RESERVED23_BIT,		/* the GSO_MASK reserved bit 23 */
+	FCOE_CRC_BIT,		/* FCoE CRC32 */
+	SCTP_CSUM_BIT,		/* SCTP checksum offload */
+	FCOE_MTU_BIT,		/* Supports max FCoE MTU, 2158 bytes*/
+	NTUPLE_BIT,		/* N-tuple filters supported */
+	RXHASH_BIT,		/* Receive hashing offload */
+	RXCSUM_BIT,		/* Receive checksumming offload */
+	NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
+	LOOPBACK_BIT,		/* Enable loopback */
+
+	/* Add you bit above this */
+	ND_FEATURE_NUM_BITS		/* (LAST VALUE) Total bits in use */
+};
+
+#define	BIT2FLAG(bit)	(1 << (bit))
+
+#define NETIF_F_SG		BIT2FLAG(SG_BIT)
+#define NETIF_F_IP_CSUM		BIT2FLAG(IP_CSUM_BIT)
+#define NETIF_F_NO_CSUM		BIT2FLAG(NO_CSUM_BIT)
+#define NETIF_F_HW_CSUM		BIT2FLAG(HW_CSUM_BIT)
+#define NETIF_F_IPV6_CSUM	BIT2FLAG(IPV6_CSUM_BIT)
+#define NETIF_F_HIGHDMA		BIT2FLAG(HIGHDMA_BIT)
+#define NETIF_F_FRAGLIST	BIT2FLAG(FRAGLIST_BIT)
+#define NETIF_F_HW_VLAN_TX	BIT2FLAG(HW_VLAN_TX_BIT)
+#define NETIF_F_HW_VLAN_RX	BIT2FLAG(HW_VLAN_RX_BIT)
+#define NETIF_F_HW_VLAN_FILTER	BIT2FLAG(HW_VLAN_FILTER_BIT)
+#define NETIF_F_VLAN_CHALLENGED	BIT2FLAG(VLAN_CHALLENGED_BIT)
+#define NETIF_F_GSO		BIT2FLAG(GSO_BIT)
+#define NETIF_F_LLTX		BIT2FLAG(LLTX_BIT)
+#define NETIF_F_NETNS_LOCAL	BIT2FLAG(NETNS_LOCAL_BIT)
+#define NETIF_F_GRO		BIT2FLAG(GRO_BIT)
+#define NETIF_F_LRO		BIT2FLAG(LRO_BIT)
+#define NETIF_F_FCOE_CRC	BIT2FLAG(FCOE_CRC_BIT)
+#define NETIF_F_SCTP_CSUM	BIT2FLAG(SCTP_CSUM_BIT)
+#define NETIF_F_FCOE_MTU	BIT2FLAG(FCOE_MTU_BIT)
+#define NETIF_F_NTUPLE		BIT2FLAG(NTUPLE_BIT)
+#define NETIF_F_RXHASH		BIT2FLAG(RXHASH_BIT)
+#define NETIF_F_RXCSUM		BIT2FLAG(RXCSUM_BIT)
+#define NETIF_F_NOCACHE_COPY	BIT2FLAG(NOCACHE_COPY_BIT)
+#define NETIF_F_LOOPBACK	BIT2FLAG(LOOPBACK_BIT)
+
+#define DEV_FEATURE_WORDS	BITS_TO_LONGS(ND_FEATURE_NUM_BITS)
+#define	DEV_FEATURE_BITS	(DEV_FEATURE_WORDS * BITS_PER_LONG)
+
+static inline void _nd_set_feature(u32 *old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		*old_field |= (1 << bit);
+	set_bit(bit, new_field);
+}
+
+static inline void _nd_clear_feature(u32 *old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		*old_field &= ~(1 << bit);
+
+	clear_bit(bit, new_field);
+}
+
+static inline bool _nd_test_feature(u32 old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		return (old_field & (1 << bit)) == 1;	
+
+	return test_bit(bit, new_field) == 1;
+}
+
+#define	netdev_set_feature	netdev_set_active_feature
+#define	netdev_set_active_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->features, (dev)->active_feature, (bit))
+#define	netdev_clear_active_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->features, (dev)->active_feature, (bit))
+#define	netdev_test_active_feature(dev, bit)	\
+	_nd_test_feature((dev)->features, (dev)->active_feature, (bit))
+
+#define	netdev_set_hw_feature	netdev_set_offered_feature
+#define	netdev_set_offered_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->hw_features, (dev)->offered_feature, (bit))
+#define	netdev_clear_offered_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->hw_features, (dev)->offered_feature, (bit))
+#define	netdev_test_offered_feature(dev, bit)	\
+	_nd_test_feature((dev)->hw_features, (dev)->offered_feature, (bit))
+
+#define	netdev_set_vlan_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->vlan_features, (dev)->vlan_feature, (bit))
+#define	netdev_clear_vlan_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->vlan_features, (dev)->vlan_feature, (bit))
+#define	netdev_test_vlan_feature(dev, bit)	\
+	_nd_test_feature((dev)->vlan_features, (dev)->vlan_feature, (bit))
+
+#define	netdev_set_wanted_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->wanted_features, (dev)->wanted_feature, (bit))
+#define	netdev_clear_wanted_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->wanted_features, (dev)->wanted_feature, (bit))
+#define	netdev_test_wanted_feature(dev, bit)	\
+	_nd_test_feature((dev)->wanted_features, (dev)->wanted_feature, (bit))
+
+
+#endif	/* __NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..41ee234 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -51,6 +51,7 @@
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
+#include <linux/netdev_features.h>
 
 struct vlan_group;
 struct netpoll_info;
@@ -1035,36 +1036,10 @@ struct net_device {
 	/* mask of features inheritable by VLAN devices */
 	u32			vlan_features;
 
-	/* Net device feature bits; if you change something,
-	 * also update netdev_features_strings[] in ethtool.c */
-
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
-/* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
-#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
+	DECLARE_BITMAP(active_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(offered_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(wanted_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(vlan_feature, DEV_FEATURE_BITS);
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-- 
1.7.3.1


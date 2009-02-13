From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 6/6] mv643xx_eth: implement Large Receive Offload
Date: Fri, 13 Feb 2009 01:08:39 +0100
Message-ID: <20090213000839.GP17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43012 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264AbZBMAIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:08:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Controlled by a compile-time (Kconfig) option for now, since it
isn't a win in all cases.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/Kconfig       |   10 ++++
 drivers/net/mv643xx_eth.c |  112 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 121 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6bdfd47..fa20751 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2310,6 +2310,16 @@ config MV643XX_ETH
 	  Some boards that use the Discovery chipset are the Momenco
 	  Ocelot C and Jaguar ATX and Pegasos II.
 
+config MV643XX_ETH_LRO
+	tristate "Marvell 643XX ethernet driver LRO support"
+	depends on MV643XX_ETH
+	select INET_LRO
+	help
+	  Say y here if you want to use Large Receive Offload for the
+	  mv643xx_eth driver.
+
+	  If in doubt, say N.
+
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
 	depends on PCI
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 26de19b..8e86d3a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -53,6 +53,7 @@
 #include <linux/mv643xx_eth.h>
 #include <linux/io.h>
 #include <linux/types.h>
+#include <linux/inet_lro.h>
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
@@ -227,6 +228,12 @@ struct tx_desc {
 #define RX_ENABLE_INTERRUPT		0x20000000
 #define RX_FIRST_DESC			0x08000000
 #define RX_LAST_DESC			0x04000000
+#define RX_IP_HDR_OK			0x02000000
+#define RX_PKT_IS_IPV4			0x01000000
+#define RX_PKT_IS_ETHERNETV2		0x00800000
+#define RX_PKT_LAYER4_TYPE_MASK		0x00600000
+#define RX_PKT_LAYER4_TYPE_TCP_IPV4	0x00000000
+#define RX_PKT_IS_VLAN_TAGGED		0x00080000
 
 /* TX descriptor command */
 #define TX_ENABLE_INTERRUPT		0x00800000
@@ -324,6 +331,12 @@ struct mib_counters {
 	u32 late_collision;
 };
 
+struct lro_counters {
+	u32 lro_aggregated;
+	u32 lro_flushed;
+	u32 lro_no_desc;
+};
+
 struct rx_queue {
 	int index;
 
@@ -337,6 +350,11 @@ struct rx_queue {
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
+
+#ifdef CONFIG_MV643XX_ETH_LRO
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_arr[8];
+#endif
 };
 
 struct tx_queue {
@@ -372,6 +390,8 @@ struct mv643xx_eth_private {
 	spinlock_t mib_counters_lock;
 	struct mib_counters mib_counters;
 
+	struct lro_counters lro_counters;
+
 	struct work_struct tx_timeout_task;
 
 	struct napi_struct napi;
@@ -496,12 +516,42 @@ static void txq_maybe_wake(struct tx_queue *txq)
 
 
 /* rx napi ******************************************************************/
+#ifdef CONFIG_MV643XX_ETH_LRO
+static int
+mv643xx_get_skb_header(struct sk_buff *skb, void **iphdr, void **tcph,
+		       u64 *hdr_flags, void *priv)
+{
+	unsigned long cmd_sts = (unsigned long)priv;
+
+	/*
+	 * Make sure that this packet is Ethernet II, is not VLAN
+	 * tagged, is IPv4, has a valid IP header, and is TCP.
+	 */
+	if ((cmd_sts & (RX_IP_HDR_OK | RX_PKT_IS_IPV4 |
+		       RX_PKT_IS_ETHERNETV2 | RX_PKT_LAYER4_TYPE_MASK |
+		       RX_PKT_IS_VLAN_TAGGED)) !=
+	    (RX_IP_HDR_OK | RX_PKT_IS_IPV4 |
+	     RX_PKT_IS_ETHERNETV2 | RX_PKT_LAYER4_TYPE_TCP_IPV4))
+		return -1;
+
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, ip_hdrlen(skb));
+	*iphdr = ip_hdr(skb);
+	*tcph = tcp_hdr(skb);
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+
+	return 0;
+}
+#endif
+
 static int rxq_process(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	struct net_device_stats *stats = &mp->dev->stats;
+	int lro_flush_needed;
 	int rx;
 
+	lro_flush_needed = 0;
 	rx = 0;
 	while (rx < budget && rxq->rx_desc_count) {
 		struct rx_desc *rx_desc;
@@ -561,7 +611,15 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		if (cmd_sts & LAYER_4_CHECKSUM_OK)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->protocol = eth_type_trans(skb, mp->dev);
-		netif_receive_skb(skb);
+
+#ifdef CONFIG_MV643XX_ETH_LRO
+		if (skb->dev->features & NETIF_F_LRO &&
+		    skb->ip_summed == CHECKSUM_UNNECESSARY) {
+			lro_receive_skb(&rxq->lro_mgr, skb, (void *)cmd_sts);
+			lro_flush_needed = 1;
+		} else
+#endif
+			netif_receive_skb(skb);
 
 		continue;
 
@@ -582,6 +640,11 @@ err:
 		dev_kfree_skb(skb);
 	}
 
+#ifdef CONFIG_MV643XX_ETH_LRO
+	if (lro_flush_needed)
+		lro_flush_all(&rxq->lro_mgr);
+#endif
+
 	if (rx < budget)
 		mp->work_rx &= ~(1 << rxq->index);
 
@@ -1161,6 +1224,28 @@ static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
 	return stats;
 }
 
+static void mv643xx_eth_grab_lro_stats(struct mv643xx_eth_private *mp)
+{
+	u32 lro_aggregated = 0;
+	u32 lro_flushed = 0;
+	u32 lro_no_desc = 0;
+	int i;
+
+#ifdef CONFIG_MV643XX_ETH_LRO
+	for (i = 0; i < mp->rxq_count; i++) {
+		struct rx_queue *rxq = mp->rxq + i;
+
+		lro_aggregated += rxq->lro_mgr.stats.aggregated;
+		lro_flushed += rxq->lro_mgr.stats.flushed;
+		lro_no_desc += rxq->lro_mgr.stats.no_desc;
+	}
+#endif
+
+	mp->lro_counters.lro_aggregated = lro_aggregated;
+	mp->lro_counters.lro_flushed = lro_flushed;
+	mp->lro_counters.lro_no_desc = lro_no_desc;
+}
+
 static inline u32 mib_read(struct mv643xx_eth_private *mp, int offset)
 {
 	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
@@ -1319,6 +1404,10 @@ struct mv643xx_eth_stats {
 	{ #m, FIELD_SIZEOF(struct mib_counters, m),		\
 	  -1, offsetof(struct mv643xx_eth_private, mib_counters.m) }
 
+#define LROSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct lro_counters, m),		\
+	  -1, offsetof(struct mv643xx_eth_private, lro_counters.m) }
+
 static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	SSTAT(rx_packets),
 	SSTAT(tx_packets),
@@ -1358,6 +1447,9 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	MIBSTAT(bad_crc_event),
 	MIBSTAT(collision),
 	MIBSTAT(late_collision),
+	LROSTAT(lro_aggregated),
+	LROSTAT(lro_flushed),
+	LROSTAT(lro_no_desc),
 };
 
 static int
@@ -1569,6 +1661,7 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
+	mv643xx_eth_grab_lro_stats(mp);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 		const struct mv643xx_eth_stats *stat;
@@ -1610,6 +1703,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
+	.get_flags		= ethtool_op_get_flags,
+	.set_flags		= ethtool_op_set_flags,
 	.get_sset_count		= mv643xx_eth_get_sset_count,
 };
 
@@ -1844,6 +1939,21 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct rx_desc);
 	}
 
+#ifdef CONFIG_MV643XX_ETH_LRO
+	rxq->lro_mgr.dev = mp->dev;
+	memset(&rxq->lro_mgr.stats, 0, sizeof(rxq->lro_mgr.stats));
+	rxq->lro_mgr.features = LRO_F_NAPI;
+	rxq->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
+	rxq->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	rxq->lro_mgr.max_desc = ARRAY_SIZE(rxq->lro_arr);
+	rxq->lro_mgr.max_aggr = 32;
+	rxq->lro_mgr.frag_align_pad = 0;
+	rxq->lro_mgr.lro_arr = rxq->lro_arr;
+	rxq->lro_mgr.get_skb_header = mv643xx_get_skb_header;
+
+	memset(&rxq->lro_arr, 0, sizeof(rxq->lro_arr));
+#endif
+
 	return 0;
 
 
-- 
1.5.6.4

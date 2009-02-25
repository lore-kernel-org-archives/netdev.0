From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/4] mv643xx_eth: make LRO unconditional
Date: Wed, 25 Feb 2009 02:41:32 +0100
Message-ID: <20090225014132.GW17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53051 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbZBYBlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:41:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/Kconfig       |   11 +----------
 drivers/net/mv643xx_eth.c |   12 ------------
 2 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa20751..6367567 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2301,6 +2301,7 @@ config UGETH_TX_ON_DEMAND
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
+	select INET_LRO
 	select PHYLIB
 	help
 	  This driver supports the gigabit ethernet MACs in the
@@ -2310,16 +2311,6 @@ config MV643XX_ETH
 	  Some boards that use the Discovery chipset are the Momenco
 	  Ocelot C and Jaguar ATX and Pegasos II.
 
-config MV643XX_ETH_LRO
-	tristate "Marvell 643XX ethernet driver LRO support"
-	depends on MV643XX_ETH
-	select INET_LRO
-	help
-	  Say y here if you want to use Large Receive Offload for the
-	  mv643xx_eth driver.
-
-	  If in doubt, say N.
-
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
 	depends on PCI
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8e86d3a..5736dcd 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -351,10 +351,8 @@ struct rx_queue {
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
 
-#ifdef CONFIG_MV643XX_ETH_LRO
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_arr[8];
-#endif
 };
 
 struct tx_queue {
@@ -516,7 +514,6 @@ static void txq_maybe_wake(struct tx_queue *txq)
 
 
 /* rx napi ******************************************************************/
-#ifdef CONFIG_MV643XX_ETH_LRO
 static int
 mv643xx_get_skb_header(struct sk_buff *skb, void **iphdr, void **tcph,
 		       u64 *hdr_flags, void *priv)
@@ -542,7 +539,6 @@ mv643xx_get_skb_header(struct sk_buff *skb, void **iphdr, void **tcph,
 
 	return 0;
 }
-#endif
 
 static int rxq_process(struct rx_queue *rxq, int budget)
 {
@@ -612,13 +608,11 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->protocol = eth_type_trans(skb, mp->dev);
 
-#ifdef CONFIG_MV643XX_ETH_LRO
 		if (skb->dev->features & NETIF_F_LRO &&
 		    skb->ip_summed == CHECKSUM_UNNECESSARY) {
 			lro_receive_skb(&rxq->lro_mgr, skb, (void *)cmd_sts);
 			lro_flush_needed = 1;
 		} else
-#endif
 			netif_receive_skb(skb);
 
 		continue;
@@ -640,10 +634,8 @@ err:
 		dev_kfree_skb(skb);
 	}
 
-#ifdef CONFIG_MV643XX_ETH_LRO
 	if (lro_flush_needed)
 		lro_flush_all(&rxq->lro_mgr);
-#endif
 
 	if (rx < budget)
 		mp->work_rx &= ~(1 << rxq->index);
@@ -1231,7 +1223,6 @@ static void mv643xx_eth_grab_lro_stats(struct mv643xx_eth_private *mp)
 	u32 lro_no_desc = 0;
 	int i;
 
-#ifdef CONFIG_MV643XX_ETH_LRO
 	for (i = 0; i < mp->rxq_count; i++) {
 		struct rx_queue *rxq = mp->rxq + i;
 
@@ -1239,7 +1230,6 @@ static void mv643xx_eth_grab_lro_stats(struct mv643xx_eth_private *mp)
 		lro_flushed += rxq->lro_mgr.stats.flushed;
 		lro_no_desc += rxq->lro_mgr.stats.no_desc;
 	}
-#endif
 
 	mp->lro_counters.lro_aggregated = lro_aggregated;
 	mp->lro_counters.lro_flushed = lro_flushed;
@@ -1939,7 +1929,6 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct rx_desc);
 	}
 
-#ifdef CONFIG_MV643XX_ETH_LRO
 	rxq->lro_mgr.dev = mp->dev;
 	memset(&rxq->lro_mgr.stats, 0, sizeof(rxq->lro_mgr.stats));
 	rxq->lro_mgr.features = LRO_F_NAPI;
@@ -1952,7 +1941,6 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 	rxq->lro_mgr.get_skb_header = mv643xx_get_skb_header;
 
 	memset(&rxq->lro_arr, 0, sizeof(rxq->lro_arr));
-#endif
 
 	return 0;
 
-- 
1.5.6.4

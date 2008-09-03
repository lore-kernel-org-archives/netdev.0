From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 06/17] mv643xx_eth: make napi unconditional
Date: Wed,  3 Sep 2008 14:29:33 +0200
Message-ID: <1220444984-20150-7-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52896 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752386AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make napi unconditional on the receive side, so that we can get rid
of all the locking and local interrupt disabling in the receive path.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   31 +++----------------------------
 1 files changed, 3 insertions(+), 28 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b41860d..2b7e76d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -58,7 +58,6 @@ static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.3";
 
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-#define MV643XX_ETH_NAPI
 #define MV643XX_ETH_TX_FAST_REFILL
 
 #ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
@@ -616,7 +615,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
-			dev_kfree_skb_irq(skb);
+			dev_kfree_skb(skb);
 		} else {
 			/*
 			 * The -4 is for the CRC in the trailer of the
@@ -630,11 +629,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 					(cmd_sts & 0x0007fff8) >> 3);
 			}
 			skb->protocol = eth_type_trans(skb, mp->dev);
-#ifdef MV643XX_ETH_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif
 		}
 
 		mp->dev->last_rx = jiffies;
@@ -645,7 +640,6 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 	return rx;
 }
 
-#ifdef MV643XX_ETH_NAPI
 static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
 	struct mv643xx_eth_private *mp;
@@ -681,7 +675,6 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 	return rx;
 }
-#endif
 
 
 /* tx ***********************************************************************/
@@ -1856,7 +1849,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	/*
 	 * RxBuffer or RxError set for any of the 8 queues?
 	 */
-#ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
 		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_RX));
 		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
@@ -1864,15 +1856,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 
 		netif_rx_schedule(dev, &mp->napi);
 	}
-#else
-	if (int_cause & INT_RX) {
-		int i;
-
-		for (i = 7; i >= 0; i--)
-			if (mp->rxq_mask & (1 << i))
-				rxq_process(mp->rxq + i, INT_MAX);
-	}
-#endif
 
 	/*
 	 * TxBuffer or TxError set for any of the 8 queues?
@@ -2101,9 +2084,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 		}
 	}
 
-#ifdef MV643XX_ETH_NAPI
 	napi_enable(&mp->napi);
-#endif
 
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
@@ -2167,9 +2148,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
 	rdl(mp, INT_MASK(mp->port_num));
 
-#ifdef MV643XX_ETH_NAPI
 	napi_disable(&mp->napi);
-#endif
+
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
@@ -2632,9 +2612,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->port_num = pd->port_number;
 
 	mp->dev = dev;
-#ifdef MV643XX_ETH_NAPI
+
 	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 64);
-#endif
 
 	set_params(mp, pd);
 
@@ -2700,10 +2679,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (dev->features & NETIF_F_IP_CSUM)
 		dev_printk(KERN_NOTICE, &dev->dev, "tx checksum offload\n");
 
-#ifdef MV643XX_ETH_NAPI
-	dev_printk(KERN_NOTICE, &dev->dev, "napi enabled\n");
-#endif
-
 	if (mp->tx_desc_sram_size > 0)
 		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
 
-- 
1.5.6.4


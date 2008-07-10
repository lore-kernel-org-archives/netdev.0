From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/6] ucc_geth: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 00:34:40 +0200
Message-ID: <20080710223440.GF31019@electric-eye.fr.zoreil.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40886 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753684AbYGJWe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:34:58 -0400
Content-Disposition: inline
In-Reply-To: <20080708.015548.127198943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Kconfig    |    4 ----
 drivers/net/ucc_geth.c |   29 ++---------------------------
 2 files changed, 2 insertions(+), 31 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c4841c0..cc78e79 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2242,10 +2242,6 @@ config UCC_GETH
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
 	  which is available on some Freescale SOCs.
 
-config UGETH_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on UCC_GETH
-
 config UGETH_MAGIC_PACKET
 	bool "Magic Packet detection support"
 	depends on UCC_GETH
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fb0b918..07933f7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3500,11 +3500,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 			dev->stats.rx_bytes += length;
 			/* Send the packet up the stack */
-#ifdef CONFIG_UGETH_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif				/* CONFIG_UGETH_NAPI */
 		}
 
 		ugeth->dev->last_rx = jiffies;
@@ -3580,7 +3576,6 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 	return 0;
 }
 
-#ifdef CONFIG_UGETH_NAPI
 static int ucc_geth_poll(struct napi_struct *napi, int budget)
 {
 	struct ucc_geth_private *ugeth = container_of(napi, struct ucc_geth_private, napi);
@@ -3607,7 +3602,6 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 
 	return howmany;
 }
-#endif				/* CONFIG_UGETH_NAPI */
 
 static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 {
@@ -3617,9 +3611,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	struct ucc_geth_info *ug_info;
 	register u32 ucce;
 	register u32 uccm;
-#ifndef CONFIG_UGETH_NAPI
-	register u32 rx_mask;
-#endif
 	register u32 tx_mask;
 	u8 i;
 
@@ -3636,21 +3627,11 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
-#ifdef CONFIG_UGETH_NAPI
 		if (netif_rx_schedule_prep(dev, &ugeth->napi)) {
 			uccm &= ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
 			__netif_rx_schedule(dev, &ugeth->napi);
 		}
-#else
-		rx_mask = UCCE_RXBF_SINGLE_MASK;
-		for (i = 0; i < ug_info->numQueuesRx; i++) {
-			if (ucce & rx_mask)
-				ucc_geth_rx(ugeth, i, (int)ugeth->ug_info->bdRingLenRx[i]);
-			ucce &= ~rx_mask;
-			rx_mask <<= 1;
-		}
-#endif /* CONFIG_UGETH_NAPI */
 	}
 
 	/* Tx event processing */
@@ -3720,9 +3701,8 @@ static int ucc_geth_open(struct net_device *dev)
 		return err;
 	}
 
-#ifdef CONFIG_UGETH_NAPI
 	napi_enable(&ugeth->napi);
-#endif
+
 	err = ucc_geth_startup(ugeth);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
@@ -3783,9 +3763,8 @@ static int ucc_geth_open(struct net_device *dev)
 	return err;
 
 out_err:
-#ifdef CONFIG_UGETH_NAPI
 	napi_disable(&ugeth->napi);
-#endif
+
 	return err;
 }
 
@@ -3796,9 +3775,7 @@ static int ucc_geth_close(struct net_device *dev)
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-#ifdef CONFIG_UGETH_NAPI
 	napi_disable(&ugeth->napi);
-#endif
 
 	ucc_geth_stop(ugeth);
 
@@ -4050,9 +4027,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->hard_start_xmit = ucc_geth_start_xmit;
 	dev->tx_timeout = ucc_geth_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_UGETH_NAPI
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
-#endif				/* CONFIG_UGETH_NAPI */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = ucc_netpoll;
 #endif
-- 
1.5.3.3


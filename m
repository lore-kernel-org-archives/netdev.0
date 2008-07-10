From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/6] via-rhine: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 00:30:14 +0200
Message-ID: <20080710223014.GB31019@electric-eye.fr.zoreil.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Roger Luethi <rl@hellgate.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59393 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754891AbYGJWa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:30:27 -0400
Content-Disposition: inline
In-Reply-To: <20080708.015548.127198943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Kconfig     |   11 -----------
 drivers/net/via-rhine.c |   27 ++-------------------------
 2 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 50ca1cf..fb618b6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1694,17 +1694,6 @@ config VIA_RHINE_MMIO
 
 	  If unsure, say Y.
 
-config VIA_RHINE_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on VIA_RHINE
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support"
 	depends on NET_PCI && PCI && MIPS_ATLAS
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8c9d6ae..96dff04 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -73,12 +73,7 @@ static const int multicast_filter_limit = 32;
    There are no ill effects from too-large receive rings. */
 #define TX_RING_SIZE	16
 #define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
-#ifdef CONFIG_VIA_RHINE_NAPI
 #define RX_RING_SIZE	64
-#else
-#define RX_RING_SIZE	16
-#endif
-
 
 /* Operational parameters that usually are not changed. */
 
@@ -583,7 +578,6 @@ static void rhine_poll(struct net_device *dev)
 }
 #endif
 
-#ifdef CONFIG_VIA_RHINE_NAPI
 static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
 	struct rhine_private *rp = container_of(napi, struct rhine_private, napi);
@@ -604,7 +598,6 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 	}
 	return work_done;
 }
-#endif
 
 static void __devinit rhine_hw_init(struct net_device *dev, long pioaddr)
 {
@@ -784,9 +777,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = rhine_poll;
 #endif
-#ifdef CONFIG_VIA_RHINE_NAPI
 	netif_napi_add(dev, &rp->napi, rhine_napipoll, 64);
-#endif
+
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
@@ -1056,9 +1048,7 @@ static void init_registers(struct net_device *dev)
 
 	rhine_set_rx_mode(dev);
 
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_enable(&rp->napi);
-#endif
 
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
@@ -1193,9 +1183,7 @@ static void rhine_tx_timeout(struct net_device *dev)
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
 
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
 
 	spin_lock(&rp->lock);
 
@@ -1319,16 +1307,12 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 
 		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
 				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
-#ifdef CONFIG_VIA_RHINE_NAPI
 			iowrite16(IntrTxAborted |
 				  IntrTxDone | IntrTxError | IntrTxUnderrun |
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
 
 			netif_rx_schedule(dev, &rp->napi);
-#else
-			rhine_rx(dev, RX_RING_SIZE);
-#endif
 		}
 
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
@@ -1520,11 +1504,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 						 PCI_DMA_FROMDEVICE);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_VIA_RHINE_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif
 			dev->last_rx = jiffies;
 			rp->stats.rx_bytes += pkt_len;
 			rp->stats.rx_packets++;
@@ -1836,9 +1816,7 @@ static int rhine_close(struct net_device *dev)
 	spin_lock_irq(&rp->lock);
 
 	netif_stop_queue(dev);
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
@@ -1937,9 +1915,8 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
+
 	netif_device_detach(dev);
 	pci_save_state(pdev);
 
-- 
1.5.3.3


From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/2] tc35815: Kill non-napi code
Date: Mon,  2 Nov 2009 23:34:46 +0900
Message-ID: <1257172487-5656-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:61642 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755203AbZKBOeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 09:34:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   68 +------------------------------------------------
 1 files changed, 1 insertions(+), 67 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 0d621ca..803eb64 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -22,12 +22,7 @@
  * All Rights Reserved.
  */
 
-#define TC35815_NAPI
-#ifdef TC35815_NAPI
-#define DRV_VERSION	"1.38-NAPI"
-#else
-#define DRV_VERSION	"1.38"
-#endif
+#define DRV_VERSION	"1.39"
 static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
 
@@ -563,12 +558,8 @@ static void free_rxbuf_skb(struct pci_dev *hwdev, struct sk_buff *skb, dma_addr_
 static int	tc35815_open(struct net_device *dev);
 static int	tc35815_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t	tc35815_interrupt(int irq, void *dev_id);
-#ifdef TC35815_NAPI
 static int	tc35815_rx(struct net_device *dev, int limit);
 static int	tc35815_poll(struct napi_struct *napi, int budget);
-#else
-static void	tc35815_rx(struct net_device *dev);
-#endif
 static void	tc35815_txdone(struct net_device *dev);
 static int	tc35815_close(struct net_device *dev);
 static struct	net_device_stats *tc35815_get_stats(struct net_device *dev);
@@ -924,9 +915,7 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 	dev->netdev_ops = &tc35815_netdev_ops;
 	dev->ethtool_ops = &tc35815_ethtool_ops;
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
-#ifdef TC35815_NAPI
 	netif_napi_add(dev, &lp->napi, tc35815_poll, NAPI_WEIGHT);
-#endif
 
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long)ioaddr;
@@ -1401,9 +1390,7 @@ tc35815_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-#ifdef TC35815_NAPI
 	napi_enable(&lp->napi);
-#endif
 
 	/* Reset the hardware here. Don't forget to set the station address. */
 	spin_lock_irq(&lp->lock);
@@ -1537,11 +1524,7 @@ static void tc35815_fatal_error_interrupt(struct net_device *dev, u32 status)
 	tc35815_schedule_restart(dev);
 }
 
-#ifdef TC35815_NAPI
 static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
-#else
-static int tc35815_do_interrupt(struct net_device *dev, u32 status)
-#endif
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	int ret = -1;
@@ -1580,12 +1563,7 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 	/* normal notification */
 	if (status & Int_IntMacRx) {
 		/* Got a packet(s). */
-#ifdef TC35815_NAPI
 		ret = tc35815_rx(dev, limit);
-#else
-		tc35815_rx(dev);
-		ret = 0;
-#endif
 		lp->lstats.rx_ints++;
 	}
 	if (status & Int_IntMacTx) {
@@ -1593,12 +1571,8 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 		lp->lstats.tx_ints++;
 		tc35815_txdone(dev);
 		netif_wake_queue(dev);
-#ifdef TC35815_NAPI
 		if (ret < 0)
 			ret = 0;
-#else
-		ret = 0;
-#endif
 	}
 	return ret;
 }
@@ -1613,7 +1587,6 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-#ifdef TC35815_NAPI
 	u32 dmactl = tc_readl(&tr->DMA_Ctl);
 
 	if (!(dmactl & DMA_IntMask)) {
@@ -1630,22 +1603,6 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 		return IRQ_HANDLED;
 	}
 	return IRQ_NONE;
-#else
-	int handled;
-	u32 status;
-
-	spin_lock(&lp->lock);
-	status = tc_readl(&tr->Int_Src);
-	/* BLEx, FDAEx will be cleared later */
-	tc_writel(status & ~(Int_BLEx | Int_FDAEx),
-		  &tr->Int_Src);	/* write to clear */
-	handled = tc35815_do_interrupt(dev, status);
-	if (status & (Int_BLEx | Int_FDAEx))
-		tc_writel(status & (Int_BLEx | Int_FDAEx), &tr->Int_Src);
-	(void)tc_readl(&tr->Int_Src);	/* flush */
-	spin_unlock(&lp->lock);
-	return IRQ_RETVAL(handled >= 0);
-#endif /* TC35815_NAPI */
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1658,20 +1615,13 @@ static void tc35815_poll_controller(struct net_device *dev)
 #endif
 
 /* We have a good packet(s), get it/them out of the buffers. */
-#ifdef TC35815_NAPI
 static int
 tc35815_rx(struct net_device *dev, int limit)
-#else
-static void
-tc35815_rx(struct net_device *dev)
-#endif
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned int fdctl;
 	int i;
-#ifdef TC35815_NAPI
 	int received = 0;
-#endif
 
 	while (!((fdctl = le32_to_cpu(lp->rfd_cur->fd.FDCtl)) & FD_CownsFD)) {
 		int status = le32_to_cpu(lp->rfd_cur->fd.FDStat);
@@ -1694,10 +1644,8 @@ tc35815_rx(struct net_device *dev)
 			int offset;
 #endif
 
-#ifdef TC35815_NAPI
 			if (--limit < 0)
 				break;
-#endif
 #ifdef TC35815_USE_PACKEDBUFFER
 			BUG_ON(bd_count > 2);
 			skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
@@ -1767,12 +1715,8 @@ tc35815_rx(struct net_device *dev)
 			if (netif_msg_pktdata(lp))
 				print_eth(data);
 			skb->protocol = eth_type_trans(skb, dev);
-#ifdef TC35815_NAPI
 			netif_receive_skb(skb);
 			received++;
-#else
-			netif_rx(skb);
-#endif
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		} else {
@@ -1888,12 +1832,9 @@ tc35815_rx(struct net_device *dev)
 #endif
 	}
 
-#ifdef TC35815_NAPI
 	return received;
-#endif
 }
 
-#ifdef TC35815_NAPI
 static int tc35815_poll(struct napi_struct *napi, int budget)
 {
 	struct tc35815_local *lp = container_of(napi, struct tc35815_local, napi);
@@ -1930,7 +1871,6 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	}
 	return received;
 }
-#endif
 
 #ifdef NO_CHECK_CARRIER
 #define TX_STA_ERR	(Tx_ExColl|Tx_Under|Tx_Defer|Tx_LateColl|Tx_TxPar|Tx_SQErr)
@@ -2050,11 +1990,7 @@ tc35815_txdone(struct net_device *dev)
 			pci_unmap_single(lp->pci_dev, lp->tx_skbs[lp->tfd_end].skb_dma, skb->len, PCI_DMA_TODEVICE);
 			lp->tx_skbs[lp->tfd_end].skb = NULL;
 			lp->tx_skbs[lp->tfd_end].skb_dma = 0;
-#ifdef TC35815_NAPI
 			dev_kfree_skb_any(skb);
-#else
-			dev_kfree_skb_irq(skb);
-#endif
 		}
 		txfd->fd.FDSystem = cpu_to_le32(0xffffffff);
 
@@ -2118,9 +2054,7 @@ tc35815_close(struct net_device *dev)
 	struct tc35815_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
-#ifdef TC35815_NAPI
 	napi_disable(&lp->napi);
-#endif
 	if (lp->phy_dev)
 		phy_stop(lp->phy_dev);
 	cancel_work_sync(&lp->restart_work);
-- 
1.5.6.5


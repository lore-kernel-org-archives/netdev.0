From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/7] via-rhine: per device debug level.
Date: Sat, 7 Jan 2012 23:52:11 +0100
Message-ID: <20120107225211.GF25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50389 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578Ab2AGXBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:01:32 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |  169 ++++++++++++++++------------------
 1 files changed, 79 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 98ec14e..e39802f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -39,9 +39,9 @@
 
 /* A few user-configurable values.
    These may be modified when a driver module is loaded. */
-
-#define DEBUG
-static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
+static int debug = 0;
+#define RHINE_MSG_DEFAULT \
+        (0x0000)
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
@@ -130,7 +130,7 @@ MODULE_LICENSE("GPL");
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(avoid_D3, bool, 0);
-MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
+MODULE_PARM_DESC(debug, "VIA Rhine debug message flags");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
 
@@ -450,6 +450,8 @@ struct rhine_private {
 	struct work_struct slow_event_task;
 	struct work_struct reset_task;
 
+	u32 msg_enable;
+
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
 	struct rx_desc *rx_head_desc;
@@ -512,8 +514,8 @@ static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool high)
 		udelay(10);
 	}
 	if (i > 64) {
-		netdev_dbg(rp->dev, "%s bit wait (%02x/%02x) cycle "
-			   "count: %04d\n", high ? "high" : "low", reg, mask, i);
+		netif_dbg(rp, hw, rp->dev, "%s bit wait (%02x/%02x) cycle "
+			  "count: %04d\n", high ? "high" : "low", reg, mask, i);
 	}
 }
 
@@ -613,6 +615,7 @@ static void rhine_chip_reset(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
+	u8 cmd1;
 
 	iowrite8(Cmd1Reset, ioaddr + ChipCmd1);
 	IOSYNC;
@@ -628,10 +631,9 @@ static void rhine_chip_reset(struct net_device *dev)
 		rhine_wait_bit_low(rp, ChipCmd1, Cmd1Reset);
 	}
 
-	if (debug > 1)
-		netdev_info(dev, "Reset %s\n",
-			    (ioread8(ioaddr + ChipCmd1) & Cmd1Reset) ?
-			    "failed" : "succeeded");
+	cmd1 = ioread8(ioaddr + ChipCmd1);
+	netif_info(rp, hw, dev, "Reset %s\n", (cmd1 & Cmd1Reset) ?
+		   "failed" : "succeeded");
 }
 
 #ifdef USE_MMIO
@@ -706,28 +708,24 @@ static void rhine_tx_err(struct rhine_private *rp, u32 status)
 	struct net_device *dev = rp->dev;
 
 	if (status & IntrTxAborted) {
-		if (debug > 1)
-			netdev_info(dev, "Abort %08x, frame dropped\n", status);
+		netif_info(rp, tx_err, dev,
+			   "Abort %08x, frame dropped\n", status);
 	}
 
 	if (status & IntrTxUnderrun) {
 		rhine_kick_tx_threshold(rp);
-		if (debug > 1)
-			netdev_info(dev, "Transmitter underrun, Tx threshold now %02x\n",
-				    rp->tx_thresh);
+		netif_info(rp, tx_err ,dev, "Transmitter underrun, "
+			   "Tx threshold now %02x\n", rp->tx_thresh);
 	}
 
-	if (status & IntrTxDescRace) {
-		if (debug > 2)
-			netdev_info(dev, "Tx descriptor write-back race\n");
-	}
+	if (status & IntrTxDescRace)
+		netif_info(rp, tx_err, dev, "Tx descriptor write-back race\n");
 
 	if ((status & IntrTxError) &&
 	    (status & (IntrTxAborted | IntrTxUnderrun | IntrTxDescRace)) == 0) {
 		rhine_kick_tx_threshold(rp);
-		if (debug > 1)
-			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
-				    rp->tx_thresh);
+		netif_info(rp, tx_err, dev, "Unspecified error. "
+			   "Tx threshold now %02x\n", rp->tx_thresh);
 	}
 
 	rhine_restart_tx(dev);
@@ -789,16 +787,12 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 
 	if (status & RHINE_EVENT_NAPI_TX) {
 		if (status & RHINE_EVENT_NAPI_TX_ERR) {
-			u8 cmd;
-
 			/* Avoid scavenging before Tx engine turned off */
 			rhine_wait_bit_low(rp, ChipCmd, CmdTxOn);
-			cmd = ioread8(ioaddr + ChipCmd);
-			if ((cmd & CmdTxOn) && (debug > 2)) {
-				netdev_warn(dev, "%s: Tx engine still on\n",
-					    __func__);
-			}
+			if (ioread8(ioaddr + ChipCmd) & CmdTxOn)
+				netif_warn(rp, tx_err, dev, "Tx still on\n");
 		}
+
 		rhine_tx(dev);
 
 		if (status & RHINE_EVENT_NAPI_TX_ERR)
@@ -943,6 +937,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
+	rp->msg_enable = netif_msg_init(debug, RHINE_MSG_DEFAULT);
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
@@ -1064,8 +1059,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		}
 	}
 	rp->mii_if.phy_id = phy_id;
-	if (debug > 1 && avoid_D3)
-		netdev_info(dev, "No D3 power state at shutdown\n");
+	if (avoid_D3)
+		netif_info(rp, probe, dev, "No D3 power state at shutdown\n");
 
 	return 0;
 
@@ -1241,7 +1236,7 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	mii_check_media(&rp->mii_if, debug, init_media);
+	mii_check_media(&rp->mii_if, netif_msg_link(rp), init_media);
 
 	if (rp->mii_if.full_duplex)
 	    iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1FDuplex,
@@ -1249,24 +1244,26 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	else
 	    iowrite8(ioread8(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
 		   ioaddr + ChipCmd1);
-	if (debug > 1)
-		netdev_info(dev, "force_media %d, carrier %d\n",
-			    rp->mii_if.force_media, netif_carrier_ok(dev));
+
+	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
+		   rp->mii_if.force_media, netif_carrier_ok(dev));
 }
 
 /* Called after status of force_media possibly changed */
 static void rhine_set_carrier(struct mii_if_info *mii)
 {
+	struct net_device *dev = mii->dev;
+	struct rhine_private *rp = netdev_priv(dev);
+
 	if (mii->force_media) {
 		/* autoneg is off: Link is always assumed to be up */
-		if (!netif_carrier_ok(mii->dev))
-			netif_carrier_on(mii->dev);
-	}
-	else	/* Let MMI library update carrier status */
-		rhine_check_media(mii->dev, 0);
-	if (debug > 1)
-		netdev_info(mii->dev, "force_media %d, carrier %d\n",
-			    mii->force_media, netif_carrier_ok(mii->dev));
+		if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
+	} else	/* Let MMI library update carrier status */
+		rhine_check_media(dev, 0);
+
+	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
+		   mii->force_media, netif_carrier_ok(dev));
 }
 
 /**
@@ -1570,8 +1567,7 @@ static int rhine_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
-	if (debug > 1)
-		netdev_dbg(dev, "%s() irq %d\n", __func__, rp->pdev->irq);
+	netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp->pdev->irq);
 
 	rc = alloc_ring(dev);
 	if (rc) {
@@ -1583,10 +1579,10 @@ static int rhine_open(struct net_device *dev)
 	rhine_chip_reset(dev);
 	rhine_task_enable(rp);
 	init_registers(dev);
-	if (debug > 2)
-		netdev_dbg(dev, "%s() Done - status %04x MII status: %04x\n",
-			   __func__, ioread16(ioaddr + ChipCmd),
-			   mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
+
+	netif_dbg(rp, ifup, dev, "%s() Done - status %04x MII status: %04x\n",
+		  __func__, ioread16(ioaddr + ChipCmd),
+		  mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	netif_start_queue(dev);
 
@@ -1716,10 +1712,9 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
 		netif_stop_queue(dev);
 
-	if (debug > 4) {
-		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
-			   rp->cur_tx-1, entry);
-	}
+	netif_dbg(rp, tx_queued, dev, "Transmit frame #%d queued in slot %d\n",
+		  rp->cur_tx - 1, entry);
+
 	return NETDEV_TX_OK;
 }
 
@@ -1740,8 +1735,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 
 	status = rhine_get_events(rp);
 
-	if (debug > 4)
-		netdev_dbg(dev, "Interrupt, status %08x\n", status);
+	netif_dbg(rp, intr, dev, "Interrupt, status %08x\n", status);
 
 	if (status & RHINE_EVENT) {
 		handled = 1;
@@ -1751,9 +1745,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 	}
 
 	if (status & ~(IntrLinkChange | IntrStatsMax | RHINE_EVENT_NAPI)) {
-		if (debug > 1)
-			netdev_err(dev, "Something Wicked happened! %08x\n",
-				   status);
+		netif_err(rp, intr, dev, "Something Wicked happened! %08x\n",
+			  status);
 	}
 
 	return IRQ_RETVAL(handled);
@@ -1769,15 +1762,13 @@ static void rhine_tx(struct net_device *dev)
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
 		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
-		if (debug > 6)
-			netdev_dbg(dev, "Tx scavenge %d status %08x\n",
-				   entry, txstatus);
+		netif_dbg(rp, tx_done, dev, "Tx scavenge %d status %08x\n",
+			  entry, txstatus);
 		if (txstatus & DescOwn)
 			break;
 		if (txstatus & 0x8000) {
-			if (debug > 1)
-				netdev_dbg(dev, "Transmit error, Tx status %08x\n",
-					   txstatus);
+			netif_dbg(rp, tx_done, dev,
+				  "Transmit error, Tx status %08x\n", txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & 0x0400)
 				dev->stats.tx_carrier_errors++;
@@ -1799,10 +1790,8 @@ static void rhine_tx(struct net_device *dev)
 				dev->stats.collisions += (txstatus >> 3) & 0x0F;
 			else
 				dev->stats.collisions += txstatus & 0x0F;
-			if (debug > 6)
-				netdev_dbg(dev, "collisions: %1.1x:%1.1x\n",
-					   (txstatus >> 3) & 0xF,
-					   txstatus & 0xF);
+			netif_dbg(rp, tx_done, dev, "collisions: %1.1x:%1.1x\n",
+				  (txstatus >> 3) & 0xF, txstatus & 0xF);
 			dev->stats.tx_bytes += rp->tx_skbuff[entry]->len;
 			dev->stats.tx_packets++;
 		}
@@ -1843,11 +1832,8 @@ static int rhine_rx(struct net_device *dev, int limit)
 	int count;
 	int entry = rp->cur_rx % RX_RING_SIZE;
 
-	if (debug > 4) {
-		netdev_dbg(dev, "%s(), entry %d status %08x\n",
-			   __func__, entry,
-			   le32_to_cpu(rp->rx_head_desc->rx_status));
-	}
+	netif_dbg(rp, rx_status, dev, "%s(), entry %d status %08x\n", __func__,
+		  entry, le32_to_cpu(rp->rx_head_desc->rx_status));
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
 	for (count = 0; count < limit; ++count) {
@@ -1859,9 +1845,8 @@ static int rhine_rx(struct net_device *dev, int limit)
 		if (desc_status & DescOwn)
 			break;
 
-		if (debug > 4)
-			netdev_dbg(dev, "%s() status is %08x\n",
-				   __func__, desc_status);
+		netif_dbg(rp, rx_status, dev, "%s() status %08x\n", __func__,
+			  desc_status);
 
 		if ((desc_status & (RxWholePkt | RxErr)) != RxWholePkt) {
 			if ((desc_status & RxWholePkt) != RxWholePkt) {
@@ -1877,9 +1862,9 @@ static int rhine_rx(struct net_device *dev, int limit)
 				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
 				/* There was a error. */
-				if (debug > 2)
-					netdev_dbg(dev, "%s() Rx error was %08x\n",
-						   __func__, desc_status);
+				netif_dbg(rp, rx_err, dev,
+					  "%s() Rx error %08x\n", __func__,
+					  desc_status);
 				dev->stats.rx_errors++;
 				if (desc_status & 0x0030)
 					dev->stats.rx_length_errors++;
@@ -2000,9 +1985,8 @@ static void rhine_restart_tx(struct net_device *dev) {
 	}
 	else {
 		/* This should never happen */
-		if (debug > 1)
-			netdev_warn(dev, "%s() Another error occurred %08x\n",
-				   __func__, intr_status);
+		netif_warn(rp, tx_err, dev, "another error occurred %08x\n",
+			   intr_status);
 	}
 
 }
@@ -2025,6 +2009,9 @@ static void rhine_slow_event_task(struct work_struct *work)
 	if (intr_status & IntrLinkChange)
 		rhine_check_media(dev, 0);
 
+	if (intr_status & IntrPCIErr)
+		netif_warn(rp, hw, dev, "PCI error\n");
+
 	napi_disable(&rp->napi);
 	rhine_irq_disable(rp);
 	/* Slow and safe. Consider __napi_schedule as a replacement ? */
@@ -2144,12 +2131,16 @@ static u32 netdev_get_link(struct net_device *dev)
 
 static u32 netdev_get_msglevel(struct net_device *dev)
 {
-	return debug;
+	struct rhine_private *rp = netdev_priv(dev);
+
+	return rp->msg_enable;
 }
 
 static void netdev_set_msglevel(struct net_device *dev, u32 value)
 {
-	debug = value;
+	struct rhine_private *rp = netdev_priv(dev);
+
+	rp->msg_enable = value;
 }
 
 static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -2222,9 +2213,8 @@ static int rhine_close(struct net_device *dev)
 	napi_disable(&rp->napi);
 	netif_stop_queue(dev);
 
-	if (debug > 1)
-		netdev_dbg(dev, "Shutting down ethercard, status was %04x\n",
-			   ioread16(ioaddr + ChipCmd));
+	netif_dbg(rp, ifdown, dev, "Shutting down ethercard, status was %04x\n",
+		  ioread16(ioaddr + ChipCmd));
 
 	/* Switch to loopback mode to avoid hardware races. */
 	iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
@@ -2340,9 +2330,8 @@ static int rhine_resume(struct pci_dev *pdev)
 		return 0;
 
 	ret = pci_set_power_state(pdev, PCI_D0);
-	if (debug > 1)
-		netdev_info(dev, "Entering power state D0 %s (%d)\n",
-			    ret ? "failed" : "succeeded", ret);
+	netif_info(rp, drv, dev, "Entering power state D0 %s (%d)\n",
+		   ret ? "failed" : "succeeded", ret);
 
 	pci_restore_state(pdev);
 
-- 
1.7.6.4

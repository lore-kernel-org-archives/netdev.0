From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Thu, 29 Dec 2011 19:39:02 +0100
Message-ID: <20111229183902.GC21946@electric-eye.fr.zoreil.com>
References: <1325092423.2327.70.camel@deadeye> <CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com> <20111228101710.51c4893f@nehalam.linuxnetplumber.net> <20111228.133450.479385013770977594.davem@davemloft.net> <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com> <20111229153902.GB21946@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56298 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab1L2Srq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 13:47:46 -0500
Content-Disposition: inline
In-Reply-To: <20111229153902.GB21946@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Feel free to try the extra "new year's eve week end is getting closer"
> patch below (against net-next).
> 
> You have been warned.

The one below could be a bit better.

Out for dinner.

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5c4983b..66e5c08 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -42,7 +42,8 @@
 
 #define DEBUG
 static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
-static int max_interrupt_work = 20;
+#define RHINE_MSG_DEFAULT \
+        (NETIF_MSG_INTR)
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
@@ -128,11 +129,9 @@ MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 
-module_param(max_interrupt_work, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(avoid_D3, bool, 0);
-MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
@@ -351,16 +350,25 @@ static const int mmio_verify_registers[] = {
 
 /* Bits in the interrupt status/mask registers. */
 enum intr_status_bits {
-	IntrRxDone=0x0001, IntrRxErr=0x0004, IntrRxEmpty=0x0020,
-	IntrTxDone=0x0002, IntrTxError=0x0008, IntrTxUnderrun=0x0210,
-	IntrPCIErr=0x0040,
-	IntrStatsMax=0x0080, IntrRxEarly=0x0100,
-	IntrRxOverflow=0x0400, IntrRxDropped=0x0800, IntrRxNoBuf=0x1000,
-	IntrTxAborted=0x2000, IntrLinkChange=0x4000,
-	IntrRxWakeUp=0x8000,
-	IntrNormalSummary=0x0003, IntrAbnormalSummary=0xC260,
-	IntrTxDescRace=0x080000,	/* mapped from IntrStatus2 */
-	IntrTxErrSummary=0x082218,
+	IntrRxDone	= 0x0001,
+	IntrTxDone	= 0x0002,
+	IntrRxErr	= 0x0004,
+	IntrTxError	= 0x0008,
+	IntrRxEmpty	= 0x0020,
+	IntrPCIErr	= 0x0040,
+	IntrStatsMax	= 0x0080,
+	IntrRxEarly	= 0x0100,
+	IntrTxUnderrun	= 0x0210,
+	IntrRxOverflow	= 0x0400,
+	IntrRxDropped	= 0x0800,
+	IntrRxNoBuf	= 0x1000,
+	IntrTxAborted	= 0x2000,
+	IntrLinkChange	= 0x4000,
+	IntrRxWakeUp	= 0x8000,
+	IntrTxDescRace		= 0x080000,	/* mapped from IntrStatus2 */
+	IntrNormalSummary	= IntrRxDone | IntrTxDone,
+	IntrTxErrSummary	= IntrTxDescRace | IntrTxAborted | IntrTxError |
+				  IntrTxUnderrun,
 };
 
 /* Bits in WOLcrSet/WOLcrClr and PwrcsrSet/PwrcsrClr */
@@ -439,8 +447,12 @@ struct rhine_private {
 	struct net_device *dev;
 	struct napi_struct napi;
 	spinlock_t lock;
+	struct mutex task_lock;
+	struct work_struct slow_event_task;
 	struct work_struct reset_task;
 
+	u32 msg_enable;
+
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
 	struct rx_desc *rx_head_desc;
@@ -482,7 +494,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
 static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
-static void rhine_error(struct net_device *dev, int intr_status);
 static void rhine_set_rx_mode(struct net_device *dev);
 static struct net_device_stats *rhine_get_stats(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -497,6 +508,8 @@ static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask);
 static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
 static void rhine_init_cam_filter(struct net_device *dev);
 static void rhine_update_vcam(struct net_device *dev);
+static void rhine_slow_event_task(struct work_struct *work);
+static void rhine_restart_tx(struct net_device *dev);
 
 #define RHINE_WAIT_FOR(condition)				\
 do {								\
@@ -508,7 +521,7 @@ do {								\
 			1024 - i, __func__, __LINE__);		\
 } while (0)
 
-static inline u32 get_intr_status(struct net_device *dev)
+static u32 get_intr_status(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
@@ -521,6 +534,16 @@ static inline u32 get_intr_status(struct net_device *dev)
 	return intr_status;
 }
 
+static void rhine_ack_event(struct rhine_private *rp, u32 mask)
+{
+	void __iomem *ioaddr = rp->base;
+
+	if (rp->quirks & rqStatusWBRace)
+		iowrite8(mask >> 16, ioaddr + IntrStatus2);
+	iowrite16(mask, ioaddr + IntrStatus);
+	mmiowb();
+}
+
 /*
  * Get power related registers into sane state.
  * Notify user about past WOL event.
@@ -657,23 +680,127 @@ static void rhine_poll(struct net_device *dev)
 }
 #endif
 
+static void rhine_kick_tx_threshold(struct rhine_private *rp)
+{
+	if (rp->tx_thresh < 0xe0) {
+		void __iomem *ioaddr = rp->base;
+
+		rp->tx_thresh += 0x20;
+		BYTE_REG_BITS_SET(rp->tx_thresh, 0x80, ioaddr + TxConfig);
+	}
+}
+
+static void rhine_tx_err(struct rhine_private *rp, u32 status)
+{
+	struct net_device *dev = rp->dev;
+
+	if (status & IntrTxAborted) {
+		netif_info(rp, tx_err, dev,
+			   "Abort %08x, frame dropped\n", status);
+	}
+
+	if (status & IntrTxUnderrun) {
+		rhine_kick_tx_threshold(rp);
+		netif_info(rp, tx_err ,dev, "Transmitter underrun, "
+			   "Tx threshold now %02x\n", rp->tx_thresh);
+	}
+
+	if (status & IntrTxDescRace)
+		netif_info(rp, tx_err, dev, "Tx descriptor write-back race\n");
+
+	if ((status & IntrTxError) &&
+	    (status & (IntrTxAborted | IntrTxUnderrun | IntrTxDescRace)) == 0) {
+		rhine_kick_tx_threshold(rp);
+		netif_info(rp, tx_err, dev, "Unspecified error. "
+			   "Tx threshold now %02x\n", rp->tx_thresh);
+	}
+
+	rhine_restart_tx(dev);
+}
+
+static void rhine_update_rx_crc_and_missed_errord(struct rhine_private *rp)
+{
+	void __iomem *ioaddr = rp->base;
+	struct net_device_stats *stats = &rp->dev->stats;
+
+	stats->rx_crc_errors    += ioread16(ioaddr + RxCRCErrs);
+	stats->rx_missed_errors += ioread16(ioaddr + RxMissed);
+
+	/*
+	 * Clears the "tally counters" for CRC errors and missed frames(?).
+	 * It has been reported that some chips need a write of 0 to clear
+	 * these, for others the counters are set to 1 when written to and
+	 * instead cleared when read. So we clear them both ways ...
+	 */
+	iowrite32(0, ioaddr + RxMissed);
+	ioread16(ioaddr + RxCRCErrs);
+	ioread16(ioaddr + RxMissed);
+}
+
+#define RHINE_EVENT_NAPI_RX	(IntrRxDone | \
+				 IntrRxErr | \
+				 IntrRxEmpty | \
+				 IntrRxOverflow	| \
+				 IntrRxDropped | \
+				 IntrRxNoBuf | \
+				 IntrRxWakeUp)
+
+#define RHINE_EVENT_NAPI_TX_ERR	(IntrTxError | \
+				 IntrTxAborted | \
+				 IntrTxUnderrun | \
+				 IntrTxDescRace)
+#define RHINE_EVENT_NAPI_TX	(IntrTxDone | RHINE_EVENT_NAPI_TX_ERR)
+
+#define RHINE_EVENT_NAPI	(RHINE_EVENT_NAPI_RX | \
+				 RHINE_EVENT_NAPI_TX | \
+				 IntrStatsMax)
+#define RHINE_EVENT_SLOW	(IntrPCIErr | IntrLinkChange)
+#define RHINE_EVENT		(RHINE_EVENT_NAPI | RHINE_EVENT_SLOW)
+
 static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
 	struct rhine_private *rp = container_of(napi, struct rhine_private, napi);
 	struct net_device *dev = rp->dev;
 	void __iomem *ioaddr = rp->base;
-	int work_done;
+	u16 enable_mask = RHINE_EVENT & 0xffff;
+	int work_done = 0;
+	u32 status;
+
+	status = get_intr_status(dev);
+	rhine_ack_event(rp, status & ~RHINE_EVENT_SLOW);
+
+	if (status & RHINE_EVENT_NAPI_RX)
+		work_done += rhine_rx(dev, budget);
+
+	if (status & RHINE_EVENT_NAPI_TX) {
+		if (status & RHINE_EVENT_NAPI_TX_ERR) {
+			/* Avoid scavenging before Tx engine turned off */
+			RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipCmd) & CmdTxOn));
+			if (ioread8(ioaddr + ChipCmd) & CmdTxOn)
+				netif_warn(rp, tx_err, dev, "Tx still on\n");
+		}
 
-	work_done = rhine_rx(dev, budget);
+		rhine_tx(dev);
+
+		if (status & RHINE_EVENT_NAPI_TX_ERR)
+			rhine_tx_err(rp, status);
+	}
+
+	if (status & IntrStatsMax) {
+		spin_lock(&rp->lock);
+		rhine_update_rx_crc_and_missed_errord(rp);
+		spin_unlock(&rp->lock);
+	}
+
+	if (status & RHINE_EVENT_SLOW) {
+		enable_mask &= ~RHINE_EVENT_SLOW;
+		schedule_work(&rp->slow_event_task);
+	}
 
 	if (work_done < budget) {
 		napi_complete(napi);
-
-		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
-			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
-			  IntrTxDone | IntrTxError | IntrTxUnderrun |
-			  IntrPCIErr | IntrStatsMax | IntrLinkChange,
-			  ioaddr + IntrEnable);
+		iowrite16(enable_mask, ioaddr + IntrEnable);
+		mmiowb();
 	}
 	return work_done;
 }
@@ -797,6 +924,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
+	rp->msg_enable = netif_msg_init(-1, RHINE_MSG_DEFAULT);
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
@@ -856,7 +984,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	mutex_init(&rp->task_lock);
 	INIT_WORK(&rp->reset_task, rhine_reset_task);
+	INIT_WORK(&rp->slow_event_task, rhine_slow_event_task);
 
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
@@ -1310,12 +1440,7 @@ static void init_registers(struct net_device *dev)
 
 	napi_enable(&rp->napi);
 
-	/* Enable interrupts by setting the interrupt mask. */
-	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
-	       IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
-	       IntrTxDone | IntrTxError | IntrTxUnderrun |
-	       IntrPCIErr | IntrStatsMax | IntrLinkChange,
-	       ioaddr + IntrEnable);
+	iowrite16(RHINE_EVENT & 0xffff, ioaddr + IntrEnable);
 
 	iowrite16(CmdStart | CmdTxOn | CmdRxOn | (Cmd1NoTxPoll << 8),
 	       ioaddr + ChipCmd);
@@ -1434,13 +1559,10 @@ static void rhine_reset_task(struct work_struct *work)
 						reset_task);
 	struct net_device *dev = rp->dev;
 
-	/* protect against concurrent rx interrupts */
-	disable_irq(rp->pdev->irq);
+	mutex_lock(&rp->task_lock);
 
 	napi_disable(&rp->napi);
 
-	spin_lock_bh(&rp->lock);
-
 	/* clear all descriptors */
 	free_tbufs(dev);
 	free_rbufs(dev);
@@ -1451,12 +1573,11 @@ static void rhine_reset_task(struct work_struct *work)
 	rhine_chip_reset(dev);
 	init_registers(dev);
 
-	spin_unlock_bh(&rp->lock);
-	enable_irq(rp->pdev->irq);
-
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
+
+	mutex_unlock(&rp->task_lock);
 }
 
 static void rhine_tx_timeout(struct net_device *dev)
@@ -1477,7 +1598,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
-	unsigned long flags;
 
 	/* Caution: the write order is important here, set the field
 	   with the "ownership" bits last. */
@@ -1529,7 +1649,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		rp->tx_ring[entry].tx_status = 0;
 
 	/* lock eth irq */
-	spin_lock_irqsave(&rp->lock, flags);
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
@@ -1543,15 +1662,12 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		BYTE_REG_BITS_ON(1 << 7, ioaddr + TQWake);
 
 	/* Wake the potentially-idle transmit channel */
-	iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
-	       ioaddr + ChipCmd1);
+	iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand, ioaddr + ChipCmd1);
 	IOSYNC;
 
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
 		netif_stop_queue(dev);
 
-	spin_unlock_irqrestore(&rp->lock, flags);
-
 	if (debug > 4) {
 		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
 			   rp->cur_tx-1, entry);
@@ -1565,63 +1681,26 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
-	u32 intr_status;
-	int boguscnt = max_interrupt_work;
+	u32 status;
 	int handled = 0;
 
-	while ((intr_status = get_intr_status(dev))) {
-		handled = 1;
-
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		if (intr_status & IntrTxDescRace)
-			iowrite8(0x08, ioaddr + IntrStatus2);
-		iowrite16(intr_status & 0xffff, ioaddr + IntrStatus);
-		IOSYNC;
-
-		if (debug > 4)
-			netdev_dbg(dev, "Interrupt, status %08x\n",
-				   intr_status);
-
-		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
-				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
-			iowrite16(IntrTxAborted |
-				  IntrTxDone | IntrTxError | IntrTxUnderrun |
-				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
-				  ioaddr + IntrEnable);
+	status = get_intr_status(dev);
 
-			napi_schedule(&rp->napi);
-		}
+	netif_dbg(rp, intr, dev, "Interrupt, status %08x\n", status);
 
-		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
-			if (intr_status & IntrTxErrSummary) {
-				/* Avoid scavenging before Tx engine turned off */
-				RHINE_WAIT_FOR(!(ioread8(ioaddr+ChipCmd) & CmdTxOn));
-				if (debug > 2 &&
-				    ioread8(ioaddr+ChipCmd) & CmdTxOn)
-					netdev_warn(dev,
-						    "%s: Tx engine still on\n",
-						    __func__);
-			}
-			rhine_tx(dev);
-		}
+	if (status & RHINE_EVENT) {
+		handled = 1;
 
-		/* Abnormal error summary/uncommon events handlers. */
-		if (intr_status & (IntrPCIErr | IntrLinkChange |
-				   IntrStatsMax | IntrTxError | IntrTxAborted |
-				   IntrTxUnderrun | IntrTxDescRace))
-			rhine_error(dev, intr_status);
+		iowrite16(0x0000, rp->base + IntrEnable);
+		mmiowb();
+		napi_schedule(&rp->napi);
+	}
 
-		if (--boguscnt < 0) {
-			netdev_warn(dev, "Too much work at interrupt, status=%#08x\n",
-				    intr_status);
-			break;
-		}
+	if (status & ~(IntrLinkChange | IntrStatsMax | RHINE_EVENT_NAPI)) {
+		netif_err(rp, intr, dev, "Something Wicked happened! %08x\n",
+			  status);
 	}
 
-	if (debug > 3)
-		netdev_dbg(dev, "exiting interrupt, status=%08x\n",
-			   ioread16(ioaddr + IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -1632,8 +1711,6 @@ static void rhine_tx(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 
-	spin_lock(&rp->lock);
-
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
 		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
@@ -1687,8 +1764,6 @@ static void rhine_tx(struct net_device *dev)
 	}
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
-
-	spin_unlock(&rp->lock);
 }
 
 /**
@@ -1839,20 +1914,8 @@ static int rhine_rx(struct net_device *dev, int limit)
 	return count;
 }
 
-/*
- * Clears the "tally counters" for CRC errors and missed frames(?).
- * It has been reported that some chips need a write of 0 to clear
- * these, for others the counters are set to 1 when written to and
- * instead cleared when read. So we clear them both ways ...
- */
-static inline void clear_tally_counters(void __iomem *ioaddr)
+static void rhine_restart_tx(struct net_device *dev)
 {
-	iowrite32(0, ioaddr + RxMissed);
-	ioread16(ioaddr + RxCRCErrs);
-	ioread16(ioaddr + RxMissed);
-}
-
-static void rhine_restart_tx(struct net_device *dev) {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	int entry = rp->dirty_tx % TX_RING_SIZE;
@@ -1880,8 +1943,7 @@ static void rhine_restart_tx(struct net_device *dev) {
 		iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
 		       ioaddr + ChipCmd1);
 		IOSYNC;
-	}
-	else {
+	} else {
 		/* This should never happen */
 		if (debug > 1)
 			netdev_warn(dev, "%s() Another error occurred %08x\n",
@@ -1890,72 +1952,46 @@ static void rhine_restart_tx(struct net_device *dev) {
 
 }
 
-static void rhine_error(struct net_device *dev, int intr_status)
+static void rhine_slow_event_task(struct work_struct *work)
 {
-	struct rhine_private *rp = netdev_priv(dev);
+	struct rhine_private *rp =
+		container_of(work, struct rhine_private, slow_event_task);
+	struct net_device *dev = rp->dev;
 	void __iomem *ioaddr = rp->base;
+	u32 intr_status;
 
-	spin_lock(&rp->lock);
+	if (!netif_running(dev))
+		return;
+
+	mutex_lock(&rp->task_lock);
+
+	intr_status = get_intr_status(dev);
+	rhine_ack_event(rp, intr_status & RHINE_EVENT_SLOW);
 
 	if (intr_status & IntrLinkChange)
 		rhine_check_media(dev, 0);
-	if (intr_status & IntrStatsMax) {
-		dev->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
-		dev->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
-		clear_tally_counters(ioaddr);
-	}
-	if (intr_status & IntrTxAborted) {
-		if (debug > 1)
-			netdev_info(dev, "Abort %08x, frame dropped\n",
-				    intr_status);
-	}
-	if (intr_status & IntrTxUnderrun) {
-		if (rp->tx_thresh < 0xE0)
-			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
-		if (debug > 1)
-			netdev_info(dev, "Transmitter underrun, Tx threshold now %02x\n",
-				    rp->tx_thresh);
-	}
-	if (intr_status & IntrTxDescRace) {
-		if (debug > 2)
-			netdev_info(dev, "Tx descriptor write-back race\n");
-	}
-	if ((intr_status & IntrTxError) &&
-	    (intr_status & (IntrTxAborted |
-	     IntrTxUnderrun | IntrTxDescRace)) == 0) {
-		if (rp->tx_thresh < 0xE0) {
-			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
-		}
-		if (debug > 1)
-			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
-				    rp->tx_thresh);
-	}
-	if (intr_status & (IntrTxAborted | IntrTxUnderrun | IntrTxDescRace |
-			   IntrTxError))
-		rhine_restart_tx(dev);
 
-	if (intr_status & ~(IntrLinkChange | IntrStatsMax | IntrTxUnderrun |
-			    IntrTxError | IntrTxAborted | IntrNormalSummary |
-			    IntrTxDescRace)) {
-		if (debug > 1)
-			netdev_err(dev, "Something Wicked happened! %08x\n",
-				   intr_status);
-	}
+	/* FIXME: ignore ? */
+	if (intr_status & IntrPCIErr)
+		netif_warn(rp, hw, dev, "PCI error\n");
 
-	spin_unlock(&rp->lock);
+	napi_disable(&rp->napi);
+	iowrite16(0x0000, ioaddr + IntrEnable);
+	mmiowb();
+	/* Slow and safe. Consider __napi_schedule as a replacement ? */
+	napi_enable(&rp->napi);
+	napi_schedule(&rp->napi);
+
+	mutex_unlock(&rp->task_lock);
 }
 
 static struct net_device_stats *rhine_get_stats(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
-	unsigned long flags;
 
-	spin_lock_irqsave(&rp->lock, flags);
-	dev->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
-	dev->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
-	clear_tally_counters(ioaddr);
-	spin_unlock_irqrestore(&rp->lock, flags);
+	spin_lock_bh(&rp->lock);
+	rhine_update_rx_crc_and_missed_errord(rp);
+	spin_unlock_bh(&rp->lock);
 
 	return &dev->stats;
 }
@@ -2022,9 +2058,9 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	spin_lock_irq(&rp->lock);
+	mutex_lock(&rp->task_lock);
 	rc = mii_ethtool_gset(&rp->mii_if, cmd);
-	spin_unlock_irq(&rp->lock);
+	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
@@ -2034,10 +2070,10 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	spin_lock_irq(&rp->lock);
+	mutex_lock(&rp->task_lock);
 	rc = mii_ethtool_sset(&rp->mii_if, cmd);
-	spin_unlock_irq(&rp->lock);
 	rhine_set_carrier(&rp->mii_if);
+	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
@@ -2073,6 +2109,7 @@ static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (!(rp->quirks & rqWOL))
 		return;
 
+	/* FIXME: huh ? */
 	spin_lock_irq(&rp->lock);
 	wol->supported = WAKE_PHY | WAKE_MAGIC |
 			 WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
@@ -2092,6 +2129,7 @@ static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~support)
 		return -EINVAL;
 
+	/* FIXME: huh (sic) ? */
 	spin_lock_irq(&rp->lock);
 	rp->wolopts = wol->wolopts;
 	spin_unlock_irq(&rp->lock);
@@ -2119,10 +2157,10 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irq(&rp->lock);
+	mutex_lock(&rp->task_lock);
 	rc = generic_mii_ioctl(&rp->mii_if, if_mii(rq), cmd, NULL);
-	spin_unlock_irq(&rp->lock);
 	rhine_set_carrier(&rp->mii_if);
+	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
@@ -2133,11 +2171,10 @@ static int rhine_close(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 
 	napi_disable(&rp->napi);
+	cancel_work_sync(&rp->slow_event_task);
 	cancel_work_sync(&rp->reset_task);
 	netif_stop_queue(dev);
 
-	spin_lock_irq(&rp->lock);
-
 	if (debug > 1)
 		netdev_dbg(dev, "Shutting down ethercard, status was %04x\n",
 			   ioread16(ioaddr + ChipCmd));
@@ -2151,8 +2188,6 @@ static int rhine_close(struct net_device *dev)
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(CmdStop, ioaddr + ChipCmd);
 
-	spin_unlock_irq(&rp->lock);
-
 	free_irq(rp->pdev->irq, dev);
 	free_rbufs(dev);
 	free_tbufs(dev);
@@ -2239,10 +2274,12 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 	pci_save_state(pdev);
 
+	/* FIXME: ? */
 	spin_lock_irqsave(&rp->lock, flags);
 	rhine_shutdown(pdev);
 	spin_unlock_irqrestore(&rp->lock, flags);
 
+	/* FIXME: nuclear workaround ? Check the commit log. */
 	free_irq(dev->irq, dev);
 	return 0;
 }
@@ -2257,6 +2294,7 @@ static int rhine_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		return 0;
 
+	/* FIXME: see above. */
 	if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
 		netdev_err(dev, "request_irq failed\n");
 

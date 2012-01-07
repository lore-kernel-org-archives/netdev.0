From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/7] via-rhine: move work from irq handler to softirq and beyond.
Date: Sat, 7 Jan 2012 23:51:23 +0100
Message-ID: <20120107225123.GD25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50375 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab2AGXAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:00:45 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Tx processing is moved from the irq handler to NAPI poll
- link events and obscure event processing is moved to its proper work queue

Locking rules undergo some changes through the driver.

- the driver offers the usual lock-free Tx path
- besides the IRQ handler, the link event task schedules the napi handler.
  The driver thus adds some internal locking to prevent a loop when both
  must be disabled.
- the reset task keeps being scheduled from the Tx watchdog handler, thus
  with implicit Tx queue disabling. It does not need to care about irq,
  only napi softirq and competing task.
- it is not worth to add a dedicated lock between {g, s}et_wol and
  rhine_shutdown. It should not hurt no narrow it down a bit though.
- rhine_reset_task must keep its huge spin_lock_bh protected section due
  to :
  - races for the CAM registers (see rhine_vlan_rx_{add, kill}_vid)
  - implicit use of napi_enable (see init_registers)
  - use of the same lock for stats read / update exclusion between
    napi rx processing and rhine_get_stats
- rhine_resume requires a softirq disabled section for the same reason
  as rhine_reset_task
- {free, request}_irq have been replaced with IntrEnable actions in
  rhine_{suspend, resume}. It is hidden behind init_registers for the
  latter.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |  402 +++++++++++++++++++---------------
 1 files changed, 225 insertions(+), 177 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index d17ca32..9a7bacc 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -42,7 +42,6 @@
 
 #define DEBUG
 static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
-static int max_interrupt_work = 20;
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
@@ -128,11 +127,9 @@ MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
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
@@ -351,16 +348,25 @@ static const int mmio_verify_registers[] = {
 
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
@@ -439,6 +445,9 @@ struct rhine_private {
 	struct net_device *dev;
 	struct napi_struct napi;
 	spinlock_t lock;
+	struct mutex task_lock;
+	bool task_enable;
+	struct work_struct slow_event_task;
 	struct work_struct reset_task;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
@@ -476,13 +485,13 @@ static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
 static void rhine_reset_task(struct work_struct *work);
+static void rhine_slow_event_task(struct work_struct *work);
 static void rhine_tx_timeout(struct net_device *dev);
 static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 				  struct net_device *dev);
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
 static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
-static void rhine_error(struct net_device *dev, int intr_status);
 static void rhine_set_rx_mode(struct net_device *dev);
 static struct net_device_stats *rhine_get_stats(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -490,6 +499,7 @@ static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
 static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
+static void rhine_restart_tx(struct net_device *dev);
 
 #define RHINE_WAIT_FOR(condition)				\
 do {								\
@@ -520,7 +530,7 @@ static void rhine_ack_events(struct rhine_private *rp, u32 mask)
 	if (rp->quirks & rqStatusWBRace)
 		iowrite8(mask >> 16, ioaddr + IntrStatus2);
 	iowrite16(mask, ioaddr + IntrStatus);
-	IOSYNC;
+	mmiowb();
 }
 
 /*
@@ -669,23 +679,125 @@ static void rhine_kick_tx_threshold(struct rhine_private *rp)
 	}
 }
 
+static void rhine_tx_err(struct rhine_private *rp, u32 status)
+{
+	struct net_device *dev = rp->dev;
+
+	if (status & IntrTxAborted) {
+		if (debug > 1)
+			netdev_info(dev, "Abort %08x, frame dropped\n", status);
+	}
+
+	if (status & IntrTxUnderrun) {
+		rhine_kick_tx_threshold(rp);
+		if (debug > 1)
+			netdev_info(dev, "Transmitter underrun, Tx threshold now %02x\n",
+				    rp->tx_thresh);
+	}
+
+	if (status & IntrTxDescRace) {
+		if (debug > 2)
+			netdev_info(dev, "Tx descriptor write-back race\n");
+	}
+
+	if ((status & IntrTxError) &&
+	    (status & (IntrTxAborted | IntrTxUnderrun | IntrTxDescRace)) == 0) {
+		rhine_kick_tx_threshold(rp);
+		if (debug > 1)
+			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
+				    rp->tx_thresh);
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
+	status = rhine_get_events(rp);
+	rhine_ack_events(rp, status & ~RHINE_EVENT_SLOW);
+
+	if (status & RHINE_EVENT_NAPI_RX)
+		work_done += rhine_rx(dev, budget);
+
+	if (status & RHINE_EVENT_NAPI_TX) {
+		if (status & RHINE_EVENT_NAPI_TX_ERR) {
+			u8 cmd;
+
+			/* Avoid scavenging before Tx engine turned off */
+			RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipCmd) & CmdTxOn));
+			cmd = ioread8(ioaddr + ChipCmd);
+			if ((cmd & CmdTxOn) && (debug > 2)) {
+				netdev_warn(dev, "%s: Tx engine still on\n",
+					    __func__);
+			}
+		}
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
 
-	work_done = rhine_rx(dev, budget);
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
@@ -868,7 +980,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	mutex_init(&rp->task_lock);
 	INIT_WORK(&rp->reset_task, rhine_reset_task);
+	INIT_WORK(&rp->slow_event_task, rhine_slow_event_task);
 
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
@@ -1278,10 +1392,10 @@ static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	spin_lock_irq(&rp->lock);
+	spin_lock_bh(&rp->lock);
 	set_bit(vid, rp->active_vlans);
 	rhine_update_vcam(dev);
-	spin_unlock_irq(&rp->lock);
+	spin_unlock_bh(&rp->lock);
 	return 0;
 }
 
@@ -1289,10 +1403,10 @@ static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	spin_lock_irq(&rp->lock);
+	spin_lock_bh(&rp->lock);
 	clear_bit(vid, rp->active_vlans);
 	rhine_update_vcam(dev);
-	spin_unlock_irq(&rp->lock);
+	spin_unlock_bh(&rp->lock);
 	return 0;
 }
 
@@ -1322,12 +1436,7 @@ static void init_registers(struct net_device *dev)
 
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
@@ -1407,6 +1516,23 @@ static void mdio_write(struct net_device *dev, int phy_id, int regnum, int value
 	rhine_enable_linkmon(ioaddr);
 }
 
+static void rhine_task_disable(struct rhine_private *rp)
+{
+	mutex_lock(&rp->task_lock);
+	rp->task_enable = false;
+	mutex_unlock(&rp->task_lock);
+
+	cancel_work_sync(&rp->slow_event_task);
+	cancel_work_sync(&rp->reset_task);
+}
+
+static void rhine_task_enable(struct rhine_private *rp)
+{
+	mutex_lock(&rp->task_lock);
+	rp->task_enable = true;
+	mutex_unlock(&rp->task_lock);
+}
+
 static int rhine_open(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1429,6 +1555,7 @@ static int rhine_open(struct net_device *dev)
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
+	rhine_task_enable(rp);
 	init_registers(dev);
 	if (debug > 2)
 		netdev_dbg(dev, "%s() Done - status %04x MII status: %04x\n",
@@ -1446,11 +1573,12 @@ static void rhine_reset_task(struct work_struct *work)
 						reset_task);
 	struct net_device *dev = rp->dev;
 
-	/* protect against concurrent rx interrupts */
-	disable_irq(rp->pdev->irq);
+	mutex_lock(&rp->task_lock);
 
-	napi_disable(&rp->napi);
+	if (!rp->task_enable)
+		goto out_unlock;
 
+	napi_disable(&rp->napi);
 	spin_lock_bh(&rp->lock);
 
 	/* clear all descriptors */
@@ -1464,11 +1592,13 @@ static void rhine_reset_task(struct work_struct *work)
 	init_registers(dev);
 
 	spin_unlock_bh(&rp->lock);
-	enable_irq(rp->pdev->irq);
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
+
+out_unlock:
+	mutex_unlock(&rp->task_lock);
 }
 
 static void rhine_tx_timeout(struct net_device *dev)
@@ -1489,7 +1619,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
-	unsigned long flags;
 
 	/* Caution: the write order is important here, set the field
 	   with the "ownership" bits last. */
@@ -1541,7 +1670,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		rp->tx_ring[entry].tx_status = 0;
 
 	/* lock eth irq */
-	spin_lock_irqsave(&rp->lock, flags);
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
@@ -1562,8 +1690,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
 		netif_stop_queue(dev);
 
-	spin_unlock_irqrestore(&rp->lock, flags);
-
 	if (debug > 4) {
 		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
 			   rp->cur_tx-1, entry);
@@ -1571,66 +1697,39 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static void rhine_irq_disable(struct rhine_private *rp)
+{
+	iowrite16(0x0000, rp->base + IntrEnable);
+	mmiowb();
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
-	u32 intr_status;
-	int boguscnt = max_interrupt_work;
+	u32 status;
 	int handled = 0;
 
-	while ((intr_status = rhine_get_events(rp))) {
-		handled = 1;
-
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		rhine_ack_events(rp, intr_status);
-
-		if (debug > 4)
-			netdev_dbg(dev, "Interrupt, status %08x\n",
-				   intr_status);
+	status = rhine_get_events(rp);
 
-		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
-				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
-			iowrite16(IntrTxAborted |
-				  IntrTxDone | IntrTxError | IntrTxUnderrun |
-				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
-				  ioaddr + IntrEnable);
+	if (debug > 4)
+		netdev_dbg(dev, "Interrupt, status %08x\n", status);
 
-			napi_schedule(&rp->napi);
-		}
-
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
+		rhine_irq_disable(rp);
+		napi_schedule(&rp->napi);
+	}
 
-		if (--boguscnt < 0) {
-			netdev_warn(dev, "Too much work at interrupt, status=%#08x\n",
-				    intr_status);
-			break;
-		}
+	if (status & ~(IntrLinkChange | IntrStatsMax | RHINE_EVENT_NAPI)) {
+		if (debug > 1)
+			netdev_err(dev, "Something Wicked happened! %08x\n",
+				   status);
 	}
 
-	if (debug > 3)
-		netdev_dbg(dev, "exiting interrupt, status=%08x\n",
-			   ioread16(ioaddr + IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -1641,8 +1740,6 @@ static void rhine_tx(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 
-	spin_lock(&rp->lock);
-
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
 		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
@@ -1696,8 +1793,6 @@ static void rhine_tx(struct net_device *dev)
 	}
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
-
-	spin_unlock(&rp->lock);
 }
 
 /**
@@ -1848,19 +1943,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 	return count;
 }
 
-/*
- * Clears the "tally counters" for CRC errors and missed frames(?).
- * It has been reported that some chips need a write of 0 to clear
- * these, for others the counters are set to 1 when written to and
- * instead cleared when read. So we clear them both ways ...
- */
-static inline void clear_tally_counters(void __iomem *ioaddr)
-{
-	iowrite32(0, ioaddr + RxMissed);
-	ioread16(ioaddr + RxCRCErrs);
-	ioread16(ioaddr + RxMissed);
-}
-
 static void rhine_restart_tx(struct net_device *dev) {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
@@ -1899,69 +1981,41 @@ static void rhine_restart_tx(struct net_device *dev) {
 
 }
 
-static void rhine_error(struct net_device *dev, int intr_status)
+static void rhine_slow_event_task(struct work_struct *work)
 {
-	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
+	struct rhine_private *rp =
+		container_of(work, struct rhine_private, slow_event_task);
+	struct net_device *dev = rp->dev;
+	u32 intr_status;
 
-	spin_lock(&rp->lock);
+	mutex_lock(&rp->task_lock);
+
+	if (!rp->task_enable)
+		goto out_unlock;
+
+	intr_status = rhine_get_events(rp);
+	rhine_ack_events(rp, intr_status & RHINE_EVENT_SLOW);
 
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
-		rhine_kick_tx_threshold(rp);
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
-		rhine_kick_tx_threshold(rp);
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
+	napi_disable(&rp->napi);
+	rhine_irq_disable(rp);
+	/* Slow and safe. Consider __napi_schedule as a replacement ? */
+	napi_enable(&rp->napi);
+	napi_schedule(&rp->napi);
 
-	spin_unlock(&rp->lock);
+out_unlock:
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
@@ -2028,9 +2082,9 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	spin_lock_irq(&rp->lock);
+	mutex_lock(&rp->task_lock);
 	rc = mii_ethtool_gset(&rp->mii_if, cmd);
-	spin_unlock_irq(&rp->lock);
+	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
@@ -2040,10 +2094,10 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
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
@@ -2125,10 +2179,10 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -2138,12 +2192,10 @@ static int rhine_close(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
+	rhine_task_disable(rp);
 	napi_disable(&rp->napi);
-	cancel_work_sync(&rp->reset_task);
 	netif_stop_queue(dev);
 
-	spin_lock_irq(&rp->lock);
-
 	if (debug > 1)
 		netdev_dbg(dev, "Shutting down ethercard, status was %04x\n",
 			   ioread16(ioaddr + ChipCmd));
@@ -2151,14 +2203,11 @@ static int rhine_close(struct net_device *dev)
 	/* Switch to loopback mode to avoid hardware races. */
 	iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
 
-	/* Disable interrupts by clearing the interrupt mask. */
-	iowrite16(0x0000, ioaddr + IntrEnable);
+	rhine_irq_disable(rp);
 
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(CmdStop, ioaddr + ChipCmd);
 
-	spin_unlock_irq(&rp->lock);
-
 	free_irq(rp->pdev->irq, dev);
 	free_rbufs(dev);
 	free_tbufs(dev);
@@ -2198,6 +2247,8 @@ static void rhine_shutdown (struct pci_dev *pdev)
 	if (rp->quirks & rq6patterns)
 		iowrite8(0x04, ioaddr + WOLcgClr);
 
+	spin_lock(&rp->lock);
+
 	if (rp->wolopts & WAKE_MAGIC) {
 		iowrite8(WOLmagic, ioaddr + WOLcrSet);
 		/*
@@ -2222,6 +2273,8 @@ static void rhine_shutdown (struct pci_dev *pdev)
 		iowrite8(ioread8(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
 	}
 
+	spin_unlock(&rp->lock);
+
 	/* Hit power state D3 (sleep) */
 	if (!avoid_D3)
 		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
@@ -2235,21 +2288,19 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
-	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
 
+	rhine_task_disable(rp);
+	rhine_irq_disable(rp);
 	napi_disable(&rp->napi);
 
 	netif_device_detach(dev);
 	pci_save_state(pdev);
 
-	spin_lock_irqsave(&rp->lock, flags);
 	rhine_shutdown(pdev);
-	spin_unlock_irqrestore(&rp->lock, flags);
 
-	free_irq(dev->irq, dev);
 	return 0;
 }
 
@@ -2257,15 +2308,11 @@ static int rhine_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
-	unsigned long flags;
 	int ret;
 
 	if (!netif_running(dev))
 		return 0;
 
-	if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
-		netdev_err(dev, "request_irq failed\n");
-
 	ret = pci_set_power_state(pdev, PCI_D0);
 	if (debug > 1)
 		netdev_info(dev, "Entering power state D0 %s (%d)\n",
@@ -2273,7 +2320,6 @@ static int rhine_resume(struct pci_dev *pdev)
 
 	pci_restore_state(pdev);
 
-	spin_lock_irqsave(&rp->lock, flags);
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 #endif
@@ -2282,8 +2328,10 @@ static int rhine_resume(struct pci_dev *pdev)
 	free_rbufs(dev);
 	alloc_tbufs(dev);
 	alloc_rbufs(dev);
+	rhine_task_enable(rp);
+	spin_lock_bh(&rp->lock);
 	init_registers(dev);
-	spin_unlock_irqrestore(&rp->lock, flags);
+	spin_unlock_bh(&rp->lock);
 
 	netif_device_attach(dev);
 
-- 
1.7.6.4

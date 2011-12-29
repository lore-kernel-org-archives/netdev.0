From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Thu, 29 Dec 2011 16:39:02 +0100
Message-ID: <20111229153902.GB21946@electric-eye.fr.zoreil.com>
References: <1325092423.2327.70.camel@deadeye> <CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com> <20111228101710.51c4893f@nehalam.linuxnetplumber.net> <20111228.133450.479385013770977594.davem@davemloft.net> <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> 2011/12/28 David Miller <davem@davemloft.net>:
[...]
> > This "shut off only some interrupts" scheme is just asking for trouble.
> 
> I agree, it's an ugly hack :)
> 
> Is there some way I can help with this, without having to touch the
> code? (C isn't my strong language, especially not kernel mode code) :)

Feel free to try the extra "new year's eve week end is getting closer"
patch below (against net-next).

You have been warned.

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5c4983b..6350a2c 100644
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
@@ -657,23 +680,62 @@ static void rhine_poll(struct net_device *dev)
 }
 #endif
 
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
+#define RHINE_EVENT_NAPI	(RHINE_EVENT_NAPI_RX | RHINE_EVENT_NAPI_TX)
+#define RHINE_EVENT_SLOW	(IntrPCIErr | IntrStatsMax | IntrLinkChange)
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
+
+		rhine_tx(dev);
+
+		if (status & RHINE_EVENT_NAPI_TX_ERR)
+			rhine_restart_tx(dev);
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
@@ -797,6 +859,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
+	rp->msg_enable = netif_msg_init(-1, RHINE_MSG_DEFAULT);
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
@@ -856,7 +919,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	mutex_init(&rp->task_lock);
 	INIT_WORK(&rp->reset_task, rhine_reset_task);
+	INIT_WORK(&rp->slow_event_task, rhine_slow_event_task);
 
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
@@ -1310,12 +1375,7 @@ static void init_registers(struct net_device *dev)
 
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
@@ -1434,8 +1494,7 @@ static void rhine_reset_task(struct work_struct *work)
 						reset_task);
 	struct net_device *dev = rp->dev;
 
-	/* protect against concurrent rx interrupts */
-	disable_irq(rp->pdev->irq);
+	mutex_lock(&rp->task_lock);
 
 	napi_disable(&rp->napi);
 
@@ -1452,7 +1511,8 @@ static void rhine_reset_task(struct work_struct *work)
 	init_registers(dev);
 
 	spin_unlock_bh(&rp->lock);
-	enable_irq(rp->pdev->irq);
+
+	mutex_unlock(&rp->task_lock);
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
@@ -1565,63 +1625,26 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
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
+	status = get_intr_status(dev);
 
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
-
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
 
@@ -1632,8 +1655,6 @@ static void rhine_tx(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 
-	spin_lock(&rp->lock);
-
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
 		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
@@ -1687,8 +1708,6 @@ static void rhine_tx(struct net_device *dev)
 	}
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
-
-	spin_unlock(&rp->lock);
 }
 
 /**
@@ -1852,7 +1871,8 @@ static inline void clear_tally_counters(void __iomem *ioaddr)
 	ioread16(ioaddr + RxMissed);
 }
 
-static void rhine_restart_tx(struct net_device *dev) {
+static void rhine_restart_tx(struct net_device *dev)
+{
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	int entry = rp->dirty_tx % TX_RING_SIZE;
@@ -1880,8 +1900,7 @@ static void rhine_restart_tx(struct net_device *dev) {
 		iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
 		       ioaddr + ChipCmd1);
 		IOSYNC;
-	}
-	else {
+	} else {
 		/* This should never happen */
 		if (debug > 1)
 			netdev_warn(dev, "%s() Another error occurred %08x\n",
@@ -1890,15 +1909,25 @@ static void rhine_restart_tx(struct net_device *dev) {
 
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
+
 	if (intr_status & IntrStatsMax) {
 		dev->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
 		dev->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
@@ -1930,19 +1959,15 @@ static void rhine_error(struct net_device *dev, int intr_status)
 			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
 				    rp->tx_thresh);
 	}
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
+	iowrite16(0x0000, ioaddr + IntrEnable);
+	mmiowb();
+	/* Slow and safe. Consider __napi_schedule as a replacement ? */
+	napi_enable(&rp->napi);
+	napi_schedule(&rp->napi);
 
-	spin_unlock(&rp->lock);
+	mutex_unlock(&rp->task_lock);
 }
 
 static struct net_device_stats *rhine_get_stats(struct net_device *dev)
@@ -2133,6 +2158,7 @@ static int rhine_close(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 
 	napi_disable(&rp->napi);
+	cancel_work_sync(&rp->slow_event_task);
 	cancel_work_sync(&rp->reset_task);
 	netif_stop_queue(dev);
 

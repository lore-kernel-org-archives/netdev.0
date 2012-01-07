From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/7] via-rhine NAPI rework and misc.
Date: Sat, 7 Jan 2012 23:48:57 +0100
Message-ID: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58925 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab2AGW6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 17:58:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have reworked the series since the last submission so as to limit
unneeded changes before the move of work from IRQ context to NAPI
and work queue.  Those changes were mostly related to debug messages.
They are now done later in the the series. I have included a few
resume + suspend changes as well. Unbalanced task disabling should
now be fixed. Newly introduced methods have been set so as to
limit useless forward declarations.

I am very confident that everything works fine and it is fairly well
known that my patches always reach perfection, especially on week end
when I'd better go downtown to avoid the noise of those pesky young
neighbors. I have however not included Bjarke's Tested-by since the
content is not strictly identical. I'll gladly do so for #1..#4 if
everything is ok.

The changes are equally available as :

git://violet.fr.zoreil.com/romieu/linux davem-next.via-rhine

Distance from 'davem-next' (356b95424cfb456e14a59eaa579422ce014c424b)
---------------------------------------------------------------------

e92b9b3b091d5fcdaed91d6fa9410deae135704b
fc3e0f8aec05dd812cba2c1e31c3d1f5fc85e55c
a384a33bb1c9ec2d99db2046b41f57023fa7d77b
7ab87ff4c770eed71e3777936299292739fcd0fe
a5abec1e84c3d9cd197667e5fa94f25c21a2cb8e
a20a28bc321fefcc23f8da7ce3722e6ae7a7199d
269f3114b53a3ce93eb5977852ac2624a380f600

Diffstat
--------

 drivers/net/ethernet/via/via-rhine.c |  668 +++++++++++++++++++---------------
 1 files changed, 368 insertions(+), 300 deletions(-)

Shortlog
--------

Francois Romieu (7):
      via-rhine: factor out tx_thresh handling
      via-rhine: balance interrupt acknowledge and events retrieval.
      via-rhine: remove useless forward declarations.
      via-rhine: move work from irq handler to softirq and beyond.
      via-rhine: RHINE_WAIT_FOR macro removal.
      via-rhine: per device debug level.
      via-rhine: rework suspend and resume.

Patch
-----

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5c4983b..10b18eb 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -39,10 +39,9 @@
 
 /* A few user-configurable values.
    These may be modified when a driver module is loaded. */
-
-#define DEBUG
-static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
-static int max_interrupt_work = 20;
+static int debug = 0;
+#define RHINE_MSG_DEFAULT \
+        (0x0000)
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
@@ -128,12 +127,10 @@ MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 
-module_param(max_interrupt_work, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(avoid_D3, bool, 0);
-MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
-MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
+MODULE_PARM_DESC(debug, "VIA Rhine debug message flags");
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
@@ -439,8 +445,13 @@ struct rhine_private {
 	struct net_device *dev;
 	struct napi_struct napi;
 	spinlock_t lock;
+	struct mutex task_lock;
+	bool task_enable;
+	struct work_struct slow_event_task;
 	struct work_struct reset_task;
 
+	u32 msg_enable;
+
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
 	struct rx_desc *rx_head_desc;
@@ -476,41 +487,50 @@ static int  mdio_read(struct net_device *dev, int phy_id, int location);
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
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
-static void rhine_shutdown (struct pci_dev *pdev);
 static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
-static void rhine_set_cam(void __iomem *ioaddr, int idx, u8 *addr);
-static void rhine_set_vlan_cam(void __iomem *ioaddr, int idx, u8 *addr);
-static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask);
-static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
-static void rhine_init_cam_filter(struct net_device *dev);
-static void rhine_update_vcam(struct net_device *dev);
-
-#define RHINE_WAIT_FOR(condition)				\
-do {								\
-	int i = 1024;						\
-	while (!(condition) && --i)				\
-		;						\
-	if (debug > 1 && i < 512)				\
-		pr_info("%4d cycles used @ %s:%d\n",		\
-			1024 - i, __func__, __LINE__);		\
-} while (0)
-
-static inline u32 get_intr_status(struct net_device *dev)
+static void rhine_restart_tx(struct net_device *dev);
+
+static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool high)
+{
+	void __iomem *ioaddr = rp->base;
+	int i;
+
+	for (i = 0; i < 1024; i++) {
+		if (high ^ !!(ioread8(ioaddr + reg) & mask))
+			break;
+		udelay(10);
+	}
+	if (i > 64) {
+		netif_dbg(rp, hw, rp->dev, "%s bit wait (%02x/%02x) cycle "
+			  "count: %04d\n", high ? "high" : "low", reg, mask, i);
+	}
+}
+
+static void rhine_wait_bit_high(struct rhine_private *rp, u8 reg, u8 mask)
+{
+	rhine_wait_bit(rp, reg, mask, true);
+}
+
+static void rhine_wait_bit_low(struct rhine_private *rp, u8 reg, u8 mask)
+{
+	rhine_wait_bit(rp, reg, mask, false);
+}
+
+static u32 rhine_get_events(struct rhine_private *rp)
 {
-	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	u32 intr_status;
 
@@ -521,6 +541,16 @@ static inline u32 get_intr_status(struct net_device *dev)
 	return intr_status;
 }
 
+static void rhine_ack_events(struct rhine_private *rp, u32 mask)
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
@@ -585,6 +615,7 @@ static void rhine_chip_reset(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
+	u8 cmd1;
 
 	iowrite8(Cmd1Reset, ioaddr + ChipCmd1);
 	IOSYNC;
@@ -597,13 +628,12 @@ static void rhine_chip_reset(struct net_device *dev)
 			iowrite8(0x40, ioaddr + MiscCmd);
 
 		/* Reset can take somewhat longer (rare) */
-		RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipCmd1) & Cmd1Reset));
+		rhine_wait_bit_low(rp, ChipCmd1, Cmd1Reset);
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
@@ -629,9 +659,15 @@ static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
+	int i;
 
 	outb(0x20, pioaddr + MACRegEEcsr);
-	RHINE_WAIT_FOR(!(inb(pioaddr + MACRegEEcsr) & 0x20));
+	for (i = 0; i < 1024; i++) {
+		if (!(inb(pioaddr + MACRegEEcsr) & 0x20))
+			break;
+	}
+	if (i > 512)
+		pr_info("%4d cycles used @ %s:%d\n", i, __func__, __LINE__);
 
 #ifdef USE_MMIO
 	/*
@@ -657,23 +693,127 @@ static void rhine_poll(struct net_device *dev)
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
+	status = rhine_get_events(rp);
+	rhine_ack_events(rp, status & ~RHINE_EVENT_SLOW);
+
+	if (status & RHINE_EVENT_NAPI_RX)
+		work_done += rhine_rx(dev, budget);
+
+	if (status & RHINE_EVENT_NAPI_TX) {
+		if (status & RHINE_EVENT_NAPI_TX_ERR) {
+			/* Avoid scavenging before Tx engine turned off */
+			rhine_wait_bit_low(rp, ChipCmd, CmdTxOn);
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
@@ -797,6 +937,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
+	rp->msg_enable = netif_msg_init(debug, RHINE_MSG_DEFAULT);
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
@@ -856,7 +997,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	mutex_init(&rp->task_lock);
 	INIT_WORK(&rp->reset_task, rhine_reset_task);
+	INIT_WORK(&rp->slow_event_task, rhine_slow_event_task);
 
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
@@ -916,8 +1059,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		}
 	}
 	rp->mii_if.phy_id = phy_id;
-	if (debug > 1 && avoid_D3)
-		netdev_info(dev, "No D3 power state at shutdown\n");
+	if (avoid_D3)
+		netif_info(rp, probe, dev, "No D3 power state at shutdown\n");
 
 	return 0;
 
@@ -1093,7 +1236,7 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	mii_check_media(&rp->mii_if, debug, init_media);
+	mii_check_media(&rp->mii_if, netif_msg_link(rp), init_media);
 
 	if (rp->mii_if.full_duplex)
 	    iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1FDuplex,
@@ -1101,24 +1244,26 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
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
@@ -1266,10 +1411,10 @@ static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
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
 
@@ -1277,10 +1422,10 @@ static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
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
 
@@ -1310,12 +1455,7 @@ static void init_registers(struct net_device *dev)
 
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
@@ -1323,23 +1463,27 @@ static void init_registers(struct net_device *dev)
 }
 
 /* Enable MII link status auto-polling (required for IntrLinkChange) */
-static void rhine_enable_linkmon(void __iomem *ioaddr)
+static void rhine_enable_linkmon(struct rhine_private *rp)
 {
+	void __iomem *ioaddr = rp->base;
+
 	iowrite8(0, ioaddr + MIICmd);
 	iowrite8(MII_BMSR, ioaddr + MIIRegAddr);
 	iowrite8(0x80, ioaddr + MIICmd);
 
-	RHINE_WAIT_FOR((ioread8(ioaddr + MIIRegAddr) & 0x20));
+	rhine_wait_bit_high(rp, MIIRegAddr, 0x20);
 
 	iowrite8(MII_BMSR | 0x40, ioaddr + MIIRegAddr);
 }
 
 /* Disable MII link status auto-polling (required for MDIO access) */
-static void rhine_disable_linkmon(void __iomem *ioaddr, u32 quirks)
+static void rhine_disable_linkmon(struct rhine_private *rp)
 {
+	void __iomem *ioaddr = rp->base;
+
 	iowrite8(0, ioaddr + MIICmd);
 
-	if (quirks & rqRhineI) {
+	if (rp->quirks & rqRhineI) {
 		iowrite8(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
 
 		/* Can be called from ISR. Evil. */
@@ -1348,13 +1492,13 @@ static void rhine_disable_linkmon(void __iomem *ioaddr, u32 quirks)
 		/* 0x80 must be set immediately before turning it off */
 		iowrite8(0x80, ioaddr + MIICmd);
 
-		RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegAddr) & 0x20);
+		rhine_wait_bit_high(rp, MIIRegAddr, 0x20);
 
 		/* Heh. Now clear 0x80 again. */
 		iowrite8(0, ioaddr + MIICmd);
 	}
 	else
-		RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegAddr) & 0x80);
+		rhine_wait_bit_high(rp, MIIRegAddr, 0x80);
 }
 
 /* Read and write over the MII Management Data I/O (MDIO) interface. */
@@ -1365,16 +1509,16 @@ static int mdio_read(struct net_device *dev, int phy_id, int regnum)
 	void __iomem *ioaddr = rp->base;
 	int result;
 
-	rhine_disable_linkmon(ioaddr, rp->quirks);
+	rhine_disable_linkmon(rp);
 
 	/* rhine_disable_linkmon already cleared MIICmd */
 	iowrite8(phy_id, ioaddr + MIIPhyAddr);
 	iowrite8(regnum, ioaddr + MIIRegAddr);
 	iowrite8(0x40, ioaddr + MIICmd);		/* Trigger read */
-	RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x40));
+	rhine_wait_bit_low(rp, MIICmd, 0x40);
 	result = ioread16(ioaddr + MIIData);
 
-	rhine_enable_linkmon(ioaddr);
+	rhine_enable_linkmon(rp);
 	return result;
 }
 
@@ -1383,16 +1527,33 @@ static void mdio_write(struct net_device *dev, int phy_id, int regnum, int value
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	rhine_disable_linkmon(ioaddr, rp->quirks);
+	rhine_disable_linkmon(rp);
 
 	/* rhine_disable_linkmon already cleared MIICmd */
 	iowrite8(phy_id, ioaddr + MIIPhyAddr);
 	iowrite8(regnum, ioaddr + MIIRegAddr);
 	iowrite16(value, ioaddr + MIIData);
 	iowrite8(0x20, ioaddr + MIICmd);		/* Trigger write */
-	RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x20));
+	rhine_wait_bit_low(rp, MIICmd, 0x20);
 
-	rhine_enable_linkmon(ioaddr);
+	rhine_enable_linkmon(rp);
+}
+
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
 }
 
 static int rhine_open(struct net_device *dev)
@@ -1406,8 +1567,7 @@ static int rhine_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
-	if (debug > 1)
-		netdev_dbg(dev, "%s() irq %d\n", __func__, rp->pdev->irq);
+	netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp->pdev->irq);
 
 	rc = alloc_ring(dev);
 	if (rc) {
@@ -1417,11 +1577,12 @@ static int rhine_open(struct net_device *dev)
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
+	rhine_task_enable(rp);
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
 
@@ -1434,11 +1595,12 @@ static void rhine_reset_task(struct work_struct *work)
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
@@ -1452,11 +1614,13 @@ static void rhine_reset_task(struct work_struct *work)
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
@@ -1477,7 +1641,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
-	unsigned long flags;
 
 	/* Caution: the write order is important here, set the field
 	   with the "ownership" bits last. */
@@ -1529,7 +1692,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		rp->tx_ring[entry].tx_status = 0;
 
 	/* lock eth irq */
-	spin_lock_irqsave(&rp->lock, flags);
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
@@ -1550,78 +1712,43 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
 		netif_stop_queue(dev);
 
-	spin_unlock_irqrestore(&rp->lock, flags);
+	netif_dbg(rp, tx_queued, dev, "Transmit frame #%d queued in slot %d\n",
+		  rp->cur_tx - 1, entry);
 
-	if (debug > 4) {
-		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
-			   rp->cur_tx-1, entry);
-	}
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
 
-	while ((intr_status = get_intr_status(dev))) {
-		handled = 1;
-
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		if (intr_status & IntrTxDescRace)
-			iowrite8(0x08, ioaddr + IntrStatus2);
-		iowrite16(intr_status & 0xffff, ioaddr + IntrStatus);
-		IOSYNC;
+	status = rhine_get_events(rp);
 
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
+		rhine_irq_disable(rp);
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
 
@@ -1632,20 +1759,16 @@ static void rhine_tx(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 
-	spin_lock(&rp->lock);
-
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
@@ -1667,10 +1790,8 @@ static void rhine_tx(struct net_device *dev)
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
@@ -1687,8 +1808,6 @@ static void rhine_tx(struct net_device *dev)
 	}
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
-
-	spin_unlock(&rp->lock);
 }
 
 /**
@@ -1713,11 +1832,8 @@ static int rhine_rx(struct net_device *dev, int limit)
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
@@ -1729,9 +1845,8 @@ static int rhine_rx(struct net_device *dev, int limit)
 		if (desc_status & DescOwn)
 			break;
 
-		if (debug > 4)
-			netdev_dbg(dev, "%s() status is %08x\n",
-				   __func__, desc_status);
+		netif_dbg(rp, rx_status, dev, "%s() status %08x\n", __func__,
+			  desc_status);
 
 		if ((desc_status & (RxWholePkt | RxErr)) != RxWholePkt) {
 			if ((desc_status & RxWholePkt) != RxWholePkt) {
@@ -1747,9 +1862,9 @@ static int rhine_rx(struct net_device *dev, int limit)
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
@@ -1839,19 +1954,6 @@ static int rhine_rx(struct net_device *dev, int limit)
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
@@ -1862,7 +1964,7 @@ static void rhine_restart_tx(struct net_device *dev) {
 	 * If new errors occurred, we need to sort them out before doing Tx.
 	 * In that case the ISR will be back here RSN anyway.
 	 */
-	intr_status = get_intr_status(dev);
+	intr_status = rhine_get_events(rp);
 
 	if ((intr_status & IntrTxErrSummary) == 0) {
 
@@ -1883,79 +1985,50 @@ static void rhine_restart_tx(struct net_device *dev) {
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
-
-	if (intr_status & ~(IntrLinkChange | IntrStatsMax | IntrTxUnderrun |
-			    IntrTxError | IntrTxAborted | IntrNormalSummary |
-			    IntrTxDescRace)) {
-		if (debug > 1)
-			netdev_err(dev, "Something Wicked happened! %08x\n",
-				   intr_status);
-	}
 
-	spin_unlock(&rp->lock);
+	if (intr_status & IntrPCIErr)
+		netif_warn(rp, hw, dev, "PCI error\n");
+
+	napi_disable(&rp->napi);
+	rhine_irq_disable(rp);
+	/* Slow and safe. Consider __napi_schedule as a replacement ? */
+	napi_enable(&rp->napi);
+	napi_schedule(&rp->napi);
+
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
@@ -2022,9 +2095,9 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	spin_lock_irq(&rp->lock);
+	mutex_lock(&rp->task_lock);
 	rc = mii_ethtool_gset(&rp->mii_if, cmd);
-	spin_unlock_irq(&rp->lock);
+	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
@@ -2034,10 +2107,10 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
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
@@ -2058,12 +2131,16 @@ static u32 netdev_get_link(struct net_device *dev)
 
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
@@ -2119,10 +2196,10 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -2132,27 +2209,21 @@ static int rhine_close(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
+	rhine_task_disable(rp);
 	napi_disable(&rp->napi);
-	cancel_work_sync(&rp->reset_task);
 	netif_stop_queue(dev);
 
-	spin_lock_irq(&rp->lock);
-
-	if (debug > 1)
-		netdev_dbg(dev, "Shutting down ethercard, status was %04x\n",
-			   ioread16(ioaddr + ChipCmd));
+	netif_dbg(rp, ifdown, dev, "Shutting down ethercard, status was %04x\n",
+		  ioread16(ioaddr + ChipCmd));
 
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
@@ -2192,6 +2263,8 @@ static void rhine_shutdown (struct pci_dev *pdev)
 	if (rp->quirks & rq6patterns)
 		iowrite8(0x04, ioaddr + WOLcgClr);
 
+	spin_lock(&rp->lock);
+
 	if (rp->wolopts & WAKE_MAGIC) {
 		iowrite8(WOLmagic, ioaddr + WOLcrSet);
 		/*
@@ -2216,58 +2289,46 @@ static void rhine_shutdown (struct pci_dev *pdev)
 		iowrite8(ioread8(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
 	}
 
-	/* Hit power state D3 (sleep) */
-	if (!avoid_D3)
-		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
+	spin_unlock(&rp->lock);
 
-	/* TODO: Check use of pci_enable_wake() */
+	if (system_state == SYSTEM_POWER_OFF && !avoid_D3) {
+		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
 
+		pci_wake_from_d3(pdev, true);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
-#ifdef CONFIG_PM
-static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+static int rhine_suspend(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
-	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
 
+	rhine_task_disable(rp);
+	rhine_irq_disable(rp);
 	napi_disable(&rp->napi);
 
 	netif_device_detach(dev);
-	pci_save_state(pdev);
 
-	spin_lock_irqsave(&rp->lock, flags);
 	rhine_shutdown(pdev);
-	spin_unlock_irqrestore(&rp->lock, flags);
 
-	free_irq(dev->irq, dev);
 	return 0;
 }
 
-static int rhine_resume(struct pci_dev *pdev)
+static int rhine_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
-	unsigned long flags;
-	int ret;
 
 	if (!netif_running(dev))
 		return 0;
 
-	if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
-		netdev_err(dev, "request_irq failed\n");
-
-	ret = pci_set_power_state(pdev, PCI_D0);
-	if (debug > 1)
-		netdev_info(dev, "Entering power state D0 %s (%d)\n",
-			    ret ? "failed" : "succeeded", ret);
-
-	pci_restore_state(pdev);
-
-	spin_lock_irqsave(&rp->lock, flags);
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 #endif
@@ -2276,25 +2337,32 @@ static int rhine_resume(struct pci_dev *pdev)
 	free_rbufs(dev);
 	alloc_tbufs(dev);
 	alloc_rbufs(dev);
+	rhine_task_enable(rp);
+	spin_lock_bh(&rp->lock);
 	init_registers(dev);
-	spin_unlock_irqrestore(&rp->lock, flags);
+	spin_unlock_bh(&rp->lock);
 
 	netif_device_attach(dev);
 
 	return 0;
 }
-#endif /* CONFIG_PM */
+
+static SIMPLE_DEV_PM_OPS(rhine_pm_ops, rhine_suspend, rhine_resume);
+#define RHINE_PM_OPS	(&rhine_pm_ops)
+
+#else
+
+#define RHINE_PM_OPS	NULL
+
+#endif /* !CONFIG_PM_SLEEP */
 
 static struct pci_driver rhine_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= __devexit_p(rhine_remove_one),
-#ifdef CONFIG_PM
-	.suspend	= rhine_suspend,
-	.resume		= rhine_resume,
-#endif /* CONFIG_PM */
-	.shutdown =	rhine_shutdown,
+	.shutdown	= rhine_shutdown,
+	.driver.pm	= RHINE_PM_OPS,
 };
 
 static struct dmi_system_id __initdata rhine_dmi_table[] = {
-- 
Ueimor

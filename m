From: Ben Dooks <ben@simtec.co.uk>
Subject: DM9000: Wake on LAN support
Date: Tue, 10 Nov 2009 17:22:24 +0000
Message-ID: <20091110172224.215538042@fluff.org.uk>
Cc: davem@davemloft.net, Simtec Linux Team <linux@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:57380 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751300AbZKJRWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:22:19 -0500
Content-Disposition: inline; filename=simtec/ready/dm9000-wakeonlan.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Wake on LAN (WOL) reception and waking the device up from
this signal via the ethtool interface. Currently we are only supporting
the magic-packet variant of wakeup.

WOL is enabled by specifying a second interrupt resource to the driver
which indicates where the interrupt for the WOL is being signalled. This
then enables the necessary ethtool calls to leave the device in a state
to receive WOL frames when going into suspend.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>

---
 drivers/net/dm9000.c |  143 ++++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/dm9000.h |    7 ++
 2 files changed, 142 insertions(+), 8 deletions(-)

Index: b/drivers/net/dm9000.c
===================================================================
--- a/drivers/net/dm9000.c	2009-11-10 10:22:37.000000000 +0000
+++ b/drivers/net/dm9000.c	2009-11-10 10:26:21.000000000 +0000
@@ -100,6 +100,7 @@ typedef struct board_info {
 
 	unsigned int	flags;
 	unsigned int	in_suspend :1;
+	unsigned int	wake_supported :1;
 	int		debug_level;
 
 	enum dm9000_type type;
@@ -116,6 +117,8 @@ typedef struct board_info {
 	struct resource *data_req;
 	struct resource *irq_res;
 
+	int		 irq_wake;
+
 	struct mutex	 addr_lock;	/* phy and eeprom access lock */
 
 	struct delayed_work phy_poll;
@@ -125,6 +128,7 @@ typedef struct board_info {
 
 	struct mii_if_info mii;
 	u32		msg_enable;
+	u32		wake_state;
 
 	int		rx_csum;
 	int		can_csum;
@@ -568,6 +572,54 @@ static int dm9000_set_eeprom(struct net_
 	return 0;
 }
 
+static void dm9000_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	memset(w, 0, sizeof(struct ethtool_wolinfo));
+
+	/* note, we could probably support wake-phy too */
+	w->supported = dm->wake_supported ? WAKE_MAGIC : 0;
+	w->wolopts = dm->wake_state;
+}
+
+static int dm9000_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
+	u32 opts = w->wolopts;
+	u32 wcr = 0;
+
+	if (!dm->wake_supported)
+		return -EOPNOTSUPP;
+
+	if (opts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	if (opts & WAKE_MAGIC)
+		wcr |= WCR_MAGICEN;
+
+	mutex_lock(&dm->addr_lock);
+
+	spin_lock_irqsave(&dm->lock, flags);
+	iow(dm, DM9000_WCR, wcr);
+	spin_unlock_irqrestore(&dm->lock, flags);
+
+	mutex_unlock(&dm->addr_lock);
+
+	if (dm->wake_state != opts) {
+		/* change in wol state, update IRQ state */
+
+		if (!dm->wake_state)
+			set_irq_wake(dm->irq_wake, 1);
+		else if (dm->wake_state & !opts)
+			set_irq_wake(dm->irq_wake, 0);
+	}
+
+	dm->wake_state = opts;
+	return 0;
+}
+
 static const struct ethtool_ops dm9000_ethtool_ops = {
 	.get_drvinfo		= dm9000_get_drvinfo,
 	.get_settings		= dm9000_get_settings,
@@ -576,6 +628,8 @@ static const struct ethtool_ops dm9000_e
 	.set_msglevel		= dm9000_set_msglevel,
 	.nway_reset		= dm9000_nway_reset,
 	.get_link		= dm9000_get_link,
+	.get_wol		= dm9000_get_wol,
+	.set_wol		= dm9000_set_wol,
  	.get_eeprom_len		= dm9000_get_eeprom_len,
  	.get_eeprom		= dm9000_get_eeprom,
  	.set_eeprom		= dm9000_set_eeprom,
@@ -722,6 +776,7 @@ dm9000_init_dm9000(struct net_device *de
 {
 	board_info_t *db = netdev_priv(dev);
 	unsigned int imr;
+	unsigned int ncr;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
@@ -736,8 +791,15 @@ dm9000_init_dm9000(struct net_device *de
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 	iow(db, DM9000_GPR, 0);	/* Enable PHY */
 
-	if (db->flags & DM9000_PLATF_EXT_PHY)
-		iow(db, DM9000_NCR, NCR_EXT_PHY);
+	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
+
+	/* if wol is needed, then always set NCR_WAKEEN otherwise we end
+	 * up dumping the wake events if we disable this. There is already
+	 * a wake-mask in DM9000_WCR */
+	if (db->wake_supported)
+		ncr |= NCR_WAKEEN;
+
+	iow(db, DM9000_NCR, ncr);
 
 	/* Program operating register */
 	iow(db, DM9000_TCR, 0);	        /* TX Polling clear */
@@ -1045,6 +1107,41 @@ static irqreturn_t dm9000_interrupt(int 
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t dm9000_wol_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	board_info_t *db = netdev_priv(dev);
+	unsigned long flags;
+	unsigned nsr, wcr;
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	nsr = ior(db, DM9000_NSR);
+	wcr = ior(db, DM9000_WCR);
+
+	dev_dbg(db->dev, "%s: NSR=0x%02x, WCR=0x%02x\n", __func__, nsr, wcr);
+
+	if (nsr & NSR_WAKEST) {
+		/* clear, so we can avoid */
+		iow(db, DM9000_NSR, NSR_WAKEST);
+
+		if (wcr & WCR_LINKST)
+			dev_info(db->dev, "wake by link status change\n");
+		if (wcr & WCR_SAMPLEST)
+			dev_info(db->dev, "wake by sample packet\n");
+		if (wcr & WCR_MAGICST )
+			dev_info(db->dev, "wake by magic packet\n");
+		if (!(wcr & (WCR_LINKST | WCR_SAMPLEST | WCR_MAGICST)))
+			dev_err(db->dev, "wake signalled with no reason? "
+				"NSR=0x%02x, WSR=0x%02x\n", nsr, wcr);
+
+	}
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	return (nsr & NSR_WAKEST) ? IRQ_HANDLED : IRQ_NONE;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  *Used by netconsole
@@ -1299,6 +1396,29 @@ dm9000_probe(struct platform_device *pde
 		goto out;
 	}
 
+	db->irq_wake = platform_get_irq(pdev, 1);
+	if (db->irq_wake >= 0) {
+		dev_dbg(db->dev, "wakeup irq %d\n", db->irq_wake);
+
+		ret = request_irq(db->irq_wake, dm9000_wol_interrupt,
+				  IRQF_SHARED, dev_name(db->dev), ndev);
+		if (ret) {
+			dev_err(db->dev, "cannot get wakeup irq (%d)\n", ret);
+		} else {
+
+			/* test to see if irq is really wakeup capable */
+			ret = set_irq_wake(db->irq_wake, 1);
+			if (ret) {
+				dev_err(db->dev, "irq %d cannot set wakeup (%d)\n",
+					db->irq_wake, ret);
+				ret = 0;
+			} else {
+				set_irq_wake(db->irq_wake, 0);
+				db->wake_supported = 1;
+			}
+		}
+	}
+
 	iosize = resource_size(db->addr_res);
 	db->addr_req = request_mem_region(db->addr_res->start, iosize,
 					  pdev->name);
@@ -1490,10 +1610,14 @@ dm9000_drv_suspend(struct device *dev)
 		db = netdev_priv(ndev);
 		db->in_suspend = 1;
 
-		if (netif_running(ndev)) {
-			netif_device_detach(ndev);
+		if (!netif_running(ndev))
+			return 0;
+
+		netif_device_detach(ndev);
+
+		/* only shutdown if not using WoL */
+		if (!db->wake_state)
 			dm9000_shutdown(ndev);
-		}
 	}
 	return 0;
 }
@@ -1506,10 +1630,13 @@ dm9000_drv_resume(struct device *dev)
 	board_info_t *db = netdev_priv(ndev);
 
 	if (ndev) {
-
 		if (netif_running(ndev)) {
-			dm9000_reset(db);
-			dm9000_init_dm9000(ndev);
+			/* reset if we were not in wake mode to ensure if
+			 * the device was powered off it is in a known state */
+			if (!db->wake_state) {
+				dm9000_reset(db);
+				dm9000_init_dm9000(ndev);
+			}
 
 			netif_device_attach(ndev);
 		}
Index: b/drivers/net/dm9000.h
===================================================================
--- a/drivers/net/dm9000.h	2009-11-10 10:22:37.000000000 +0000
+++ b/drivers/net/dm9000.h	2009-11-10 10:25:44.000000000 +0000
@@ -111,6 +111,13 @@
 #define RSR_CE              (1<<1)
 #define RSR_FOE             (1<<0)
 
+#define WCR_LINKEN		(1 << 5)
+#define WCR_SAMPLEEN		(1 << 4)
+#define WCR_MAGICEN		(1 << 3)
+#define WCR_LINKST		(1 << 2)
+#define WCR_SAMPLEST		(1 << 1)
+#define WCR_MAGICST		(1 << 0)
+
 #define FCTR_HWOT(ot)	(( ot & 0xf ) << 4 )
 #define FCTR_LWOT(ot)	( ot & 0xf )
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'

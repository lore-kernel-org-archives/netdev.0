From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/2] ethernet: dm9000 driver: davicom: upgrade driver: 3rd trial
Date: Wed, 27 Mar 2013 20:09:27 +0800
Message-ID: <1364386168-12503-1-git-send-email-josright123@gmail.com>
Cc: linux-kernel@vger.kernel.org, Joseph CHANG <josright123@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Matthew Leach <matthew@mattleach.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joseph CHANG <joseph_chang@davicom.com.tw>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixing bug for DM9000B(DSP) which is a DSP revision! 3rd trial.

Tested to Davicom DM9000 series include DM9000E(analog),
DM9000A(analog), DM9000B(DSP), and DM9000C(DSP) in X86 and
ARM Embedded Linux these years.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/ethernet/davicom/dm9000.c |  219 +++++++++++++++++----------------
 drivers/net/ethernet/davicom/dm9000.h |   11 ++-
 2 files changed, 124 insertions(+), 106 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8cdf025..9dd4bd6 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -47,7 +47,7 @@
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
 #define CARDNAME	"dm9000"
-#define DRV_VERSION	"1.31"
+#define DRV_VERSION	"1.39"
 
 /*
  * Transmit timeout, default 5 seconds.
@@ -257,6 +257,109 @@ static void dm9000_dumpblk_32bit(void __iomem *reg, int count)
 		tmp = readl(reg);
 }
 
+/*
+ * Sleep, either by using msleep() or if we are suspending, then
+ * use mdelay() to sleep.
+ */
+static void dm9000_msleep(board_info_t *db, unsigned int ms)
+{
+	if (db->in_suspend)
+		mdelay(ms);
+	else
+		msleep(ms);
+}
+
+/*
+ *   Read a word from phyxcer
+ */
+static int
+dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
+{
+	board_info_t *db = netdev_priv(dev);
+	unsigned long flags;
+	unsigned int reg_save;
+	int ret;
+
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock,flags);
+
+	/* Save previous register address */
+	reg_save = readb(db->io_addr);
+
+	/* Fill the phyxcer register into REG_0C */
+	iow(db, DM9000_EPAR, DM9000_PHY | reg);
+
+	iow(db, DM9000_EPCR, EPCR_ERPRR | EPCR_EPOS);	/* Issue phyxcer read command */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+
+	dm9000_msleep(db, 1);		/* Wait read complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
+	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
+
+	/* The read data keeps on REG_0D & REG_0E */
+	ret = (ior(db, DM9000_EPDRH) << 8) | ior(db, DM9000_EPDRL);
+
+	/* restore the previous address */
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+
+	mutex_unlock(&db->addr_lock);
+
+	dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
+	return ret;
+}
+
+/*
+ *   Write a word to phyxcer
+ */
+static void
+dm9000_phy_write(struct net_device *dev,
+		 int phyaddr_unused, int reg, int value)
+{
+	board_info_t *db = netdev_priv(dev);
+	unsigned long flags;
+	unsigned long reg_save;
+
+	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock,flags);
+
+	/* Save previous register address */
+	reg_save = readb(db->io_addr);
+
+	/* Fill the phyxcer register into REG_0C */
+	iow(db, DM9000_EPAR, DM9000_PHY | reg);
+
+	/* Fill the written data into REG_0D & REG_0E */
+	iow(db, DM9000_EPDRL, value);
+	iow(db, DM9000_EPDRH, value >> 8);
+
+	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);	/* Issue phyxcer write command */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_msleep(db, 1);		/* Wait write complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
+	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
+
+	/* restore the previous address */
+	writeb(reg_save, db->io_addr);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+	mutex_unlock(&db->addr_lock);
+}
+
 /* dm9000_set_io
  *
  * select the specified set of io routines to use with the
@@ -795,6 +898,8 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 
+	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
+
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
 
 	/* if wol is needed, then always set NCR_WAKEEN otherwise we end
@@ -830,6 +935,8 @@ dm9000_init_dm9000(struct net_device *dev)
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
 	dev->trans_start = jiffies;
+
+	dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM); /* Init */
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -1201,109 +1308,6 @@ dm9000_open(struct net_device *dev)
 	return 0;
 }
 
-/*
- * Sleep, either by using msleep() or if we are suspending, then
- * use mdelay() to sleep.
- */
-static void dm9000_msleep(board_info_t *db, unsigned int ms)
-{
-	if (db->in_suspend)
-		mdelay(ms);
-	else
-		msleep(ms);
-}
-
-/*
- *   Read a word from phyxcer
- */
-static int
-dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
-{
-	board_info_t *db = netdev_priv(dev);
-	unsigned long flags;
-	unsigned int reg_save;
-	int ret;
-
-	mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock,flags);
-
-	/* Save previous register address */
-	reg_save = readb(db->io_addr);
-
-	/* Fill the phyxcer register into REG_0C */
-	iow(db, DM9000_EPAR, DM9000_PHY | reg);
-
-	iow(db, DM9000_EPCR, EPCR_ERPRR | EPCR_EPOS);	/* Issue phyxcer read command */
-
-	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
-
-	dm9000_msleep(db, 1);		/* Wait read complete */
-
-	spin_lock_irqsave(&db->lock,flags);
-	reg_save = readb(db->io_addr);
-
-	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
-
-	/* The read data keeps on REG_0D & REG_0E */
-	ret = (ior(db, DM9000_EPDRH) << 8) | ior(db, DM9000_EPDRL);
-
-	/* restore the previous address */
-	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
-
-	mutex_unlock(&db->addr_lock);
-
-	dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
-	return ret;
-}
-
-/*
- *   Write a word to phyxcer
- */
-static void
-dm9000_phy_write(struct net_device *dev,
-		 int phyaddr_unused, int reg, int value)
-{
-	board_info_t *db = netdev_priv(dev);
-	unsigned long flags;
-	unsigned long reg_save;
-
-	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
-	mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock,flags);
-
-	/* Save previous register address */
-	reg_save = readb(db->io_addr);
-
-	/* Fill the phyxcer register into REG_0C */
-	iow(db, DM9000_EPAR, DM9000_PHY | reg);
-
-	/* Fill the written data into REG_0D & REG_0E */
-	iow(db, DM9000_EPDRL, value);
-	iow(db, DM9000_EPDRH, value >> 8);
-
-	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);	/* Issue phyxcer write command */
-
-	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock, flags);
-
-	dm9000_msleep(db, 1);		/* Wait write complete */
-
-	spin_lock_irqsave(&db->lock,flags);
-	reg_save = readb(db->io_addr);
-
-	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
-
-	/* restore the previous address */
-	writeb(reg_save, db->io_addr);
-
-	spin_unlock_irqrestore(&db->lock, flags);
-	mutex_unlock(&db->addr_lock);
-}
-
 static void
 dm9000_shutdown(struct net_device *dev)
 {
@@ -1502,7 +1506,12 @@ dm9000_probe(struct platform_device *pdev)
 	db->flags |= DM9000_PLATF_SIMPLE_PHY;
 #endif
 
-	dm9000_reset(db);
+	/* Fixing bug on dm9000_probe, takeover dm9000_reset(db),
+	 * Need 'NCR_MAC_LBK' bit to indeed stable our DM9000 fifo
+	 * while probe stage.
+	 */
+
+	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
diff --git a/drivers/net/ethernet/davicom/dm9000.h b/drivers/net/ethernet/davicom/dm9000.h
index 55688bd..9ce058a 100644
--- a/drivers/net/ethernet/davicom/dm9000.h
+++ b/drivers/net/ethernet/davicom/dm9000.h
@@ -69,7 +69,9 @@
 #define NCR_WAKEEN          (1<<6)
 #define NCR_FCOL            (1<<4)
 #define NCR_FDX             (1<<3)
-#define NCR_LBK             (3<<1)
+
+#define NCR_RESERVED        (3<<1)
+#define NCR_MAC_LBK         (1<<1)
 #define NCR_RST	            (1<<0)
 
 #define NSR_SPEED           (1<<7)
@@ -167,5 +169,12 @@
 #define ISR_LNKCHNG		(1<<5)
 #define ISR_UNDERRUN		(1<<4)
 
+/* Davicom MII registers.
+ */
+
+#define MII_DM_DSPCR		0x1b    /* DSP Control Register */
+
+#define DSPCR_INIT_PARAM	0xE100	/* DSP init parameter */
+
 #endif /* _DM9000X_H_ */
 
-- 
1.7.1

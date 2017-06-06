From: Liu Xiang <liu.xiang6@zte.com.cn>
Subject: [PATCH v2] net: davicom: dm9000: Avoid spinlock recursion during dm9000_timeout routine
Date: Tue,  6 Jun 2017 22:17:06 +0800
Message-ID: <1496758626-2726-1-git-send-email-liu.xiang6@zte.com.cn>
Cc: linux-kernel@vger.kernel.org, liuxiang1999@gmail.com,
        Liu Xiang <liu.xiang6@zte.com.cn>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the DM9000B, dm9000_phy_write() is called after the main spinlock
is held, during the dm9000_timeout() routine. Spinlock recursion
occurs because the main spinlock is requested again in
dm9000_phy_write(). So spinlock should be avoided in phy operation
during the dm9000_timeout() routine.

---
v2:
   dm9000_phy_write_reg is extracted from dm9000_phy_write, with no lock,
   do the real phy operation.
---

Signed-off-by: Liu Xiang <liu.xiang6@zte.com.cn>
---
 drivers/net/ethernet/davicom/dm9000.c | 37 +++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 008dc81..0aa2900 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -327,21 +327,13 @@ static void dm9000_msleep(struct board_info *db, unsigned int ms)
 	return ret;
 }
 
-/* Write a word to phyxcer */
 static void
-dm9000_phy_write(struct net_device *dev,
-		 int phyaddr_unused, int reg, int value)
+dm9000_phy_write_reg(struct net_device *dev,
+		     int phyaddr_unused, int reg, int value)
 {
 	struct board_info *db = netdev_priv(dev);
-	unsigned long flags;
 	unsigned long reg_save;
 
-	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
-	if (!db->in_timeout)
-		mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock, flags);
-
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
 
@@ -356,17 +348,32 @@ static void dm9000_msleep(struct board_info *db, unsigned int ms)
 	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);
 
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock, flags);
 
-	dm9000_msleep(db, 1);		/* Wait write complete */
+	mdelay(1);	/* Wait write complete */
 
-	spin_lock_irqsave(&db->lock, flags);
 	reg_save = readb(db->io_addr);
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
+}
+
+/* Write a word to phyxcer */
+static void
+dm9000_phy_write(struct net_device *dev,
+		 int phyaddr_unused, int reg, int value)
+{
+	struct board_info *db = netdev_priv(dev);
+	unsigned long flags;
+
+	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
+	if (!db->in_timeout)
+		mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	dm9000_phy_write_reg(dev, phyaddr_unused, reg, value);
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	if (!db->in_timeout)
@@ -933,8 +940,8 @@ static unsigned char dm9000_type_to_char(enum dm9000_type type)
 	 * manual phy reset, and setting init params.
 	 */
 	if (db->type == TYPE_DM9000B) {
-		dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);
-		dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM);
+		dm9000_phy_write_reg(dev, 0, MII_BMCR, BMCR_RESET);
+		dm9000_phy_write_reg(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM);
 	}
 
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
-- 
1.9.1

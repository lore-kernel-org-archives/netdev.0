From: Liu Xiang <liu.xiang6@zte.com.cn>
Subject: [PATCH] net: davicom: dm9000: Avoid spinlock recursion during dm9000_timeout routine
Date: Wed, 31 May 2017 23:06:42 +0800
Message-ID: <1496243202-3492-1-git-send-email-liu.xiang6@zte.com.cn>
Cc: linux-kernel@vger.kernel.org, Liu Xiang <liu.xiang6@zte.com.cn>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the DM9000B, dm9000_phy_write() is called after the main spinlock
is held, during the dm9000_timeout() routine. Spinlock recursion
occurs because the main spinlock is requested again in
dm9000_phy_write(). So spinlock should be avoided in dm9000_phy_write()
during the dm9000_timeout() routine.

Signed-off-by: Liu Xiang <liu.xiang6@zte.com.cn>
---
 drivers/net/ethernet/davicom/dm9000.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 008dc81..afe33de 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -337,11 +337,11 @@ static void dm9000_msleep(struct board_info *db, unsigned int ms)
 	unsigned long reg_save;
 
 	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
-	if (!db->in_timeout)
+	if (!db->in_timeout) {
 		mutex_lock(&db->addr_lock);
 
-	spin_lock_irqsave(&db->lock, flags);
-
+		spin_lock_irqsave(&db->lock, flags);
+	}
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
 
@@ -356,11 +356,13 @@ static void dm9000_msleep(struct board_info *db, unsigned int ms)
 	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);
 
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock, flags);
+	if (!db->in_timeout)
+		spin_unlock_irqrestore(&db->lock, flags);
 
 	dm9000_msleep(db, 1);		/* Wait write complete */
 
-	spin_lock_irqsave(&db->lock, flags);
+	if (!db->in_timeout)
+		spin_lock_irqsave(&db->lock, flags);
 	reg_save = readb(db->io_addr);
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
@@ -368,9 +370,11 @@ static void dm9000_msleep(struct board_info *db, unsigned int ms)
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
 
-	spin_unlock_irqrestore(&db->lock, flags);
-	if (!db->in_timeout)
+	if (!db->in_timeout) {
+		spin_unlock_irqrestore(&db->lock, flags);
+
 		mutex_unlock(&db->addr_lock);
+	}
 }
 
 /* dm9000_set_io
-- 
1.9.1

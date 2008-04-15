From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2.6.26 1/2] phylib: factor out get_phy_id from within get_phy_device
Date: Tue, 15 Apr 2008 12:49:21 -0400
Message-ID: <1208278162-17462-2-git-send-email-paul.gortmaker@windriver.com>
References: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62649 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbYDOQuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 12:50:44 -0400
In-Reply-To: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were already doing what amounts to a get_phy_id from within
get_phy_device, and rather than duplicate this for the TBIPA
probing, we might as well just factor it out and make it available
instead.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/phy_device.c |   38 +++++++++++++++++++++++++++++---------
 include/linux/phy.h          |    1 +
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f4c4fd8..8b1121b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -86,35 +86,55 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 EXPORT_SYMBOL(phy_device_create);
 
 /**
- * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * get_phy_id - reads the specified addr for its ID.
  * @bus: the target MII bus
  * @addr: PHY address on the MII bus
+ * @phy_id: where to store the ID retrieved.
  *
  * Description: Reads the ID registers of the PHY at @addr on the
- *   @bus, then allocates and returns the phy_device to represent it.
+ *   @bus, stores it in @phy_id and returns zero on success.
  */
-struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
+int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 {
 	int phy_reg;
-	u32 phy_id;
-	struct phy_device *dev = NULL;
 
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
 	phy_reg = bus->read(bus, addr, MII_PHYSID1);
 
 	if (phy_reg < 0)
-		return ERR_PTR(phy_reg);
+		return -EIO;
 
-	phy_id = (phy_reg & 0xffff) << 16;
+	*phy_id = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
 	phy_reg = bus->read(bus, addr, MII_PHYSID2);
 
 	if (phy_reg < 0)
-		return ERR_PTR(phy_reg);
+		return -EIO;
+
+	*phy_id |= (phy_reg & 0xffff);
+
+	return 0;
+}
+
+/**
+ * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * @bus: the target MII bus
+ * @addr: PHY address on the MII bus
+ *
+ * Description: Reads the ID registers of the PHY at @addr on the
+ *   @bus, then allocates and returns the phy_device to represent it.
+ */
+struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
+{
+	struct phy_device *dev = NULL;
+	u32 phy_id;
+	int r;
 
-	phy_id |= (phy_reg & 0xffff);
+	r = get_phy_id(bus, addr, &phy_id);
+	if (r)
+		return ERR_PTR(r);
 
 	/* If the phy_id is all Fs, there is no device there */
 	if (0xffffffff == phy_id)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5e43ae7..e794c4d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -361,6 +361,7 @@ struct phy_driver {
 
 int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
-- 
1.5.4.3


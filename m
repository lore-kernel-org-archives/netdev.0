From: <shh.xie@gmail.com>
Subject: [PATCH][v3] net: phy: fix a bug in get_phy_c45_ids
Date: Tue, 3 Nov 2015 12:27:33 +0800
Message-ID: <1446524853-3050-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0083.outbound.protection.outlook.com ([207.46.100.83]:36192
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751612AbbKCEuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2015 23:50:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

When probing devices-in-package for a c45 phy, device zero is the last
device to probe, however, if driver reads 0 from device zero,
c45_ids->devices_in_package is set to '0', the loop condition of probing
will be matched again, see codes below:

for (i = 1;i < num_ids && c45_ids->devices_in_package == 0;i++)

driver will run in a dead loop.

This patch restructures the bug and confusing loop, it provides a helper
function get_phy_c45_devs_in_pkg which to read devices-in-package registers
of a MMD, and rewrites the loop with using the helper function.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes in v3:
removed a leading space on the first line of comment of get_phy_c45_devs_in_pkg.

changes in v2:
1. uses a helper function to read devices in package registers of a MMD.

2. rewrites the probing loop with using the helper function.

 drivers/net/phy/phy_device.c | 74 +++++++++++++++++++++++++++++---------------
 1 file changed, 49 insertions(+), 25 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3833891..8c84b9e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -205,6 +205,37 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 }
 EXPORT_SYMBOL(phy_device_create);
 
+/* get_phy_c45_devs_in_pkg - reads a MMD's devices in package registers.
+ * @bus: the target MII bus
+ * @addr: PHY address on the MII bus
+ * @dev_addr: MMD address in the PHY.
+ * @devices_in_package: where to store the devices in package information.
+ *
+ * Description: reads devices in package registers of a MMD at @dev_addr
+ * from PHY at @addr on @bus.
+ *
+ * Returns: 0 on success, -EIO on failure.
+ */
+static int get_phy_c45_devs_in_pkg(struct mii_bus *bus, int addr, int dev_addr,
+				   u32 *devices_in_package)
+{
+	int phy_reg, reg_addr;
+
+	reg_addr = MII_ADDR_C45 | dev_addr << 16 | MDIO_DEVS2;
+	phy_reg = mdiobus_read(bus, addr, reg_addr);
+	if (phy_reg < 0)
+		return -EIO;
+	*devices_in_package = (phy_reg & 0xffff) << 16;
+
+	reg_addr = MII_ADDR_C45 | dev_addr << 16 | MDIO_DEVS1;
+	phy_reg = mdiobus_read(bus, addr, reg_addr);
+	if (phy_reg < 0)
+		return -EIO;
+	*devices_in_package |= (phy_reg & 0xffff);
+
+	return 0;
+}
+
 /**
  * get_phy_c45_ids - reads the specified addr for its 802.3-c45 IDs.
  * @bus: the target MII bus
@@ -223,38 +254,31 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 	int phy_reg;
 	int i, reg_addr;
 	const int num_ids = ARRAY_SIZE(c45_ids->device_ids);
+	u32 *devs = &c45_ids->devices_in_package;
 
-	/* Find first non-zero Devices In package.  Device
-	 * zero is reserved, so don't probe it.
+	/* Find first non-zero Devices In package. Device zero is reserved
+	 * for 802.3 c45 complied PHYs, so don't probe it at first.
 	 */
-	for (i = 1;
-	     i < num_ids && c45_ids->devices_in_package == 0;
-	     i++) {
-retry:		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
-		phy_reg = mdiobus_read(bus, addr, reg_addr);
+	for (i = 1; i < num_ids && *devs == 0; i++) {
+		phy_reg = get_phy_c45_devs_in_pkg(bus, addr, i, devs);
 		if (phy_reg < 0)
 			return -EIO;
-		c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
 
-		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS1;
-		phy_reg = mdiobus_read(bus, addr, reg_addr);
-		if (phy_reg < 0)
-			return -EIO;
-		c45_ids->devices_in_package |= (phy_reg & 0xffff);
-
-		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
-			if (i) {
-				/*  If mostly Fs, there is no device there,
-				 *  then let's continue to probe more, as some
-				 *  10G PHYs have zero Devices In package,
-				 *  e.g. Cortina CS4315/CS4340 PHY.
-				 */
-				i = 0;
-				goto retry;
-			} else {
-				/* no device there, let's get out of here */
+		if ((*devs & 0x1fffffff) == 0x1fffffff) {
+			/*  If mostly Fs, there is no device there,
+			 *  then let's continue to probe more, as some
+			 *  10G PHYs have zero Devices In package,
+			 *  e.g. Cortina CS4315/CS4340 PHY.
+			 */
+			phy_reg = get_phy_c45_devs_in_pkg(bus, addr, 0, devs);
+			if (phy_reg < 0)
+				return -EIO;
+			/* no device there, let's get out of here */
+			if ((*devs & 0x1fffffff) == 0x1fffffff) {
 				*phy_id = 0xffffffff;
 				return 0;
+			} else {
+				break;
 			}
 		}
 	}
-- 
2.1.0.27.g96db324

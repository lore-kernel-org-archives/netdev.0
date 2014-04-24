From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH v2] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Thu, 24 Apr 2014 16:22:35 +0800
Message-ID: <1398327755-10702-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0183.outbound.protection.outlook.com ([207.46.163.183]:43234
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755450AbaDXJG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 05:06:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
zero Devices In package, current driver can't get correct
devices_in_package value by non-zero Devices In package.
so let's probe more with zero Devices In package to support
more C45 PHYs which have zero Devices In package.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
v2: refined to reuse code.

 drivers/net/phy/phy_device.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index cfb5110..4f5d518 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -232,7 +232,7 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 	for (i = 1;
 	     i < num_ids && c45_ids->devices_in_package == 0;
 	     i++) {
-		reg_addr = MII_ADDR_C45 | i << 16 | 6;
+retry:		reg_addr = MII_ADDR_C45 | i << 16 | 6;
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
@@ -244,12 +244,20 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 			return -EIO;
 		c45_ids->devices_in_package |= (phy_reg & 0xffff);
 
-		/* If mostly Fs, there is no device there,
-		 * let's get out of here.
-		 */
 		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
-			*phy_id = 0xffffffff;
-			return 0;
+			if (i) {
+				/*  If mostly Fs, there is no device there,
+				 *  then let's continue to probe more, as some
+				 *  10G PHYs have zero Devices In package,
+				 *  e.g. Cortina CS4315/CS4340 PHY.
+				 */
+				i = 0;
+				goto retry;
+			} else {
+				/* no device there, let's get out of here */
+				*phy_id = 0xffffffff;
+				return 0;
+			}
 		}
 	}
 
-- 
1.8.0

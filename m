From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH] net/phy:  tune get_phy_c45_ids to support more c45 phy
Date: Thu, 24 Apr 2014 10:17:36 +0800
Message-ID: <1398305856-9761-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:40943
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752316AbaDXDBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 23:01:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
zero Devices In package, current driver can't get correct
devices_in_package value by non-zero Devices In package.
so let's probe more with zero Devices In package to support
more C45 PHYs which have zero Devices In package.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
Tested with CS4315 on T2080RDB, this patch have no impact on previous XAUI phy with verification. 

 drivers/net/phy/phy_device.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index cfb5110..8fd777e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -244,12 +244,29 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 			return -EIO;
 		c45_ids->devices_in_package |= (phy_reg & 0xffff);
 
-		/* If mostly Fs, there is no device there,
-		 * let's get out of here.
+		/* If mostly Fs, let's continue to probe more
+		 * as some 10G PHYs have zero Devices In package
+		 * e.g. Cortina CS4315/CS4340 PHY.
 		 */
 		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
-			*phy_id = 0xffffffff;
-			return 0;
+			reg_addr = MII_ADDR_C45 | 0 << 16 | 6;
+			phy_reg = mdiobus_read(bus, addr, reg_addr);
+			if (phy_reg < 0)
+				return -EIO;
+			c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
+			reg_addr = MII_ADDR_C45 | 0 << 16 | 5;
+			phy_reg = mdiobus_read(bus, addr, reg_addr);
+			if (phy_reg < 0)
+				return -EIO;
+			c45_ids->devices_in_package |= (phy_reg & 0xffff);
+			/* If mostly Fs, there is no device there,
+			 * let's get out of here.
+			 */
+			if ((c45_ids->devices_in_package & 0x1fffffff) ==
+							0x1fffffff) {
+				*phy_id = 0xffffffff;
+				return 0;
+			}
 		}
 	}
 
-- 
1.8.0

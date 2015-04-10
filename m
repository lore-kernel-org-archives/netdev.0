From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Fri, 10 Apr 2015 17:10:20 +0800
Message-ID: <1428657020-11191-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
zero Devices In package, current driver can't get correct
devices_in_package value by non-zero Devices In package.
so let's probe more with zero Devices In package to support
more C45 PHYs.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
 drivers/net/phy/phy_device.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..07cf455 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -242,12 +242,29 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 			return -EIO;
 		c45_ids->devices_in_package |= (phy_reg & 0xffff);
 
-		/* If mostly Fs, there is no device there,
-		 * let's get out of here.
+		/* If mostly Fs, let's continue to probe more
+		 * as some c45 PHYs have zero Devices In package,
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
2.1.0.27.g96db324

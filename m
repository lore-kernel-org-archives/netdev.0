From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH v2] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Tue, 14 Apr 2015 18:09:52 +0800
Message-ID: <1429006192-21403-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0107.outbound.protection.outlook.com ([65.55.169.107]:45712
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752433AbbDNKNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 06:13:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
zero Devices In package, current driver can't get correct
devices_in_package value by non-zero Devices In package.
so let's probe more with zero Devices In package to support
more C45 PHYs.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
v2: use MDIO_DEVS1 and MDIO_DEVS2 instead of constant '6', '5'

 drivers/net/phy/phy_device.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..c4f836f 100644
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
+			reg_addr = MII_ADDR_C45 | 0 << 16 | MDIO_DEVS2;
+			phy_reg = mdiobus_read(bus, addr, reg_addr);
+			if (phy_reg < 0)
+				return -EIO;
+			c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
+			reg_addr = MII_ADDR_C45 | 0 << 16 | MDIO_DEVS1;
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

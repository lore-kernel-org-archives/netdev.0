From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH v3] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Fri, 26 Jun 2015 17:58:52 +0800
Message-ID: <1435312732-24890-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0102.outbound.protection.outlook.com ([65.55.169.102]:53609
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751561AbbFZKDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
zero Devices In package, current driver can't get correct
devices_in_package value by non-zero Devices In package.
so let's probe more with zero Devices In package to support
more C45 PHYs.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
v3: restructure the loop to probe naturally.  
v2: use MDIO_DEVS1 and MDIO_DEVS2 instead of constant '6', '5'

 drivers/net/phy/phy_device.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..3e90037 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -230,7 +230,7 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 	for (i = 1;
 	     i < num_ids && c45_ids->devices_in_package == 0;
 	     i++) {
-		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
+retry:		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
@@ -242,12 +242,20 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
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
2.1.0.27.g96db324

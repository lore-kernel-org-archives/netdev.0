From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHYs
Date: Tue, 23 May 2017 15:53:18 +0000
Message-ID: <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete the work started by the following patches
5f6c99e0 net: phy: fix a bug in get_phy_c45_ids
da1da284 net/phy: tune get_phy_c45_ids to support more c45 phy

in order to properly get non-standard C45 10G PHY IDs (e.g. Cortina
CS4340).

Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
---
 drivers/net/phy/phy_device.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1219eea..fef5627 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -335,7 +335,7 @@ static int phy_bus_match(struct device *dev, struct device_driver *drv)
 		return phydrv->match_phy_device(phydev);
 
 	if (phydev->is_c45) {
-		for (i = 1; i < num_ids; i++) {
+		for (i = 0; i < num_ids; i++) {
 			if (!(phydev->c45_ids.devices_in_package & (1 << i)))
 				continue;
 
@@ -488,28 +488,30 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 				*phy_id = 0xffffffff;
 				return 0;
 			} else {
+				c45_ids->devices_in_package |= 1;
 				break;
 			}
 		}
 	}
 
 	/* Now probe Device Identifiers for each device present. */
-	for (i = 1; i < num_ids; i++) {
+	for (i = 0; i < num_ids; i++) {
 		if (!(c45_ids->devices_in_package & (1 << i)))
 			continue;
 
-		reg_addr = MII_ADDR_C45 | i << 16 | MII_PHYSID1;
+		reg_addr = MII_ADDR_C45 | i << 16 | (i ? MII_PHYSID1 : 0);
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
 		c45_ids->device_ids[i] = (phy_reg & 0xffff) << 16;
 
-		reg_addr = MII_ADDR_C45 | i << 16 | MII_PHYSID2;
+		reg_addr = MII_ADDR_C45 | i << 16 | (i ? MII_PHYSID2 : 1);
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
 		c45_ids->device_ids[i] |= (phy_reg & 0xffff);
 	}
+
 	*phy_id = 0;
 	return 0;
 }
-- 
1.9.1

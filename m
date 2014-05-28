From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH v3] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Wed, 28 May 2014 16:54:36 +0800
Message-ID: <1401267276-29648-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:38754
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752603AbaE1JnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 05:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently get_phy_c45_ids() driver assumes that device zero is reserved and
doesn't probe c45 device which has zero device address. The driver only
probes c45 phy with non-zero device address by code:
for(i = 1; i < num_ids && c45_ids->devices_in_package == 0; i++)

This patch updates the driver to support those c45 phy which has special zero
device address(e.g. the device address is zero on Cortina CS4315/CS4340 10G
PHY, 'i' must be zero to have it work).

We should first probe non-zero devices, if not found, then probe device zero.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
---
v3: refined commit messages.
v2: refined to reuse code.

 drivers/net/phy/phy_device.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index cfb5110..88f1d38 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -226,13 +226,11 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 	int i, reg_addr;
 	const int num_ids = ARRAY_SIZE(c45_ids->device_ids);
 
-	/* Find first non-zero Devices In package.  Device
-	 * zero is reserved, so don't probe it.
-	 */
+	/* Find first non-zero Devices In package */
 	for (i = 1;
 	     i < num_ids && c45_ids->devices_in_package == 0;
 	     i++) {
-		reg_addr = MII_ADDR_C45 | i << 16 | 6;
+retry:		reg_addr = MII_ADDR_C45 | i << 16 | 6;
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
@@ -244,12 +242,20 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
 			return -EIO;
 		c45_ids->devices_in_package |= (phy_reg & 0xffff);
 
-		/* If mostly Fs, there is no device there,
-		 * let's get out of here.
-		 */
 		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
-			*phy_id = 0xffffffff;
-			return 0;
+			if (i) {
+				/*  If mostly Fs, there is no non-zero device
+				 *  found, then let's continue to probe more
+				 *  for special device which has zero device
+				 *  address, thus set i = 0 to try again.
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

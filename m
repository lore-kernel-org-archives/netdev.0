From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH] smsc911x: Ignore error return from device_get_phy_mode()
Date: Wed, 26 Aug 2015 11:49:08 -0700
Message-ID: <1440614948-27428-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tony@atomide.com, jeremy.linton@arm.com,
	Guenter Roeck <linux@roeck-us.net>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is
configured or used") introduces an error check for the return value from
device_get_phy_mode() and bails out if there is an error. Unfortunately,
there are configurations where no phy is configured. Those configurations
now fail.

To fix the problem, assign a phy interface mode of PHY_INTERFACE_MODE_NA
if device_get_phy_mode() returns an error.

Check the return value from device_property_read_u32() to see if there
is a suitable firmware interface to read the data, and abort if not.
The function should return -ENXIO in that case; however, it returns
-ENODATA. Check for both.

Fixes: 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is configured or used")
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Needs testing. RFC because I am not sure if the -ENODATA check is acceptable.

 drivers/net/ethernet/smsc/smsc911x.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 6eef3251d833..81e29e420fd0 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2369,23 +2369,29 @@ static int smsc911x_probe_config(struct smsc911x_platform_config *config,
 {
 	int phy_interface;
 	u32 width = 0;
+	int err;
 
 	phy_interface = device_get_phy_mode(dev);
 	if (phy_interface < 0)
-		return phy_interface;
-
+		phy_interface = PHY_INTERFACE_MODE_NA;
 	config->phy_interface = phy_interface;
 
 	device_get_mac_address(dev, config->mac, ETH_ALEN);
 
-	device_property_read_u32(dev, "reg-shift", &config->shift);
-
-	device_property_read_u32(dev, "reg-io-width", &width);
-	if (width == 4)
+	err = device_property_read_u32(dev, "reg-io-width", &width);
+	/* device_property_read_u32() should return -ENXIO if there is no
+	 * suitable firmware interface. In reality it returns -ENODATA.
+	 * Check for both and use platform data if that is the case.
+	 */
+	if (err == -ENXIO || err == -ENODATA)
+		return err;
+	if (!err && width == 4)
 		config->flags |= SMSC911X_USE_32BIT;
 	else
 		config->flags |= SMSC911X_USE_16BIT;
 
+	device_property_read_u32(dev, "reg-shift", &config->shift);
+
 	if (device_property_present(dev, "smsc,irq-active-high"))
 		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
 
-- 
2.1.4

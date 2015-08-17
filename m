From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is configured or used
Date: Mon, 17 Aug 2015 13:45:36 -0700
Message-ID: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
the call to smsc911x_probe_config() unconditional, and no longer fails if
there is no device node. device_get_phy_mode() is called unconditionally,
and if there is no phy node configured returns an error code. This error
code is assigned to phy_interface, and interpreted elsewhere in the code
as valid phy mode. This in turn causes qemu to crash when running a
variant of realview_pb_defconfig.

	qemu: hardware error: lan9118_read: Bad reg 0x86

Fixes: 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT")
Cc: Jeremy Linton <jeremy.linton@arm.com>
Cc Graeme Gregory <graeme.gregory@linaro.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/smsc/smsc911x.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 0f21aa3bb537..34f97684506b 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2367,12 +2367,17 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
 static int smsc911x_probe_config(struct smsc911x_platform_config *config,
 				 struct device *dev)
 {
+	int phy_interface;
 	u32 width = 0;
 
 	if (!dev)
 		return -ENODEV;
 
-	config->phy_interface = device_get_phy_mode(dev);
+	phy_interface = device_get_phy_mode(dev);
+	if (phy_interface < 0)
+		return phy_interface;
+
+	config->phy_interface = phy_interface;
 
 	device_get_mac_address(dev, config->mac, ETH_ALEN);
 
-- 
2.1.4

From: <dinguyen@altera.com>
Subject: [RFC] phy: micrel: Convert micrel PHY driver to use OF
Date: Tue, 13 Aug 2013 11:42:36 -0500
Message-ID: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dinh Nguyen <dinguyen@altera.com>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Olof Johansson <olof@lixom.net>,
	Rob Herring <rob.herring@calxeda.com>
To: <dinh.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:13233
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756514Ab3HMQnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 12:43:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Convert the Micrel PHY driver to use OF. This initial patch is only
the beginning of an idea to convert the PHY driver to device tree.

Signed-of-by: Dinh Nguyen <dinguyen@altera.com>
Cc: netdev@vger.kernel.org
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: Felipe Balbi <balbi@ti.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Olof Johansson <olof@lixom.net>
Cc: Rob Herring <rob.herring@calxeda.com>

---
Hello,

I would like to solicit comments on the need to convert the ethernet PHY
drivers to use OF/device trees? For the platform that I'm interested in,
SOCFPGA, it is using the stmicro ethernet driver. It has a Micrel PHY
on the board. The only way that I know of how to change the skew settings
for the phy is through a board level initialization.

One of the ARM maintainers suggested that perhaps refactoring the ethernet
driver to use device tree would be nice. But that would not help me with
configuring the PHY settings.

So a little investigation led me to believe that refactoring the /net/phy
drivers into a device tree implementation would help greatly. I was thinking
it could be done like the pinctrl or some of the usb/phy driver.

Since I am only familiar with the ARM SoC space, I want to make sure that
this idea is right approach. I can start with the micrel PHY driver
first, as that is the only HW I have access to.

Thanks for any comments,

Dinh
---
 drivers/net/phy/micrel.c |  107 ++++++++++++++++------------------------------
 1 file changed, 37 insertions(+), 70 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2510435..6ee1e88 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -174,6 +174,15 @@ static int ksz8873mll_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
+static const struct phy_driver ksphy_driver_data[] = {
+{
+	.config_init    = kszphy_config_init,
+	.config_aneg    = genphy_config_aneg,
+	.read_status    = genphy_read_status,
+	.ack_interrupt  = kszphy_ack_interrupt,
+	.config_intr    = ks_config_intr,
+};
+
 static struct phy_driver ksphy_driver[] = {
 {
 	.phy_id		= PHY_ID_KS8737,
@@ -181,12 +190,6 @@ static struct phy_driver ksphy_driver[] = {
 	.name		= "Micrel KS8737",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ks8737_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8021,
 	.phy_id_mask	= 0x00ffffff,
@@ -194,12 +197,6 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= ksz8021_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8031,
 	.phy_id_mask	= 0x00ffffff,
@@ -207,12 +204,6 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= ksz8021_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8041,
 	.phy_id_mask	= 0x00fffff0,
@@ -220,12 +211,6 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8051,
 	.phy_id_mask	= 0x00fffff0,
@@ -233,60 +218,30 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= ks8051_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8001,
 	.name		= "Micrel KSZ8001 or KS8721",
 	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8081,
 	.name		= "Micrel KSZ8081 or KSZ8091",
 	.phy_id_mask	= 0x00fffff0,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8061,
 	.name		= "Micrel KSZ8061",
 	.phy_id_mask	= 0x00fffff0,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= kszphy_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ksz9021_config_intr,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ9031,
 	.phy_id_mask	= 0x00fffff0,
@@ -294,32 +249,18 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ksz9021_config_intr,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ8873MLL Switch",
 	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= ksz8873mll_config_aneg,
-	.read_status	= ksz8873mll_read_status,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ886X,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ886X Switch",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.driver		= { .owner = THIS_MODULE, },
 } };
 
 static int __init ksphy_init(void)
@@ -334,8 +275,34 @@ static void __exit ksphy_exit(void)
 		ARRAY_SIZE(ksphy_driver));
 }
 
-module_init(ksphy_init);
-module_exit(ksphy_exit);
+static const struct of_device_id phy_micrel_match[] = {
+	{ .compatible = "micrel,ks8721", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ks8737", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8001", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8021", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8031", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8041", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8051", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8061", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8081", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8091", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8021-gigabit", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8031-gigabit", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz8873mll-switch", .data = &ksphy_driver_data },
+	{ .compatible = "micrel,ksz886x-switch", .data = &ksphy_driver_data },
+	{},
+};
+MODULE_DEVICE_TABLE(of, phy_micrel_match);
+
+static struct platform_driver phy_micrel_driver = {
+	.probe          = ksphy_init,
+	.remove         = ksphy_exit,
+	.driver         = {
+		.name           = "phy_micrel",
+		.of_match_table = of_match_ptr(phy_micrel_match),
+	},
+};
+module_platform_driver(phy_micrel_driver);
 
 MODULE_DESCRIPTION("Micrel PHY driver");
 MODULE_AUTHOR("David J. Choi");
-- 
1.7.9.5

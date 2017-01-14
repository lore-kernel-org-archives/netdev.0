From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 10/10] ARM: orion: Register DSA switch as a MDIO device
Date: Sat, 14 Jan 2017 13:47:13 -0800
Message-ID: <20170114214713.28109-11-f.fainelli@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM
        SUB-ARCHITECTURES), linux-kernel@vger.kernel.org (open list),
        gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170114214713.28109-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Utilize the ability to pass board specific MDIO bus information towards a
particular MDIO device thus allowing us to provide the per-port switch layout
to the Marvell 88E6XXX switch driver.

Since we would end-up with conflicting registration paths, do not register the
"dsa" platform device anymore.

Note that the MDIO devices registered by code in net/dsa/dsa2.c does not
parse a dsa_platform_data, but directly take a dsa_chip_data (specific
to a single switch chip), so we update the different call sites to pass
this structure down to orion_ge00_switch_init().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm/mach-orion5x/common.c               |  2 +-
 arch/arm/mach-orion5x/common.h               |  4 ++--
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |  7 +------
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |  7 +------
 arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c |  7 +------
 arch/arm/mach-orion5x/wnr854t-setup.c        |  2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |  7 +------
 arch/arm/plat-orion/common.c                 | 25 +++++++++++++++++++------
 arch/arm/plat-orion/include/plat/common.h    |  4 ++--
 9 files changed, 29 insertions(+), 36 deletions(-)

diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 04910764c385..83a7ec4c16d0 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -105,7 +105,7 @@ void __init orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data)
 /*****************************************************************************
  * Ethernet switch
  ****************************************************************************/
-void __init orion5x_eth_switch_init(struct dsa_platform_data *d)
+void __init orion5x_eth_switch_init(struct dsa_chip_data *d)
 {
 	orion_ge00_switch_init(d);
 }
diff --git a/arch/arm/mach-orion5x/common.h b/arch/arm/mach-orion5x/common.h
index 8a4115bd441d..efeffc6b4ebb 100644
--- a/arch/arm/mach-orion5x/common.h
+++ b/arch/arm/mach-orion5x/common.h
@@ -3,7 +3,7 @@
 
 #include <linux/reboot.h>
 
-struct dsa_platform_data;
+struct dsa_chip_data;
 struct mv643xx_eth_platform_data;
 struct mv_sata_platform_data;
 
@@ -41,7 +41,7 @@ void orion5x_setup_wins(void);
 void orion5x_ehci0_init(void);
 void orion5x_ehci1_init(void);
 void orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data);
-void orion5x_eth_switch_init(struct dsa_platform_data *d);
+void orion5x_eth_switch_init(struct dsa_chip_data *d);
 void orion5x_i2c_init(void);
 void orion5x_sata_init(struct mv_sata_platform_data *sata_data);
 void orion5x_spi_init(void);
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index dccadf68ea2b..a3c1336d30c9 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -101,11 +101,6 @@ static struct dsa_chip_data rd88f5181l_fxo_switch_chip_data = {
 	.port_names[7]	= "lan3",
 };
 
-static struct dsa_platform_data __initdata rd88f5181l_fxo_switch_plat_data = {
-	.nr_chips	= 1,
-	.chip		= &rd88f5181l_fxo_switch_chip_data,
-};
-
 static void __init rd88f5181l_fxo_init(void)
 {
 	/*
@@ -120,7 +115,7 @@ static void __init rd88f5181l_fxo_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_fxo_eth_data);
-	orion5x_eth_switch_init(&rd88f5181l_fxo_switch_plat_data);
+	orion5x_eth_switch_init(&rd88f5181l_fxo_switch_chip_data);
 	orion5x_uart0_init();
 
 	mvebu_mbus_add_window_by_id(ORION_MBUS_DEVBUS_BOOT_TARGET,
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index affe5ec825de..252efe29bd1a 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -102,11 +102,6 @@ static struct dsa_chip_data rd88f5181l_ge_switch_chip_data = {
 	.port_names[7]	= "lan3",
 };
 
-static struct dsa_platform_data __initdata rd88f5181l_ge_switch_plat_data = {
-	.nr_chips	= 1,
-	.chip		= &rd88f5181l_ge_switch_chip_data,
-};
-
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
 	I2C_BOARD_INFO("ds1338", 0x68),
 };
@@ -125,7 +120,7 @@ static void __init rd88f5181l_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f5181l_ge_switch_plat_data);
+	orion5x_eth_switch_init(&rd88f5181l_ge_switch_chip_data);
 	orion5x_i2c_init();
 	orion5x_uart0_init();
 
diff --git a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
index 67ee8571b03c..f4f1dbe1d91d 100644
--- a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
@@ -40,11 +40,6 @@ static struct dsa_chip_data rd88f6183ap_ge_switch_chip_data = {
 	.port_names[5]	= "cpu",
 };
 
-static struct dsa_platform_data __initdata rd88f6183ap_ge_switch_plat_data = {
-	.nr_chips	= 1,
-	.chip		= &rd88f6183ap_ge_switch_chip_data,
-};
-
 static struct mtd_partition rd88f6183ap_ge_partitions[] = {
 	{
 		.name	= "kernel",
@@ -89,7 +84,7 @@ static void __init rd88f6183ap_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f6183ap_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_plat_data);
+	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_chip_data);
 	spi_register_board_info(rd88f6183ap_ge_spi_slave_info,
 				ARRAY_SIZE(rd88f6183ap_ge_spi_slave_info));
 	orion5x_spi_init();
diff --git a/arch/arm/mach-orion5x/wnr854t-setup.c b/arch/arm/mach-orion5x/wnr854t-setup.c
index 4dbcdbe1de7c..ac3376fc269f 100644
--- a/arch/arm/mach-orion5x/wnr854t-setup.c
+++ b/arch/arm/mach-orion5x/wnr854t-setup.c
@@ -124,7 +124,7 @@ static void __init wnr854t_init(void)
 	 * Configure peripherals.
 	 */
 	orion5x_eth_init(&wnr854t_eth_data);
-	orion5x_eth_switch_init(&wnr854t_switch_plat_data);
+	orion5x_eth_switch_init(&wnr854t_switch_chip_data);
 	orion5x_uart0_init();
 
 	mvebu_mbus_add_window_by_id(ORION_MBUS_DEVBUS_BOOT_TARGET,
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index a6a8c4648d74..9250bb2e429c 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -191,11 +191,6 @@ static struct dsa_chip_data wrt350n_v2_switch_chip_data = {
 	.port_names[7]	= "lan4",
 };
 
-static struct dsa_platform_data __initdata wrt350n_v2_switch_plat_data = {
-	.nr_chips	= 1,
-	.chip		= &wrt350n_v2_switch_chip_data,
-};
-
 static void __init wrt350n_v2_init(void)
 {
 	/*
@@ -210,7 +205,7 @@ static void __init wrt350n_v2_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&wrt350n_v2_eth_data);
-	orion5x_eth_switch_init(&wrt350n_v2_switch_plat_data);
+	orion5x_eth_switch_init(&wrt350n_v2_switch_chip_data);
 	orion5x_uart0_init();
 
 	mvebu_mbus_add_window_by_id(ORION_MBUS_DEVBUS_BOOT_TARGET,
diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
index 272f49b2c68f..9255b6d67ba5 100644
--- a/arch/arm/plat-orion/common.c
+++ b/arch/arm/plat-orion/common.c
@@ -22,6 +22,7 @@
 #include <linux/platform_data/dma-mv_xor.h>
 #include <linux/platform_data/usb-ehci-orion.h>
 #include <plat/common.h>
+#include <linux/phy.h>
 
 /* Create a clkdev entry for a given device/clk */
 void __init orion_clkdev_add(const char *con_id, const char *dev_id,
@@ -470,15 +471,27 @@ void __init orion_ge11_init(struct mv643xx_eth_platform_data *eth_data,
 /*****************************************************************************
  * Ethernet switch
  ****************************************************************************/
-void __init orion_ge00_switch_init(struct dsa_platform_data *d)
+static __initconst const char *orion_ge00_mvmdio_bus_name = "orion-mii";
+static __initdata struct mdio_board_info
+		  orion_ge00_switch_board_info;
+
+void __init orion_ge00_switch_init(struct dsa_chip_data *d)
 {
-	int i;
+	struct mdio_board_info *bd;
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(d->port_names); i++)
+		if (!strcmp(d->port_names[i], "cpu"))
+			break;
 
-	d->netdev = &orion_ge00.dev;
-	for (i = 0; i < d->nr_chips; i++)
-		d->chip[i].host_dev = &orion_ge_mvmdio.dev;
+	bd = &orion_ge00_switch_board_info;
+	bd->bus_id = orion_ge00_mvmdio_bus_name;
+	bd->mdio_addr = d->sw_addr;
+	d->netdev[i] = &orion_ge00.dev;
+	strcpy(bd->modalias, "mv88e6085");
+	bd->platform_data = d;
 
-	platform_device_register_data(NULL, "dsa", 0, d, sizeof(d));
+	mdiobus_register_board_info(&orion_ge00_switch_board_info, 1);
 }
 
 /*****************************************************************************
diff --git a/arch/arm/plat-orion/include/plat/common.h b/arch/arm/plat-orion/include/plat/common.h
index 9347f3c58a6d..3647d3b33c20 100644
--- a/arch/arm/plat-orion/include/plat/common.h
+++ b/arch/arm/plat-orion/include/plat/common.h
@@ -12,7 +12,7 @@
 #include <linux/mv643xx_eth.h>
 #include <linux/platform_data/usb-ehci-orion.h>
 
-struct dsa_platform_data;
+struct dsa_chip_data;
 struct mv_sata_platform_data;
 
 void __init orion_uart0_init(void __iomem *membase,
@@ -57,7 +57,7 @@ void __init orion_ge11_init(struct mv643xx_eth_platform_data *eth_data,
 			    unsigned long mapbase,
 			    unsigned long irq);
 
-void __init orion_ge00_switch_init(struct dsa_platform_data *d);
+void __init orion_ge00_switch_init(struct dsa_chip_data *d);
 
 void __init orion_i2c_init(unsigned long mapbase,
 			   unsigned long irq,
-- 
2.9.3

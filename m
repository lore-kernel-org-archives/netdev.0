From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 2/3] ARM: shmobile: lager: enable Ether
Date: Wed, 24 Jul 2013 17:56:08 +0900
Message-ID: <1374656169-9241-3-git-send-email-horms+renesas@verge.net.au>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

This patch has a run-time dependency on "sh_eth: add support for r8a7790 SoC".

v5
* As suggested by Laurent Pinchart
  - Do not use eth_magic pinmux group, that pin is not used on Lager
* As suggested by Morimoto-san and Magnus Damm
  - Refactor moving all setup code into boards-lager.c

v4
* Remove needs_gpio_reset and reset_gpio from ether_platdata
  as the patch that adds that feature and those fields has
  been dropped.
* Annotate ether_platdata as __initdata

v3
* Use newly added "r8a7790-ether" instead of "sh-eth"

v2
* Do not add MSTP812, EtherAVB. It is not used.
* As suggested by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
  - Move Ethernet element of MSTP enum to a separate line
  - Move declaration of r8a7790_add_ether_device() to immediately
    after that of r8a7790_add_standard_devices()
  - Add __initdata annotation to ether_resource.
* As suggested by Laurent Pinchart
  - Do not manipilate sh_eth reset GPIO directly,
    rather, do so through newly proposed support for this in
    the sh_eth driver.
* A suggested by Sergei Shtylyov
  - Move DTS portion into a separate patch
---
 arch/arm/mach-shmobile/board-lager.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/arch/arm/mach-shmobile/board-lager.c b/arch/arm/mach-shmobile/board-lager.c
index 3c67b2a..86e6319 100644
--- a/arch/arm/mach-shmobile/board-lager.c
+++ b/arch/arm/mach-shmobile/board-lager.c
@@ -31,6 +31,7 @@
 #include <linux/platform_device.h>
 #include <linux/regulator/fixed.h>
 #include <linux/regulator/machine.h>
+#include <linux/sh_eth.h>
 #include <mach/common.h>
 #include <mach/irqs.h>
 #include <mach/r8a7790.h>
@@ -91,6 +92,20 @@ static struct resource mmcif1_resources[] = {
 	DEFINE_RES_IRQ(gic_spi(170)),
 };
 
+/* Ether */
+static struct sh_eth_plat_data ether_pdata __initdata = {
+	.phy			= 0x1,
+	.edmac_endian		= EDMAC_LITTLE_ENDIAN,
+	.register_type		= SH_ETH_REG_FAST_RCAR,
+	.phy_interface		= PHY_INTERFACE_MODE_RMII,
+	.ether_link_active_low	= 1,
+};
+
+static struct resource ether_resources[] __initdata = {
+	DEFINE_RES_MEM(0xee700000, 0x400),
+	DEFINE_RES_IRQ(gic_spi(162)), /* IRQ0 */
+};
+
 static const struct pinctrl_map lager_pinctrl_map[] = {
 	/* SCIF0 (CN19: DEBUG SERIAL0) */
 	PIN_MAP_MUX_GROUP_DEFAULT("sh-sci.6", "pfc-r8a7790",
@@ -103,6 +118,15 @@ static const struct pinctrl_map lager_pinctrl_map[] = {
 				  "mmc1_data8", "mmc1"),
 	PIN_MAP_MUX_GROUP_DEFAULT("sh_mmcif.1", "pfc-r8a7790",
 				  "mmc1_ctrl", "mmc1"),
+	/* Ether */
+	PIN_MAP_MUX_GROUP_DEFAULT("sh-eth", "pfc-r8a7790",
+				  "eth_link", "eth"),
+	PIN_MAP_MUX_GROUP_DEFAULT("sh-eth", "pfc-r8a7790",
+				  "eth_mdio", "eth"),
+	PIN_MAP_MUX_GROUP_DEFAULT("sh-eth", "pfc-r8a7790",
+				  "eth_rmii", "eth"),
+	PIN_MAP_MUX_GROUP_DEFAULT("sh-eth", "pfc-r8a7790",
+				  "intc_irq0", "intc"),
 };
 
 static void __init lager_add_standard_devices(void)
@@ -114,6 +138,7 @@ static void __init lager_add_standard_devices(void)
 	r8a7790_pinmux_init();
 
 	r8a7790_add_standard_devices();
+
 	platform_device_register_data(&platform_bus, "leds-gpio", -1,
 				      &lager_leds_pdata,
 				      sizeof(lager_leds_pdata));
@@ -125,6 +150,11 @@ static void __init lager_add_standard_devices(void)
 	platform_device_register_resndata(&platform_bus, "sh_mmcif", 1,
 					  mmcif1_resources, ARRAY_SIZE(mmcif1_resources),
 					  &mmcif1_pdata, sizeof(mmcif1_pdata));
+
+	platform_device_register_resndata(&platform_bus, "r8a7790-ether", -1,
+					  ether_resources,
+					  ARRAY_SIZE(ether_resources),
+					  &ether_pdata, sizeof(ether_pdata));
 }
 
 static const char *lager_boards_compat_dt[] __initdata = {
-- 
1.8.2.1


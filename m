From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 1/2] Revert "ARM: imx: add FEC sleep mode callback function"
Date: Wed,  7 Jan 2015 10:39:52 -0200
Message-ID: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Cc: shawn.guo@linaro.org, fugang.duan@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:55708 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbAGMki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 07:40:38 -0500
Received: by mail-vc0-f177.google.com with SMTP id ij19so415877vcb.22
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 04:40:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

i.MX platform maintainer Shawn Guo is not happy with the such commit as
explained below [1]:

"The GPR difference between SoCs can be encoded in device tree as well.
It's pointless to repeat the same code pattern for every single
platform, that need to set up GPR bits for enabling magic packet wake
up, while the only difference is the register and bit offset.

The platform code will become quite messy and unmaintainable if every
device driver dump their GPR register setup code into platform.

Sorry, but it's NACK from me."

This reverts commit 456062b3ec6f5b9 ("ARM: imx: add FEC sleep mode callback 
function").

[1] http://www.spinics.net/lists/netdev/msg310922.html

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 arch/arm/mach-imx/mach-imx6q.c  | 41 +--------------------------------
 arch/arm/mach-imx/mach-imx6sx.c | 50 -----------------------------------------
 2 files changed, 1 insertion(+), 90 deletions(-)

diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index 2f76168..5057d61 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -31,8 +31,6 @@
 #include <linux/micrel_phy.h>
 #include <linux/mfd/syscon.h>
 #include <linux/mfd/syscon/imx6q-iomuxc-gpr.h>
-#include <linux/fec.h>
-#include <linux/netdevice.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
 #include <asm/system_misc.h>
@@ -41,35 +39,6 @@
 #include "cpuidle.h"
 #include "hardware.h"
 
-static struct fec_platform_data fec_pdata;
-
-static void imx6q_fec_sleep_enable(int enabled)
-{
-	struct regmap *gpr;
-
-	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6q-iomuxc-gpr");
-	if (!IS_ERR(gpr)) {
-		if (enabled)
-			regmap_update_bits(gpr, IOMUXC_GPR13,
-					   IMX6Q_GPR13_ENET_STOP_REQ,
-					   IMX6Q_GPR13_ENET_STOP_REQ);
-
-		else
-			regmap_update_bits(gpr, IOMUXC_GPR13,
-					   IMX6Q_GPR13_ENET_STOP_REQ, 0);
-	} else
-		pr_err("failed to find fsl,imx6q-iomux-gpr regmap\n");
-}
-
-static void __init imx6q_enet_plt_init(void)
-{
-	struct device_node *np;
-
-	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@02188000");
-	if (np && of_get_property(np, "fsl,magic-packet", NULL))
-		fec_pdata.sleep_mode_enable = imx6q_fec_sleep_enable;
-}
-
 /* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
 static int ksz9021rn_phy_fixup(struct phy_device *phydev)
 {
@@ -292,12 +261,6 @@ static void __init imx6q_axi_init(void)
 	}
 }
 
-/* Add auxdata to pass platform data */
-static const struct of_dev_auxdata imx6q_auxdata_lookup[] __initconst = {
-	OF_DEV_AUXDATA("fsl,imx6q-fec", 0x02188000, NULL, &fec_pdata),
-	{ /* sentinel */ }
-};
-
 static void __init imx6q_init_machine(void)
 {
 	struct device *parent;
@@ -311,13 +274,11 @@ static void __init imx6q_init_machine(void)
 
 	imx6q_enet_phy_init();
 
-	of_platform_populate(NULL, of_default_bus_match_table,
-			     imx6q_auxdata_lookup, parent);
+	of_platform_populate(NULL, of_default_bus_match_table, NULL, parent);
 
 	imx_anatop_init();
 	cpu_is_imx6q() ?  imx6q_pm_init() : imx6dl_pm_init();
 	imx6q_1588_init();
-	imx6q_enet_plt_init();
 	imx6q_axi_init();
 }
 
diff --git a/arch/arm/mach-imx/mach-imx6sx.c b/arch/arm/mach-imx/mach-imx6sx.c
index 68fad21..66988eb 100644
--- a/arch/arm/mach-imx/mach-imx6sx.c
+++ b/arch/arm/mach-imx/mach-imx6sx.c
@@ -12,62 +12,12 @@
 #include <linux/regmap.h>
 #include <linux/mfd/syscon.h>
 #include <linux/mfd/syscon/imx6q-iomuxc-gpr.h>
-#include <linux/fec.h>
-#include <linux/netdevice.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
 
 #include "common.h"
 #include "cpuidle.h"
 
-static struct fec_platform_data fec_pdata[2];
-
-static void imx6sx_fec1_sleep_enable(int enabled)
-{
-	struct regmap *gpr;
-
-	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6sx-iomuxc-gpr");
-	if (!IS_ERR(gpr)) {
-		if (enabled)
-			regmap_update_bits(gpr, IOMUXC_GPR4,
-					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ,
-					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ);
-		else
-			regmap_update_bits(gpr, IOMUXC_GPR4,
-					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ, 0);
-	} else
-		pr_err("failed to find fsl,imx6sx-iomux-gpr regmap\n");
-}
-
-static void imx6sx_fec2_sleep_enable(int enabled)
-{
-	struct regmap *gpr;
-
-	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6sx-iomuxc-gpr");
-	if (!IS_ERR(gpr)) {
-		if (enabled)
-			regmap_update_bits(gpr, IOMUXC_GPR4,
-					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ,
-					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ);
-		else
-			regmap_update_bits(gpr, IOMUXC_GPR4,
-					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ, 0);
-	} else
-		pr_err("failed to find fsl,imx6sx-iomux-gpr regmap\n");
-}
-
-static void __init imx6sx_enet_plt_init(void)
-{
-	struct device_node *np;
-
-	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@02188000");
-	if (np && of_get_property(np, "fsl,magic-packet", NULL))
-		fec_pdata[0].sleep_mode_enable = imx6sx_fec1_sleep_enable;
-	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@021b4000");
-	if (np && of_get_property(np, "fsl,magic-packet", NULL))
-		fec_pdata[1].sleep_mode_enable = imx6sx_fec2_sleep_enable;
-}
-
 static int ar8031_phy_fixup(struct phy_device *dev)
 {
 	u16 val;
-- 
1.9.1

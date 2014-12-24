From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode callback function
Date: Wed, 24 Dec 2014 17:30:40 +0800
Message-ID: <1419413441-3406-3-git-send-email-b38611@freescale.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0114.outbound.protection.outlook.com ([157.56.111.114]:44211
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751096AbaLXKGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:06:08 -0500
In-Reply-To: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i.MX6q/dl, i.MX6SX SOCs enet support sleep mode that magic packet can
wake up system in suspend status. For different SOCs, there have some
SOC specifical GPR register to set sleep on/off mode. So add these to
callback function for driver.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/mach-imx/mach-imx6q.c  |   41 +++++++++++++++++++++++++++++++-
 arch/arm/mach-imx/mach-imx6sx.c |   50 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index 5057d61..2f76168 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -31,6 +31,8 @@
 #include <linux/micrel_phy.h>
 #include <linux/mfd/syscon.h>
 #include <linux/mfd/syscon/imx6q-iomuxc-gpr.h>
+#include <linux/fec.h>
+#include <linux/netdevice.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
 #include <asm/system_misc.h>
@@ -39,6 +41,35 @@
 #include "cpuidle.h"
 #include "hardware.h"
 
+static struct fec_platform_data fec_pdata;
+
+static void imx6q_fec_sleep_enable(int enabled)
+{
+	struct regmap *gpr;
+
+	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6q-iomuxc-gpr");
+	if (!IS_ERR(gpr)) {
+		if (enabled)
+			regmap_update_bits(gpr, IOMUXC_GPR13,
+					   IMX6Q_GPR13_ENET_STOP_REQ,
+					   IMX6Q_GPR13_ENET_STOP_REQ);
+
+		else
+			regmap_update_bits(gpr, IOMUXC_GPR13,
+					   IMX6Q_GPR13_ENET_STOP_REQ, 0);
+	} else
+		pr_err("failed to find fsl,imx6q-iomux-gpr regmap\n");
+}
+
+static void __init imx6q_enet_plt_init(void)
+{
+	struct device_node *np;
+
+	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@02188000");
+	if (np && of_get_property(np, "fsl,magic-packet", NULL))
+		fec_pdata.sleep_mode_enable = imx6q_fec_sleep_enable;
+}
+
 /* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
 static int ksz9021rn_phy_fixup(struct phy_device *phydev)
 {
@@ -261,6 +292,12 @@ static void __init imx6q_axi_init(void)
 	}
 }
 
+/* Add auxdata to pass platform data */
+static const struct of_dev_auxdata imx6q_auxdata_lookup[] __initconst = {
+	OF_DEV_AUXDATA("fsl,imx6q-fec", 0x02188000, NULL, &fec_pdata),
+	{ /* sentinel */ }
+};
+
 static void __init imx6q_init_machine(void)
 {
 	struct device *parent;
@@ -274,11 +311,13 @@ static void __init imx6q_init_machine(void)
 
 	imx6q_enet_phy_init();
 
-	of_platform_populate(NULL, of_default_bus_match_table, NULL, parent);
+	of_platform_populate(NULL, of_default_bus_match_table,
+			     imx6q_auxdata_lookup, parent);
 
 	imx_anatop_init();
 	cpu_is_imx6q() ?  imx6q_pm_init() : imx6dl_pm_init();
 	imx6q_1588_init();
+	imx6q_enet_plt_init();
 	imx6q_axi_init();
 }
 
diff --git a/arch/arm/mach-imx/mach-imx6sx.c b/arch/arm/mach-imx/mach-imx6sx.c
index 7a96c65..747b012 100644
--- a/arch/arm/mach-imx/mach-imx6sx.c
+++ b/arch/arm/mach-imx/mach-imx6sx.c
@@ -12,12 +12,62 @@
 #include <linux/regmap.h>
 #include <linux/mfd/syscon.h>
 #include <linux/mfd/syscon/imx6q-iomuxc-gpr.h>
+#include <linux/fec.h>
+#include <linux/netdevice.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
 
 #include "common.h"
 #include "cpuidle.h"
 
+static struct fec_platform_data fec_pdata[2];
+
+static void imx6sx_fec1_sleep_enable(int enabled)
+{
+	struct regmap *gpr;
+
+	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6sx-iomuxc-gpr");
+	if (!IS_ERR(gpr)) {
+		if (enabled)
+			regmap_update_bits(gpr, IOMUXC_GPR4,
+					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ,
+					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ);
+		else
+			regmap_update_bits(gpr, IOMUXC_GPR4,
+					   IMX6SX_GPR4_FEC_ENET1_STOP_REQ, 0);
+	} else
+		pr_err("failed to find fsl,imx6sx-iomux-gpr regmap\n");
+}
+
+static void imx6sx_fec2_sleep_enable(int enabled)
+{
+	struct regmap *gpr;
+
+	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6sx-iomuxc-gpr");
+	if (!IS_ERR(gpr)) {
+		if (enabled)
+			regmap_update_bits(gpr, IOMUXC_GPR4,
+					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ,
+					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ);
+		else
+			regmap_update_bits(gpr, IOMUXC_GPR4,
+					   IMX6SX_GPR4_FEC_ENET2_STOP_REQ, 0);
+	} else
+		pr_err("failed to find fsl,imx6sx-iomux-gpr regmap\n");
+}
+
+static void __init imx6sx_enet_plt_init(void)
+{
+	struct device_node *np;
+
+	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@02188000");
+	if (np && of_get_property(np, "fsl,magic-packet", NULL))
+		fec_pdata[0].sleep_mode_enable = imx6sx_fec1_sleep_enable;
+	np = of_find_node_by_path("/soc/aips-bus@02100000/ethernet@021b4000");
+	if (np && of_get_property(np, "fsl,magic-packet", NULL))
+		fec_pdata[1].sleep_mode_enable = imx6sx_fec2_sleep_enable;
+}
+
 static int ar8031_phy_fixup(struct phy_device *dev)
 {
 	u16 val;
-- 
1.7.8

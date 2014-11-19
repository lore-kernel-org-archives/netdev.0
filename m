From: Peter Griffin <peter.griffin@linaro.org>
Subject: [PATCH 1/7] phy: phy-stih407-usb: Pass sysconfig register offsets via syscfg property.
Date: Wed, 19 Nov 2014 08:27:06 +0000
Message-ID: <1416385632-5832-2-git-send-email-peter.griffin@linaro.org>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin@linaro.org, lee.jones@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	alexandre.torgue@st.com
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on Arnds review comments here https://lkml.org/lkml/2014/11/13/161, update
the phy driver to not use the reg property to access the sysconfig register offsets.

This is because other phy's (miphy28, miphy365) have a combination of memory mapped
registers and sysconfig control regs, and we shouldn't be mixing address spaces
in the reg property. In addition we would ideally like the sysconfig offsets to be
passed via DT in a uniform way. This new method will also allow us to support devices
which have sysconfig registers in different banks more easily and it is also analagous
to how keystone and bcm7745 platforms pass there syscon offsets in DT.

This breaks DT compatibility, but this platform is considered WIP, and is only
used by a few developers who are upstreaming support for it.

Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
---
 .../devicetree/bindings/phy/phy-stih407-usb.txt    | 10 ++-------
 drivers/phy/phy-stih407-usb.c                      | 25 ++++++++++++----------
 2 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/Documentation/devicetree/bindings/phy/phy-stih407-usb.txt b/Documentation/devicetree/bindings/phy/phy-stih407-usb.txt
index 1ef8228..de6a706 100644
--- a/Documentation/devicetree/bindings/phy/phy-stih407-usb.txt
+++ b/Documentation/devicetree/bindings/phy/phy-stih407-usb.txt
@@ -5,10 +5,7 @@ host controllers (when controlling usb2/1.1 devices) available on STiH407 SoC fa
 
 Required properties:
 - compatible		: should be "st,stih407-usb2-phy"
-- reg			: contain the offset and length of the system configuration registers
-			  used as glue logic to control & parameter phy
-- reg-names		: the names of the system configuration registers in "reg", should be "param" and "reg"
-- st,syscfg		: sysconfig register to manage phy parameter at driver level
+- st,syscfg		: phandle of sysconfig bank plus integer array containing phyparam and phyctrl register offsets
 - resets		: list of phandle and reset specifier pairs. There should be two entries, one
 			  for the whole phy and one for the port
 - reset-names		: list of reset signal names. Should be "global" and "port"
@@ -19,11 +16,8 @@ Example:
 
 usb2_picophy0: usbpicophy@f8 {
 	compatible	= "st,stih407-usb2-phy";
-	reg		= <0xf8 0x04>,	/* syscfg 5062 */
-			  <0xf4 0x04>;	/* syscfg 5061 */
-	reg-names	= "param", "ctrl";
 	#phy-cells	= <0>;
-	st,syscfg	= <&syscfg_core>;
+	st,syscfg	= <&syscfg_core 0x100 0xf4>;
 	resets		= <&softreset STIH407_PICOPHY_SOFTRESET>,
 			  <&picophyreset STIH407_PICOPHY0_RESET>;
 	reset-names	= "global", "port";
diff --git a/drivers/phy/phy-stih407-usb.c b/drivers/phy/phy-stih407-usb.c
index 42428d4..24d5e2a 100644
--- a/drivers/phy/phy-stih407-usb.c
+++ b/drivers/phy/phy-stih407-usb.c
@@ -22,6 +22,9 @@
 #include <linux/mfd/syscon.h>
 #include <linux/phy/phy.h>
 
+#define PHYPARAM_REG	1
+#define PHYCTRL_REG	2
+
 /* Default PHY_SEL and REFCLKSEL configuration */
 #define STIH407_USB_PICOPHY_CTRL_PORT_CONF	0x6
 #define STIH407_USB_PICOPHY_CTRL_PORT_MASK	0x1f
@@ -93,7 +96,7 @@ static int stih407_usb2_picophy_probe(struct platform_device *pdev)
 	struct device_node *np = dev->of_node;
 	struct phy_provider *phy_provider;
 	struct phy *phy;
-	struct resource *res;
+	int ret;
 
 	phy_dev = devm_kzalloc(dev, sizeof(*phy_dev), GFP_KERNEL);
 	if (!phy_dev)
@@ -123,19 +126,19 @@ static int stih407_usb2_picophy_probe(struct platform_device *pdev)
 		return PTR_ERR(phy_dev->regmap);
 	}
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ctrl");
-	if (!res) {
-		dev_err(dev, "No ctrl reg found\n");
-		return -ENXIO;
+	ret = of_property_read_u32_index(np, "st,syscfg", PHYPARAM_REG,
+					&phy_dev->param);
+	if (ret) {
+		dev_err(dev, "can't get phyparam offset (%d)\n", ret);
+		return ret;
 	}
-	phy_dev->ctrl = res->start;
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "param");
-	if (!res) {
-		dev_err(dev, "No param reg found\n");
-		return -ENXIO;
+	ret = of_property_read_u32_index(np, "st,syscfg", PHYCTRL_REG,
+					&phy_dev->ctrl);
+	if (ret) {
+		dev_err(dev, "can't get phyctrl offset (%d)\n", ret);
+		return ret;
 	}
-	phy_dev->param = res->start;
 
 	phy = devm_phy_create(dev, NULL, &stih407_usb2_picophy_data, NULL);
 	if (IS_ERR(phy)) {
-- 
1.9.1

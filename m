From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 3/3] net: davinci_emac: Get device MAC on 3517
Date: Wed, 28 Jan 2015 11:33:06 -0800
Message-ID: <1422473586-18100-4-git-send-email-tony@atomide.com>
References: <1422473586-18100-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.ore.mailhop.org ([54.186.10.118]:58292 "EHLO
	smtp5.ore.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbbA2COl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 21:14:41 -0500
In-Reply-To: <1422473586-18100-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like on 3517 davinci_emac MAC address registers have a
different layout compared to dm816x and am33xx.

Let's add a function to get the 3517 MAC address.

Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 arch/arm/boot/dts/am3517.dtsi          |  1 +
 drivers/net/ethernet/ti/davinci_emac.c | 35 +++++++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/am3517.dtsi b/arch/arm/boot/dts/am3517.dtsi
index 5a452fd..c90724b 100644
--- a/arch/arm/boot/dts/am3517.dtsi
+++ b/arch/arm/boot/dts/am3517.dtsi
@@ -31,6 +31,7 @@
 			status = "disabled";
 			reg = <0x5c000000 0x30000>;
 			interrupts = <67 68 69 70>;
+			syscon = <&omap3_scm_general>;
 			ti,davinci-ctrl-reg-offset = <0x10000>;
 			ti,davinci-ctrl-mod-reg-offset = <0>;
 			ti,davinci-ctrl-ram-offset = <0x20000>;
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index a716938..aeebc0a 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -52,6 +52,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/clk.h>
 #include <linux/platform_device.h>
+#include <linux/regmap.h>
 #include <linux/semaphore.h>
 #include <linux/phy.h>
 #include <linux/bitops.h>
@@ -65,6 +66,7 @@
 #include <linux/of_mdio.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
+#include <linux/mfd/syscon.h>
 
 #include <asm/irq.h>
 #include <asm/page.h>
@@ -1880,6 +1882,33 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	return  pdata;
 }
 
+static int davinci_emac_3517_get_macid(struct device *dev, u16 offset,
+				       int slave, u8 *mac_addr)
+{
+	u32 macid_lsb;
+	u32 macid_msb;
+	struct regmap *syscon;
+
+	syscon = syscon_regmap_lookup_by_phandle(dev->of_node, "syscon");
+	if (IS_ERR(syscon)) {
+		if (PTR_ERR(syscon) == -ENODEV)
+			return 0;
+		return PTR_ERR(syscon);
+	}
+
+	regmap_read(syscon, offset, &macid_lsb);
+	regmap_read(syscon, offset + 4, &macid_msb);
+
+	mac_addr[0] = (macid_msb >> 16) & 0xff;
+	mac_addr[1] = (macid_msb >> 8)  & 0xff;
+	mac_addr[2] = macid_msb & 0xff;
+	mac_addr[3] = (macid_lsb >> 16) & 0xff;
+	mac_addr[4] = (macid_lsb >> 8)  & 0xff;
+	mac_addr[5] = macid_lsb & 0xff;
+
+	return 0;
+}
+
 static int davinci_emac_try_get_mac(struct platform_device *pdev,
 				    int instance, u8 *mac_addr)
 {
@@ -1888,7 +1917,11 @@ static int davinci_emac_try_get_mac(struct platform_device *pdev,
 	if (!pdev->dev.of_node)
 		return error;
 
-	if (of_device_is_compatible(pdev->dev.of_node, "ti,dm816-emac"))
+	if (of_device_is_compatible(pdev->dev.of_node, "ti,am3517-emac"))
+		error = davinci_emac_3517_get_macid(&pdev->dev, 0x110,
+						    0, mac_addr);
+	else if (of_device_is_compatible(pdev->dev.of_node,
+					 "ti,dm816-emac"))
 		error = cpsw_am33xx_cm_get_macid(&pdev->dev, 0x30,
 						 instance,
 						 mac_addr);
-- 
2.1.4

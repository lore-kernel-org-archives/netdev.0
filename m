From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH] net: davinci_emac: Fix platform data handling and make
 usable for am3517
Date: Tue, 3 Dec 2013 15:13:02 -0800
Message-ID: <20131203231301.GN26766@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:29920 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab3LCXNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 18:13:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When booted with device tree, we may still have platform data passed
as auxdata. For am3517 this is needed for passing the interrupt_enable
and interrupt_disable callbacks that access the omap system control module
registers. These callback functions will eventually go away when we have
a separate system control module driver.

Some of the things that are currently passed as platform data we don't need
to set up as device tree properties as they are always the same on am3517.
So let's use a new compatible flag for those so we can get those from
the device tree match data.

Also note that we need to fix setting of phy_dev to NULL instead of an empty
string as the code later on uses that to find the first phy on the mdio bus.
This seems to have been caused by 5d69e0076a72 (net: davinci_emac: switch to
new mdio).

Signed-off-by: Tony Lindgren <tony@atomide.com>

--- a/Documentation/devicetree/bindings/net/davinci_emac.txt
+++ b/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -4,7 +4,7 @@ This file provides information, what the device node
 for the davinci_emac interface contains.
 
 Required properties:
-- compatible: "ti,davinci-dm6467-emac";
+- compatible: "ti,davinci-dm6467-emac" or "ti,am3517-emac"
 - reg: Offset and length of the register set for the device
 - ti,davinci-ctrl-reg-offset: offset to control register
 - ti,davinci-ctrl-mod-reg-offset: offset to control module register
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -61,6 +61,7 @@
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
+#include <linux/of_device.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
 
@@ -1752,10 +1753,14 @@ static const struct net_device_ops emac_netdev_ops = {
 #endif
 };
 
+static const struct of_device_id davinci_emac_of_match[];
+
 static struct emac_platform_data *
 davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 {
 	struct device_node *np;
+	const struct of_device_id *match;
+	const struct emac_platform_data *auxdata;
 	struct emac_platform_data *pdata = NULL;
 	const u8 *mac_addr;
 
@@ -1793,7 +1798,20 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
 	if (!priv->phy_node)
-		pdata->phy_id = "";
+		pdata->phy_id = NULL;
+
+	auxdata = pdev->dev.platform_data;
+	if (auxdata) {
+		pdata->interrupt_enable = auxdata->interrupt_enable;
+		pdata->interrupt_disable = auxdata->interrupt_disable;
+	}
+
+	match = of_match_device(davinci_emac_of_match, &pdev->dev);
+	if (match && match->data) {
+		auxdata = match->data;
+		pdata->version = auxdata->version;
+		pdata->hw_ram_addr = auxdata->hw_ram_addr;
+	}
 
 	pdev->dev.platform_data = pdata;
 
@@ -2020,8 +2038,14 @@ static const struct dev_pm_ops davinci_emac_pm_ops = {
 };
 
 #if IS_ENABLED(CONFIG_OF)
+static const struct emac_platform_data am3517_emac_data = {
+	.version		= EMAC_VERSION_2,
+	.hw_ram_addr		= 0x01e20000,
+};
+
 static const struct of_device_id davinci_emac_of_match[] = {
 	{.compatible = "ti,davinci-dm6467-emac", },
+	{.compatible = "ti,am3517-emac", .data = &am3517_emac_data, },
 	{},
 };
 MODULE_DEVICE_TABLE(of, davinci_emac_of_match);

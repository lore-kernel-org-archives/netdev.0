From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v4 2/5] net: davinci_mdio: enhance pinctrl support
Date: Wed, 5 Jun 2013 22:38:16 +0530
Message-ID: <1370452099-24026-3-git-send-email-mugunthanvnm@ti.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36201 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756718Ab3FERHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 13:07:46 -0400
In-Reply-To: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amend cpsw controller to optionally take a pin control handle and set
the state of the pins to:

- "default" on boot, resume
- "sleep" on suspend()

This should make it possible to optimize energy usage for the pins
for the suspend/resume cycle.

If any of the above pin states are missing in dt, a warning message
about the missing state is displayed.
If certain pin-states are not available, to remove this warning message
pass respective state name with null phandler.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |   45 ++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 12aec17..9e6aaeb 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -38,6 +38,7 @@
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/pinctrl/consumer.h>
 
 /*
  * This timeout definition is a worst-case ultra defensive measure against
@@ -94,6 +95,11 @@ struct davinci_mdio_data {
 	struct mii_bus	*bus;
 	bool		suspended;
 	unsigned long	access_time; /* jiffies */
+
+	/* Two optional pin states - default & sleep */
+	struct pinctrl		*pinctrl;
+	struct pinctrl_state	*pins_def;
+	struct pinctrl_state	*pins_sleep;
 };
 
 static void __davinci_mdio_reset(struct davinci_mdio_data *data)
@@ -347,6 +353,35 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 
+	data->pinctrl = devm_pinctrl_get(&pdev->dev);
+	if (!IS_ERR(data->pinctrl)) {
+		data->pins_def = pinctrl_lookup_state(data->pinctrl,
+						      PINCTRL_STATE_DEFAULT);
+		/* enable pins to be muxed in and configured */
+		if (IS_ERR(data->pins_def))
+			dev_warn(&pdev->dev, "could not get default pinstate\n");
+		else
+			if (pinctrl_select_state(data->pinctrl,
+						 data->pins_def))
+				dev_err(&pdev->dev,
+					"could not set default pins\n");
+
+		data->pins_sleep = pinctrl_lookup_state(data->pinctrl,
+							PINCTRL_STATE_SLEEP);
+		if (IS_ERR(data->pins_sleep))
+			dev_warn(&pdev->dev, "could not get sleep pinstate\n");
+	} else {
+		/* Since we continue even when pinctrl node is not found,
+		 * Invalidate pins as not available. This is to make sure that
+		 * IS_ERR(pins_xxx) results in failure when used.
+		 */
+		data->pins_def = ERR_PTR(-ENODATA);
+		data->pins_sleep = ERR_PTR(-ENODATA);
+
+		dev_warn(&pdev->dev,
+			 "pins are not configured from the driver\n");
+	}
+
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 	data->clk = clk_get(&pdev->dev, "fck");
@@ -454,6 +489,11 @@ static int davinci_mdio_suspend(struct device *dev)
 	data->suspended = true;
 	spin_unlock(&data->lock);
 
+	/* Optionally let pins go into sleep states */
+	if (!IS_ERR(data->pins_sleep))
+		if (pinctrl_select_state(data->pinctrl, data->pins_sleep))
+			dev_err(dev, "could not set pins to sleep state\n");
+
 	return 0;
 }
 
@@ -465,6 +505,11 @@ static int davinci_mdio_resume(struct device *dev)
 	spin_lock(&data->lock);
 	pm_runtime_get_sync(data->dev);
 
+	/* Optionaly enable pins to be muxed in and configured */
+	if (!IS_ERR(data->pins_def))
+		if (pinctrl_select_state(data->pinctrl, data->pins_def))
+			dev_err(dev, "could not set default pins\n");
+
 	/* restart the scan state machine */
 	ctrl = __raw_readl(&data->regs->control);
 	ctrl |= CONTROL_ENABLE;
-- 
1.7.9.5

From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 1/6] net: cpsw: enhance pinctrl support
Date: Thu, 23 May 2013 18:00:23 +0530
Message-ID: <1369312228-3308-2-git-send-email-mugunthanvnm@ti.com>
References: <1369312228-3308-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Hebbar Gururaja <gururaja.hebbar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:58272 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758440Ab3EWM3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 08:29:42 -0400
In-Reply-To: <1369312228-3308-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hebbar Gururaja <gururaja.hebbar@ti.com>

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

Signed-off-by: Hebbar Gururaja <gururaja.hebbar@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   49 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 21a5b29..1150f06 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -35,6 +35,7 @@
 #include <linux/if_vlan.h>
 
 #include <linux/platform_data/cpsw.h>
+#include <linux/pinctrl/consumer.h>
 
 #include "cpsw_ale.h"
 #include "cpts.h"
@@ -351,6 +352,11 @@ struct cpsw_priv {
 	bool irq_enabled;
 	struct cpts *cpts;
 	u32 emac_port;
+
+	/* Two optional pin states - default & sleep */
+	struct pinctrl		*pinctrl;
+	struct pinctrl_state	*pins_default;
+	struct pinctrl_state	*pins_sleep;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -1689,6 +1695,36 @@ static int cpsw_probe(struct platform_device *pdev)
 	 */
 	pm_runtime_enable(&pdev->dev);
 
+	priv->pinctrl = devm_pinctrl_get(&pdev->dev);
+	if (!IS_ERR(priv->pinctrl)) {
+		priv->pins_default = pinctrl_lookup_state(priv->pinctrl,
+							  PINCTRL_STATE_DEFAULT);
+		/* enable pins to be muxed in and configured */
+		if (IS_ERR(priv->pins_default))
+			dev_warn(&pdev->dev, "could not get default pinstate\n");
+		else
+			if (pinctrl_select_state(priv->pinctrl,
+						 priv->pins_default))
+				dev_err(&pdev->dev,
+					"could not set default pins\n");
+
+		priv->pins_sleep = pinctrl_lookup_state(priv->pinctrl,
+							PINCTRL_STATE_SLEEP);
+		if (IS_ERR(priv->pins_sleep))
+			dev_warn(&pdev->dev, "could not get sleep pinstate\n");
+	} else {
+		/*
+		* Since we continue even when pinctrl node is not found,
+		* Invalidate pins as not available. This is to make sure that
+		* IS_ERR(pins_xxx) results in failure when used.
+		*/
+		priv->pins_default = ERR_PTR(-ENODATA);
+		priv->pins_sleep = ERR_PTR(-ENODATA);
+
+		dev_warn(&pdev->dev,
+			 "pins are not configured from the driver\n");
+	}
+
 	if (cpsw_probe_dt(&priv->data, pdev)) {
 		pr_err("cpsw: platform data missing\n");
 		ret = -ENODEV;
@@ -1973,11 +2009,17 @@ static int cpsw_suspend(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
+	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
 	pm_runtime_put_sync(&pdev->dev);
 
+	/* Optionally let pins go into sleep states */
+	if (!IS_ERR(priv->pins_sleep))
+		if (pinctrl_select_state(priv->pinctrl, priv->pins_sleep))
+			dev_err(dev, "could not set pins to sleep state\n");
+
 	return 0;
 }
 
@@ -1985,8 +2027,15 @@ static int cpsw_resume(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
+	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	pm_runtime_get_sync(&pdev->dev);
+
+	/* Optionaly enable pins to be muxed in and configured */
+	if (!IS_ERR(priv->pins_default))
+		if (pinctrl_select_state(priv->pinctrl, priv->pins_default))
+			dev_err(dev, "could not set default pins\n");
+
 	if (netif_running(ndev))
 		cpsw_ndo_open(ndev);
 	return 0;
-- 
1.7.9.5

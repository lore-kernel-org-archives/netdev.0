From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Wed, 5 Jun 2013 22:38:15 +0530
Message-ID: <1370452099-24026-2-git-send-email-mugunthanvnm@ti.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Hebbar Gururaja <gururaja.hebbar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/ethernet/ti/cpsw.c |   48 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a45f64e..0599515 100644
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
+	struct pinctrl_state	*pins_def;
+	struct pinctrl_state	*pins_sleep;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -1691,6 +1697,35 @@ static int cpsw_probe(struct platform_device *pdev)
 	 */
 	pm_runtime_enable(&pdev->dev);
 
+	priv->pinctrl = devm_pinctrl_get(&pdev->dev);
+	if (!IS_ERR(priv->pinctrl)) {
+		priv->pins_def = pinctrl_lookup_state(priv->pinctrl,
+						      PINCTRL_STATE_DEFAULT);
+		/* enable pins to be muxed in and configured */
+		if (IS_ERR(priv->pins_def))
+			dev_warn(&pdev->dev, "could not get default pinstate\n");
+		else
+			if (pinctrl_select_state(priv->pinctrl,
+						 priv->pins_def))
+				dev_err(&pdev->dev,
+					"could not set default pins\n");
+
+		priv->pins_sleep = pinctrl_lookup_state(priv->pinctrl,
+							PINCTRL_STATE_SLEEP);
+		if (IS_ERR(priv->pins_sleep))
+			dev_warn(&pdev->dev, "could not get sleep pinstate\n");
+	} else {
+		/* Since we continue even when pinctrl node is not found,
+		 * Invalidate pins as not available. This is to make sure that
+		 * IS_ERR(pins_xxx) results in failure when used.
+		 */
+		priv->pins_def = ERR_PTR(-ENODATA);
+		priv->pins_sleep = ERR_PTR(-ENODATA);
+
+		dev_warn(&pdev->dev,
+			 "pins are not configured from the driver\n");
+	}
+
 	if (cpsw_probe_dt(&priv->data, pdev)) {
 		pr_err("cpsw: platform data missing\n");
 		ret = -ENODEV;
@@ -1974,11 +2009,17 @@ static int cpsw_suspend(struct device *dev)
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
 
@@ -1986,8 +2027,15 @@ static int cpsw_resume(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
+	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	pm_runtime_get_sync(&pdev->dev);
+
+	/* Optionaly enable pins to be muxed in and configured */
+	if (!IS_ERR(priv->pins_def))
+		if (pinctrl_select_state(priv->pinctrl, priv->pins_def))
+			dev_err(dev, "could not set default pins\n");
+
 	if (netif_running(ndev))
 		cpsw_ndo_open(ndev);
 	return 0;
-- 
1.7.9.5


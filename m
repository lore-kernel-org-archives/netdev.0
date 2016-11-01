From: Paul Cercueil <paul@crapouillou.net>
Subject: [PATCH 2/2] net: rfkill-regulator: Add devicetree support
Date: Tue,  1 Nov 2016 11:58:40 +0100
Message-ID: <20161101105840.24313-2-paul@crapouillou.net>
References: <20161101105840.24313-1-paul@crapouillou.net>
Cc: Maarten ter Huurne <maarten@treewalker.org>,
        Paul Cercueil <paul@crapouillou.net>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101105840.24313-1-paul@crapouillou.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds the support for probing the rfkill-regulator
from devicetree.

Information about the devicetree bindings can be found here:
Documentation/devicetree/bindings/net/rfkill-regulator.txt

Signed-off-by: Paul Cercueil <paul@crapouillou.net>
---
 net/rfkill/rfkill-regulator.c | 43 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index 50cd26a..29ded4c 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -13,6 +13,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/of.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/platform_device.h>
@@ -60,24 +61,38 @@ static struct rfkill_ops rfkill_regulator_ops = {
 static int rfkill_regulator_probe(struct platform_device *pdev)
 {
 	struct rfkill_regulator_platform_data *pdata = pdev->dev.platform_data;
+	struct device_node *node = pdev->dev.of_node;
 	struct rfkill_regulator_data *rfkill_data;
 	struct regulator *vcc;
 	struct rfkill *rf_kill;
+	const char *name;
+	u32 type;
 	int ret = 0;
 
-	if (pdata == NULL) {
+	if (pdata) {
+		if (!pdata->name || !pdata->type) {
+			dev_err(&pdev->dev, "invalid name or type in platform data\n");
+			return -EINVAL;
+		}
+
+		name = pdata->name;
+		type = pdata->type;
+	} else if (node) {
+		ret = of_property_read_u32(node, "rfkill-type", &type);
+		if (ret < 0)
+			return ret;
+
+		ret = of_property_read_string(node, "rfkill-name", &name);
+		if (ret < 0)
+			return ret;
+	} else {
 		dev_err(&pdev->dev, "no platform data\n");
 		return -ENODEV;
 	}
 
-	if (pdata->name == NULL || pdata->type == 0) {
-		dev_err(&pdev->dev, "invalid name or type in platform data\n");
-		return -EINVAL;
-	}
-
 	vcc = regulator_get_exclusive(&pdev->dev, "vrfkill");
 	if (IS_ERR(vcc)) {
-		dev_err(&pdev->dev, "Cannot get vcc for %s\n", pdata->name);
+		dev_err(&pdev->dev, "Cannot get vcc for %s\n", name);
 		ret = PTR_ERR(vcc);
 		goto out;
 	}
@@ -88,9 +103,8 @@ static int rfkill_regulator_probe(struct platform_device *pdev)
 		goto err_data_alloc;
 	}
 
-	rf_kill = rfkill_alloc(pdata->name, &pdev->dev,
-				pdata->type,
-				&rfkill_regulator_ops, rfkill_data);
+	rf_kill = rfkill_alloc(name, &pdev->dev, type,
+			       &rfkill_regulator_ops, rfkill_data);
 	if (rf_kill == NULL) {
 		ret = -ENOMEM;
 		goto err_rfkill_alloc;
@@ -110,7 +124,7 @@ static int rfkill_regulator_probe(struct platform_device *pdev)
 	}
 
 	platform_set_drvdata(pdev, rfkill_data);
-	dev_info(&pdev->dev, "%s initialized\n", pdata->name);
+	dev_info(&pdev->dev, "%s initialized\n", name);
 
 	return 0;
 
@@ -137,11 +151,18 @@ static int rfkill_regulator_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id rfkill_regulator_of_match[] = {
+	{ .compatible = "rfkill-regulator" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, rfkill_regulator_of_match);
+
 static struct platform_driver rfkill_regulator_driver = {
 	.probe = rfkill_regulator_probe,
 	.remove = rfkill_regulator_remove,
 	.driver = {
 		.name = "rfkill-regulator",
+		.of_match_table = of_match_ptr(rfkill_regulator_of_match),
 	},
 };
 
-- 
2.9.3

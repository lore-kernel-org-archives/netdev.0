From: Marek Belisko <marek@goldelico.com>
Subject: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Fri,  7 Feb 2014 20:48:49 +0100
Message-ID: <1391802529-29861-1-git-send-email-marek@goldelico.com>
Cc: neilb@suse.de, hns@goldelico.com, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Marek Belisko <marek@goldelico.com>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, grant.likely@linaro.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: Marek Belisko <marek@goldelico.com>
---
Based on Neil's patch and extend for documentation and bindings include.

 .../bindings/net/rfkill/rfkill-relugator.txt       | 28 ++++++++++++++++
 include/dt-bindings/net/rfkill-regulator.h         | 23 +++++++++++++
 net/rfkill/rfkill-regulator.c                      | 38 ++++++++++++++++++++++
 3 files changed, 89 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
 create mode 100644 include/dt-bindings/net/rfkill-regulator.h

diff --git a/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
new file mode 100644
index 0000000..cdb7dd7
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
@@ -0,0 +1,28 @@
+Regulator consumer for rfkill devices
+
+Required properties:
+- compatible   : Must be "rfkill-regulator".
+- label  : Name of rfkill device.
+- type  : Type of rfkill device.
+
+Possible values (defined in include/dt-bindings/net/rfkill-regulator.h):
+	RFKILL_TYPE_ALL
+	RFKILL_TYPE_WLAN
+	RFKILL_TYPE_BLUETOOTH
+	RFKILL_TYPE_UWB
+	RFKILL_TYPE_WIMAX
+	RFKILL_TYPE_WWAN
+	RFKILL_TYPE_GPS
+	RFKILL_TYPE_FM
+	RFKILL_TYPE_NFC
+
+- vrfkill-supply - regulator device.
+
+Example:
+	gps-rfkill {
+		compatible = "rfkill-regulator";
+		label = "GPS";
+		type = <RFKILL_TYPE_GPS>;
+		vrfkill-supply = <&reg>;
+	};
+
diff --git a/include/dt-bindings/net/rfkill-regulator.h b/include/dt-bindings/net/rfkill-regulator.h
new file mode 100644
index 0000000..ae32273
--- /dev/null
+++ b/include/dt-bindings/net/rfkill-regulator.h
@@ -0,0 +1,23 @@
+/*
+ * This header provides macros for rfkill-regulator bindings.
+ *
+ * Copyright (C) 2014 Marek Belisko <marek@goldelico.com>
+ *
+ * GPLv2 only
+ */
+
+#ifndef __DT_BINDINGS_RFKILL_REGULATOR_H__
+#define __DT_BINDINGS_RFKILL_REGULATOR_H__
+
+
+#define RFKILL_TYPE_ALL		(0)
+#define RFKILL_TYPE_WLAN	(1)
+#define RFKILL_TYPE_BLUETOOTH	(2)
+#define RFKILL_TYPE_UWB		(3)
+#define RFKILL_TYPE_WIMAX	(4)
+#define RFKILL_TYPE_WWAN	(5)
+#define RFKILL_TYPE_GPS		(6)
+#define RFKILL_TYPE_FM		(7)
+#define RFKILL_TYPE_NFC		(8)
+
+#endif /* __DT_BINDINGS_RFKILL_REGULATOR_H__ */
diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index cf5b145..a04aff8 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -19,6 +19,7 @@
 #include <linux/regulator/consumer.h>
 #include <linux/rfkill.h>
 #include <linux/rfkill-regulator.h>
+#include <linux/of_platform.h>
 
 struct rfkill_regulator_data {
 	struct rfkill *rf_kill;
@@ -57,6 +58,31 @@ static struct rfkill_ops rfkill_regulator_ops = {
 	.set_block = rfkill_regulator_set_block,
 };
 
+#ifdef CONFIG_OF
+static struct rfkill_regulator_platform_data *
+rfkill_regulator_parse_pdata(struct device *dev)
+{
+	struct rfkill_regulator_platform_data *pdata;
+	struct device_node *np = dev->of_node;
+	u32 num;
+	if (!np)
+		return NULL;
+	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return NULL;
+	if (of_property_read_u32(np, "type", &num) == 0)
+		pdata->type = num;
+	of_property_read_string(np, "label", &pdata->name);
+	return pdata;
+}
+#else
+static inline struct rfkill_regulator_platform_data *
+rfkill_regulator_parse_pdata(struct device *dev)
+{
+	return NULL;
+}
+#endif
+
 static int rfkill_regulator_probe(struct platform_device *pdev)
 {
 	struct rfkill_regulator_platform_data *pdata = pdev->dev.platform_data;
@@ -65,6 +91,9 @@ static int rfkill_regulator_probe(struct platform_device *pdev)
 	struct rfkill *rf_kill;
 	int ret = 0;
 
+	if (!pdata)
+		pdata = rfkill_regulator_parse_pdata(&pdev->dev);
+
 	if (pdata == NULL) {
 		dev_err(&pdev->dev, "no platform data\n");
 		return -ENODEV;
@@ -137,12 +166,21 @@ static int rfkill_regulator_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id rfkill_regulator_match[] = {
+	{.compatible = "rfkill-regulator"},
+	{}
+};
+MODULE_DEVICE_TABLE(of, rfkill_regulator_match);
+#endif
+
 static struct platform_driver rfkill_regulator_driver = {
 	.probe = rfkill_regulator_probe,
 	.remove = rfkill_regulator_remove,
 	.driver = {
 		.name = "rfkill-regulator",
 		.owner = THIS_MODULE,
+		.of_match_table = of_match_ptr(rfkill_regulator_match),
 	},
 };
 
-- 
1.8.3.2


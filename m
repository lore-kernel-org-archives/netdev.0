From: Robert Marklund <robert.marklund@stericsson.com>
Subject: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 08:56:37 +0200
Message-ID: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
Cc: Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>
To: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:37795 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574Ab1JQHGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 03:06:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some regulator support, there can be
necessary to add more regulators to suite
all power save needs. But this is a start.

Also add a wait for the chip to be ready after
the regulators are enabled, this was a bug in
the old implementation.

Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
---
 drivers/net/smsc911x.c |  113 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..4de3bd8 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -53,6 +53,8 @@
 #include <linux/phy.h>
 #include <linux/smsc911x.h>
 #include <linux/device.h>
+#include <linux/regulator/consumer.h>
+
 #include "smsc911x.h"
 
 #define SMSC_CHIPNAME		"smsc911x"
@@ -133,6 +135,10 @@ struct smsc911x_data {
 
 	/* register access functions */
 	const struct smsc911x_ops *ops;
+
+	/* regulators */
+	struct regulator *regulator_vddvario;
+	struct regulator *regulator_vdd33a;
 };
 
 /* Easy access to information */
@@ -357,6 +363,81 @@ out:
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
+/* Enable resources(clocks and regulators) */
+static int smsc911x_enable_resources(struct platform_device *pdev, bool enable)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int err = 0;
+
+	/* enable/diable regulator for vddvario */
+	if (pdata->regulator_vddvario) {
+		if (enable) {
+			err = regulator_enable(pdata->regulator_vddvario);
+			if (err < 0) {
+				netdev_err(ndev, "%s: regulator_enable failed '%s'\n",
+						__func__, "vddvario");
+			}
+		} else
+			err = regulator_disable(pdata->regulator_vdd33a);
+	}
+
+	/* enable/diableregulator for vdd33a */
+	if (pdata->regulator_vdd33a) {
+		if (enable) {
+			err = regulator_enable(pdata->regulator_vdd33a);
+			if (err < 0) {
+				netdev_err(ndev, "%s: regulator_enable failed '%s'\n",
+						__func__, "vdd33a");
+			}
+		} else
+			err = regulator_disable(pdata->regulator_vdd33a);
+	}
+	return err;
+}
+
+
+/* Request resources(clocks and regulators) */
+static int smsc911x_request_resources(struct platform_device *pdev,
+		bool request)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int err = 0;
+
+	/* Request regulator for vddvario */
+	if (request && !pdata->regulator_vddvario) {
+		pdata->regulator_vddvario = regulator_get(&pdev->dev,
+				"vddvario");
+		if (IS_ERR(pdata->regulator_vddvario)) {
+			netdev_warn(ndev,
+					"%s: Failed to get regulator '%s'\n",
+					__func__, "vddvario");
+			pdata->regulator_vddvario = NULL;
+		}
+	} else if (!request && pdata->regulator_vddvario) {
+		regulator_put(pdata->regulator_vddvario);
+		pdata->regulator_vddvario = NULL;
+	}
+
+	/* Request regulator for vdd33a */
+	if (request && !pdata->regulator_vddvario) {
+		pdata->regulator_vdd33a = regulator_get(&pdev->dev,
+				"vdd33a");
+		if (IS_ERR(pdata->regulator_vdd33a)) {
+			netdev_warn(ndev,
+					"%s: Failed to get regulator '%s'\n",
+					__func__, "vdd33a");
+			pdata->regulator_vdd33a = NULL;
+		}
+	} else if (!request && pdata->regulator_vdd33a) {
+		regulator_put(pdata->regulator_vdd33a);
+		pdata->regulator_vdd33a = NULL;
+	}
+
+	return err;
+}
+
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
  * and smsc911x_mac_write, so assumes mac_lock is held */
 static int smsc911x_mac_complete(struct smsc911x_data *pdata)
@@ -2047,6 +2128,7 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
 	struct resource *res;
+	int retval;
 
 	dev = platform_get_drvdata(pdev);
 	BUG_ON(!dev);
@@ -2074,6 +2156,12 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 
 	iounmap(pdata->ioaddr);
 
+	if (smsc911x_enable_resources(pdev, false))
+		pr_warn("Could not disable resource\n");
+
+	retval = smsc911x_request_resources(pdev, false);
+	/* ignore not all have regulators */
+
 	free_netdev(dev);
 
 	return 0;
@@ -2104,6 +2192,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	unsigned int intcfg = 0;
 	int res_size, irq_flags;
 	int retval;
+	int to = 100;
 
 	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
 
@@ -2158,6 +2247,17 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
 
+	platform_set_drvdata(pdev, dev);
+
+	retval = smsc911x_request_resources(pdev, true);
+	/* ignore not all have regulators */
+
+	retval = smsc911x_enable_resources(pdev, true);
+	if (retval) {
+		pr_warn("Could not enable resource\n");
+		goto out_0;
+	}
+
 	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
 		retval = -ENOMEM;
@@ -2170,6 +2270,18 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	if (config->shift)
 		pdata->ops = &shifted_smsc911x_ops;
 
+	/* poll the READY bit in PMT_CTRL. Any other access to the device is
+	 * forbidden while this bit isn't set. Try for 100ms
+	 */
+	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && --to)
+		udelay(1000);
+
+	if (to == 0) {
+		pr_err("Device not READY in 100ms aborting\n");
+		goto out_0;
+	}
+
+
 	retval = smsc911x_init(dev);
 	if (retval < 0)
 		goto out_unmap_io_3;
@@ -2262,6 +2374,7 @@ out_0:
 	return retval;
 }
 
+
 #ifdef CONFIG_PM
 /* This implementation assumes the devices remains powered on its VDDVARIO
  * pins during suspend. */
-- 
1.7.1

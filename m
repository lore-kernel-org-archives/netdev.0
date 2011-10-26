From: Linus Walleij <linus.walleij@stericsson.com>
Subject: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 10:05:56 +0200
Message-ID: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:60095 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754608Ab1JZISP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 04:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Marklund <robert.marklund@stericsson.com>

Add some basic regulator support for the power pins, as needed
by the ST-Ericsson Snowball platform that powers up the SMSC911
chip using an external regulator.

Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |  128 +++++++++++++++++++++++++++++++---
 1 files changed, 117 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8843071..fca01eb 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -44,6 +44,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/platform_device.h>
+#include <linux/regulator/consumer.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/bug.h>
@@ -138,6 +139,10 @@ struct smsc911x_data {
 
 	/* register access functions */
 	const struct smsc911x_ops *ops;
+
+	/* regulators */
+	struct regulator *regulator_vddvario;
+	struct regulator *regulator_vdd33a;
 };
 
 /* Easy access to information */
@@ -362,6 +367,86 @@ out:
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
+/*
+ * Enable or disable resources, currently just regulators.
+ */
+static int smsc911x_enable_disable_resources(struct platform_device *pdev,
+					     bool enable)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int err = 0;
+
+	/* enable/disable regulator for vddvario */
+	if (pdata->regulator_vddvario) {
+		if (enable) {
+			err = regulator_enable(pdata->regulator_vddvario);
+			if (err < 0) {
+			  netdev_err(ndev, "regulator_enable failed for "
+				     "vddvario");
+			}
+		} else
+			err = regulator_disable(pdata->regulator_vddvario);
+	}
+
+	/* enable/disable regulator for vdd33a */
+	if (pdata->regulator_vdd33a) {
+		if (enable) {
+			err = regulator_enable(pdata->regulator_vdd33a);
+			if (err < 0) {
+				netdev_err(ndev, "regulator_enable failed for "
+					   "vdd33a");
+			}
+		} else
+			err = regulator_disable(pdata->regulator_vdd33a);
+	}
+	return err;
+}
+
+/*
+ * Request or free resources, currently just regulators.
+ *
+ * The SMSC911x has two power pins: vddvario and vdd33a, in designs where
+ * these are not always-on we need to request regulators to be turned on
+ * before we can try to access the device registers.
+ */
+static int smsc911x_request_free_resources(struct platform_device *pdev,
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
+			netdev_err(ndev, "Failed to get regulator vddvario\n");
+			err = PTR_ERR(pdata->regulator_vddvario);
+			pdata->regulator_vddvario = NULL;
+		}
+	} else if (!request && pdata->regulator_vddvario) {
+		regulator_put(pdata->regulator_vddvario);
+		pdata->regulator_vddvario = NULL;
+	}
+
+	/* Request regulator for vdd33a */
+	if (request && !pdata->regulator_vdd33a) {
+		pdata->regulator_vdd33a = regulator_get(&pdev->dev, "vdd33a");
+		if (IS_ERR(pdata->regulator_vdd33a)) {
+			netdev_err(ndev, "Failed to get regulator vdd33a\n");
+			err = PTR_ERR(pdata->regulator_vdd33a);
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
@@ -2065,6 +2150,7 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
 	struct resource *res;
+	int retval;
 
 	dev = platform_get_drvdata(pdev);
 	BUG_ON(!dev);
@@ -2092,6 +2178,12 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 
 	iounmap(pdata->ioaddr);
 
+	if (smsc911x_enable_disable_resources(pdev, false))
+		pr_warn("Could not disable resource\n");
+
+	retval = smsc911x_request_free_resources(pdev, false);
+	/* ignore not all have regulators */
+
 	free_netdev(dev);
 
 	return 0;
@@ -2218,10 +2310,24 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
 
+	platform_set_drvdata(pdev, dev);
+
+	retval = smsc911x_request_free_resources(pdev, true);
+	if (retval) {
+		pr_err("Could request regulators needed aborting\n");
+		goto out_return_resources;
+	}
+
+	retval = smsc911x_enable_disable_resources(pdev, true);
+	if (retval) {
+		pr_err("Could enable regulators needed aborting\n");
+		goto out_disable_resources;
+	}
+
 	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
 		retval = -ENOMEM;
-		goto out_free_netdev_2;
+		goto out_disable_resources;
 	}
 
 	retval = smsc911x_probe_config_dt(&pdata->config, np);
@@ -2233,7 +2339,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
-		goto out_unmap_io_3;
+		goto out_disable_resources;
 	}
 
 	/* assume standard, non-shifted, access to HW registers */
@@ -2244,7 +2350,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	retval = smsc911x_init(dev);
 	if (retval < 0)
-		goto out_unmap_io_3;
+		goto out_disable_resources;
 
 	/* configure irq polarity and type before connecting isr */
 	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
@@ -2264,15 +2370,13 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	if (retval) {
 		SMSC_WARN(pdata, probe,
 			  "Unable to claim requested irq: %d", dev->irq);
-		goto out_unmap_io_3;
+		goto out_free_irq;
 	}
 
-	platform_set_drvdata(pdev, dev);
-
 	retval = register_netdev(dev);
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error %i registering device", retval);
-		goto out_unset_drvdata_4;
+		goto out_free_irq;
 	} else {
 		SMSC_TRACE(pdata, probe,
 			   "Network interface: \"%s\"", dev->name);
@@ -2321,12 +2425,14 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 out_unregister_netdev_5:
 	unregister_netdev(dev);
-out_unset_drvdata_4:
-	platform_set_drvdata(pdev, NULL);
+out_free_irq:
 	free_irq(dev->irq, dev);
-out_unmap_io_3:
+out_disable_resources:
+	(void)smsc911x_enable_disable_resources(pdev, false);
+out_return_resources:
+	(void)smsc911x_request_free_resources(pdev, false);
+	platform_set_drvdata(pdev, NULL);
 	iounmap(pdata->ioaddr);
-out_free_netdev_2:
 	free_netdev(dev);
 out_release_io_1:
 	release_mem_region(res->start, resource_size(res));
-- 
1.7.3.2

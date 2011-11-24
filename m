From: Robert Marklund <robert.marklund@stericsson.com>
Subject: [PATCH 2/2 v5] net/smsc911x: Add regulator support
Date: Thu, 24 Nov 2011 12:03:07 +0100
Message-ID: <1322132587-2049-1-git-send-email-robert.marklund@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mathieu Poirier <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, <linux-sh@vger.kernel.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>, <linux-omap@vger.kernel.org>,
	Mike Frysinger <vapier@gentoo.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	Linus Walleij <linus.walleij@linaro.org>
To: <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some basic regulator support for the power pins, as needed
by the ST-Ericsson Snowball platform that powers up the SMSC911
chip using an external regulator.

Platforms that use regulators and the smsc911x and have no defined
regulator for the smsc911x and claim complete regulator
constraints with no dummy regulators will need to provide it, for
example using a fixed voltage regulator. It appears that this may
affect (apart from Ux500 Snowball) possibly these archs/machines
that from some grep:s appear to define both CONFIG_SMSC911X and
CONFIG_REGULATOR:

- ARM Freescale mx3 and OMAP 2 plus, Raumfeld machines
- Blackfin
- Super-H

Cc: Paul Mundt <lethal@linux-sh.org>
Cc: linux-sh@vger.kernel.org
Cc: Sascha Hauer <s.hauer@pengutronix.de>
Cc: Tony Lindgren <tony@atomide.com>
Cc: linux-omap@vger.kernel.org
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
Reviewed-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
ChangeLog v4->v5:
- Split the enable_disable method on Mikes request.
ChangeLog v3->v4:
- Remove dual prints and old comment on Mike's request.
- Split the request_free fucntion on Mike and Sascha request.
ChangeLog v2->v3:
- Use bulk regulators on Mark's request.
- Add Cc-fileds to some possibly affected platforms.
ChangeLog v1->v2:
- Don't check for NULL regulators and error out properly if the
  regulators can't be found. All platforms using the smsc911x
  and the regulator framework simultaneously need to provide some
  kind of regulator for it.
---
 drivers/net/ethernet/smsc/smsc911x.c |  111 ++++++++++++++++++++++++++++++----
 1 files changed, 100 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8843071..06d0df6 100644
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
@@ -88,6 +89,8 @@ struct smsc911x_ops {
 				unsigned int *buf, unsigned int wordcount);
 };
 
+#define SMSC911X_NUM_SUPPLIES 2
+
 struct smsc911x_data {
 	void __iomem *ioaddr;
 
@@ -138,6 +141,9 @@ struct smsc911x_data {
 
 	/* register access functions */
 	const struct smsc911x_ops *ops;
+
+	/* regulators */
+	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
 };
 
 /* Easy access to information */
@@ -362,6 +368,76 @@ out:
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
+/*
+ * enable resources, currently just regulators.
+ */
+static int smsc911x_enable_resources(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int ret = 0;
+
+	ret = regulator_bulk_enable(ARRAY_SIZE(pdata->supplies),
+			pdata->supplies);
+	if (ret)
+		netdev_err(ndev, "failed to enable regulators %d\n",
+				ret);
+	return ret;
+}
+
+/*
+ * disable resources, currently just regulators.
+ */
+static int smsc911x_disable_resources(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int ret = 0;
+
+	ret = regulator_bulk_disable(ARRAY_SIZE(pdata->supplies),
+			pdata->supplies);
+	return ret;
+}
+
+/*
+ * Request resources, currently just regulators.
+ *
+ * The SMSC911x has two power pins: vddvario and vdd33a, in designs where
+ * these are not always-on we need to request regulators to be turned on
+ * before we can try to access the device registers.
+ */
+static int smsc911x_request_resources(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+	int ret = 0;
+
+	/* Request regulators */
+	pdata->supplies[0].supply = "vdd33a";
+	pdata->supplies[1].supply = "vddvario";
+	ret = regulator_bulk_get(&pdev->dev,
+			ARRAY_SIZE(pdata->supplies),
+			pdata->supplies);
+	if (ret)
+		netdev_err(ndev, "couldn't get regulators %d\n",
+				ret);
+	return ret;
+}
+
+/*
+ * Free resources, currently just regulators.
+ *
+ */
+static void smsc911x_free_resources(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(ndev);
+
+	/* Free regulators */
+	regulator_bulk_free(ARRAY_SIZE(pdata->supplies),
+			pdata->supplies);
+}
+
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
  * and smsc911x_mac_write, so assumes mac_lock is held */
 static int smsc911x_mac_complete(struct smsc911x_data *pdata)
@@ -2092,6 +2168,9 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 
 	iounmap(pdata->ioaddr);
 
+	(void)smsc911x_disable_resources(pdev);
+	smsc911x_free_resources(pdev);
+
 	free_netdev(dev);
 
 	return 0;
@@ -2218,10 +2297,20 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
 
+	platform_set_drvdata(pdev, dev);
+
+	retval = smsc911x_request_resources(pdev);
+	if (retval)
+		goto out_return_resources;
+
+	retval = smsc911x_enable_resources(pdev);
+	if (retval)
+		goto out_disable_resources;
+
 	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
 		retval = -ENOMEM;
-		goto out_free_netdev_2;
+		goto out_disable_resources;
 	}
 
 	retval = smsc911x_probe_config_dt(&pdata->config, np);
@@ -2233,7 +2322,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
-		goto out_unmap_io_3;
+		goto out_disable_resources;
 	}
 
 	/* assume standard, non-shifted, access to HW registers */
@@ -2244,7 +2333,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	retval = smsc911x_init(dev);
 	if (retval < 0)
-		goto out_unmap_io_3;
+		goto out_disable_resources;
 
 	/* configure irq polarity and type before connecting isr */
 	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
@@ -2264,15 +2353,13 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
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
@@ -2321,12 +2408,14 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 out_unregister_netdev_5:
 	unregister_netdev(dev);
-out_unset_drvdata_4:
-	platform_set_drvdata(pdev, NULL);
+out_free_irq:
 	free_irq(dev->irq, dev);
-out_unmap_io_3:
+out_disable_resources:
+	(void)smsc911x_disable_resources(pdev);
+out_return_resources:
+	smsc911x_free_resources(pdev);
+	platform_set_drvdata(pdev, NULL);
 	iounmap(pdata->ioaddr);
-out_free_netdev_2:
 	free_netdev(dev);
 out_release_io_1:
 	release_mem_region(res->start, resource_size(res));
-- 
1.7.1


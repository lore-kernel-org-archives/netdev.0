From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH] net/smsc911x: add device tree probe support
Date: Mon, 25 Jul 2011 17:44:00 +0800
Message-ID: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>, <patches@linaro.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:38600 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab1GYJhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 05:37:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It adds device tree probe support for smsc911x driver.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
Cc: David S. Miller <davem@davemloft.net>
---
 Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
 drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
 2 files changed, 132 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc.txt

diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
new file mode 100644
index 0000000..1920695
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc.txt
@@ -0,0 +1,34 @@
+* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
+
+Required properties:
+- compatible : Should be "smsc,lan<model>""smsc,lan"
+- reg : Address and length of the io space for SMSC LAN
+- smsc-int-gpios : Should specify the GPIO for SMSC LAN interrupt line
+- phy-mode : String, operation mode of the PHY interface.
+  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
+  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
+
+Optional properties:
+- smsc,irq-active-high : Indicates the IRQ polarity is active-low
+- smsc,irq-push-pull : Indicates the IRQ type is push-pull
+- smsc,register-needs-shift : Indicates the register access needs shift
+- smsc,access-in-32bit : Indicates the access to controller is in 32-bit
+  mode
+- smsc,force-internal-phy : Forces SMSC LAN controller to use
+  internal PHY
+- smsc,force-external-phy : Forces SMSC LAN controller to use
+  external PHY
+- smsc,save-mac-address : Indicates that mac address needs to be saved
+  before resetting the controller
+- local-mac-address : 6 bytes, mac address
+
+Examples:
+
+lan9220@f4000000 {
+	compatible = "smsc,lan9220", "smsc,lan";
+	reg = <0xf4000000 0x2000000>;
+	phy-mode = "mii";
+	smsc-int-gpios = <&gpio1 31 0>; /* GPIO2_31 */
+	smsc,irq-push-pull;
+	smsc,access-in-32bit;
+};
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..0097048 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -53,6 +53,10 @@
 #include <linux/phy.h>
 #include <linux/smsc911x.h>
 #include <linux/device.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_gpio.h>
+#include <linux/of_net.h>
 #include "smsc911x.h"
 
 #define SMSC_CHIPNAME		"smsc911x"
@@ -2095,25 +2099,67 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
 	.tx_writefifo = smsc911x_tx_writefifo_shift,
 };
 
+#ifdef CONFIG_OF
+static int __devinit smsc911x_probe_config_dt(
+				struct smsc911x_platform_config *config,
+				struct device_node *np)
+{
+	const char *mac;
+
+	if (!np)
+		return -ENODEV;
+
+	config->phy_interface = of_get_phy_mode(np);
+
+	mac = of_get_mac_address(np);
+	if (mac)
+		memcpy(config->mac, mac, ETH_ALEN);
+
+	if (of_get_property(np, "smsc,irq-active-high", NULL))
+		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
+
+	if (of_get_property(np, "smsc,irq-push-pull", NULL))
+		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
+
+	if (of_get_property(np, "smsc,register-needs-shift", NULL))
+		config->shift = 1;
+
+	if (of_get_property(np, "smsc,access-in-32bit", NULL))
+		config->flags |= SMSC911X_USE_32BIT;
+
+	if (of_get_property(np, "smsc,force-internal-phy", NULL))
+		config->flags |= SMSC911X_FORCE_INTERNAL_PHY;
+
+	if (of_get_property(np, "smsc,force-external-phy", NULL))
+		config->flags |= SMSC911X_FORCE_EXTERNAL_PHY;
+
+	if (of_get_property(np, "smsc,save-mac-address", NULL))
+		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
+
+	return 0;
+}
+#else
+static inline int smsc911x_probe_config_dt(
+				struct smsc911x_platform_config *config,
+				struct device_node *np)
+{
+	return -ENODEV;
+}
+#endif /* CONFIG_OF */
+
 static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 {
+	struct device_node *np = pdev->dev.of_node;
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
 	struct smsc911x_platform_config *config = pdev->dev.platform_data;
 	struct resource *res, *irq_res;
 	unsigned int intcfg = 0;
-	int res_size, irq_flags;
-	int retval;
+	int irq_gpio, res_size, irq_flags = 0;
+	int retval = 0;
 
 	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
 
-	/* platform data specifies irq & dynamic bus configuration */
-	if (!pdev->dev.platform_data) {
-		pr_warn("platform_data not provided\n");
-		retval = -ENODEV;
-		goto out_0;
-	}
-
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
 	if (!res)
@@ -2125,13 +2171,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	}
 	res_size = resource_size(res);
 
-	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!irq_res) {
-		pr_warn("Could not allocate irq resource\n");
-		retval = -ENODEV;
-		goto out_0;
-	}
-
 	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
 		retval = -EBUSY;
 		goto out_0;
@@ -2148,26 +2187,53 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	pdata = netdev_priv(dev);
 
-	dev->irq = irq_res->start;
-	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
-	pdata->ioaddr = ioremap_nocache(res->start, res_size);
-
-	/* copy config parameters across to pdata */
-	memcpy(&pdata->config, config, sizeof(pdata->config));
+	if (np) {
+		irq_gpio = of_get_named_gpio(np, "smsc-int-gpios", 0);
+		retval = gpio_request_one(irq_gpio, GPIOF_IN, "smsc-int-gpio");
+		if (!retval)
+			dev->irq = gpio_to_irq(irq_gpio);
+	} else {
+		irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+		if (irq_res) {
+			dev->irq = irq_res->start;
+			irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
+		} else {
+			retval = -ENODEV;
+		}
+	}
 
-	pdata->dev = dev;
-	pdata->msg_enable = ((1 << debug) - 1);
+	if (retval) {
+		SMSC_WARN(pdata, probe, "Error smsc911x irq not found");
+		retval = -EINVAL;
+		goto out_free_netdev_2;
+	}
 
+	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
 		retval = -ENOMEM;
 		goto out_free_netdev_2;
 	}
 
+	pdata->dev = dev;
+	pdata->msg_enable = ((1 << debug) - 1);
+
+	retval = smsc911x_probe_config_dt(&pdata->config, np);
+	if (retval && config) {
+		/* copy config parameters across to pdata */
+		memcpy(&pdata->config, config, sizeof(pdata->config));
+		retval = 0;
+	}
+
+	if (retval) {
+		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
+		goto out_unmap_io_3;
+	}
+
 	/* assume standard, non-shifted, access to HW registers */
 	pdata->ops = &standard_smsc911x_ops;
 	/* apply the right access if shifting is needed */
-	if (config->shift)
+	if (pdata->config.shift)
 		pdata->ops = &shifted_smsc911x_ops;
 
 	retval = smsc911x_init(dev);
@@ -2314,6 +2380,12 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
 #define SMSC911X_PM_OPS NULL
 #endif
 
+static const struct of_device_id smsc_dt_ids[] = {
+	{ .compatible = "smsc,lan", },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, smsc_dt_ids);
+
 static struct platform_driver smsc911x_driver = {
 	.probe = smsc911x_drv_probe,
 	.remove = __devexit_p(smsc911x_drv_remove),
@@ -2321,6 +2393,7 @@ static struct platform_driver smsc911x_driver = {
 		.name	= SMSC_CHIPNAME,
 		.owner	= THIS_MODULE,
 		.pm	= SMSC911X_PM_OPS,
+		.of_match_table = smsc_dt_ids,
 	},
 };
 
-- 
1.7.4.1



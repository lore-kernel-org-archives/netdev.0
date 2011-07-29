From: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2] net/smsc911x: add device tree probe support
Date: Fri, 29 Jul 2011 16:43:16 +0800
Message-ID: <1311928996-10729-1-git-send-email-shawn.guo@linaro.org>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1311587040-8988-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

It adds device tree probe support for smsc911x driver.

Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
Changes since v1:
 * Instead of getting irq line from gpio number, it use irq domain
   to keep platform_get_resource(IORESOURCE_IRQ) works for dt too.
 * Use 'lan9115' the first model that smsc911x supports in the match
   table
 * Use reg-shift and reg-io-width which already used in of_serial for
   shift and access size binding

 Documentation/devicetree/bindings/net/smsc911x.txt |   38 +++++++++
 drivers/net/smsc911x.c                             |   85 +++++++++++++++++---
 2 files changed, 112 insertions(+), 11 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc911x.txt

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
new file mode 100644
index 0000000..271c454
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -0,0 +1,38 @@
+* Smart Mixed-Signal Connectivity (SMSC) LAN911x/912x Controller
+
+Required properties:
+- compatible : Should be "smsc,lan<model>", "smsc,lan9115"
+- reg : Address and length of the io space for SMSC LAN
+- interrupts : Should contain SMSC LAN interrupt line
+- interrupt-parent : Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- phy-mode : String, operation mode of the PHY interface.
+  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
+  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
+
+Optional properties:
+- reg-shift : Specify the quantity to shift the register offsets by
+- reg-io-width : Specify the size (in bytes) of the IO accesses that
+  should be performed on the device.  Valid value for SMSC LAN is
+  2 or 4.  If it's omitted or invalid, the size would be 2.
+- smsc,irq-active-high : Indicates the IRQ polarity is active-low
+- smsc,irq-push-pull : Indicates the IRQ type is push-pull
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
+	compatible = "smsc,lan9220", "smsc,lan9115";
+	reg = <0xf4000000 0x2000000>;
+	phy-mode = "mii";
+	interrupt-parent = <&gpio1>;
+	interrupts = <31>;
+	reg-io-width = <4>;
+	smsc,irq-push-pull;
+};
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..75c08a5 100644
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
@@ -2095,8 +2099,58 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
 	.tx_writefifo = smsc911x_tx_writefifo_shift,
 };
 
+#ifdef CONFIG_OF
+static int __devinit smsc911x_probe_config_dt(
+				struct smsc911x_platform_config *config,
+				struct device_node *np)
+{
+	const char *mac;
+	u32 width = 0;
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
+	of_property_read_u32(np, "reg-shift", &config->shift);
+
+	of_property_read_u32(np, "reg-io-width", &width);
+	if (width == 4)
+		config->flags |= SMSC911X_USE_32BIT;
+
+	if (of_get_property(np, "smsc,irq-active-high", NULL))
+		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
+
+	if (of_get_property(np, "smsc,irq-push-pull", NULL))
+		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
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
@@ -2107,13 +2161,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
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
@@ -2152,9 +2199,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
-	/* copy config parameters across to pdata */
-	memcpy(&pdata->config, config, sizeof(pdata->config));
-
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
 
@@ -2164,10 +2208,22 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev_2;
 	}
 
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
@@ -2314,6 +2370,12 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
 #define SMSC911X_PM_OPS NULL
 #endif
 
+static const struct of_device_id smsc911x_dt_ids[] = {
+	{ .compatible = "smsc,lan9115", },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
+
 static struct platform_driver smsc911x_driver = {
 	.probe = smsc911x_drv_probe,
 	.remove = __devexit_p(smsc911x_drv_remove),
@@ -2321,6 +2383,7 @@ static struct platform_driver smsc911x_driver = {
 		.name	= SMSC_CHIPNAME,
 		.owner	= THIS_MODULE,
 		.pm	= SMSC911X_PM_OPS,
+		.of_match_table = smsc911x_dt_ids,
 	},
 };
 
-- 
1.7.4.1

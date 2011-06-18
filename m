From: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] net/fec: add device tree support
Date: Sat, 18 Jun 2011 23:19:13 +0800
Message-ID: <1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1308410354-21387-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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

It adds device tree data parsing support for fec driver.

Signed-off-by: Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |   14 ++++++++++
 drivers/net/fec.c                                 |   28 +++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
new file mode 100644
index 0000000..705111d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -0,0 +1,14 @@
+* Freescale Fast Ethernet Controller (FEC)
+
+Required properties:
+- compatible : should be "fsl,<soc>-fec", "fsl,fec"
+- reg : address and length of the register set for the device
+- interrupts : should contain fec interrupt
+
+Example:
+
+fec@83fec000 {
+	compatible = "fsl,imx51-fec", "fsl,fec";
+	reg = <0x83fec000 0x4000>;
+	interrupts = <87>;
+};
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 885d8ba..ef3d175 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -44,6 +44,8 @@
 #include <linux/platform_device.h>
 #include <linux/phy.h>
 #include <linux/fec.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
 
 #include <asm/cacheflush.h>
 
@@ -78,6 +80,26 @@ static struct platform_device_id fec_devtype[] = {
 	{ }
 };
 
+#ifdef CONFIG_OF
+static const struct of_device_id fec_dt_ids[] = {
+	{ .compatible = "fsl,fec", .data = &fec_devtype[0], },
+	{},
+};
+
+static const struct of_device_id *
+fec_get_of_device_id(struct platform_device *pdev)
+{
+	return of_match_device(fec_dt_ids, &pdev->dev);
+}
+#else
+#define fec_dt_ids NULL
+static inline struct of_device_id *
+fec_get_of_device_id(struct platform_device *pdev)
+{
+	return NULL;
+}
+#endif
+
 static unsigned char macaddr[ETH_ALEN];
 module_param_array(macaddr, byte, NULL, 0);
 MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
@@ -1363,6 +1385,11 @@ fec_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	int i, irq, ret = 0;
 	struct resource *r;
+	const struct of_device_id *of_id;
+
+	of_id = fec_get_of_device_id(pdev);
+	if (of_id)
+		pdev->id_entry = (struct platform_device_id *) of_id->data;
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!r)
@@ -1531,6 +1558,7 @@ static struct platform_driver fec_driver = {
 #ifdef CONFIG_PM
 		.pm	= &fec_pm_ops,
 #endif
+		.of_match_table = fec_dt_ids,
 	},
 	.id_table = fec_devtype,
 	.probe	= fec_probe,
-- 
1.7.4.1

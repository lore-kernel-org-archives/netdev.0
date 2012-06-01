From: <s-paulraj-l0cyMroinI0@public.gmane.org>
Subject: [PATCH] net: add device tree support for davinci mdio
Date: Fri, 1 Jun 2012 14:38:50 -0400
Message-ID: <1338575930-32075-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sandeep Paulraj <s-paulraj-l0cyMroinI0@public.gmane.org>

This patch adds device tree support in the DaVinci MDIO driver.
The driver is currently being used in DaVinci and OMAP based SOCs; not all of
which have device tree support.
The davinci mdio driver has a way to set the bus frequency
using platform data. There is however no way to pass this information
from device tree.
This patch first looks for a device tree node; if it finds
a node then it looks for the bus frequency from the device tree
bindings. Else it tries to obtain this from platform data.

The new bindings are also explained in the the Documentation for
davini_mdio

Signed-off-by: Sandeep Paulraj <s-paulraj-l0cyMroinI0@public.gmane.org>
---
 .../devicetree/bindings/net/davinci_mdio.txt       |   16 ++++++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c             |   19 ++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/davinci_mdio.txt

diff --git a/Documentation/devicetree/bindings/net/davinci_mdio.txt b/Documentation/devicetree/bindings/net/davinci_mdio.txt
new file mode 100644
index 0000000..545e216
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davinci_mdio.txt
@@ -0,0 +1,16 @@
+MDIO on DaVinci SOCs
+
+Currently defined compatibles:
+- ti,davinci-mdio
+
+Required properties:
+- bus-frequency: The operating frequency of the mdio bus
+
+Example:
+
+mdio: mdio@2090300 {
+			compatible	= "ti,davinci-mdio";
+			reg		= <0x2090300 0x100>;
+			bus-frequency	= <50000000>;
+		};
+
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index af8b8fc..efa13c5 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -34,6 +34,7 @@
 #include <linux/clk.h>
 #include <linux/err.h>
 #include <linux/io.h>
+#include <linux/of.h>
 #include <linux/davinci_emac.h>
 
 /*
@@ -286,11 +287,13 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = pdev->dev.platform_data;
+	struct device_node *node = pdev->dev.of_node;
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data;
 	struct resource *res;
 	struct phy_device *phy;
 	int ret, addr;
+	u32 bus_freq;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (!data) {
@@ -298,7 +301,15 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	data->pdata = pdata ? (*pdata) : default_pdata;
+	if (node) {
+		ret = of_property_read_u32(node, "bus-frequency", &bus_freq);
+		if (ret < 0) {
+			dev_info(&pdev->dev, "Using default bus frequency\n");
+			bus_freq = 50000000;
+		}
+		data->pdata.bus_freq = bus_freq;
+	} else
+		data->pdata = pdata ? (*pdata) : default_pdata;
 
 	data->bus = mdiobus_alloc();
 	if (!data->bus) {
@@ -450,11 +461,17 @@ static const struct dev_pm_ops davinci_mdio_pm_ops = {
 	.resume		= davinci_mdio_resume,
 };
 
+static struct of_device_id __devinitdata of_match[] = {
+	{ .compatible = "ti,davinci-mdio", },
+	{},
+};
+
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
 		.name	 = "davinci_mdio",
 		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_mdio_pm_ops,
+		.of_match_table	= of_match,
 	},
 	.probe = davinci_mdio_probe,
 	.remove = __devexit_p(davinci_mdio_remove),
-- 
1.7.9.5

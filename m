From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 1/2] net/macb: add DT support for Cadence macb/gem driver
Date: Mon,  5 Dec 2011 12:59:52 +0100
Message-ID: <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
References: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1322847782-22650-1-git-send-email-nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
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

From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>

Allow the device tree to provide the mac address and the phy mode.

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
[nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org: change "compatible" node property, doc and DT hwaddr]
Signed-off-by: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
[jamie-wmLquQDDieKakBO8gow8eQ@public.gmane.org: add "gem" compatibility strings and doc]
Acked-by: Jamie Iles<jamie-wmLquQDDieKakBO8gow8eQ@public.gmane.org>
---
v3: add "gem" compatibility strings
v2: modify macb_get_hwaddr_dt() parameter

 Documentation/devicetree/bindings/net/macb.txt |   24 ++++++++
 drivers/net/ethernet/cadence/macb.c            |   73 +++++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h            |    2 +
 3 files changed, 91 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/macb.txt

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
new file mode 100644
index 0000000..2e24f05
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -0,0 +1,24 @@
+* Cadence MACB/GEM Ethernet controller
+
+Required properties:
+- compatible: Should be "cdns,[<chip>-]{macb|gem}"
+  Use "cdns,at91sam9260-macb" Atmel at91sam9260 and at91sam9263 SoCs.
+  Use "cdns,at32ap7000-macb" for other 10/100 usage or use the generic form: "cdns,macb".
+  Use "cnds,pc302-gem" for Picochip picoXcell pc302 and later devices based on
+  the Cadence GEM, or the generic form: "cdns,gem".
+- reg: Address and length of the register set for the device
+- interrupts: Should contain macb interrupt
+- phy-mode: String, operation mode of the PHY interface.
+  Supported values are: "mii", "rmii", "gmii", "rgmii".
+
+Optional properties:
+- local-mac-address: 6 bytes, mac address
+
+Examples:
+
+	macb0: ethernet@fffc4000 {
+		compatible = "cdns,at32ap7000-macb";
+		reg = <0xfffc4000 0x4000>;
+		interrupts = <21>;
+		phy-mode = "rmii";
+	};
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 64d6146..baf1a0d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -23,6 +23,8 @@
 #include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
 
 #include "macb.h"
 
@@ -191,7 +193,6 @@ static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev;
-	struct macb_platform_data *pdata;
 	int ret;
 
 	phydev = phy_find_first(bp->mii_bus);
@@ -200,14 +201,11 @@ static int macb_mii_probe(struct net_device *dev)
 		return -1;
 	}
 
-	pdata = bp->pdev->dev.platform_data;
 	/* TODO : add pin_irq */
 
 	/* attach the mac to the phy */
 	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change, 0,
-				 pdata && pdata->is_rmii ?
-				 PHY_INTERFACE_MODE_RMII :
-				 PHY_INTERFACE_MODE_MII);
+				 bp->phy_interface);
 	if (ret) {
 		netdev_err(dev, "Could not attach to PHY\n");
 		return ret;
@@ -1244,6 +1242,52 @@ static const struct net_device_ops macb_netdev_ops = {
 #endif
 };
 
+#if defined(CONFIG_OF)
+static const struct of_device_id macb_dt_ids[] = {
+	{ .compatible = "cdns,at32ap7000-macb" },
+	{ .compatible = "cdns,at91sam9260-macb" },
+	{ .compatible = "cdns,macb" },
+	{ .compatible = "cdns,pc302-gem" },
+	{ .compatible = "cdns,gem" },
+	{ /* sentinel */ }
+};
+
+MODULE_DEVICE_TABLE(of, macb_dt_ids);
+
+static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+
+	if (np)
+		return of_get_phy_mode(np);
+
+	return -ENODEV;
+}
+
+static int __devinit macb_get_hwaddr_dt(struct macb *bp)
+{
+	struct device_node *np = bp->pdev->dev.of_node;
+	if (np) {
+		const char *mac = of_get_mac_address(np);
+		if (mac) {
+			memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
+			return 0;
+		}
+	}
+
+	return -ENODEV;
+}
+#else
+static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
+{
+	return -ENODEV;
+}
+static int __devinit macb_get_hwaddr_dt(struct macb *bp)
+{
+	return -ENODEV;
+}
+#endif
+
 static int __init macb_probe(struct platform_device *pdev)
 {
 	struct macb_platform_data *pdata;
@@ -1318,10 +1362,22 @@ static int __init macb_probe(struct platform_device *pdev)
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
 
-	macb_get_hwaddr(bp);
-	pdata = pdev->dev.platform_data;
+	err = macb_get_hwaddr_dt(bp);
+	if (err < 0)
+		macb_get_hwaddr(bp);
+
+	err = macb_get_phy_mode_dt(pdev);
+	if (err < 0) {
+		pdata = pdev->dev.platform_data;
+		if (pdata && pdata->is_rmii)
+			bp->phy_interface = PHY_INTERFACE_MODE_RMII;
+		else
+			bp->phy_interface = PHY_INTERFACE_MODE_MII;
+	} else {
+		bp->phy_interface = err;
+	}
 
-	if (pdata && pdata->is_rmii)
+	if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
 #if defined(CONFIG_ARCH_AT91)
 		macb_or_gem_writel(bp, USRIO, (MACB_BIT(RMII) |
 					       MACB_BIT(CLKEN)));
@@ -1444,6 +1500,7 @@ static struct platform_driver macb_driver = {
 	.driver		= {
 		.name		= "macb",
 		.owner	= THIS_MODULE,
+		.of_match_table	= of_match_ptr(macb_dt_ids),
 	},
 };
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 1931078..335e288 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -532,6 +532,8 @@ struct macb {
 	unsigned int 		link;
 	unsigned int 		speed;
 	unsigned int 		duplex;
+
+	phy_interface_t		phy_interface;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.5.4

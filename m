From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4] mv643xx_eth: add Device Tree bindings
Date: Fri, 29 Mar 2013 19:14:36 +0100
Message-ID: <1364580879-4297-2-git-send-email-florian@openwrt.org>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34625 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756296Ab3C2SO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 14:14:56 -0400
In-Reply-To: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Device Tree bindings following the already defined
bindings at Documentation/devicetree/bindings/marvell.txt. The binding
documentation is also enhanced with new optionnal properties required
for supporting certain devices (RX/TX queue and SRAM). Since we now have
proper support for the orion MDIO bus driver, there is no need to fiddle
around with device tree phandles.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 Documentation/devicetree/bindings/marvell.txt |   21 ++++-
 drivers/net/ethernet/marvell/mv643xx_eth.c    |  114 ++++++++++++++++++++++++-
 2 files changed, 130 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
index f1533d9..fd05016 100644
--- a/Documentation/devicetree/bindings/marvell.txt
+++ b/Documentation/devicetree/bindings/marvell.txt
@@ -112,9 +112,14 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
    Required properties:
      - #address-cells : <1>
      - #size-cells : <0>
-     - compatible : "marvell,mv64360-eth-block"
+     - compatible : "marvell,mv64360-eth-block", "marvell,mv64360-eth-group",
+		    "marvell,mv643xx-eth-block"
      - reg : Offset and length of the register set for this block
 
+   Optional properties:
+     - tx-csum-limit : Hardware limit above which transmit checksumming
+                       is disabled.
+
    Example Discovery Ethernet block node:
      ethernet-block@2000 {
 	     #address-cells = <1>;
@@ -130,7 +135,7 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
 
    Required properties:
      - device_type : Should be "network".
-     - compatible : Should be "marvell,mv64360-eth".
+     - compatible : Should be "marvell,mv64360-eth", "marvell,mv643xx-eth".
      - reg : Should be <0>, <1>, or <2>, according to which registers
        within the silicon block the device uses.
      - interrupts : <a> where a is the interrupt number for the port.
@@ -140,6 +145,18 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
        controller.
      - local-mac-address : 6 bytes, MAC address
 
+   Optional properties:
+     - clocks : Phandle to the clock control device and gate bit
+     - clock-names : String describing the clock gate bit
+     - rx-queue-count : number of RX queues to use
+     - tx-queue-count : number of TX queues to use
+     - rx-queue-size : size of the RX queue (in bytes)
+     - tx-queue-size : size of the TX queue (in bytes)
+     - rx-sram-addr : address of the SRAM for RX path (non 0 means used)
+     - rx-sram-size : size of the SRAM for RX path (non 0 means used)
+     - tx-sram-addr : address of the SRAM for TX path (non 0 means used)
+     - tx-sram-size : size of the SRAM for TX path (non 0 means used)
+
    Example Discovery Ethernet port node:
      ethernet@0 {
 	     device_type = "network";
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index aedbd82..57164cb 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -60,6 +60,10 @@
 #include <linux/inet_lro.h>
 #include <linux/slab.h>
 #include <linux/clk.h>
+#include <linux/stringify.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/of_net.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.4";
@@ -2542,14 +2546,24 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	}
 }
 
+static const struct of_device_id mv643xx_eth_match[] = {
+	{ .compatible = "marvell,mv64360-eth" },
+	{ .compatible = "marvell,mv643xx-eth" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv643xx_eth_match);
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_eth_version_printed;
+	struct device_node *np = pdev->dev.of_node;
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 	struct mv643xx_eth_shared_private *msp;
 	const struct mbus_dram_target_info *dram;
 	struct resource *res;
 	int ret;
+	const int *prop;
+	int tx_csum_limit = 0;
 
 	if (!mv643xx_eth_version_printed++)
 		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
@@ -2576,13 +2590,19 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (dram)
 		mv643xx_eth_conf_mbus_windows(msp, dram);
 
-	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
-					pd->tx_csum_limit : 9 * 1024;
+	if (np) {
+		prop = of_get_property(np, "tx-csum-limit", NULL);
+		if (prop)
+			tx_csum_limit = be32_to_cpup(prop);
+	} else
+		tx_csum_limit = pd->tx_csum_limit;
+
+	msp->tx_csum_limit = tx_csum_limit ? tx_csum_limit : 9 * 1024;
 	infer_hw_params(msp);
 
 	platform_set_drvdata(pdev, msp);
 
-	return 0;
+	return of_platform_bus_probe(np, mv643xx_eth_match, &pdev->dev);
 
 out_free:
 	kfree(msp);
@@ -2600,12 +2620,22 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id mv643xx_eth_shared_match[] = {
+	{ .compatible = "marvell,mv64360-eth-group" },
+	{ .compatible = "marvell,mv64360-eth-block" },
+	{ .compatible = "marvell,mv643xx-eth-group" },
+	{ .compatible = "marvell,mv643xx-eth-block" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, mv643xx_eth_shared_match);
+
 static struct platform_driver mv643xx_eth_shared_driver = {
 	.probe		= mv643xx_eth_shared_probe,
 	.remove		= mv643xx_eth_shared_remove,
 	.driver = {
 		.name	= MV643XX_ETH_SHARED_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = mv643xx_eth_shared_match,
 	},
 };
 
@@ -2764,6 +2794,71 @@ static const struct net_device_ops mv643xx_eth_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static int mv643xx_eth_of_probe(struct platform_device *pdev)
+{
+	struct mv643xx_eth_platform_data *pd;
+	struct device_node *np = pdev->dev.of_node;
+	struct device_node *shared = of_get_parent(np);
+	struct device_node *phy_node;
+	const int *prop;
+	const char *mac_addr;
+
+	if (!pdev->dev.of_node)
+		return 0;
+
+	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return -ENOMEM;
+
+	pdev->dev.platform_data = pd;
+
+	pd->shared = of_find_device_by_node(shared);
+	if (!pd->shared)
+		return -ENODEV;
+
+	prop = of_get_property(np, "reg", NULL);
+	if (!prop)
+		return -EINVAL;
+
+	pd->port_number = be32_to_cpup(prop);
+
+	phy_node = of_parse_phandle(np, "phy", 0);
+	if (!phy_node)
+		pd->phy_addr = MV643XX_ETH_PHY_NONE;
+	else {
+		prop = of_get_property(phy_node, "reg", NULL);
+		if (prop)
+			pd->phy_addr = be32_to_cpup(prop);
+	}
+
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(pd->mac_addr, mac_addr, ETH_ALEN);
+
+#define rx_tx_queue_sram_property(_name)			\
+	prop = of_get_property(np, __stringify(_name), NULL);	\
+	if (prop)						\
+		pd->_name = be32_to_cpup(prop);
+
+	rx_tx_queue_sram_property(rx_queue_count);
+	rx_tx_queue_sram_property(tx_queue_count);
+	rx_tx_queue_sram_property(rx_queue_size);
+	rx_tx_queue_sram_property(tx_queue_size);
+	rx_tx_queue_sram_property(rx_sram_addr);
+	rx_tx_queue_sram_property(rx_sram_size);
+	rx_tx_queue_sram_property(tx_sram_addr);
+	rx_tx_queue_sram_property(rx_sram_size);
+
+	return 0;
+}
+#else
+static inline int mv643xx_eth_of_probe(struct platform_device *dev)
+{
+	return 0;
+}
+#endif
+
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2772,7 +2867,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	struct resource *res;
 	int err;
 
+	err = mv643xx_eth_of_probe(pdev);
+	if (err)
+		return err;
+
 	pd = pdev->dev.platform_data;
+
 	if (pd == NULL) {
 		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
 		return -ENODEV;
@@ -2896,6 +2996,8 @@ out:
 	}
 #endif
 	free_netdev(dev);
+	if (pdev->dev.of_node)
+		kfree(pd);
 
 	return err;
 }
@@ -2903,6 +3005,7 @@ out:
 static int mv643xx_eth_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
+	struct mv643xx_eth_platform_data *pd = pdev->dev.platform_data;
 
 	unregister_netdev(mp->dev);
 	if (mp->phy != NULL)
@@ -2918,6 +3021,9 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 
 	free_netdev(mp->dev);
 
+	if (pdev->dev.of_node)
+		kfree(pd);
+
 	platform_set_drvdata(pdev, NULL);
 
 	return 0;
@@ -2935,6 +3041,7 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 		port_reset(mp);
 }
 
+
 static struct platform_driver mv643xx_eth_driver = {
 	.probe		= mv643xx_eth_probe,
 	.remove		= mv643xx_eth_remove,
@@ -2942,6 +3049,7 @@ static struct platform_driver mv643xx_eth_driver = {
 	.driver = {
 		.name	= MV643XX_ETH_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = mv643xx_eth_match,
 	},
 };
 
-- 
1.7.10.4

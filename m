From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 05/12] net: mv643xx_eth: add DT parsing support
Date: Tue, 21 May 2013 18:41:43 +0200
Message-ID: <1369154510-4927-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds device tree parsing support for the shared driver of mv643xx_eth.
As the bindings are slightly different from current PPC bindings new binding
documentation is also added. Following PPC-style device setup, the shared
driver now also adds port platform_devices and sets up port platform_data.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Note: Although different, device tree bindings are compatible with PPC
bindings. As I do not have access to any PPC platform using mv643xx_eth,
I leave conversion ("phy" vs "phy-handle") and compatible string name
up to PPC guys.

Due to hang reports for modular built mvmdio and mv643xx_eth, I have
tested module loading/unloading/reloading on CuBox (Dove) and Dockstar
(Kirkwood) without any issues for the whole patch set.

Changelog:
v3->v4:
- separation of independent patches (phy, of_mdio, devm)
- stand-alone device tree binding compatible to existing mv64x60 binding
- device node match for shared driver only
- device node registration for port drivers
- properly return -EPROBE_DEFER on missing of phy (Reported by Simon Baatz)

v2->v3:
- rebase on top of mv643xx_eth clean-ups
- do not reparse existing platform_data
- use managed devm_kzalloc for parsed platform_data
- use of_property_read_u32 where applicable
- add phy_node to platform_data
- use of_connect_phy if DT phy node was found

v1->v2:
- properly ifdef of_platform_bus_probe with CONFIG_OF
- handle of_platform_bus_probe errors and cleanup accordingly
- use of_property_read_u32 where applicable
- parse "duplex" and "speed" property in PHY-less configuration

Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 .../devicetree/bindings/net/marvell-orion-net.txt  |   83 +++++++++++
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  152 +++++++++++++++++++-
 2 files changed, 231 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-orion-net.txt

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-net.txt b/Documentation/devicetree/bindings/net/marvell-orion-net.txt
new file mode 100644
index 0000000..23ffd57
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/marvell-orion-net.txt
@@ -0,0 +1,83 @@
+Marvell Orion/Discovery ethernet controller
+=============================================
+
+The Marvell Discovery ethernet controller can be found on Marvell Orion SoCs
+(Kirkwood, Dove, Orion5x, and Discovery Innovation) and as part of Marvell
+Discovery system controller chips (mv64[345]60).
+
+The Discovery ethernet controller is described with two levels of nodes. The
+first level describes the ethernet controller itself and the second level
+describes up to 3 ethernet port nodes within that controller. The reason for
+the multiple levels is that the port registers are interleaved within a single
+set of controller registers. Each port node describes port-specific properties.
+
+Note: The above separation is only true for Discovery system controllers.
+For Orion SoCs we stick to the separation, although there each controller has
+only one port associated. Multiple ports are implemented as multiple single-port
+controllers.
+
+* Ethernet controller node
+
+Required controller properties:
+ - #address-cells: shall be 1.
+ - #size-cells: shall be 0.
+ - compatible: shall be "marvell,orion-eth".
+ - reg: address and length of the controller registers.
+
+Optional controller properties:
+ - clocks: phandle reference to the controller clock.
+ - marvell,tx-checksum-limit: max tx packet size for hardware checksum.
+
+* Ethernet port node
+
+Required port properties:
+ - device_type: shall be "network".
+ - compatible: shall be "marvell,orion-eth-port".
+ - reg: port number relative to ethernet controller, shall be 0, 1, or 2.
+ - interrupts: port interrupt.
+ - local-mac-address: 6 bytes MAC address.
+
+Optional port properties:
+ - marvell,tx-queue-size: size of the transmit ring buffer.
+ - marvell,tx-sram-addr: address of transmit descriptor buffer located in SRAM.
+ - marvell,tx-sram-size: size of transmit descriptor buffer located in SRAM.
+ - marvell,rx-queue-size: size of the receive ring buffer.
+ - marvell,rx-sram-addr: address of receive descriptor buffer located in SRAM.
+ - marvell,rx-sram-size: size of receive descriptor buffer located in SRAM.
+
+and
+
+ - phy-handle: phandle reference to ethernet PHY.
+
+or
+
+ - speed: port speed if no PHY connected.
+ - duplex: port mode if no PHY connected.
+
+* Node example:
+
+mdio-bus {
+	...
+	ethphy: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		...
+	};
+};
+
+eth: ethernet-controller@72000 {
+	compatible = "marvell,orion-eth";
+	#address-cells = <1>;
+	#size-cells = <0>;
+	reg = <0x72000 0x2000>;
+	clocks = <&gate_clk 2>;
+	marvell,tx-checksum-limit = <1600>;
+
+	ethernet@0 {
+		device_type = "network";
+		compatible = "marvell,orion-eth-port";
+		reg = <0>;
+		interrupts = <29>;
+		phy-handle = <&ethphy>;
+		local-mac-address = [00 00 00 00 00 00];
+	};
+};
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 0f5c3c2..f2c229c 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -60,6 +60,9 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/clk.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
 #include <linux/of_mdio.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
@@ -2451,13 +2454,147 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	}
 }
 
+#if defined(CONFIG_OF)
+static const struct of_device_id mv643xx_eth_shared_ids[] = {
+	{ .compatible = "marvell,orion-eth", },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, mv643xx_eth_shared_ids);
+#endif
+
+#if defined(CONFIG_OF) && !defined(CONFIG_MV64X60)
+#define mv643xx_eth_property(_np, _name, _v)				\
+	do {								\
+		u32 tmp;						\
+		if (!of_property_read_u32(_np, "marvell," _name, &tmp))	\
+			_v = tmp;					\
+	} while (0)
+
+static struct platform_device *port_platdev[3];
+
+static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
+					  struct device_node *pnp)
+{
+	struct platform_device *ppdev;
+	struct mv643xx_eth_platform_data ppd;
+	struct resource res;
+	const char *mac_addr;
+	int ret;
+
+	memset(&ppd, 0, sizeof(ppd));
+	ppd.shared = pdev;
+
+	memset(&res, 0, sizeof(res));
+	if (!of_irq_to_resource(pnp, 0, &res)) {
+		dev_err(&pdev->dev, "missing interrupt on %s\n", pnp->name);
+		return -EINVAL;
+	}
+
+	if (of_property_read_u32(pnp, "reg", &ppd.port_number)) {
+		dev_err(&pdev->dev, "missing reg property on %s\n", pnp->name);
+		return -EINVAL;
+	}
+
+	if (ppd.port_number >= 3) {
+		dev_err(&pdev->dev, "invalid reg property on %s\n", pnp->name);
+		return -EINVAL;
+	}
+
+	mac_addr = of_get_mac_address(pnp);
+	if (mac_addr)
+		memcpy(ppd.mac_addr, mac_addr, 6);
+
+	mv643xx_eth_property(pnp, "tx-queue-size", ppd.tx_queue_size);
+	mv643xx_eth_property(pnp, "tx-sram-addr", ppd.tx_sram_addr);
+	mv643xx_eth_property(pnp, "tx-sram-size", ppd.tx_sram_size);
+	mv643xx_eth_property(pnp, "rx-queue-size", ppd.rx_queue_size);
+	mv643xx_eth_property(pnp, "rx-sram-addr", ppd.rx_sram_addr);
+	mv643xx_eth_property(pnp, "rx-sram-size", ppd.rx_sram_size);
+
+	ppd.phy_node = of_parse_phandle(pnp, "phy-handle", 0);
+	if (!ppd.phy_node) {
+		ppd.phy_addr = MV643XX_ETH_PHY_NONE;
+		of_property_read_u32(pnp, "speed", &ppd.speed);
+		of_property_read_u32(pnp, "duplex", &ppd.duplex);
+	}
+
+	ppdev = platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number);
+	if (!ppdev)
+		return -ENOMEM;
+	ppdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+
+	ret = platform_device_add_resources(ppdev, &res, 1);
+	if (ret)
+		goto port_err;
+
+	ret = platform_device_add_data(ppdev, &ppd, sizeof(ppd));
+	if (ret)
+		goto port_err;
+
+	ret = platform_device_add(ppdev);
+	if (ret)
+		goto port_err;
+
+	port_platdev[ppd.port_number] = ppdev;
+
+	return 0;
+
+port_err:
+	platform_device_put(ppdev);
+	return ret;
+}
+
+static int mv643xx_eth_shared_of_probe(struct platform_device *pdev)
+{
+	struct mv643xx_eth_shared_platform_data *pd;
+	struct device_node *pnp, *np = pdev->dev.of_node;
+	int ret;
+
+	/* bail out if not registered from DT */
+	if (!np)
+		return 0;
+
+	pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return -ENOMEM;
+	pdev->dev.platform_data = pd;
+
+	mv643xx_eth_property(np, "tx-checksum-limit", pd->tx_csum_limit);
+
+	for_each_available_child_of_node(np, pnp) {
+		ret = mv643xx_eth_shared_of_add_port(pdev, pnp);
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
+static void mv643xx_eth_shared_of_remove(void)
+{
+	int n;
+
+	for (n = 0; n < 3; n++) {
+		platform_device_del(port_platdev[n]);
+		port_platdev[n] = NULL;
+	}
+}
+#else
+static int mv643xx_eth_shared_of_probe(struct platform_device *pdev)
+{
+	return 0
+}
+
+#define mv643xx_eth_shared_of_remove()
+#endif
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_eth_version_printed;
-	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
+	struct mv643xx_eth_shared_platform_data *pd;
 	struct mv643xx_eth_shared_private *msp;
 	const struct mbus_dram_target_info *dram;
 	struct resource *res;
+	int ret;
 
 	if (!mv643xx_eth_version_printed++)
 		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
@@ -2470,6 +2607,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	msp = devm_kzalloc(&pdev->dev, sizeof(*msp), GFP_KERNEL);
 	if (msp == NULL)
 		return -ENOMEM;
+	platform_set_drvdata(pdev, msp);
 
 	msp->base = devm_ioremap(&pdev->dev, res->start, resource_size(res));
 	if (msp->base == NULL)
@@ -2486,12 +2624,15 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (dram)
 		mv643xx_eth_conf_mbus_windows(msp, dram);
 
+	ret = mv643xx_eth_shared_of_probe(pdev);
+	if (ret)
+		return ret;
+	pd = pdev->dev.platform_data;
+
 	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
 					pd->tx_csum_limit : 9 * 1024;
 	infer_hw_params(msp);
 
-	platform_set_drvdata(pdev, msp);
-
 	return 0;
 }
 
@@ -2499,9 +2640,9 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 
+	mv643xx_eth_shared_of_remove();
 	if (!IS_ERR(msp->clk))
 		clk_disable_unprepare(msp->clk);
-
 	return 0;
 }
 
@@ -2511,6 +2652,7 @@ static struct platform_driver mv643xx_eth_shared_driver = {
 	.driver = {
 		.name	= MV643XX_ETH_SHARED_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(mv643xx_eth_shared_ids),
 	},
 };
 
@@ -2710,6 +2852,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (!IS_ERR(mp->clk)) {
 		clk_prepare_enable(mp->clk);
 		mp->t_clk = clk_get_rate(mp->clk);
+	} else if (!IS_ERR(mp->shared->clk)) {
+		mp->t_clk = clk_get_rate(mp->shared->clk);
 	}
 
 	set_params(mp, pd);
-- 
1.7.10.4

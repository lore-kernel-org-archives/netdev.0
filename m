From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 2/4] net: hix5hd2_gmac: add reset control and clock signals
Date: Thu, 11 Aug 2016 17:01:53 +0800
Message-ID: <1470906115-155569-3-git-send-email-lidongpo@hisilicon.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Li Dongpo <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<mturquette@baylibre.com>, <sboyd@codeaurora.org>,
	<linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Dongpo <lidongpo@hisilicon.com>

Add three reset control signals, "mac_core_rst", "mac_ifc_rst" and
"phy_rst".
The following diagram explained how the reset signals work.

                        SoC
|-----------------------------------------------------
|                               ------                |
|                               | cpu |               |
|                               ------                |
|                                  |                  |
|                              ------------ AMBA bus  |
|                         GMAC     |                  |
|                            ----------------------   |
| ------------- mac_core_rst | --------------      |  |
| |clock and   |-------------->|   mac core  |     |  |
| |reset       |             | --------------      |  |
| |generator   |----         |       |             |  |
| -------------     |        | ----------------    |  |
|          |        ---------->| mac interface |   |  |
|          |     mac_ifc_rst | ----------------    |  |
|          |                 |       |             |  |
|          |                 | ------------------  |  |
|          |phy_rst          | | RGMII interface | |  |
|          |                 | ------------------  |  |
|          |                 ----------------------   |
|----------|------------------------------------------|
           |                          |
           |                      ----------
           |--------------------- |PHY chip |
                                  ----------

The "mac_core_rst" represents "mac core reset signal", it resets
the mac core including packet processing unit, descriptor processing unit,
tx engine, rx engine, control unit.
The "mac_ifc_rst" represents "mac interface reset signal", it resets
the mac interface. The mac interface unit connects mac core and
data interface like MII/RMII/RGMII. After we set a new value of
interface mode, we must reset mac interface to reload the new mode value.
The "phy_rst" represents "phy reset signal", it does a hardware reset
on the PHY chip. This reset signal is optinal if the PHY can work well
without the hardware reset.

Add one more clock signal, the existing is MAC core clock,
and the new one is MAC interface clock.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 .../bindings/net/hisilicon-hix5hd2-gmac.txt        |  16 ++-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 140 +++++++++++++++++++--
 2 files changed, 143 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
index 3c02fac..a0bf2ca 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
@@ -17,6 +17,16 @@ Required properties:
 - phy-handle: see ethernet.txt [1].
 - mac-address: see ethernet.txt [1].
 - clocks: clock phandle and specifier pair.
+- clock-names: contain the clock name "mac_core" and "mac_ifc".
+- resets: should contain the phandle to the MAC core reset signal(required),
+	the MAC interface reset signal(required)
+	and the PHY reset signal(optional).
+- reset-names: contain the reset signal name "mac_core"(required),
+	"mac_ifc"(required) and "phy"(optional).
+- hisilicon,phy-reset-delays-us: triplet of delays if PHY reset signal given.
+	The 1st cell is reset pre-delay in micro seconds.
+	The 2nd cell is reset pulse in micro seconds.
+	The 3rd cell is reset post-delay in micro seconds.
 
 - PHY subnode: inherits from phy binding [2]
 
@@ -33,7 +43,11 @@ Example:
 		phy-mode = "mii";
 		phy-handle = <&phy2>;
 		mac-address = [00 00 00 00 00 00];
-		clocks = <&clock HIX5HD2_MAC0_CLK>;
+		clocks = <&clock HIX5HD2_MAC0_CLK>, <&clock HIX5HD2_MAC_IFC0_CLK>;
+		clock-names = "mac_core", "mac_ifc";
+		resets = <&clock 0xcc 8>, <&clock 0xcc 10>, <&clock 0x120 4>;
+		reset-names = "mac_core", "mac_ifc", "phy";
+		hisilicon,phy-reset-delays-us = <10000 10000 30000>;
 
 		phy2: ethernet-phy@2 {
 			reg = <2>;
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 679a5e5..11e70bb 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -14,6 +14,7 @@
 #include <linux/of_device.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
+#include <linux/reset.h>
 #include <linux/clk.h>
 #include <linux/circ_buf.h>
 
@@ -197,6 +198,15 @@
 #define GEMAC_V2			(GEMAC_V1 | HW_CAP_TSO)
 #define HAS_CAP_TSO(hw_cap)		((hw_cap) & HW_CAP_TSO)
 
+#define PHY_RESET_DELAYS_PROPERTY	"hisilicon,phy-reset-delays-us"
+
+enum phy_reset_delays {
+	PRE_DELAY,
+	PULSE,
+	POST_DELAY,
+	DELAYS_NUM,
+};
+
 struct hix5hd2_desc {
 	__le32 buff_addr;
 	__le32 cmd;
@@ -255,12 +265,23 @@ struct hix5hd2_priv {
 	unsigned int speed;
 	unsigned int duplex;
 
-	struct clk *clk;
+	struct clk *mac_core_clk;
+	struct clk *mac_ifc_clk;
+	struct reset_control *mac_core_rst;
+	struct reset_control *mac_ifc_rst;
+	struct reset_control *phy_rst;
+	u32 phy_reset_delays[DELAYS_NUM];
 	struct mii_bus *bus;
 	struct napi_struct napi;
 	struct work_struct tx_timeout_task;
 };
 
+static inline void hix5hd2_mac_interface_reset(struct hix5hd2_priv *priv)
+{
+	reset_control_assert(priv->mac_ifc_rst);
+	reset_control_deassert(priv->mac_ifc_rst);
+}
+
 static void hix5hd2_config_port(struct net_device *dev, u32 speed, u32 duplex)
 {
 	struct hix5hd2_priv *priv = netdev_priv(dev);
@@ -293,6 +314,7 @@ static void hix5hd2_config_port(struct net_device *dev, u32 speed, u32 duplex)
 	if (duplex)
 		val |= GMAC_FULL_DUPLEX;
 	writel_relaxed(val, priv->ctrl_base);
+	hix5hd2_mac_interface_reset(priv);
 
 	writel_relaxed(BIT_MODE_CHANGE_EN, priv->base + MODE_CHANGE_EN);
 	if (speed == SPEED_1000)
@@ -807,16 +829,26 @@ static int hix5hd2_net_open(struct net_device *dev)
 	struct phy_device *phy;
 	int ret;
 
-	ret = clk_prepare_enable(priv->clk);
+	ret = clk_prepare_enable(priv->mac_core_clk);
+	if (ret < 0) {
+		netdev_err(dev, "failed to enable mac core clk %d\n", ret);
+		return ret;
+	}
+
+	ret = clk_prepare_enable(priv->mac_ifc_clk);
 	if (ret < 0) {
-		netdev_err(dev, "failed to enable clk %d\n", ret);
+		clk_disable_unprepare(priv->mac_core_clk);
+		netdev_err(dev, "failed to enable mac ifc clk %d\n", ret);
 		return ret;
 	}
 
 	phy = of_phy_connect(dev, priv->phy_node,
 			     &hix5hd2_adjust_link, 0, priv->phy_mode);
-	if (!phy)
+	if (!phy) {
+		clk_disable_unprepare(priv->mac_ifc_clk);
+		clk_disable_unprepare(priv->mac_core_clk);
 		return -ENODEV;
+	}
 
 	phy_start(phy);
 	hix5hd2_hw_init(priv);
@@ -847,7 +879,8 @@ static int hix5hd2_net_close(struct net_device *dev)
 		phy_disconnect(dev->phydev);
 	}
 
-	clk_disable_unprepare(priv->clk);
+	clk_disable_unprepare(priv->mac_ifc_clk);
+	clk_disable_unprepare(priv->mac_core_clk);
 
 	return 0;
 }
@@ -1015,6 +1048,45 @@ static void hix5hd2_destroy_sg_desc_queue(struct hix5hd2_priv *priv)
 	}
 }
 
+static inline void hix5hd2_mac_core_reset(struct hix5hd2_priv *priv)
+{
+	reset_control_assert(priv->mac_core_rst);
+	reset_control_deassert(priv->mac_core_rst);
+}
+
+static void hix5hd2_sleep_us(u32 time_us)
+{
+	u32 time_ms;
+
+	if (!time_us)
+		return;
+
+	time_ms = DIV_ROUND_UP(time_us, 1000);
+	if (time_ms < 20)
+		usleep_range(time_us, time_us + 500);
+	else
+		msleep(time_ms);
+}
+
+static void hix5hd2_phy_reset(struct hix5hd2_priv *priv)
+{
+	/* To make sure PHY hardware reset success,
+	 * we must keep PHY in deassert state first and
+	 * then complete the hardware reset operation
+	 */
+	reset_control_deassert(priv->phy_rst);
+	hix5hd2_sleep_us(priv->phy_reset_delays[PRE_DELAY]);
+
+	reset_control_assert(priv->phy_rst);
+	/* delay some time to ensure reset ok,
+	 * this depends on PHY hardware feature
+	 */
+	hix5hd2_sleep_us(priv->phy_reset_delays[PULSE]);
+	reset_control_deassert(priv->phy_rst);
+	/* delay some time to ensure later MDIO access */
+	hix5hd2_sleep_us(priv->phy_reset_delays[POST_DELAY]);
+}
+
 static const struct of_device_id hix5hd2_of_match[];
 
 static int hix5hd2_dev_probe(struct platform_device *pdev)
@@ -1060,23 +1132,62 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 		goto out_free_netdev;
 	}
 
-	priv->clk = devm_clk_get(&pdev->dev, NULL);
-	if (IS_ERR(priv->clk)) {
-		netdev_err(ndev, "failed to get clk\n");
+	priv->mac_core_clk = devm_clk_get(&pdev->dev, "mac_core");
+	if (IS_ERR(priv->mac_core_clk)) {
+		netdev_err(ndev, "failed to get mac core clk\n");
 		ret = -ENODEV;
 		goto out_free_netdev;
 	}
 
-	ret = clk_prepare_enable(priv->clk);
+	ret = clk_prepare_enable(priv->mac_core_clk);
 	if (ret < 0) {
-		netdev_err(ndev, "failed to enable clk %d\n", ret);
+		netdev_err(ndev, "failed to enable mac core clk %d\n", ret);
 		goto out_free_netdev;
 	}
 
+	priv->mac_ifc_clk = devm_clk_get(&pdev->dev, "mac_ifc");
+	if (IS_ERR(priv->mac_ifc_clk)) {
+		netdev_err(ndev, "failed to get mac ifc clk\n");
+		ret = -ENODEV;
+		goto out_disable_mac_core_clk;
+	}
+
+	ret = clk_prepare_enable(priv->mac_ifc_clk);
+	if (ret < 0) {
+		netdev_err(ndev, "failed to enable mac ifc clk %d\n", ret);
+		goto out_disable_mac_core_clk;
+	}
+
+	priv->mac_core_rst = devm_reset_control_get(dev, "mac_core");
+	if (IS_ERR(priv->mac_core_rst)) {
+		ret = PTR_ERR(priv->mac_core_rst);
+		goto out_disable_clk;
+	}
+	hix5hd2_mac_core_reset(priv);
+
+	priv->mac_ifc_rst = devm_reset_control_get(dev, "mac_ifc");
+	if (IS_ERR(priv->mac_ifc_rst)) {
+		ret = PTR_ERR(priv->mac_ifc_rst);
+		goto out_disable_clk;
+	}
+
+	priv->phy_rst = devm_reset_control_get(dev, "phy");
+	if (IS_ERR(priv->phy_rst)) {
+		priv->phy_rst = NULL;
+	} else {
+		ret = of_property_read_u32_array(node,
+						 PHY_RESET_DELAYS_PROPERTY,
+						 priv->phy_reset_delays,
+						 DELAYS_NUM);
+		if (ret)
+			goto out_disable_clk;
+		hix5hd2_phy_reset(priv);
+	}
+
 	bus = mdiobus_alloc();
 	if (bus == NULL) {
 		ret = -ENOMEM;
-		goto out_free_netdev;
+		goto out_disable_clk;
 	}
 
 	bus->priv = priv;
@@ -1159,7 +1270,8 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 		goto out_destroy_queue;
 	}
 
-	clk_disable_unprepare(priv->clk);
+	clk_disable_unprepare(priv->mac_ifc_clk);
+	clk_disable_unprepare(priv->mac_core_clk);
 
 	return ret;
 
@@ -1174,6 +1286,10 @@ err_mdiobus:
 	mdiobus_unregister(bus);
 err_free_mdio:
 	mdiobus_free(bus);
+out_disable_clk:
+	clk_disable_unprepare(priv->mac_ifc_clk);
+out_disable_mac_core_clk:
+	clk_disable_unprepare(priv->mac_core_clk);
 out_free_netdev:
 	free_netdev(ndev);
 
-- 
2.8.2

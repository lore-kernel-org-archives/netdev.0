From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 5/7] net: ethernet: mediatek: add the whole ethernet reset into the reset process
Date: Wed, 14 Sep 2016 11:50:39 +0800
Message-ID: <1473825041-21072-6-git-send-email-sean.wang@mediatek.com>
References: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:1727 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755746AbcINDux (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:50:53 -0400
In-Reply-To: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

1) original driver only resets DMA used by descriptor rings
which can't guarantee it can recover all various kinds of fatal
errors, so the patch tries to reset the underlying hardware
resource from scratch on Mediatek SoC required for ethernet
running, including power, pin mux control, clock and internal
circuits on the ethernet in order to restore into the initial
state which the rebooted machine gives.

2) add state variable inside structure mtk_eth to help distinguish
mtk_hw_init is called between the initialization during boot time
or re-initialization during the reset process.

3) add ge_mode variable inside structure mtk_mac for restoring
the interface mode of the current setup for the target MAC.

4) remove __init attribute from mtk_hw_init definition

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 52 ++++++++++++++++++++++++-----
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  8 +++++
 2 files changed, 52 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index fd5d064..b9ddbcb 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -231,7 +231,7 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 {
 	struct mtk_eth *eth = mac->hw;
 	struct device_node *np;
-	u32 val, ge_mode;
+	u32 val;
 
 	np = of_parse_phandle(mac->of_node, "phy-handle", 0);
 	if (!np && of_phy_is_fixed_link(mac->of_node))
@@ -245,18 +245,18 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII:
-		ge_mode = 0;
+		mac->ge_mode = 0;
 		break;
 	case PHY_INTERFACE_MODE_MII:
-		ge_mode = 1;
+		mac->ge_mode = 1;
 		break;
 	case PHY_INTERFACE_MODE_REVMII:
-		ge_mode = 2;
+		mac->ge_mode = 2;
 		break;
 	case PHY_INTERFACE_MODE_RMII:
 		if (!mac->id)
 			goto err_phy;
-		ge_mode = 3;
+		mac->ge_mode = 3;
 		break;
 	default:
 		goto err_phy;
@@ -265,7 +265,7 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	/* put the gmac into the right mode */
 	regmap_read(eth->ethsys, ETHSYS_SYSCFG0, &val);
 	val &= ~SYSCFG0_GE_MODE(SYSCFG0_GE_MASK, mac->id);
-	val |= SYSCFG0_GE_MODE(ge_mode, mac->id);
+	val |= SYSCFG0_GE_MODE(mac->ge_mode, mac->id);
 	regmap_write(eth->ethsys, ETHSYS_SYSCFG0, val);
 
 	mtk_phy_connect_node(eth, mac, np);
@@ -1414,9 +1414,12 @@ static int mtk_stop(struct net_device *dev)
 	return 0;
 }
 
-static int __init mtk_hw_init(struct mtk_eth *eth)
+static int mtk_hw_init(struct mtk_eth *eth)
 {
-	int i;
+	int i, val;
+
+	if (test_and_set_bit(MTK_HW_INIT, &eth->state))
+		return 0;
 
 	pm_runtime_enable(eth->dev);
 	pm_runtime_get_sync(eth->dev);
@@ -1432,6 +1435,15 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	reset_control_deassert(eth->rstc);
 	usleep_range(10, 20);
 
+	regmap_read(eth->ethsys, ETHSYS_SYSCFG0, &val);
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->mac[i])
+			continue;
+		val &= ~SYSCFG0_GE_MODE(SYSCFG0_GE_MASK, eth->mac[i]->id);
+		val |= SYSCFG0_GE_MODE(eth->mac[i]->ge_mode, eth->mac[i]->id);
+	}
+	regmap_write(eth->ethsys, ETHSYS_SYSCFG0, val);
+
 	/* Set GE2 driving and slew rate */
 	regmap_write(eth->pctl, GPIO_DRV_SEL10, 0xa00);
 
@@ -1483,6 +1495,9 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 
 static int mtk_hw_deinit(struct mtk_eth *eth)
 {
+	if (!test_and_clear_bit(MTK_HW_INIT, &eth->state))
+		return 0;
+
 	clk_disable_unprepare(eth->clks[MTK_CLK_GP2]);
 	clk_disable_unprepare(eth->clks[MTK_CLK_GP1]);
 	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
@@ -1557,6 +1572,27 @@ static void mtk_pending_work(struct work_struct *work)
 		__set_bit(i, &restart);
 	}
 
+	/* restart underlying hardware such as power, clock, pin mux
+	 * and the connected phy
+	 */
+	mtk_hw_deinit(eth);
+
+	if (eth->dev->pins)
+		devm_kfree(eth->dev, eth->dev->pins);
+	pinctrl_bind_pins(eth->dev);
+
+	mtk_hw_init(eth);
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->mac[i] ||
+		    of_phy_is_fixed_link(eth->mac[i]->of_node))
+			continue;
+		err = phy_init_hw(eth->mac[i]->phy_dev);
+		if (err)
+			dev_err(eth->dev, "%s: PHY init failed.\n",
+				eth->netdev[i]->name);
+	}
+
 	/* restart DMA and enable IRQs */
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
 		if (!test_bit(i, &restart))
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 0b984dc..388cbe7 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -330,6 +330,10 @@ enum mtk_clks_map {
 	MTK_CLK_MAX
 };
 
+enum mtk_dev_state {
+	MTK_HW_INIT
+};
+
 /* struct mtk_tx_buf -	This struct holds the pointers to the memory pointed at
  *			by the TX descriptor	s
  * @skb:		The SKB pointer of the packet being sent
@@ -413,6 +417,7 @@ struct mtk_rx_ring {
  * @clks:		clock array for all clocks required
  * @mii_bus:		If there is a bus we need to create an instance for it
  * @pending_work:	The workqueue used to reset the dma ring
+ * @state               Initialization and runtime state of the device.
  */
 
 struct mtk_eth {
@@ -441,11 +446,13 @@ struct mtk_eth {
 
 	struct mii_bus			*mii_bus;
 	struct work_struct		pending_work;
+	unsigned long			state;
 };
 
 /* struct mtk_mac -	the structure that holds the info about the MACs of the
  *			SoC
  * @id:			The number of the MAC
+ * @ge_mode:            Interface mode kept for setup restoring
  * @of_node:		Our devicetree node
  * @hw:			Backpointer to our main datastruture
  * @hw_stats:		Packet statistics counter
@@ -453,6 +460,7 @@ struct mtk_eth {
  */
 struct mtk_mac {
 	int				id;
+	int				ge_mode;
 	struct device_node		*of_node;
 	struct mtk_eth			*hw;
 	struct mtk_hw_stats		*hw_stats;
-- 
1.9.1

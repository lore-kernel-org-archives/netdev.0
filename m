From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 7/8] net: ethernet: annapurna: add eee helpers to the Alpine driver
Date: Fri,  3 Feb 2017 19:12:15 +0100
Message-ID: <20170203181216.30214-8-antoine.tenart@free-electrons.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36482 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdBCSPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:15:11 -0500
In-Reply-To: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the get_eee() and set_eee() helpers to support the Energy-Efficient
(EEE) feature in the Annapurna Labs Alpine driver.
---
 drivers/net/ethernet/annapurna/al_eth.c            | 44 +++++++++++
 drivers/net/ethernet/annapurna/al_hw_eth.h         | 28 +++++++
 drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h | 11 +++
 .../net/ethernet/annapurna/al_hw_eth_mac_regs.h    | 11 +++
 drivers/net/ethernet/annapurna/al_hw_eth_main.c    | 92 ++++++++++++++++++++++
 5 files changed, 186 insertions(+)

diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
index d06a75a49ce5..674dafdb638a 100644
--- a/drivers/net/ethernet/annapurna/al_eth.c
+++ b/drivers/net/ethernet/annapurna/al_eth.c
@@ -2519,6 +2519,47 @@ static u32 al_eth_get_rxfh_indir_size(struct net_device *netdev)
 	return AL_ETH_RX_RSS_TABLE_SIZE;
 }
 
+static int al_eth_get_eee(struct net_device *netdev,
+			  struct ethtool_eee *edata)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct al_eth_eee_params params;
+
+	if (!adapter->phy_exist)
+		return -EOPNOTSUPP;
+
+	al_eth_eee_get(&adapter->hw_adapter, &params);
+
+	edata->eee_enabled = params.enable;
+	edata->tx_lpi_timer = params.tx_eee_timer;
+
+	return phy_ethtool_get_eee(adapter->phydev, edata);
+}
+
+static int al_eth_set_eee(struct net_device *netdev,
+			  struct ethtool_eee *edata)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct al_eth_eee_params params;
+
+	struct phy_device *phydev;
+
+	if (!adapter->phy_exist)
+		return -EOPNOTSUPP;
+
+	phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+
+	phy_init_eee(phydev, 1);
+
+	params.enable = edata->eee_enabled;
+	params.tx_eee_timer = edata->tx_lpi_timer;
+	params.min_interval = 10;
+
+	al_eth_eee_config(&adapter->hw_adapter, &params);
+
+	return phy_ethtool_set_eee(phydev, edata);
+}
+
 static void al_eth_get_wol(struct net_device *netdev,
 			   struct ethtool_wolinfo *wol)
 {
@@ -2576,6 +2617,9 @@ static const struct ethtool_ops al_eth_ethtool_ops = {
 	.set_pauseparam		= al_eth_set_pauseparam,
 	.get_rxnfc		= al_eth_get_rxnfc,
 	.get_rxfh_indir_size    = al_eth_get_rxfh_indir_size,
+
+	.get_eee		= al_eth_get_eee,
+	.set_eee		= al_eth_set_eee,
 };
 
 static void al_eth_tx_csum(struct al_eth_ring *tx_ring,
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth.h b/drivers/net/ethernet/annapurna/al_hw_eth.h
index a44f3f200838..2ef11de6b1db 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth.h
+++ b/drivers/net/ethernet/annapurna/al_hw_eth.h
@@ -884,6 +884,34 @@ int al_eth_filter_config(struct al_hw_eth_adapter *adapter, struct al_eth_filter
 
 int al_eth_flow_control_config(struct al_hw_eth_adapter *adapter, struct al_eth_flow_control_params *params);
 
+struct al_eth_eee_params {
+	u8 enable;
+	u32 tx_eee_timer; /* time in cycles the interface delays prior to entering eee state */
+	u32 min_interval; /* minimum interval in cycles between two eee states */
+	u32 stop_cnt; /* time in cycles to stop Tx mac i/f after getting out of eee state */
+	bool fast_wake; /* fast_wake is only applicable to 40/50G, otherwise the mode is deep_sleep */
+};
+
+/*
+ * configure EEE mode
+ * @param adapter pointer to the private structure.
+ * @param params pointer to the eee input parameters.
+ *
+ * @return return 0 on success. otherwise on failure.
+ */
+int al_eth_eee_config(struct al_hw_eth_adapter *adapter,
+		      struct al_eth_eee_params *params);
+
+/*
+ * get EEE configuration
+ * @param adapter pointer to the private structure.
+ * @param params pointer to the eee output parameters.
+ *
+ * @return return 0 on success. otherwise on failure.
+ */
+int al_eth_eee_get(struct al_hw_eth_adapter *adapter,
+		   struct al_eth_eee_params *params);
+
 /* enum for methods when updating systime using triggers */
 enum al_eth_pth_update_method {
 	AL_ETH_PTH_UPDATE_METHOD_SET = 0, /* Set the time in int/ext update time */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h b/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
index c239ac1e8b6c..c9353012101e 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
@@ -1085,4 +1085,15 @@ struct al_ec_regs {
 /* Threshold high */
 #define EC_EFC_RX_FIFO_HYST_TH_HIGH_SHIFT 16
 
+/* Use Ethernet controller Tx FIFO empty status for EEE control */
+#define EC_EEE_CFG_E_USE_EC_TX_FIFO      BIT(2)
+/* Use Ethernet controller Rx FIFO empty status for EEE control */
+#define EC_EEE_CFG_E_USE_EC_RX_FIFO      BIT(3)
+/* Enable Low power signalling. */
+#define EC_EEE_CFG_E_ENABLE              BIT(4)
+/* Mask output to MAC.  */
+#define EC_EEE_CFG_E_MASK_MAC_EEE        BIT(8)
+/* Mask output to stop MAC interface. */
+#define EC_EEE_CFG_E_MASK_EC_TMI_STOP    BIT(9)
+
 #endif /* __AL_HW_EC_REG_H */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h b/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
index b2b956b7e28f..4201f3c4b01f 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
@@ -692,6 +692,10 @@ struct al_eth_mac_regs {
 /* LED default value */
 #define ETH_MAC_GEN_LED_CFG_DEF          BIT(4)
 
+/* EEE timer value  */
+#define ETH_MAC_KR_PCS_CFG_EEE_TIMER_VAL_MASK 0x0000FF00
+#define ETH_MAC_KR_PCS_CFG_EEE_TIMER_VAL_SHIFT 8
+
 #define ETH_MAC_SGMII_REG_ADDR_CTRL_REG	0x0
 #define ETH_MAC_SGMII_REG_ADDR_IF_MODE_REG 0x14
 
@@ -703,6 +707,10 @@ struct al_eth_mac_regs {
 #define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_1000		0x2
 #define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_DUPLEX		BIT(4)
 
+/* Low power timer configuration */
+#define ETH_MAC_GEN_V3_PCS_40G_LL_EEE_CFG_TIMER_VAL_MASK 0x000000FF
+#define ETH_MAC_GEN_V3_PCS_40G_LL_EEE_CFG_TIMER_VAL_SHIFT 0
+
 /* command config */
 #define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR	0x00000008
 #define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_TX_ENA	BIT(0)
@@ -724,4 +732,7 @@ struct al_eth_mac_regs {
 /* spare */
 #define ETH_MAC_GEN_V3_SPARE_CHICKEN_DISABLE_TIMESTAMP_STRETCH BIT(0)
 
+/* 40g EEE control and capability */
+#define ETH_MAC_GEN_V3_PCS_40G_EEE_CONTROL_ADDR         0x00000028
+
 #endif /* __AL_HW_ETH_MAC_REGS_H__ */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_main.c b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
index dac0c1e2a941..99ed601332da 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth_main.c
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
@@ -20,6 +20,12 @@
 #define AL_ADDR_LOW(x)	((u32)((dma_addr_t)(x)))
 #define AL_ADDR_HIGH(x)	((u32)((((dma_addr_t)(x)) >> 16) >> 16))
 
+/* Number of xfi_txclk cycles that accumulate into 100ns */
+#define ETH_MAC_KR_10_PCS_CFG_EEE_TIMER_VAL 52
+#define ETH_MAC_KR_25_PCS_CFG_EEE_TIMER_VAL 80
+#define ETH_MAC_XLG_40_PCS_CFG_EEE_TIMER_VAL 63
+#define ETH_MAC_XLG_50_PCS_CFG_EEE_TIMER_VAL 85
+
 #define AL_ETH_TX_PKT_UDMA_FLAGS	(AL_ETH_TX_FLAGS_NO_SNOOP | \
 					 AL_ETH_TX_FLAGS_INT)
 
@@ -2639,6 +2645,89 @@ int al_eth_flow_control_config(struct al_hw_eth_adapter *adapter,
 	return 0;
 }
 
+int al_eth_eee_get(struct al_hw_eth_adapter *adapter,
+		   struct al_eth_eee_params *params)
+{
+	u32 reg;
+
+	netdev_dbg(adapter->netdev, "[%s]: getting eee.\n", adapter->name);
+
+	reg = readl(&adapter->ec_regs_base->eee.cfg_e);
+	params->enable = (reg & EC_EEE_CFG_E_ENABLE) ? true : false;
+
+	params->tx_eee_timer = readl(&adapter->ec_regs_base->eee.pre_cnt);
+	params->min_interval = readl(&adapter->ec_regs_base->eee.post_cnt);
+	params->stop_cnt = readl(&adapter->ec_regs_base->eee.stop_cnt);
+
+	return 0;
+}
+
+int al_eth_eee_config(struct al_hw_eth_adapter *adapter,
+		      struct al_eth_eee_params *params)
+{
+	u32 reg;
+
+	netdev_dbg(adapter->netdev, "[%s]: config eee.\n", adapter->name);
+
+	if (params->enable == 0) {
+		netdev_dbg(adapter->netdev, "[%s]: disable eee.\n",
+			   adapter->name);
+		writel(0, &adapter->ec_regs_base->eee.cfg_e);
+		return 0;
+	}
+	if (AL_ETH_IS_10G_MAC(adapter->mac_mode) || AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+		reg = readl(&adapter->mac_regs_base->kr.pcs_cfg);
+		reg &= ~ETH_MAC_KR_PCS_CFG_EEE_TIMER_VAL_MASK;
+		reg |= (AL_ETH_IS_10G_MAC(adapter->mac_mode) ?
+			ETH_MAC_KR_10_PCS_CFG_EEE_TIMER_VAL :
+			ETH_MAC_KR_25_PCS_CFG_EEE_TIMER_VAL) <<
+			ETH_MAC_KR_PCS_CFG_EEE_TIMER_VAL_SHIFT,
+		writel(reg, &adapter->mac_regs_base->kr.pcs_cfg);
+	}
+	if ((adapter->mac_mode == AL_ETH_MAC_MODE_XLG_LL_40G) ||
+	    (adapter->mac_mode == AL_ETH_MAC_MODE_XLG_LL_50G)) {
+		reg = readl(&adapter->mac_regs_base->gen_v3.pcs_40g_ll_eee_cfg);
+		reg &= ~ETH_MAC_GEN_V3_PCS_40G_LL_EEE_CFG_TIMER_VAL_MASK;
+		reg |= ((adapter->mac_mode == AL_ETH_MAC_MODE_XLG_LL_40G) ?
+			ETH_MAC_XLG_40_PCS_CFG_EEE_TIMER_VAL :
+			ETH_MAC_XLG_50_PCS_CFG_EEE_TIMER_VAL) <<
+			ETH_MAC_GEN_V3_PCS_40G_LL_EEE_CFG_TIMER_VAL_SHIFT;
+		writel(reg, &adapter->mac_regs_base->gen_v3.pcs_40g_ll_eee_cfg);
+
+		/* set Deep sleep mode as the LPI function (instead of Fast wake mode) */
+		al_eth_40g_pcs_reg_write(adapter, ETH_MAC_GEN_V3_PCS_40G_EEE_CONTROL_ADDR,
+					 params->fast_wake ? 1 : 0);
+	}
+
+	writel(params->tx_eee_timer, &adapter->ec_regs_base->eee.pre_cnt);
+	writel(params->min_interval, &adapter->ec_regs_base->eee.post_cnt);
+	writel(params->stop_cnt, &adapter->ec_regs_base->eee.stop_cnt);
+
+	reg = EC_EEE_CFG_E_MASK_EC_TMI_STOP | EC_EEE_CFG_E_MASK_MAC_EEE |
+	      EC_EEE_CFG_E_ENABLE | EC_EEE_CFG_E_USE_EC_TX_FIFO |
+	      EC_EEE_CFG_E_USE_EC_RX_FIFO;
+
+	/*
+	 * Addressing RMN: 3732
+	 *
+	 * RMN description:
+	 * When the HW get into eee mode, it can't transmit any pause packet
+	 * (when flow control policy is enabled).
+	 * In such case, the HW has no way to handle extreme pushback from
+	 * the Rx_path fifos.
+	 *
+	 * Software flow:
+	 * Configure RX_FIFO empty as eee mode term.
+	 * That way, nothing will prevent pause packet transmittion in
+	 * case of extreme pushback from the Rx_path fifos.
+	 *
+	 */
+
+	writel(reg, &adapter->ec_regs_base->eee.cfg_e);
+
+	return 0;
+}
+
 /* get statistics */
 int al_eth_mac_stats_get(struct al_hw_eth_adapter *adapter, struct al_eth_mac_stats *stats)
 {
@@ -2860,6 +2949,9 @@ int al_eth_mac_stats_get(struct al_hw_eth_adapter *adapter, struct al_eth_mac_st
 		stats->etherStatsPkts1519toX = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts1519toMax);
 	}
 
+	stats->eee_in = readl(&adapter->mac_regs_base->stat.eee_in);
+	stats->eee_out = readl(&adapter->mac_regs_base->stat.eee_out);
+
 /*	stats->etherStatsPkts = 1; */
 	return 0;
 }
-- 
2.11.0

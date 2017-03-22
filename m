From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: add set_mac to the stmmac_ops
Date: Wed, 22 Mar 2017 14:29:04 +0100
Message-ID: <20170322132904.2687-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two different set_mac functions exists but stmmac_dwmac4_set_mac() is
only used for enabling and never for disabling.
So on dwmac4, the MAC RX/TX is never disabled.

This patch add a generic function pointer set_mac() to stmmac_ops and
replace all call to stmmac_set_mac/stmmac_dwmac4_set_mac by a call to
this pointer.

Since dwmac4_ops is const, set_mac cannot be modified after, and so dwmac4_ops
is duplioacted like dwmac4_dma_ops.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  2 ++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  1 +
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 36 ++++++++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 15 ++++-----
 5 files changed, 46 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index badc441..ec92e51 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -465,6 +465,8 @@ struct mac_device_info;
 struct stmmac_ops {
 	/* MAC core initialization */
 	void (*core_init)(struct mac_device_info *hw, int mtu);
+	/* Enable the MAC RX/TX */
+	void (*set_mac)(void __iomem *ioaddr, bool enable);
 	/* Enable and verify that the IPC module is supported */
 	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Enable RX Queues */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 7f78f77..f3d9305 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -490,6 +490,7 @@ static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
 
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
+	.set_mac = stmmac_set_mac,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
 	.dump_regs = dwmac1000_dump_regs,
 	.host_irq_status = dwmac1000_irq_status,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 524135e..1b36091 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -150,6 +150,7 @@ static void dwmac100_pmt(struct mac_device_info *hw, unsigned long mode)
 
 static const struct stmmac_ops dwmac100_ops = {
 	.core_init = dwmac100_core_init,
+	.set_mac = stmmac_set_mac,
 	.rx_ipc = dwmac100_rx_ipc_enable,
 	.dump_regs = dwmac100_dump_mac_regs,
 	.host_irq_status = dwmac100_irq_status,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 10599db..4cfc767 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -601,6 +601,35 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
 
 static const struct stmmac_ops dwmac4_ops = {
 	.core_init = dwmac4_core_init,
+	.set_mac = stmmac_set_mac,
+	.rx_ipc = dwmac4_rx_ipc_enable,
+	.rx_queue_enable = dwmac4_rx_queue_enable,
+	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
+	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
+	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
+	.map_mtl_to_dma = dwmac4_map_mtl_dma,
+	.config_cbs = dwmac4_config_cbs,
+	.dump_regs = dwmac4_dump_regs,
+	.host_irq_status = dwmac4_irq_status,
+	.host_mtl_irq_status = dwmac4_irq_mtl_status,
+	.flow_ctrl = dwmac4_flow_ctrl,
+	.pmt = dwmac4_pmt,
+	.set_umac_addr = dwmac4_set_umac_addr,
+	.get_umac_addr = dwmac4_get_umac_addr,
+	.set_eee_mode = dwmac4_set_eee_mode,
+	.reset_eee_mode = dwmac4_reset_eee_mode,
+	.set_eee_timer = dwmac4_set_eee_timer,
+	.set_eee_pls = dwmac4_set_eee_pls,
+	.pcs_ctrl_ane = dwmac4_ctrl_ane,
+	.pcs_rane = dwmac4_rane,
+	.pcs_get_adv_lp = dwmac4_get_adv_lp,
+	.debug = dwmac4_debug,
+	.set_filter = dwmac4_set_filter,
+};
+
+static const struct stmmac_ops dwmac410_ops = {
+	.core_init = dwmac4_core_init,
+	.set_mac = stmmac_dwmac4_set_mac,
 	.rx_ipc = dwmac4_rx_ipc_enable,
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
@@ -644,8 +673,6 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	if (mac->multicast_filter_bins)
 		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
 
-	mac->mac = &dwmac4_ops;
-
 	mac->link.port = GMAC_CONFIG_PS;
 	mac->link.duplex = GMAC_CONFIG_DM;
 	mac->link.speed = GMAC_CONFIG_FES;
@@ -666,5 +693,10 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	else
 		mac->dma = &dwmac4_dma_ops;
 
+	if (*synopsys_id >= DWMAC_CORE_4_00)
+		mac->mac = &dwmac410_ops;
+	else
+		mac->mac = &dwmac4_ops;
+
 	return mac;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 79ffb08..2993ac8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2006,10 +2006,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	}
 
 	/* Enable the MAC Rx/Tx */
-	if (priv->synopsys_id >= DWMAC_CORE_4_00)
-		stmmac_dwmac4_set_mac(priv->ioaddr, true);
-	else
-		stmmac_set_mac(priv->ioaddr, true);
+	if (priv->hw->mac->set_mac)
+		priv->hw->mac->set_mac(priv->ioaddr, true);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
@@ -2224,7 +2222,8 @@ static int stmmac_release(struct net_device *dev)
 	free_dma_desc_resources(priv);
 
 	/* Disable the MAC Rx/Tx */
-	stmmac_set_mac(priv->ioaddr, false);
+	if (priv->hw->mac->set_mac)
+		priv->hw->mac->set_mac(priv->ioaddr, false);
 
 	netif_carrier_off(dev);
 
@@ -3710,7 +3709,8 @@ int stmmac_dvr_remove(struct device *dev)
 
 	stmmac_stop_all_dma(priv);
 
-	stmmac_set_mac(priv->ioaddr, false);
+	if (priv->hw->mac->set_mac)
+		priv->hw->mac->set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	if (priv->plat->stmmac_rst)
@@ -3761,7 +3761,8 @@ int stmmac_suspend(struct device *dev)
 		priv->hw->mac->pmt(priv->hw, priv->wolopts);
 		priv->irq_wake = 1;
 	} else {
-		stmmac_set_mac(priv->ioaddr, false);
+		if (priv->hw->mac->set_mac)
+			priv->hw->mac->set_mac(priv->ioaddr, false);
 		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
 		clk_disable(priv->plat->pclk);
-- 
2.10.2

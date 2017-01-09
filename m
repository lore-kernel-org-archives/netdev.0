From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v6 2/3] stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure
Date: Mon, 9 Jan 2017 12:35:09 +0000
Message-ID: <173801947a1731c5e7dc65b155edea7ea5b958cc.1483964586.git.jpinto@synopsys.com>
References: <cover.1483964586.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lars.persson@axis.com>, <niklass@axis.com>, <swarren@nvidia.com>,
        <treding@nvidia.com>, <netdev@vger.kernel.org>,
        <nathan.sullivan@ni.com>, Joao Pinto <Joao.Pinto@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:52576 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760736AbdAIMfX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 07:35:23 -0500
In-Reply-To: <cover.1483964586.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to the
plat_stmmacenet_data structure. It also moves these platform variables
initialization to stmmac_platform. This was done for two reasons:

a) If PCI is used, platform related code is being executed in stmmac_main
resulting in warnings that have no sense and conceptually was not right

b) stmmac as a synopsys reference ethernet driver stack will be hosting
more and more drivers to its structure like synopsys/dwc_eth_qos.c.
These drivers have their own DT bindings that are not compatible with
stmmac's. One of the most important are the clock names, and so they need
to be parsed in the glue logic and initialized there, and that is the main
reason why the clocks were passed to the platform structure.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
Tested-by: Niklas Cassel <niklas.cassel@axis.com>
Reviewed-by: Lars Persson <larper@axis.com>
Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>
---
changes v5 -> v6:
- rebased master branch to achieve clean patch
changes v3 -> v5:
- Nothing changed, just to keep up patch set version
changes v2 -> v3:
- dwmac-socfpga glue driver was also using stmmac_rst from priv struct and
was causing a build error caught by kbuild robot
changes v1 -> v2:
- Nothing changed, just to keep up patch set version

 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  5 --
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 82 ++++------------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 47 +++++++++++++
 include/linux/stmmac.h                             |  5 ++
 6 files changed, 70 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 1f99702..17d4bba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -341,7 +341,7 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	 * mode. Create a copy of the core reset handle so it can be used by
 	 * the driver later.
 	 */
-	dwmac->stmmac_rst = stpriv->stmmac_rst;
+	dwmac->stmmac_rst = stpriv->plat->stmmac_rst;
 
 	ret = socfpga_dwmac_set_phy_mode(dwmac);
 	if (ret)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index eab04ae..bf8a83e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -106,9 +106,6 @@ struct stmmac_priv {
 	u32 msg_enable;
 	int wolopts;
 	int wol_irq;
-	struct clk *stmmac_clk;
-	struct clk *pclk;
-	struct reset_control *stmmac_rst;
 	int clk_csr;
 	struct timer_list eee_ctrl_timer;
 	int lpi_irq;
@@ -120,8 +117,6 @@ struct stmmac_priv {
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_clock_ops;
 	unsigned int default_addend;
-	struct clk *clk_ptp_ref;
-	unsigned int clk_ptp_rate;
 	u32 adv_ts;
 	int use_riwt;
 	int irq_wake;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 699ee1d..322e5c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -712,7 +712,7 @@ static int stmmac_ethtool_op_set_eee(struct net_device *dev,
 
 static u32 stmmac_usec2riwt(u32 usec, struct stmmac_priv *priv)
 {
-	unsigned long clk = clk_get_rate(priv->stmmac_clk);
+	unsigned long clk = clk_get_rate(priv->plat->stmmac_clk);
 
 	if (!clk)
 		return 0;
@@ -722,7 +722,7 @@ static u32 stmmac_usec2riwt(u32 usec, struct stmmac_priv *priv)
 
 static u32 stmmac_riwt2usec(u32 riwt, struct stmmac_priv *priv)
 {
-	unsigned long clk = clk_get_rate(priv->stmmac_clk);
+	unsigned long clk = clk_get_rate(priv->plat->stmmac_clk);
 
 	if (!clk)
 		return 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fa0b4de..02808e8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -158,7 +158,7 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 {
 	u32 clk_rate;
 
-	clk_rate = clk_get_rate(priv->stmmac_clk);
+	clk_rate = clk_get_rate(priv->plat->stmmac_clk);
 
 	/* Platform provided default clk_csr would be assumed valid
 	 * for all other cases except for the below mentioned ones.
@@ -607,7 +607,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 
 		/* program Sub Second Increment reg */
 		sec_inc = priv->hw->ptp->config_sub_second_increment(
-			priv->ptpaddr, priv->clk_ptp_rate,
+			priv->ptpaddr, priv->plat->clk_ptp_rate,
 			priv->plat->has_gmac4);
 		temp = div_u64(1000000000ULL, sec_inc);
 
@@ -617,7 +617,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 * where, freq_div_ratio = 1e9ns/sec_inc
 		 */
 		temp = (u64)(temp << 32);
-		priv->default_addend = div_u64(temp, priv->clk_ptp_rate);
+		priv->default_addend = div_u64(temp, priv->plat->clk_ptp_rate);
 		priv->hw->ptp->config_addend(priv->ptpaddr,
 					     priv->default_addend);
 
@@ -645,18 +645,6 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
 		return -EOPNOTSUPP;
 
-	/* Fall-back to main clock in case of no PTP ref is passed */
-	priv->clk_ptp_ref = devm_clk_get(priv->device, "clk_ptp_ref");
-	if (IS_ERR(priv->clk_ptp_ref)) {
-		priv->clk_ptp_rate = clk_get_rate(priv->stmmac_clk);
-		priv->clk_ptp_ref = NULL;
-		netdev_dbg(priv->dev, "PTP uses main clock\n");
-	} else {
-		clk_prepare_enable(priv->clk_ptp_ref);
-		priv->clk_ptp_rate = clk_get_rate(priv->clk_ptp_ref);
-		netdev_dbg(priv->dev, "PTP rate %d\n", priv->clk_ptp_rate);
-	}
-
 	priv->adv_ts = 0;
 	/* Check if adv_ts can be enabled for dwmac 4.x core */
 	if (priv->plat->has_gmac4 && priv->dma_cap.atime_stamp)
@@ -683,8 +671,8 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 
 static void stmmac_release_ptp(struct stmmac_priv *priv)
 {
-	if (priv->clk_ptp_ref)
-		clk_disable_unprepare(priv->clk_ptp_ref);
+	if (priv->plat->clk_ptp_ref)
+		clk_disable_unprepare(priv->plat->clk_ptp_ref);
 	stmmac_ptp_unregister(priv);
 }
 
@@ -3278,44 +3266,8 @@ int stmmac_dvr_probe(struct device *device,
 	if ((phyaddr >= 0) && (phyaddr <= 31))
 		priv->plat->phy_addr = phyaddr;
 
-	priv->stmmac_clk = devm_clk_get(priv->device, STMMAC_RESOURCE_NAME);
-	if (IS_ERR(priv->stmmac_clk)) {
-		netdev_warn(priv->dev, "%s: warning: cannot get CSR clock\n",
-			    __func__);
-		/* If failed to obtain stmmac_clk and specific clk_csr value
-		 * is NOT passed from the platform, probe fail.
-		 */
-		if (!priv->plat->clk_csr) {
-			ret = PTR_ERR(priv->stmmac_clk);
-			goto error_clk_get;
-		} else {
-			priv->stmmac_clk = NULL;
-		}
-	}
-	clk_prepare_enable(priv->stmmac_clk);
-
-	priv->pclk = devm_clk_get(priv->device, "pclk");
-	if (IS_ERR(priv->pclk)) {
-		if (PTR_ERR(priv->pclk) == -EPROBE_DEFER) {
-			ret = -EPROBE_DEFER;
-			goto error_pclk_get;
-		}
-		priv->pclk = NULL;
-	}
-	clk_prepare_enable(priv->pclk);
-
-	priv->stmmac_rst = devm_reset_control_get(priv->device,
-						  STMMAC_RESOURCE_NAME);
-	if (IS_ERR(priv->stmmac_rst)) {
-		if (PTR_ERR(priv->stmmac_rst) == -EPROBE_DEFER) {
-			ret = -EPROBE_DEFER;
-			goto error_hw_init;
-		}
-		dev_info(priv->device, "no reset control found\n");
-		priv->stmmac_rst = NULL;
-	}
-	if (priv->stmmac_rst)
-		reset_control_deassert(priv->stmmac_rst);
+	if (priv->plat->stmmac_rst)
+		reset_control_deassert(priv->plat->stmmac_rst);
 
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
@@ -3409,10 +3361,6 @@ int stmmac_dvr_probe(struct device *device,
 error_mdio_register:
 	netif_napi_del(&priv->napi);
 error_hw_init:
-	clk_disable_unprepare(priv->pclk);
-error_pclk_get:
-	clk_disable_unprepare(priv->stmmac_clk);
-error_clk_get:
 	free_netdev(ndev);
 
 	return ret;
@@ -3438,10 +3386,10 @@ int stmmac_dvr_remove(struct device *dev)
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
-	if (priv->stmmac_rst)
-		reset_control_assert(priv->stmmac_rst);
-	clk_disable_unprepare(priv->pclk);
-	clk_disable_unprepare(priv->stmmac_clk);
+	if (priv->plat->stmmac_rst)
+		reset_control_assert(priv->plat->stmmac_rst);
+	clk_disable_unprepare(priv->plat->pclk);
+	clk_disable_unprepare(priv->plat->stmmac_clk);
 	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
 	    priv->hw->pcs != STMMAC_PCS_TBI &&
 	    priv->hw->pcs != STMMAC_PCS_RTBI)
@@ -3490,8 +3438,8 @@ int stmmac_suspend(struct device *dev)
 		stmmac_set_mac(priv->ioaddr, false);
 		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
-		clk_disable(priv->pclk);
-		clk_disable(priv->stmmac_clk);
+		clk_disable(priv->plat->pclk);
+		clk_disable(priv->plat->stmmac_clk);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -3531,8 +3479,8 @@ int stmmac_resume(struct device *dev)
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
 		/* enable the clk prevously disabled */
-		clk_enable(priv->stmmac_clk);
-		clk_enable(priv->pclk);
+		clk_enable(priv->plat->stmmac_clk);
+		clk_enable(priv->plat->pclk);
 		/* reset the phy so that it's ready */
 		if (priv->mii)
 			stmmac_mdio_reset(priv->mii);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 78ccb50..b489ae4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -335,7 +335,54 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 
 	plat->axi = stmmac_axi_setup(pdev);
 
+	/* clock setup */
+	plat->stmmac_clk = devm_clk_get(&pdev->dev,
+					STMMAC_RESOURCE_NAME);
+	if (IS_ERR(plat->stmmac_clk)) {
+		dev_warn(&pdev->dev, "Cannot get CSR clock\n");
+		plat->stmmac_clk = NULL;
+	}
+	clk_prepare_enable(plat->stmmac_clk);
+
+	plat->pclk = devm_clk_get(&pdev->dev, "pclk");
+	if (IS_ERR(plat->pclk)) {
+		if (PTR_ERR(plat->pclk) == -EPROBE_DEFER)
+			goto error_pclk_get;
+
+		plat->pclk = NULL;
+	}
+	clk_prepare_enable(plat->pclk);
+
+	/* Fall-back to main clock in case of no PTP ref is passed */
+	plat->clk_ptp_ref = devm_clk_get(&pdev->dev, "clk_ptp_ref");
+	if (IS_ERR(plat->clk_ptp_ref)) {
+		plat->clk_ptp_rate = clk_get_rate(plat->stmmac_clk);
+		plat->clk_ptp_ref = NULL;
+		dev_warn(&pdev->dev, "PTP uses main clock\n");
+	} else {
+		clk_prepare_enable(plat->clk_ptp_ref);
+		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
+		dev_info(&pdev->dev, "No reset control found\n");
+	}
+
+	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
+						  STMMAC_RESOURCE_NAME);
+	if (IS_ERR(plat->stmmac_rst)) {
+		if (PTR_ERR(plat->stmmac_rst) == -EPROBE_DEFER)
+			goto error_hw_init;
+
+		dev_info(&pdev->dev, "no reset control found\n");
+		plat->stmmac_rst = NULL;
+	}
+
 	return plat;
+
+error_hw_init:
+	clk_disable_unprepare(plat->pclk);
+error_pclk_get:
+	clk_disable_unprepare(plat->stmmac_clk);
+
+	return ERR_PTR(-EPROBE_DEFER);
 }
 
 /**
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index e3cd758..d76033d6 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -138,6 +138,11 @@ struct plat_stmmacenet_data {
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
+	struct clk *stmmac_clk;
+	struct clk *pclk;
+	struct clk *clk_ptp_ref;
+	unsigned int clk_ptp_rate;
+	struct reset_control *stmmac_rst;
 	struct stmmac_axi *axi;
 	int has_gmac4;
 	bool tso_en;
-- 
2.9.3

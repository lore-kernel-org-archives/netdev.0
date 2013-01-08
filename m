From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 1/3] net: stmac: add gmac autonet set for SGMII, TBI, and RTBI
Date: Tue, 08 Jan 2013 15:35:39 -0800
Message-ID: <000901cdedf8$dfaf4390$9f0dcab0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, kgene.kim@samsung.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: en-zw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds gmac autoneg set function for SGMII, TBI,
and RTBI interface. In case of PHY's autoneg is set, gmac's
autoneg enable bit should set. After checking phy's autoneg
if phydev's autoneg is '1' gmac's ANE bit set for those
interface.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h         |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |   11 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    9 +++++++++
 3 files changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
b/drivers/net/ethernet/stmicro/stmmac/common.h
index 186d148..72ba769 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -344,6 +344,7 @@ struct stmmac_ops {
 	void (*reset_eee_mode) (void __iomem *ioaddr);
 	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
 	void (*set_eee_pls) (void __iomem *ioaddr, int link);
+	void (*set_autoneg) (void __iomem *ioaddr);
 };
 
 struct mac_link {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index bfe0226..a0737b39 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -297,6 +297,16 @@ static void  dwmac1000_set_eee_timer(void __iomem
*ioaddr, int ls, int tw)
 	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
+static void dwmac1000_set_autoneg(void __iomem *ioaddr)
+{
+	u32 value;
+
+	value = readl(ioaddr + GMAC_AN_CTRL);
+	value |= 0x1000;
+	writel(value, ioaddr + GMAC_AN_CTRL);
+}
+
+
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
@@ -311,6 +321,7 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.reset_eee_mode =  dwmac1000_reset_eee_mode,
 	.set_eee_timer =  dwmac1000_set_eee_timer,
 	.set_eee_pls =  dwmac1000_set_eee_pls,
+	.set_autoneg =  dwmac1000_set_autoneg,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f07c061..3e28934 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1007,6 +1007,7 @@ static int stmmac_open(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
+	int interface = priv->plat->interface;
 
 	clk_prepare_enable(priv->stmmac_clk);
 
@@ -1041,6 +1042,14 @@ static int stmmac_open(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
+	/* If phy autoneg is on, set gmac autoneg for SGMII, TBI and RTBI*/
+	if((interface == PHY_INTERFACE_MODE_SGMII) ||
+		(interface == PHY_INTERFACE_MODE_TBI) ||
+		(interface == PHY_INTERFACE_MODE_RTBI)) {
+		if (priv->phydev->autoneg)
+			priv->hw->mac->set_autoneg(priv->ioaddr);
+	}
+
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			 IRQF_SHARED, dev->name, dev);
-- 
1.7.10.4

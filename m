From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH net-next 2/3] net: stmmac: add autoneg complete irq
Date: Tue, 15 Jan 2013 13:49:18 -0800
Message-ID: <00c501cdf36a$2cac3a60$8604af20$@samsung.com>
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


This patch adds auto-negotiation complete irq and ISR.
when the irq is occured it read GMAC_AN_STATUS register
to clear PCSANCIS bit.

Singed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h         |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |    5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h         |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    2 ++
 4 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
b/drivers/net/ethernet/stmicro/stmmac/common.h
index 72ba769..bc5ce7a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -203,6 +203,7 @@ enum core_specific_irq_mask {
 	core_irq_tx_path_exit_lpi_mode = 32,
 	core_irq_rx_path_in_lpi_mode = 64,
 	core_irq_rx_path_exit_lpi_mode = 128,
+	core_irq_pcs_autoneg_complete = 256,
 };
 
 /* DMA HW capabilities */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index a0737b39..0643ed3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -222,6 +222,11 @@ static int dwmac1000_irq_status(void __iomem *ioaddr)
 		readl(ioaddr + GMAC_PMT);
 		status |= core_irq_receive_pmt_irq;
 	}
+	if (unlikely(intr_status & pcs_ane_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC: PCS Auto-negotiation complete\n");
+		readl(ioaddr + GMAC_AN_STATUS);
+		status |= core_irq_pcs_autoneg_complete;
+	}
 	/* MAC trx/rx EEE LPI entry/exit interrupts */
 	if (intr_status & lpiis_irq) {
 		/* Clean LPI interrupt by reading the Reg 12 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b05df89..b4220f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 	u32 tx_coal_timer;
 	int use_riwt;
 	u32 rx_riwt;
+	bool core_pcs_an;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3e28934..0d2afbb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1623,6 +1623,8 @@ static irqreturn_t stmmac_interrupt(int irq, void
*dev_id)
 				priv->xstats.mmc_rx_csum_offload_irq_n++;
 			if (status & core_irq_receive_pmt_irq)
 				priv->xstats.irq_receive_pmt_irq_n++;
+			if (status & core_irq_pcs_autoneg_complete)
+				priv->core_pcs_an = true;
 
 			/* For LPI we need to save the tx status */
 			if (status & core_irq_tx_path_in_lpi_mode) {
-- 
1.7.10.4

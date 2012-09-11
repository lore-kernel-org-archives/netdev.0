From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 6/8] stmmac: fix and review the rx irq path after adding new mitigation
Date: Tue, 11 Sep 2012 08:55:12 +0200
Message-ID: <1347346514-23411-7-git-send-email-peppe.cavallaro@st.com>
References: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:49982 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756287Ab2IKGzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 02:55:49 -0400
In-Reply-To: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After adopting the new mitigation approach I have
found a couple of problems in the rx irq path.
The enable/disable_dma_irq functions now are used for
handling the DMA_INTR_ENA_RIE bit in the DMA register 7.
So this patch masks the specific bit in this register.
Also these function names have been changed (to make clear
their meaning).
A new extra statistic field has been added to show the early
receive status in the interrupt handler as well. This has been
useful on debugging stage, indeed.
In the end, this patch also adds an extra check to avoid to call
napi_schedule when the DMA_INTR_ENA_RIE bit is disabled in the
Interrupt Mask register.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   12 +++++---
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   27 ++++++++++++++-----
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    9 ++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   17 ++++--------
 7 files changed, 45 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index b9033cc..9daa9df 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -85,7 +85,7 @@ struct stmmac_extra_stats {
 	unsigned long rx_missed_cntr;
 	unsigned long rx_overflow_cntr;
 	unsigned long rx_vlan;
-	/* Tx/Rx IRQ errors */
+	/* Tx/Rx IRQ error info */
 	unsigned long tx_undeflow_irq;
 	unsigned long tx_process_stopped_irq;
 	unsigned long tx_jabber_irq;
@@ -95,7 +95,8 @@ struct stmmac_extra_stats {
 	unsigned long rx_watchdog_irq;
 	unsigned long tx_early_irq;
 	unsigned long fatal_bus_error_irq;
-	/* Extra info */
+	/* Tx/Rx IRQ Events */
+	unsigned long rx_early_irq;
 	unsigned long threshold;
 	unsigned long tx_pkt_n;
 	unsigned long rx_pkt_n;
@@ -106,11 +107,12 @@ struct stmmac_extra_stats {
 	unsigned long txtimer;
 	unsigned long tx_clean;
 	unsigned long tx_reset_ic_bit;
+	unsigned long irq_receive_pmt_irq_n;
+	/* MMC info */
 	unsigned long mmc_tx_irq_n;
 	unsigned long mmc_rx_irq_n;
 	unsigned long mmc_rx_csum_offload_irq_n;
 	/* EEE */
-	unsigned long irq_receive_pmt_irq_n;
 	unsigned long irq_tx_path_in_lpi_mode_n;
 	unsigned long irq_tx_path_exit_lpi_mode_n;
 	unsigned long irq_rx_path_in_lpi_mode_n;
@@ -302,8 +304,8 @@ struct stmmac_dma_ops {
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
 	void (*enable_dma_transmission) (void __iomem *ioaddr);
-	void (*enable_dma_irq) (void __iomem *ioaddr);
-	void (*disable_dma_irq) (void __iomem *ioaddr);
+	void (*enable_rx_dma_irq) (void __iomem *ioaddr);
+	void (*disable_rx_dma_irq) (void __iomem *ioaddr);
 	void (*start_tx) (void __iomem *ioaddr);
 	void (*stop_tx) (void __iomem *ioaddr);
 	void (*start_rx) (void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index bf83c03..9804e82 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -184,8 +184,8 @@ const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.dump_regs = dwmac1000_dump_dma_regs,
 	.dma_mode = dwmac1000_dma_operation_mode,
 	.enable_dma_transmission = dwmac_enable_dma_transmission,
-	.enable_dma_irq = dwmac_enable_dma_irq,
-	.disable_dma_irq = dwmac_disable_dma_irq,
+	.enable_rx_dma_irq = dwmac_enable_rx_dma_irq,
+	.disable_rx_dma_irq = dwmac_disable_rx_dma_irq,
 	.start_tx = dwmac_dma_start_tx,
 	.stop_tx = dwmac_dma_stop_tx,
 	.start_rx = dwmac_dma_start_rx,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index c2b4d55..81630c3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -134,8 +134,8 @@ const struct stmmac_dma_ops dwmac100_dma_ops = {
 	.dma_mode = dwmac100_dma_operation_mode,
 	.dma_diagnostic_fr = dwmac100_dma_diagnostic_fr,
 	.enable_dma_transmission = dwmac_enable_dma_transmission,
-	.enable_dma_irq = dwmac_enable_dma_irq,
-	.disable_dma_irq = dwmac_disable_dma_irq,
+	.enable_rx_dma_irq = dwmac_enable_rx_dma_irq,
+	.disable_rx_dma_irq = dwmac_disable_rx_dma_irq,
 	.start_tx = dwmac_dma_start_tx,
 	.stop_tx = dwmac_dma_stop_tx,
 	.start_rx = dwmac_dma_start_rx,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 4eeff5d..b91c8cf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -105,8 +105,8 @@
 #define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
 
 extern void dwmac_enable_dma_transmission(void __iomem *ioaddr);
-extern void dwmac_enable_dma_irq(void __iomem *ioaddr);
-extern void dwmac_disable_dma_irq(void __iomem *ioaddr);
+extern void dwmac_enable_rx_dma_irq(void __iomem *ioaddr);
+extern void dwmac_disable_rx_dma_irq(void __iomem *ioaddr);
 extern void dwmac_dma_start_tx(void __iomem *ioaddr);
 extern void dwmac_dma_stop_tx(void __iomem *ioaddr);
 extern void dwmac_dma_start_rx(void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 73766e6..a650019 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -39,14 +39,20 @@ void dwmac_enable_dma_transmission(void __iomem *ioaddr)
 	writel(1, ioaddr + DMA_XMT_POLL_DEMAND);
 }
 
-void dwmac_enable_dma_irq(void __iomem *ioaddr)
+void dwmac_enable_rx_dma_irq(void __iomem *ioaddr)
 {
-	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
+	u32 value = readl(ioaddr + DMA_INTR_ENA);
+
+	value |= DMA_INTR_ENA_RIE;
+	writel(value, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_disable_dma_irq(void __iomem *ioaddr)
+void dwmac_disable_rx_dma_irq(void __iomem *ioaddr)
 {
-	writel(0, ioaddr + DMA_INTR_ENA);
+	u32 value = readl(ioaddr + DMA_INTR_ENA);
+
+	value &= ~DMA_INTR_ENA_RIE;
+	writel(value, ioaddr + DMA_INTR_ENA);
 }
 
 void dwmac_dma_start_tx(void __iomem *ioaddr)
@@ -206,15 +212,22 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* TX/RX NORMAL interrupts */
 	if (intr_status & DMA_STATUS_NIS) {
 		x->normal_irq_n++;
-		if (likely(intr_status & DMA_STATUS_RI))
-			ret |= handle_rx;
-		if (intr_status & (DMA_STATUS_TI))
+		if (likely(intr_status & DMA_STATUS_RI)) {
+			u32 value = readl(ioaddr + DMA_INTR_ENA);
+			/* to schedule NAPI on real RIE event. */
+			if (likely(value & DMA_INTR_ENA_RIE))
+				ret |= handle_rx;
+		}
+		if (intr_status & DMA_STATUS_TI)
 			ret |= handle_tx;
+		if (intr_status & DMA_STATUS_ERI)
+			x->rx_early_irq++;
 	}
 	/* Optional hardware blocks, interrupts should be disabled */
 	if (unlikely(intr_status &
 		     (DMA_STATUS_GPI | DMA_STATUS_GMI | DMA_STATUS_GLI)))
 		pr_info("%s: unexpected status %08x\n", __func__, intr_status);
+
 	/* Clear the interrupt by writing a logic 1 to the CSR5[15-0] */
 	writel((intr_status & 0x1ffff), ioaddr + DMA_STATUS);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d27cc18..1ea5520 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -76,7 +76,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(rx_missed_cntr),
 	STMMAC_STAT(rx_overflow_cntr),
 	STMMAC_STAT(rx_vlan),
-	/* Tx/Rx IRQ errors */
+	/* Tx/Rx IRQ error info */
 	STMMAC_STAT(tx_undeflow_irq),
 	STMMAC_STAT(tx_process_stopped_irq),
 	STMMAC_STAT(tx_jabber_irq),
@@ -86,7 +86,8 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(rx_watchdog_irq),
 	STMMAC_STAT(tx_early_irq),
 	STMMAC_STAT(fatal_bus_error_irq),
-	/* Extra info */
+	/* Tx/Rx IRQ Events */
+	STMMAC_STAT(rx_early_irq),
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
@@ -97,10 +98,12 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(txtimer),
 	STMMAC_STAT(tx_clean),
 	STMMAC_STAT(tx_reset_ic_bit),
+	STMMAC_STAT(irq_receive_pmt_irq_n),
+	/* MMC info */
 	STMMAC_STAT(mmc_tx_irq_n),
 	STMMAC_STAT(mmc_rx_irq_n),
 	STMMAC_STAT(mmc_rx_csum_offload_irq_n),
-	STMMAC_STAT(irq_receive_pmt_irq_n),
+	/* EEE */
 	STMMAC_STAT(irq_tx_path_in_lpi_mode_n),
 	STMMAC_STAT(irq_tx_path_exit_lpi_mode_n),
 	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b0731e6..0b37c6d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -778,12 +778,12 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 {
-	priv->hw->dma->enable_dma_irq(priv->ioaddr);
+	priv->hw->dma->enable_rx_dma_irq(priv->ioaddr);
 }
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 {
-	priv->hw->dma->disable_dma_irq(priv->ioaddr);
+	priv->hw->dma->disable_rx_dma_irq(priv->ioaddr);
 }
 
 static void stmmac_txtimer(unsigned long data)
@@ -815,14 +815,6 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
-static void stmmac_rx_work(struct stmmac_priv *priv)
-{
-	if (likely(napi_schedule_prep(&priv->napi))) {
-		stmmac_disable_irq(priv);
-		__napi_schedule(&priv->napi);
-	}
-}
-
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
 	int status;
@@ -830,7 +822,10 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely(status & handle_rx)) {
 		priv->xstats.rx_normal_irq_n++;
-		stmmac_rx_work(priv);
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			stmmac_disable_irq(priv);
+			__napi_schedule(&priv->napi);
+		}
 	}
 	if (likely(status & handle_tx)) {
 		priv->xstats.tx_normal_irq_n++;
-- 
1.7.4.4

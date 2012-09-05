From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/7] stmmac: manage tx clean out of rx_poll
Date: Wed,  5 Sep 2012 17:03:47 +0200
Message-ID: <1346857432-24657-3-git-send-email-peppe.cavallaro@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:44130 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752370Ab2IEPEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:04:11 -0400
In-Reply-To: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to invoke the stmmac_tx (tx handler)
out of the NAPI poll method.
This will make easier the next step to add the new
mitigation schema.
Also the patch enhances the ethtool to report some
stats for normal TX and RX IRQs.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   13 +++++++----
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    7 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    4 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   22 ++++++++++++++-----
 4 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 719be39..bd32fe6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -95,7 +95,9 @@ struct stmmac_extra_stats {
 	unsigned long threshold;
 	unsigned long tx_pkt_n;
 	unsigned long rx_pkt_n;
-	unsigned long poll_n;
+	unsigned long rx_napi_poll;
+	unsigned long rx_normal_irq_n;
+	unsigned long tx_normal_irq_n;
 	unsigned long sched_timer_n;
 	unsigned long normal_irq_n;
 	unsigned long mmc_tx_irq_n;
@@ -169,10 +171,11 @@ enum rx_frame_status { /* IPC status */
 	llc_snap = 4,
 };
 
-enum tx_dma_irq_status {
-	tx_hard_error = 1,
-	tx_hard_error_bump_tc = 2,
-	handle_tx_rx = 3,
+enum dma_irq_status {
+	tx_hard_error = 0x1,
+	tx_hard_error_bump_tc = 0x2,
+	handle_rx = 0x4,
+	handle_tx = 0x8,
 };
 
 enum core_specific_irq_mask {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 4e0e18a..73766e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -206,9 +206,10 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* TX/RX NORMAL interrupts */
 	if (intr_status & DMA_STATUS_NIS) {
 		x->normal_irq_n++;
-		if (likely((intr_status & DMA_STATUS_RI) ||
-			 (intr_status & (DMA_STATUS_TI))))
-				ret = handle_tx_rx;
+		if (likely(intr_status & DMA_STATUS_RI))
+			ret |= handle_rx;
+		if (intr_status & (DMA_STATUS_TI))
+			ret |= handle_tx;
 	}
 	/* Optional hardware blocks, interrupts should be disabled */
 	if (unlikely(intr_status &
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 76fd61a..505fe71 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -90,7 +90,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
-	STMMAC_STAT(poll_n),
+	STMMAC_STAT(rx_napi_poll),
+	STMMAC_STAT(rx_normal_irq_n),
+	STMMAC_STAT(tx_normal_irq_n),
 	STMMAC_STAT(sched_timer_n),
 	STMMAC_STAT(normal_irq_n),
 	STMMAC_STAT(normal_irq_n),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c8985f3..b247c39 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -824,16 +824,27 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
+static inline void stmmac_rx_schedule(struct stmmac_priv *priv)
+{
+	if (likely(napi_schedule_prep(&priv->napi))) {
+		stmmac_disable_irq(priv);
+		__napi_schedule(&priv->napi);
+	}
+}
 
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
 	int status;
 
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
-	if (likely(status == handle_tx_rx))
-		_stmmac_schedule(priv);
-
-	else if (unlikely(status == tx_hard_error_bump_tc)) {
+	if (likely(status == handle_rx)) {
+		priv->xstats.rx_normal_irq_n++;
+		stmmac_rx_schedule(priv);
+	}
+	if (likely(status == handle_tx)) {
+		priv->xstats.tx_normal_irq_n++;
+		stmmac_tx(priv);
+	} else if (unlikely(status == tx_hard_error_bump_tc)) {
 		/* Try to bump up the dma threshold on this failure */
 		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 			tc += 64;
@@ -1443,8 +1454,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
 	int work_done = 0;
 
-	priv->xstats.poll_n++;
-	stmmac_tx(priv);
+	priv->xstats.rx_napi_poll++;
 	work_done = stmmac_rx(priv, budget);
 
 	if (work_done < budget) {
-- 
1.7.4.4

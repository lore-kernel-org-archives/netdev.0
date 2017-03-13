From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 11/11] net: stmmac: stmmac interrupt treatment prepared for multiple queues
Date: Mon, 13 Mar 2017 16:12:42 +0000
Message-ID: <1467c3e48552c58d0c0c620aded4807487996922.1489419357.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:57389 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753737AbdCMQNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:13:22 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the main ISR for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 28 ++++++++++++++++-------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7f46493..0af82a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3114,6 +3114,12 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+	u32 queues_count;
+	u32 queue;
+
+	queues_count = (rx_cnt > tx_cnt) ? rx_cnt : tx_cnt;
 
 	if (priv->irq_wake)
 		pm_wakeup_event(priv->device, 0);
@@ -3128,20 +3134,26 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
 
-		if (priv->synopsys_id >= DWMAC_CORE_4_00)
-			status |= priv->hw->mac->host_mtl_irq_status(priv->hw,
-								STMMAC_CHAN0);
-
 		if (unlikely(status)) {
 			/* For LPI we need to save the tx status */
 			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
 				priv->tx_path_in_lpi_mode = true;
 			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
-			if (status & CORE_IRQ_MTL_RX_OVERFLOW && priv->hw->dma->set_rx_tail_ptr)
-				priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
-							priv->rx_tail_addr,
-							STMMAC_CHAN0);
+		}
+
+		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+			for (queue = 0; queue < queues_count; queue++) {
+				status |=
+				priv->hw->mac->host_mtl_irq_status(priv->hw,
+								   queue);
+
+				if (status & CORE_IRQ_MTL_RX_OVERFLOW &&
+				    priv->hw->dma->set_rx_tail_ptr)
+					priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
+								priv->rx_tail_addr,
+								queue);
+			}
 		}
 
 		/* PCS link status */
-- 
2.9.3

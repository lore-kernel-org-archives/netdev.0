From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/2] drivers: net: cpsw: remove  disable_irq/enable_irq as irq can be masked from cpsw itself
Date: Mon, 27 Jul 2015 16:49:00 +0530
Message-ID: <1437995941-5857-2-git-send-email-mugunthanvnm@ti.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43492 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbbG0LTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:19:19 -0400
In-Reply-To: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW interrupts can be disabled by masking CPSW interrupts and
clearing interrupt by writing appropriate EOI. So removing all
disable_irq/enable_irq as discussed in [1]

[1] http://patchwork.ozlabs.org/patch/492741/

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 27 ++-------------------------
 1 file changed, 2 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d155bf2..d68d759 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -389,7 +389,6 @@ struct cpsw_priv {
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
-	bool irq_enabled;
 	struct cpts *cpts;
 	u32 emac_port;
 };
@@ -767,12 +766,7 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	struct cpsw_priv *priv = dev_id;
 
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
-
-	cpsw_intr_disable(priv);
-	if (priv->irq_enabled == true) {
-		disable_irq_nosync(priv->irqs_table[0]);
-		priv->irq_enabled = false;
-	}
+	writel(0, &priv->wr_regs->rx_en);
 
 	if (netif_running(priv->ndev)) {
 		napi_schedule(&priv->napi);
@@ -797,15 +791,8 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 
 	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
-		struct cpsw_priv *prim_cpsw;
-
 		napi_complete(napi);
-		cpsw_intr_enable(priv);
-		prim_cpsw = cpsw_get_slave_priv(priv, 0);
-		if (prim_cpsw->irq_enabled == false) {
-			prim_cpsw->irq_enabled = true;
-			enable_irq(priv->irqs_table[0]);
-		}
+		writel(0xff, &priv->wr_regs->rx_en);
 	}
 
 	if (num_rx)
@@ -1230,7 +1217,6 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 static int cpsw_ndo_open(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_priv *prim_cpsw;
 	int i, ret;
 	u32 reg;
 
@@ -1315,14 +1301,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 
-	prim_cpsw = cpsw_get_slave_priv(priv, 0);
-	if (prim_cpsw->irq_enabled == false) {
-		if ((priv == prim_cpsw) || !netif_running(prim_cpsw->ndev)) {
-			prim_cpsw->irq_enabled = true;
-			enable_irq(prim_cpsw->irqs_table[0]);
-		}
-	}
-
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = true;
 	return 0;
@@ -2169,7 +2147,6 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 	priv->rx_packet_max = max(rx_packet_max, 128);
 	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
-	priv->irq_enabled = true;
 	if (!priv->cpts) {
 		dev_err(&pdev->dev, "error allocating cpts\n");
 		ret = -ENOMEM;
-- 
2.5.0.rc3.2.g6f9504c

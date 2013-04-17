From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check which device is active
Date: Wed, 17 Apr 2013 23:52:14 +0200
Message-ID: <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41217 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966827Ab3DQVwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:52:38 -0400
In-Reply-To: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_running() reports false before even the ->ndo_stop() callback is
called. That means if one executes "ifconfig down" and the system
receives an interrupt before the interrupt source has been disabled we
hang for always for two reasons:
- we never disable the interrupt source because devices claim to be
  already inactive (or non-present)
- since the ISR always reports IRQ_HANDLED the line is never deactivated
  because it looks like the ISR feels respsonsible.

This patch introduces now the ->active field which is set/cleared in
ndo_open / ndo_stop.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3b22a36..c32780d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -341,6 +341,7 @@ struct cpsw_priv {
 	int				host_port;
 	struct clk			*clk;
 	u8				mac_addr[ETH_ALEN];
+	u8				active;
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
@@ -511,19 +512,24 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
 
-	if (likely(netif_running(priv->ndev))) {
+	if (priv->active) {
 		cpsw_intr_disable(priv);
 		cpsw_disable_irq(priv);
 		napi_schedule(&priv->napi);
-	} else {
-		priv = cpsw_get_slave_priv(priv, 1);
-		if (likely(priv) && likely(netif_running(priv->ndev))) {
-			cpsw_intr_disable(priv);
-			cpsw_disable_irq(priv);
-			napi_schedule(&priv->napi);
-		}
+		return IRQ_HANDLED;
+	}
+
+	priv = cpsw_get_slave_priv(priv, 1);
+	if (!priv)
+		return IRQ_NONE;
+
+	if (priv->active) {
+		cpsw_intr_disable(priv);
+		cpsw_disable_irq(priv);
+		napi_schedule(&priv->napi);
+		return IRQ_HANDLED;
 	}
-	return IRQ_HANDLED;
+	return IRQ_NONE;
 }
 
 static int cpsw_poll(struct napi_struct *napi, int budget)
@@ -937,6 +943,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
+	priv->active = 1;
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
@@ -980,6 +987,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	pm_runtime_put_sync(&priv->pdev->dev);
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = false;
+	priv->active = 0;
 	return 0;
 }
 
-- 
1.7.10.4

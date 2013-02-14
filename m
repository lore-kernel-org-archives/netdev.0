From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/1] drivers: net: davinci_cpdma: acknowledge interrupt properly
Date: Thu, 14 Feb 2013 23:56:46 +0530
Message-ID: <1360866406-17261-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53747 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758371Ab3BNS1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 13:27:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPDMA interrupts are not properly acknowledged which leads to interrupt
storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
used for rx and tx respectively.

Reported-by: Pantelis Antoniou <panto@antoniou-consulting.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes from Initial Version:
* Changed Tx and Rx EOI seperated so that Tx interrupt will not be cleared
  without processing any txpackets so that none of the interrupt are missed
  or cleared without processing.

 drivers/net/ethernet/ti/cpsw.c          |   25 ++++++++++++++++---------
 drivers/net/ethernet/ti/davinci_cpdma.c |    4 ++--
 drivers/net/ethernet/ti/davinci_cpdma.h |    9 ++++++++-
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4ceed6e..7e93df6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -510,19 +510,21 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 	int			num_tx, num_rx;
 
 	num_tx = cpdma_chan_process(priv->txch, 128);
-	num_rx = cpdma_chan_process(priv->rxch, budget);
-
-	if (num_rx || num_tx)
-		cpsw_dbg(priv, intr, "poll %d rx, %d tx pkts\n",
-			 num_rx, num_tx);
+	if (num_tx)
+		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
 
+	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
 		napi_complete(napi);
 		cpsw_intr_enable(priv);
-		cpdma_ctlr_eoi(priv->dma);
+		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
 		cpsw_enable_irq(priv);
 	}
 
+	if (num_rx || num_tx)
+		cpsw_dbg(priv, intr, "poll %d rx, %d tx pkts\n",
+			 num_rx, num_tx);
+
 	return num_rx;
 }
 
@@ -835,7 +837,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
 
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = true;
@@ -1075,7 +1078,9 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	cpdma_chan_start(priv->txch);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
+
 }
 
 static struct net_device_stats *cpsw_ndo_get_stats(struct net_device *ndev)
@@ -1094,7 +1099,9 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 	cpsw_interrupt(ndev->irq, priv);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
+
 }
 #endif
 
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 7d3bffd..68c3418 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -493,9 +493,9 @@ int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 	return 0;
 }
 
-void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr)
+void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
 {
-	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 0);
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, value);
 }
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index a97d6ab..ac65033 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -63,6 +63,13 @@ struct cpdma_chan_stats {
 	u32			teardown_dequeue;
 };
 
+enum {
+	CPDMA_EOI_RX_THRESH = 0,
+	CPDMA_EOI_RX,
+	CPDMA_EOI_TX,
+	CPDMA_EOI_MISC,
+};
+
 struct cpdma_ctlr;
 struct cpdma_chan;
 
@@ -88,7 +95,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
-void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr);
+void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value);
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
 
-- 
1.7.9.5

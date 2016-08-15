From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 4/5] net: ethernet: ti: davinci_cpdma: move cpdma channel struct macroses to internals
Date: Tue, 16 Aug 2016 02:25:48 +0300
Message-ID: <1471303549-4134-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1471303549-4134-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	nsekhar@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37293 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932290AbcHOX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:26:07 -0400
Received: by mail-wm0-f47.google.com with SMTP id i5so132188525wmg.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 16:26:06 -0700 (PDT)
In-Reply-To: <1471303549-4134-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep the driver internals in C file. Currently it's not required for
drivers to know rx or tx a channel is, except create function.
So correct "channel create" function, and use all channel struct
macroses only for internal use.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          |  7 ++-----
 drivers/net/ethernet/ti/davinci_cpdma.c | 13 +++++++++++--
 drivers/net/ethernet/ti/davinci_cpdma.h |  9 +--------
 drivers/net/ethernet/ti/davinci_emac.c  |  8 ++++----
 4 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 05f36fc..6dcbd8a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2535,11 +2535,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
-	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, tx_chan_num(0),
-					  cpsw_tx_handler);
-	cpsw->rxch[0] = cpdma_chan_create(cpsw->dma, rx_chan_num(0),
-					  cpsw_rx_handler);
-
+	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
+	cpsw->rxch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_rx_handler, 1);
 	if (WARN_ON(!cpsw->rxch[0] || !cpsw->txch[0])) {
 		dev_err(priv->dev, "error initializing dma channels\n");
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4b578b1..c3f35f1 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -124,6 +124,13 @@ struct cpdma_chan {
 	int	int_set, int_clear, td;
 };
 
+#define tx_chan_num(chan)	(chan)
+#define rx_chan_num(chan)	((chan) + CPDMA_MAX_CHANNELS)
+#define is_rx_chan(chan)	((chan)->chan_num >= CPDMA_MAX_CHANNELS)
+#define is_tx_chan(chan)	(!is_rx_chan(chan))
+#define __chan_linear(chan_num)	((chan_num) & (CPDMA_MAX_CHANNELS - 1))
+#define chan_linear(chan)	__chan_linear((chan)->chan_num)
+
 /* The following make access to common cpdma_ctlr params more readable */
 #define dmaregs		params.dmaregs
 #define num_chan	params.num_chan
@@ -441,12 +448,14 @@ static void cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
 }
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
-				     cpdma_handler_fn handler)
+				     cpdma_handler_fn handler, int rx_type)
 {
+	int offset = chan_num * 4;
 	struct cpdma_chan *chan;
-	int offset = (chan_num % CPDMA_MAX_CHANNELS) * 4;
 	unsigned long flags;
 
+	chan_num = rx_type ? rx_chan_num(chan_num) : tx_chan_num(chan_num);
+
 	if (__chan_linear(chan_num) >= ctlr->num_chan)
 		return NULL;
 
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 070f1d0..a07b22b 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -17,13 +17,6 @@
 
 #define CPDMA_MAX_CHANNELS	BITS_PER_LONG
 
-#define tx_chan_num(chan)	(chan)
-#define rx_chan_num(chan)	((chan) + CPDMA_MAX_CHANNELS)
-#define is_rx_chan(chan)	((chan)->chan_num >= CPDMA_MAX_CHANNELS)
-#define is_tx_chan(chan)	(!is_rx_chan(chan))
-#define __chan_linear(chan_num)	((chan_num) & (CPDMA_MAX_CHANNELS - 1))
-#define chan_linear(chan)	__chan_linear((chan)->chan_num)
-
 #define CPDMA_RX_SOURCE_PORT(__status__)	((__status__ >> 16) & 0x7)
 
 #define CPDMA_EOI_RX_THRESH	0x0
@@ -79,7 +72,7 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
-				     cpdma_handler_fn handler);
+				     cpdma_handler_fn handler, int rx_type);
 int cpdma_chan_get_rx_buf_num(struct cpdma_chan *chan);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 2d6fc9a..2fd94a5 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1870,10 +1870,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
 		goto no_pdata;
 	}
 
-	priv->txchan = cpdma_chan_create(priv->dma, tx_chan_num(EMAC_DEF_TX_CH),
-				       emac_tx_handler);
-	priv->rxchan = cpdma_chan_create(priv->dma, rx_chan_num(EMAC_DEF_RX_CH),
-				       emac_rx_handler);
+	priv->txchan = cpdma_chan_create(priv->dma, EMAC_DEF_TX_CH,
+					 emac_tx_handler, 0);
+	priv->rxchan = cpdma_chan_create(priv->dma, EMAC_DEF_RX_CH,
+					 emac_rx_handler, 1);
 	if (WARN_ON(!priv->txchan || !priv->rxchan)) {
 		rc = -ENOMEM;
 		goto no_cpdma_chan;
-- 
1.9.1

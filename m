From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 3/4] net: ethernet: ti: davinci_cpdma: move cpdma channel struct macroses to internals
Date: Thu, 30 Jun 2016 22:04:37 +0300
Message-ID: <1467313478-22919-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35309 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbcF3TEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 15:04:52 -0400
Received: by mail-lf0-f50.google.com with SMTP id l188so62171683lfe.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 12:04:51 -0700 (PDT)
In-Reply-To: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better to move functions that works with channel internals to C file.
Currently it's not required for drivers to know rx or tx a channel
is, except create function. So correct "channel create" function, and
use all channel struct macroses only for internal use.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          |  6 ++----
 drivers/net/ethernet/ti/davinci_cpdma.c | 13 +++++++++++--
 drivers/net/ethernet/ti/davinci_cpdma.h |  9 +--------
 drivers/net/ethernet/ti/davinci_emac.c  |  8 ++++----
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 14d53eb..595ed56 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2575,10 +2575,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
-	priv->txch[0] = cpdma_chan_create(priv->dma, tx_chan_num(0),
-					  cpsw_tx_handler);
-	priv->rxch[0] = cpdma_chan_create(priv->dma, rx_chan_num(0),
-					  cpsw_rx_handler);
+	priv->txch[0] = cpdma_chan_create(priv->dma, 0, cpsw_tx_handler, 0);
+	priv->rxch[0] = cpdma_chan_create(priv->dma, 0, cpsw_rx_handler, 1);
 
 	if (WARN_ON(!priv->rxch[0] || !priv->txch[0])) {
 		dev_err(priv->dev, "error initializing dma channels\n");
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index a4b299d..d6c4967 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -126,6 +126,13 @@ struct cpdma_chan {
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
@@ -520,12 +527,14 @@ static void cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
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
index 3ce91a1..52db03a 100644
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
@@ -80,7 +73,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
-				     cpdma_handler_fn handler);
+				     cpdma_handler_fn handler, int rx_type);
 int cpdma_chan_get_rx_buf_num(struct cpdma_chan *chan);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index f56d66e..1df0c89 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2008,10 +2008,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
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

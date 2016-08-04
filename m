From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] priority improvement
Date: Fri,  5 Aug 2016 00:11:52 +0300
Message-ID: <1470345113-804-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32875 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966251AbcHDVMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 17:12:13 -0400
Received: by mail-lf0-f52.google.com with SMTP id b199so190865844lfe.0
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 14:12:12 -0700 (PDT)
In-Reply-To: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 45 +++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 9ddaccc..cd12f52 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -788,22 +788,16 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi_tx);
 	int			num_tx, ch;
-	u32			ch_map;
+	unsigned long		ch_map;
 
 	/* process every unprocessed channel */
-	ch_map = cpdma_ctrl_txchs_state(priv->dma);
-	for (ch = 0, num_tx = 0; num_tx < budget; ch_map >>= 1, ch++) {
-		if (!ch_map) {
-			ch_map = cpdma_ctrl_txchs_state(priv->dma);
-			if (!ch_map)
-				break;
-
-			ch = 0;
-		}
-
-		if (!(ch_map & 0x01))
-			continue;
+	for (num_tx = 0; num_tx < budget;) {
+		ch_map = cpdma_ctrl_txchs_state(priv->dma);
+		if (!ch_map)
+			break;
 
+		/* process beginning from higher priority queue */
+		ch = __fls(ch_map);
 		num_tx += cpdma_chan_process(priv->txch[ch], budget - num_tx);
 	}
 
@@ -829,19 +823,13 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 	u32			ch_map;
 
 	/* process every unprocessed channel */
-	ch_map = cpdma_ctrl_rxchs_state(priv->dma);
-	for (ch = 0, num_rx = 0; num_rx < budget; ch_map >>= 1, ch++) {
-		if (!ch_map) {
-			ch_map = cpdma_ctrl_rxchs_state(priv->dma);
-			if (!ch_map)
-				break;
-
-			ch = 0;
-		}
-
-		if (!(ch_map & 0x01))
-			continue;
+	for (num_rx = 0; num_rx < budget;) {
+		ch_map = cpdma_ctrl_rxchs_state(priv->dma);
+		if (!ch_map)
+			break;
 
+		/* process beginning from higher priority queue */
+		ch = __fls(ch_map);
 		num_rx += cpdma_chan_process(priv->rxch[ch], budget - num_rx);
 	}
 
@@ -1130,8 +1118,11 @@ cpsw_tx_queue_mapping(struct cpsw_priv *priv, struct sk_buff *skb)
 {
 	unsigned int q_idx = skb_get_queue_mapping(skb);
 
-	if (q_idx >= priv->tx_ch_num)
-		q_idx = q_idx % priv->tx_ch_num;
+	/* cpsw h/w has backward order queue priority, 7 - highest */
+	if (likely(q_idx < priv->tx_ch_num))
+		q_idx = priv->tx_ch_num - q_idx - 1;
+	else
+		q_idx = 0;
 
 	return priv->txch[q_idx];
 }
-- 
1.9.1

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 4/5] net: ethernet: ti: cpsw: optimize end of poll cycle
Date: Tue, 29 Nov 2016 17:00:50 +0200
Message-ID: <1480431651-6081-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:32861 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933943AbcK2PBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:01:35 -0500
Received: by mail-lf0-f44.google.com with SMTP id c13so123488957lfg.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:01:34 -0800 (PST)
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check budget fullness only after it's updated and update
channel mask only once to keep budget balance between channels.
It's also needed for farther changes.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 24 ++++++------------------
 1 file changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c102675..8a70298 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -788,19 +788,13 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 
 	/* process every unprocessed channel */
 	ch_map = cpdma_ctrl_txchs_state(cpsw->dma);
-	for (ch = 0, num_tx = 0; num_tx < budget; ch_map >>= 1, ch++) {
-		if (!ch_map) {
-			ch_map = cpdma_ctrl_txchs_state(cpsw->dma);
-			if (!ch_map)
-				break;
-
-			ch = 0;
-		}
-
+	for (ch = 0, num_tx = 0; ch_map; ch_map >>= 1, ch++) {
 		if (!(ch_map & 0x01))
 			continue;
 
 		num_tx += cpdma_chan_process(cpsw->txch[ch], budget - num_tx);
+		if (num_tx >= budget)
+			break;
 	}
 
 	if (num_tx < budget) {
@@ -823,19 +817,13 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 
 	/* process every unprocessed channel */
 	ch_map = cpdma_ctrl_rxchs_state(cpsw->dma);
-	for (ch = 0, num_rx = 0; num_rx < budget; ch_map >>= 1, ch++) {
-		if (!ch_map) {
-			ch_map = cpdma_ctrl_rxchs_state(cpsw->dma);
-			if (!ch_map)
-				break;
-
-			ch = 0;
-		}
-
+	for (ch = 0, num_rx = 0; ch_map; ch_map >>= 1, ch++) {
 		if (!(ch_map & 0x01))
 			continue;
 
 		num_rx += cpdma_chan_process(cpsw->rxch[ch], budget - num_rx);
+		if (num_rx >= budget)
+			break;
 	}
 
 	if (num_rx < budget) {
-- 
2.7.4

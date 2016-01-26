From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH] net: mv643xx_eth: fix packet corruption with TSO and tiny unaligned packets.
Date: Tue, 26 Jan 2016 16:12:35 +0100
Message-ID: <1453821155-27561-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code in txq_put_data() would use txq->tx_curr_desc to index the
tso_hdrs/tso_hdrs_dma buffers, for less than 8 bytes unaligned
fragments, which is already moved to the next descriptor at the
beginning of the function.

If that fragment was the last of the the skb, the next skb would use
that same space to place the ip headers, overwritting that small
fragment data.

Fixes: 91986fd3d335 (net: mv643xx_eth: Ensure proper data alignment in TSO TX path)
Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a0c0383..5583118 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -762,10 +762,10 @@ txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
 
 	if (length <= 8 && (uintptr_t)data & 0x7) {
 		/* Copy unaligned small data fragment to TSO header data area */
-		memcpy(txq->tso_hdrs + txq->tx_curr_desc * TSO_HEADER_SIZE,
+		memcpy(txq->tso_hdrs + tx_index * TSO_HEADER_SIZE,
 		       data, length);
 		desc->buf_ptr = txq->tso_hdrs_dma
-			+ txq->tx_curr_desc * TSO_HEADER_SIZE;
+			+ tx_index * TSO_HEADER_SIZE;
 	} else {
 		/* Alignment is okay, map buffer and hand off to hardware */
 		txq->tx_desc_mapping[tx_index] = DESC_DMA_MAP_SINGLE;
-- 
1.9.1

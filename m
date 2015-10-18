From: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Subject: [PATCH net 1/2] net: mv643xx_eth: Ensure proper data alignment in TSO TX path
Date: Sun, 18 Oct 2015 16:02:43 +0200
Message-ID: <1445176964-22760-2-git-send-email-philipp@familie-kirchhofer.de>
References: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Cc: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.196.166.47.78.clients.your-server.de ([78.47.166.196]:42168
	"EHLO vserver.familie-kirchhofer.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752439AbbJROIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:08:54 -0400
In-Reply-To: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX DMA engine requires that buffers with a size of 8 bytes or smaller
must be 64 bit aligned. This requirement may be violated when doing TSO,
as in this case larger skb frags can be broken up and transmitted in small
parts with then inappropriate alignment.

Fix this by checking for proper alignment before handing a buffer to the
DMA engine. If the data is misaligned realign it by copying it into the
TSO header data area.

Signed-off-by: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d52639b..68073bc 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -759,11 +759,23 @@ txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
 
 	desc->l4i_chk = 0;
 	desc->byte_cnt = length;
-	desc->buf_ptr = dma_map_single(dev->dev.parent, data,
-				       length, DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(dev->dev.parent, desc->buf_ptr))) {
-		WARN(1, "dma_map_single failed!\n");
-		return -ENOMEM;
+
+	if (length <= 8 && (uintptr_t)data & 0x7) {
+		/* Copy unaligned small data fragment to TSO header data area */
+		memcpy(txq->tso_hdrs + txq->tx_curr_desc * TSO_HEADER_SIZE,
+		       data, length);
+		desc->buf_ptr = txq->tso_hdrs_dma
+			+ txq->tx_curr_desc * TSO_HEADER_SIZE;
+	} else {
+		/* Alignment is okay, map buffer and hand off to hardware */
+		txq->tx_desc_mapping[tx_index] = DESC_DMA_MAP_SINGLE;
+		desc->buf_ptr = dma_map_single(dev->dev.parent, data,
+			length, DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(dev->dev.parent,
+					       desc->buf_ptr))) {
+			WARN(1, "dma_map_single failed!\n");
+			return -ENOMEM;
+		}
 	}
 
 	cmd_sts = BUFFER_OWNED_BY_DMA;

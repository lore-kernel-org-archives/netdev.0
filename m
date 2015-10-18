From: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Subject: [PATCH net 2/2] net: mv643xx_eth: Defer writing the first TX descriptor when using TSO
Date: Sun, 18 Oct 2015 16:02:44 +0200
Message-ID: <1445176964-22760-3-git-send-email-philipp@familie-kirchhofer.de>
References: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Cc: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.196.166.47.78.clients.your-server.de ([78.47.166.196]:42169
	"EHLO vserver.familie-kirchhofer.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752427AbbJROIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:08:54 -0400
In-Reply-To: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent a race between the TX DMA engine and the CPU the writing of the
first transmit descriptor must be deferred until all following descriptors
have been updated. The network card may otherwise start transmitting before
all packet descriptors are set up correctly, which leads to data corruption
or an aborted transmit operation.

This deferral is already done in the non-TSO TX path, implement it also in
the TSO TX path.

Signed-off-by: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 68073bc..5124535 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -791,7 +791,8 @@ txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
 }
 
 static inline void
-txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
+txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length,
+		u32 *first_cmd_sts, bool first_desc)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
@@ -800,6 +801,7 @@ txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
 	int ret;
 	u32 cmd_csum = 0;
 	u16 l4i_chk = 0;
+	u32 cmd_sts;
 
 	tx_index = txq->tx_curr_desc;
 	desc = &txq->tx_desc_area[tx_index];
@@ -815,9 +817,17 @@ txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
 	desc->byte_cnt = hdr_len;
 	desc->buf_ptr = txq->tso_hdrs_dma +
 			txq->tx_curr_desc * TSO_HEADER_SIZE;
-	desc->cmd_sts = cmd_csum | BUFFER_OWNED_BY_DMA  | TX_FIRST_DESC |
+	cmd_sts = cmd_csum | BUFFER_OWNED_BY_DMA  | TX_FIRST_DESC |
 				   GEN_CRC;
 
+	/* Defer updating the first command descriptor until all
+	 * following descriptors have been written.
+	 */
+	if (first_desc)
+		*first_cmd_sts = cmd_sts;
+	else
+		desc->cmd_sts = cmd_sts;
+
 	txq->tx_curr_desc++;
 	if (txq->tx_curr_desc == txq->tx_ring_size)
 		txq->tx_curr_desc = 0;
@@ -831,6 +841,8 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 	int desc_count = 0;
 	struct tso_t tso;
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	struct tx_desc *first_tx_desc;
+	u32 first_cmd_sts = 0;
 
 	/* Count needed descriptors */
 	if ((txq->tx_desc_count + tso_count_descs(skb)) >= txq->tx_ring_size) {
@@ -838,11 +850,14 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 		return -EBUSY;
 	}
 
+	first_tx_desc = &txq->tx_desc_area[txq->tx_curr_desc];
+
 	/* Initialize the TSO handler, and prepare the first payload */
 	tso_start(skb, &tso);
 
 	total_len = skb->len - hdr_len;
 	while (total_len > 0) {
+		bool first_desc = (desc_count == 0);
 		char *hdr;
 
 		data_left = min_t(int, skb_shinfo(skb)->gso_size, total_len);
@@ -852,7 +867,8 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 		/* prepare packet headers: MAC + IP + TCP */
 		hdr = txq->tso_hdrs + txq->tx_curr_desc * TSO_HEADER_SIZE;
 		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
-		txq_put_hdr_tso(skb, txq, data_left);
+		txq_put_hdr_tso(skb, txq, data_left, &first_cmd_sts,
+				first_desc);
 
 		while (data_left > 0) {
 			int size;
@@ -872,6 +888,10 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 	__skb_queue_tail(&txq->tx_skb, skb);
 	skb_tx_timestamp(skb);
 
+	/* ensure all other descriptors are written before first cmd_sts */
+	wmb();
+	first_tx_desc->cmd_sts = first_cmd_sts;
+
 	/* clear TX_END status */
 	mp->work_tx_end &= ~(1 << txq->index);
 

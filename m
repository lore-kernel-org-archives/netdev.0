From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 07/16] net: fec: set cbd_sc without relying on previous value
Date: Wed, 24 Feb 2016 17:36:50 -0700
Message-ID: <1456360619-24390-8-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34601 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758669AbcBYAk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:29 -0500
Received: by mail-pf0-f170.google.com with SMTP id x65so22281430pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:29 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relying on the wrap bit to stay valid once initialized
when the controller also writes to this byte seems
undesirable since we can easily know what the value
should be.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 38 +++++++++----------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 791f385..6ceb5f9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -340,9 +340,8 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		ebdp = (struct bufdesc_ex *)bdp;
 
-		status = fec16_to_cpu(bdp->cbd_sc);
-		status &= ~BD_ENET_TX_STATS;
-		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+		status = BD_ENET_TX_TC | BD_ENET_TX_READY |
+				((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 		frag_len = skb_shinfo(skb)->frags[frag].size;
 
 		/* Handle the last BD specially */
@@ -436,8 +435,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Fill in a Tx ring entry */
 	bdp = txq->bd.cur;
 	last_bdp = bdp;
-	status = fec16_to_cpu(bdp->cbd_sc);
-	status &= ~BD_ENET_TX_STATS;
 
 	/* Set buffer length and buffer pointer */
 	bufaddr = skb->data;
@@ -462,6 +459,8 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 		return NETDEV_TX_OK;
 	}
 
+	status = BD_ENET_TX_TC | BD_ENET_TX_READY |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 	if (nr_frags) {
 		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
 		if (IS_ERR(last_bdp)) {
@@ -512,7 +511,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
-	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
 	bdp->cbd_sc = cpu_to_fec16(status);
 
 	/* If this was the last BD in the ring, start at the beginning again. */
@@ -544,11 +542,6 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	unsigned int estatus = 0;
 	dma_addr_t addr;
 
-	status = fec16_to_cpu(bdp->cbd_sc);
-	status &= ~BD_ENET_TX_STATS;
-
-	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
-
 	if (((unsigned long) data) & fep->tx_align ||
 		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], data, size);
@@ -578,15 +571,16 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 		ebdp->cbd_esc = cpu_to_fec32(estatus);
 	}
 
+	status = BD_ENET_TX_TC | BD_ENET_TX_READY |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 	/* Handle the last BD specially */
 	if (last_tcp)
-		status |= (BD_ENET_TX_LAST | BD_ENET_TX_TC);
+		status |= BD_ENET_TX_LAST;
 	if (is_last) {
 		status |= BD_ENET_TX_INTR;
 		if (fep->bufdesc_ex)
 			ebdp->cbd_esc |= cpu_to_fec32(BD_ENET_TX_INT);
 	}
-
 	bdp->cbd_sc = cpu_to_fec16(status);
 
 	return 0;
@@ -602,13 +596,8 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
 	void *bufaddr;
 	unsigned long dmabuf;
-	unsigned short status;
 	unsigned int estatus = 0;
 
-	status = fec16_to_cpu(bdp->cbd_sc);
-	status &= ~BD_ENET_TX_STATS;
-	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
-
 	bufaddr = txq->tso_hdrs + index * TSO_HEADER_SIZE;
 	dmabuf = txq->tso_hdrs_dma + index * TSO_HEADER_SIZE;
 	if (((unsigned long)bufaddr) & fep->tx_align ||
@@ -641,8 +630,8 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 		ebdp->cbd_esc = cpu_to_fec32(estatus);
 	}
 
-	bdp->cbd_sc = cpu_to_fec16(status);
-
+	bdp->cbd_sc = cpu_to_fec16(BD_ENET_TX_TC | BD_ENET_TX_READY |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0));
 	return 0;
 }
 
@@ -1453,12 +1442,6 @@ static int fec_rxq(struct net_device *ndev, struct fec_enet_private *fep,
 		}
 
 rx_processing_done:
-		/* Clear the status flags for this buffer */
-		status &= ~BD_ENET_RX_STATS;
-
-		/* Mark the buffer empty */
-		status |= BD_ENET_RX_EMPTY;
-
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 
@@ -1470,7 +1453,8 @@ rx_processing_done:
 		 * performed before transferring ownership.
 		 */
 		wmb();
-		bdp->cbd_sc = cpu_to_fec16(status);
+		bdp->cbd_sc = cpu_to_fec16(BD_ENET_RX_EMPTY |
+				((bdp == rxq->bd.last) ? BD_SC_WRAP : 0));
 
 		/* Update BD pointer to next entry */
 		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
-- 
2.5.0

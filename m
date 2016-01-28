From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 15/40] net: fec: set cbd_sc without relying on previous value
Date: Thu, 28 Jan 2016 14:25:39 -0700
Message-ID: <1454016364-30985-16-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36390 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcA1V2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:34 -0500
Received: by mail-pf0-f177.google.com with SMTP id n128so29532829pfn.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:33 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relying on the wrap bit to stay valid once initialized
when the controller also writes to this byte seems
undesirable since we can easily know what the value
should be.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a7af1ac..9285425 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -338,9 +338,8 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		ebdp = (struct bufdesc_ex *)bdp;
 
-		status = bdp->cbd_sc;
-		status &= ~BD_ENET_TX_STATS;
-		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+		status = (BD_ENET_TX_TC | BD_ENET_TX_READY) |
+				((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 		frag_len = skb_shinfo(skb)->frags[frag].size;
 
 		/* Handle the last BD specially */
@@ -435,8 +434,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Fill in a Tx ring entry */
 	bdp = txq->bd.cur;
 	last_bdp = bdp;
-	status = bdp->cbd_sc;
-	status &= ~BD_ENET_TX_STATS;
 
 	/* Set buffer length and buffer pointer */
 	bufaddr = skb->data;
@@ -461,6 +458,8 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 		return NETDEV_TX_OK;
 	}
 
+	status = (BD_ENET_TX_TC | BD_ENET_TX_READY) |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 	if (nr_frags) {
 		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
 		if (IS_ERR(last_bdp))
@@ -507,7 +506,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
-	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
 	bdp->cbd_sc = status;
 
 	/* If this was the last BD in the ring, start at the beginning again. */
@@ -539,10 +537,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	unsigned int estatus = 0;
 	dma_addr_t addr;
 
-	status = bdp->cbd_sc;
-	status &= ~BD_ENET_TX_STATS;
-
-	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+	status = (BD_ENET_TX_TC | BD_ENET_TX_READY) |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 
 	if (((unsigned long) data) & fep->tx_align ||
 		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
@@ -600,10 +596,8 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	unsigned short status;
 	unsigned int estatus = 0;
 
-	status = bdp->cbd_sc;
-	status &= ~BD_ENET_TX_STATS;
-	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
-
+	status = (BD_ENET_TX_TC | BD_ENET_TX_READY) |
+			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 	bufaddr = txq->tso_hdrs + index * TSO_HEADER_SIZE;
 	dmabuf = txq->tso_hdrs_dma + index * TSO_HEADER_SIZE;
 	if (((unsigned long)bufaddr) & fep->tx_align ||
@@ -1442,12 +1436,6 @@ static int fec_rxq(struct net_device *ndev, struct fec_enet_private *fep,
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
 
@@ -1459,7 +1447,8 @@ rx_processing_done:
 		 * performed before transferring ownership.
 		 */
 		wmb();
-		bdp->cbd_sc = status;
+		bdp->cbd_sc = BD_ENET_RX_EMPTY |
+				((bdp == rxq->bd.last) ? BD_SC_WRAP : 0);
 
 		/* Update BD pointer to next entry */
 		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
-- 
2.5.0

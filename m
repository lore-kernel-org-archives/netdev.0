From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 31/40] net: fec: don't transfer ownership until entire tso is queued
Date: Thu, 28 Jan 2016 14:25:55 -0700
Message-ID: <1454016364-30985-32-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36591 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912AbcA1V3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:01 -0500
Received: by mail-pf0-f179.google.com with SMTP id n128so29538166pfn.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:01 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, we cannot undo our work if an error condition arises
later.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b829c29..ee6cd69 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -590,7 +590,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 static int
 fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 			 struct sk_buff *skb, struct net_device *ndev,
-			 struct bufdesc *bdp, int index)
+			 struct bufdesc *bdp, int index,
+			 unsigned short *pstatus)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
@@ -632,9 +633,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 		ebdp->cbd_bdu = 0;
 		ebdp->cbd_esc = estatus;
 	}
-
-	bdp->cbd_sc = status;
-
+	*pstatus = status;
 	return 0;
 }
 
@@ -646,7 +645,10 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int total_len, data_left;
 	struct bufdesc *bdp = txq->bd.cur;
+	struct bufdesc *first_bdp = bdp;
 	struct tso_t tso;
+	unsigned short status = 0;
+	unsigned short *pstatus = &status;
 	unsigned int index = 0;
 	int ret;
 
@@ -676,7 +678,8 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 		/* prepare packet headers: MAC + IP + TCP */
 		hdr = txq->tso_hdrs + index * TSO_HEADER_SIZE;
 		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
-		ret = fec_enet_txq_put_hdr_tso(txq, skb, ndev, bdp, index);
+		ret = fec_enet_txq_put_hdr_tso(txq, skb, ndev, bdp, index,
+					       pstatus);
 		if (ret)
 			goto err_release;
 
@@ -700,12 +703,23 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 		}
 
 		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+		pstatus = &bdp->cbd_sc;
 	}
 
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
-
 	skb_tx_timestamp(skb);
+	/* Make sure the updates to rest of the descriptor are performed before
+	 * transferring ownership.
+	 */
+	wmb();
+	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
+	 */
+	first_bdp->cbd_sc = status;
+	/* Make sure ownership is transferred before the
+	 * update to txq->bd.cur.
+	 */
+	wmb();
 	txq->bd.cur = bdp;
 
 	/* Trigger transmission start */
-- 
2.5.0

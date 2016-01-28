From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 11/40] net: fec: pass txq to fec_enet_tx_queue instead of queue_id
Date: Thu, 28 Jan 2016 14:25:35 -0700
Message-ID: <1454016364-30985-12-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36646 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967720AbcA1V22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:28 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so29098541pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:27 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

queue_id is the qid member of struct bufdesc_prop.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 01b9740..711a8d6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1149,25 +1149,18 @@ fec_enet_hwtstamp(struct fec_enet_private *fep, unsigned ts,
 	hwtstamps->hwtstamp = ns_to_ktime(ns);
 }
 
-static void
-fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
+static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
+		    struct fec_enet_priv_tx_q *txq)
 {
-	struct	fec_enet_private *fep;
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
-	struct fec_enet_priv_tx_q *txq;
 	struct netdev_queue *nq;
 	int	index = 0;
 	int	entries_free;
 
-	fep = netdev_priv(ndev);
-
-	queue_id = FEC_ENET_GET_QUQUE(queue_id);
-
-	txq = fep->tx_queue[queue_id];
 	/* get next bdp of dirty_tx */
-	nq = netdev_get_tx_queue(ndev, queue_id);
+	nq = netdev_get_tx_queue(ndev, txq->bd.qid);
 	bdp = txq->dirty_tx;
 
 	/* get next bdp of dirty_tx */
@@ -1259,11 +1252,13 @@ static void
 fec_enet_tx(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_enet_priv_tx_q *txq;
 	u16 queue_id;
 	/* First process class A queue, then Class B and Best Effort queue */
 	for_each_set_bit(queue_id, &fep->work_tx, FEC_ENET_MAX_TX_QS) {
 		clear_bit(queue_id, &fep->work_tx);
-		fec_enet_tx_queue(ndev, queue_id);
+		txq = fep->tx_queue[FEC_ENET_GET_QUQUE(queue_id)];
+		fec_txq(ndev, fep, txq);
 	}
 	return;
 }
-- 
2.5.0

From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 04/16] net: fec: pass rxq/txq to fec_enet_rx/tx_queue instead of queue_id
Date: Tue,  5 Apr 2016 19:25:50 -0700
Message-ID: <1459909562-22865-5-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34773 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759840AbcDFC2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:17 -0400
Received: by mail-pf0-f182.google.com with SMTP id c20so23180961pfc.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:15 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The queue_id is the qid member of struct bufdesc_prop.
Passing rxq/txq will allow the macro FEC_ENET_GET_QUQUE to be removed
in the next patch.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Acked-by: Fugang Duan <fugang.duan@nxp.com>

---
v3:
add Acked-by
combine with "net: fec: pass txq to fec_enet_tx_queue instead of queue_id"
reverted change that passed fep as a parameter
---
 drivers/net/ethernet/freescale/fec_main.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7993040..b4d46f8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1156,25 +1156,18 @@ fec_enet_hwtstamp(struct fec_enet_private *fep, unsigned ts,
 	hwtstamps->hwtstamp = ns_to_ktime(ns);
 }
 
-static void
-fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
+static void fec_txq(struct net_device *ndev, struct fec_enet_priv_tx_q *txq)
 {
-	struct	fec_enet_private *fep;
+	struct  fec_enet_private *fep = netdev_priv(ndev);
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
@@ -1268,11 +1261,13 @@ static void
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
+		fec_txq(ndev, txq);
 	}
 	return;
 }
@@ -1328,11 +1323,10 @@ static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff **skb,
  * not been given to the system, we just set the empty indicator,
  * effectively tossing the packet.
  */
-static int
-fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
+static int fec_rxq(struct net_device *ndev, struct fec_enet_priv_rx_q *rxq,
+		   int budget)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct  sk_buff *skb_new = NULL;
@@ -1350,8 +1344,6 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 #ifdef CONFIG_M532x
 	flush_cache_all();
 #endif
-	queue_id = FEC_ENET_GET_QUQUE(queue_id);
-	rxq = fep->rx_queue[queue_id];
 
 	/* First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
@@ -1519,11 +1511,12 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	int     pkt_received = 0;
 	u16	queue_id;
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_enet_priv_rx_q *rxq;
 
 	for_each_set_bit(queue_id, &fep->work_rx, FEC_ENET_MAX_RX_QS) {
 		clear_bit(queue_id, &fep->work_rx);
-		pkt_received += fec_enet_rx_queue(ndev,
-					budget - pkt_received, queue_id);
+		rxq = fep->rx_queue[FEC_ENET_GET_QUQUE(queue_id)];
+		pkt_received += fec_rxq(ndev, rxq, budget - pkt_received);
 	}
 	return pkt_received;
 }
-- 
2.5.0

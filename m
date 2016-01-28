From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 10/40] net: fec: pass rxq to fec_enet_rx_queue instead of queue_id
Date: Thu, 28 Jan 2016 14:25:34 -0700
Message-ID: <1454016364-30985-11-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34130 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcA1V2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:25 -0500
Received: by mail-pa0-f50.google.com with SMTP id uo6so29717879pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:25 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The queue_id is the qid member of struct bufdesc_prop.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3ed79fd..01b9740 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1320,11 +1320,9 @@ static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff **skb,
  * not been given to the system, we just set the empty indicator,
  * effectively tossing the packet.
  */
-static int
-fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
+static int fec_rxq(struct net_device *ndev, struct fec_enet_private *fep,
+		   struct fec_enet_priv_rx_q *rxq, int budget)
 {
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct  sk_buff *skb_new = NULL;
@@ -1342,8 +1340,6 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 #ifdef CONFIG_M532x
 	flush_cache_all();
 #endif
-	queue_id = FEC_ENET_GET_QUQUE(queue_id);
-	rxq = fep->rx_queue[queue_id];
 
 	/* First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
@@ -1508,11 +1504,12 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	int     pkt_received = 0;
 	u16	queue_id;
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_enet_priv_rx_q *rxq;
 
 	for_each_set_bit(queue_id, &fep->work_rx, FEC_ENET_MAX_RX_QS) {
 		clear_bit(queue_id, &fep->work_rx);
-		pkt_received += fec_enet_rx_queue(ndev,
-					budget - pkt_received, queue_id);
+		rxq = fep->rx_queue[FEC_ENET_GET_QUQUE(queue_id)];
+		pkt_received += fec_rxq(ndev, fep, rxq, budget - pkt_received);
 	}
 	return pkt_received;
 }
-- 
2.5.0

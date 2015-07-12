From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH] net: mvneta: fix refilling for Rx DMA buffers
Date: Mon, 13 Jul 2015 00:04:57 +0200
Message-ID: <1436738697-21652-1-git-send-email-simon.guinot@sequanux.org>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	Yoann Sculo <yoann@sculo.fr>, <stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:56429 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbbGLWFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jul 2015 18:05:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some Armada 370-based NAS, I have experimented kernel bugs and
crashes when the mvneta Ethernet driver fails to refill Rx DMA buffers
due to memory shortage.

With the actual code, if the memory allocation fails while refilling a
Rx DMA buffer, then the corresponding descriptor is let with the address
of an unmapped DMA buffer already passed to the network stack. Since the
driver still increments the non-occupied counter for Rx descriptor (if a
next packet is handled successfully), then the Ethernet controller is
allowed to reuse the unfilled Rx descriptor...

As a fix, this patch first refills a Rx descriptor before handling the
stored data and unmapping the associated Rx DMA buffer. Additionally the
occupied and non-occupied counters for the Rx descriptors queues are now
both updated with the rx_done value: the number of descriptors ready to
be returned to the networking controller. Moreover note that there is no
point in using different values for this counters because both the
mvneta driver and the Ethernet controller are unable to handle holes in
the Rx descriptors queues.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
Cc: <stable@vger.kernel.org> # v3.8+
Tested-by: Yoann Sculo <yoann@sculo.fr>
---
 drivers/net/ethernet/marvell/mvneta.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..ac3da11e63a0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1455,7 +1455,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		     struct mvneta_rx_queue *rxq)
 {
 	struct net_device *dev = pp->dev;
-	int rx_done, rx_filled;
+	int rx_done;
 	u32 rcvd_pkts = 0;
 	u32 rcvd_bytes = 0;
 
@@ -1466,7 +1466,6 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		rx_todo = rx_done;
 
 	rx_done = 0;
-	rx_filled = 0;
 
 	/* Fairness NAPI loop */
 	while (rx_done < rx_todo) {
@@ -1477,7 +1476,6 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		int rx_bytes, err;
 
 		rx_done++;
-		rx_filled++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		data = (unsigned char *)rx_desc->buf_cookie;
@@ -1517,6 +1515,14 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 			continue;
 		}
 
+		/* Refill processing */
+		err = mvneta_rx_refill(pp, rx_desc);
+		if (err) {
+			netdev_err(dev, "Linux processing - Can't refill\n");
+			rxq->missed++;
+			goto err_drop_frame;
+		}
+
 		skb = build_skb(data, pp->frag_size > PAGE_SIZE ? 0 : pp->frag_size);
 		if (!skb)
 			goto err_drop_frame;
@@ -1536,14 +1542,6 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		mvneta_rx_csum(pp, rx_status, skb);
 
 		napi_gro_receive(&pp->napi, skb);
-
-		/* Refill processing */
-		err = mvneta_rx_refill(pp, rx_desc);
-		if (err) {
-			netdev_err(dev, "Linux processing - Can't refill\n");
-			rxq->missed++;
-			rx_filled--;
-		}
 	}
 
 	if (rcvd_pkts) {
@@ -1556,7 +1554,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 	}
 
 	/* Update rxq management counters */
-	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_filled);
+	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done);
 
 	return rx_done;
 }
-- 
2.1.4

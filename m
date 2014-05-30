From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 5/8] net: mv643xx_eth: Count dropped packets properly
Date: Fri, 30 May 2014 13:40:08 -0300
Message-ID: <1401468011-10609-6-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58440 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933858AbaE3QlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:22 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit fixes the current dropped packet count by doing it properly,
increasing the count when a packet is discarded; i.e. the packet is not
processed and the driver returns NETDEV_TX_OK.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c68ff5d..97a60de 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -967,7 +967,6 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	nq = netdev_get_tx_queue(dev, queue);
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
-		txq->tx_dropped++;
 		netdev_printk(KERN_DEBUG, dev,
 			      "failed to linearize skb with tiny unaligned fragment\n");
 		return NETDEV_TX_BUSY;
@@ -976,6 +975,7 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
 		if (net_ratelimit())
 			netdev_err(dev, "tx queue full?!\n");
+		txq->tx_dropped++;
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -997,6 +997,9 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_tx_stop_queue(nq);
 	} else if (ret == -EBUSY) {
 		return NETDEV_TX_BUSY;
+	} else {
+		txq->tx_dropped++;
+		dev_kfree_skb_any(skb);
 	}
 
 	return NETDEV_TX_OK;
-- 
1.9.1

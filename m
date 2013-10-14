From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 07/07] natsemi: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:23 +0200
Message-ID: <1381775183-24866-8-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35472 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab3JNSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:52 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to natsemi to use byte queue limits.

This patch was not tested on real hardware currently, but compiles fine and
should work.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/natsemi/natsemi.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 7a5e295..3d738b9 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -1973,6 +1973,7 @@ static void init_ring(struct net_device *dev)
 			*((i+1)%TX_RING_SIZE+RX_RING_SIZE));
 		np->tx_ring[i].cmd_status = 0;
 	}
+	netdev_reset_queue(dev);
 
 	/* 2) RX ring */
 	np->dirty_rx = 0;
@@ -2012,6 +2013,7 @@ static void drain_tx(struct net_device *dev)
 		}
 		np->tx_skbuff[i] = NULL;
 	}
+	netdev_reset_queue(dev);
 }
 
 static void drain_rx(struct net_device *dev)
@@ -2116,6 +2118,8 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_irq(skb);
 		dev->stats.tx_dropped++;
 	}
+
+	netdev_sent_queue(dev, skb->len);
 	spin_unlock_irqrestore(&np->lock, flags);
 
 	if (netif_msg_tx_queued(np)) {
@@ -2128,6 +2132,7 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 static void netdev_tx_done(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 		int entry = np->dirty_tx % TX_RING_SIZE;
@@ -2158,9 +2163,14 @@ static void netdev_tx_done(struct net_device *dev)
 					np->tx_skbuff[entry]->len,
 					PCI_DMA_TODEVICE);
 		/* Free the original skb. */
+		bytes_compl += np->tx_skbuff[entry]->len;
+		pkts_compl++;
 		dev_kfree_skb_irq(np->tx_skbuff[entry]);
 		np->tx_skbuff[entry] = NULL;
 	}
+
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	if (netif_queue_stopped(dev) &&
 	    np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		/* The ring is no longer full, wake queue. */
-- 
1.8.4

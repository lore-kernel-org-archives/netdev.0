From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 04/07] via-rhine: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:20 +0200
Message-ID: <1381775183-24866-5-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35467 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756964Ab3JNSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:52 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to via-rhine to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/via/via-rhine.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index bdf697b..49bd6653 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1220,6 +1220,7 @@ static void alloc_tbufs(struct net_device* dev)
 	}
 	rp->tx_ring[i-1].next_desc = cpu_to_le32(rp->tx_ring_dma);
 
+	netdev_reset_queue(dev);
 }
 
 static void free_tbufs(struct net_device* dev)
@@ -1719,6 +1720,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	/* lock eth irq */
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
+	netdev_sent_queue(dev, skb->len);
 	wmb();
 
 	rp->cur_tx++;
@@ -1783,6 +1785,7 @@ static void rhine_tx(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
@@ -1830,10 +1833,17 @@ static void rhine_tx(struct net_device *dev)
 					 rp->tx_skbuff[entry]->len,
 					 PCI_DMA_TODEVICE);
 		}
+
+		bytes_compl += rp->tx_skbuff[entry]->len;
+		pkts_compl++;
 		dev_kfree_skb(rp->tx_skbuff[entry]);
+
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
+
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
 }
-- 
1.8.4

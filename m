From: John Crispin <john@phrozen.org>
Subject: [PATCH 12/12] net-next: mediatek: remove superfluous queue wake up call
Date: Thu,  5 May 2016 11:26:25 +0200
Message-ID: <1462440385-51939-13-git-send-email-john@phrozen.org>
References: <1462440385-51939-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462440385-51939-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code checks if the queue should be stopped because we are below the
threshold of free descriptors only to check if it should be started again.
If we do end up in a state where we are at the threshold limit, it makes
more sense to just stop the queue and wait for the next IRQ to trigger the
TX housekeeping again. There is no rush in enqueuing the next packet, it
needs to wait for all the others in the queue to be dispatched first
anyway.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 2d3c464..4d0b179 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -780,12 +780,9 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (mtk_tx_map(skb, dev, tx_num, ring, gso) < 0)
 		goto drop;
 
-	if (unlikely(atomic_read(&ring->free_count) <= ring->thresh)) {
+	if (unlikely(atomic_read(&ring->free_count) <= ring->thresh))
 		mtk_stop_queue(eth);
-		if (unlikely(atomic_read(&ring->free_count) >
-			     ring->thresh))
-			mtk_wake_queue(eth);
-	}
+
 	spin_unlock_irqrestore(&eth->page_lock, flags);
 
 	return NETDEV_TX_OK;
-- 
1.7.10.4

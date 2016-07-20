From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/2] gro_cells: gro_cells_receive now return error code
Date: Wed, 20 Jul 2016 18:11:31 +0200
Message-ID: <c0a581d329912140d67a8347ea1160753a24f890.1469030596.git.pabeni@redhat.com>
References: <cover.1469030596.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755086AbcGTQMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 12:12:22 -0400
In-Reply-To: <cover.1469030596.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so that the caller can update stats accordingly, if needed

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/gro_cells.h | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index cf6c745..d15214d 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -14,27 +14,26 @@ struct gro_cells {
 	struct gro_cell __percpu	*cells;
 };
 
-static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
+static inline int gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
 {
 	struct gro_cell *cell;
 	struct net_device *dev = skb->dev;
 
-	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
-		netif_rx(skb);
-		return;
-	}
+	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO))
+		return netif_rx(skb);
 
 	cell = this_cpu_ptr(gcells->cells);
 
 	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
-		return;
+		return NET_RX_DROP;
 	}
 
 	__skb_queue_tail(&cell->napi_skbs, skb);
 	if (skb_queue_len(&cell->napi_skbs) == 1)
 		napi_schedule(&cell->napi);
+	return NET_RX_SUCCESS;
 }
 
 /* called under BH context */
-- 
1.8.3.1

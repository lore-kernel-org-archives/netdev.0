From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gro_cells: remove spinlock protecting receive
 queues
Date: Mon, 31 Aug 2015 13:57:34 -0700
Message-ID: <1441054654.8932.159.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34419 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbbHaU5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 16:57:36 -0400
Received: by pabzx8 with SMTP id zx8so150724639pab.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 13:57:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As David pointed out, spinlock are no longer needed
to protect the per cpu queues used in gro cells infrastructure.

Also use new napi_complete_done() API so that gro_flush_timeout
tweaks have an effect.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/gro_cells.h |   18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 0f712c0..cf6c745 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -32,37 +32,28 @@ static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *s
 		return;
 	}
 
-	/* We run in BH context */
-	spin_lock(&cell->napi_skbs.lock);
-
 	__skb_queue_tail(&cell->napi_skbs, skb);
 	if (skb_queue_len(&cell->napi_skbs) == 1)
 		napi_schedule(&cell->napi);
-
-	spin_unlock(&cell->napi_skbs.lock);
 }
 
-/* called unser BH context */
+/* called under BH context */
 static inline int gro_cell_poll(struct napi_struct *napi, int budget)
 {
 	struct gro_cell *cell = container_of(napi, struct gro_cell, napi);
 	struct sk_buff *skb;
 	int work_done = 0;
 
-	spin_lock(&cell->napi_skbs.lock);
 	while (work_done < budget) {
 		skb = __skb_dequeue(&cell->napi_skbs);
 		if (!skb)
 			break;
-		spin_unlock(&cell->napi_skbs.lock);
 		napi_gro_receive(napi, skb);
 		work_done++;
-		spin_lock(&cell->napi_skbs.lock);
 	}
 
 	if (work_done < budget)
-		napi_complete(napi);
-	spin_unlock(&cell->napi_skbs.lock);
+		napi_complete_done(napi, work_done);
 	return work_done;
 }
 
@@ -77,7 +68,7 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
 	for_each_possible_cpu(i) {
 		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
 
-		skb_queue_head_init(&cell->napi_skbs);
+		__skb_queue_head_init(&cell->napi_skbs);
 		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
 		napi_enable(&cell->napi);
 	}
@@ -92,8 +83,9 @@ static inline void gro_cells_destroy(struct gro_cells *gcells)
 		return;
 	for_each_possible_cpu(i) {
 		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
+
 		netif_napi_del(&cell->napi);
-		skb_queue_purge(&cell->napi_skbs);
+		__skb_queue_purge(&cell->napi_skbs);
 	}
 	free_percpu(gcells->cells);
 	gcells->cells = NULL;

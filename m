From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix a race in gro_cell_poll()
Date: Mon, 10 Dec 2012 14:32:03 -0800
Message-ID: <1355178723.27891.85.camel@edumazet-glaptop>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
	 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
	 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
	 <1355158471.27891.44.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC32A1@SJEXCHMB06.corp.ad.broadcom.com>
	 <1355176551.27891.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:58768 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595Ab2LJWcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 17:32:06 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1411455dak.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 14:32:05 -0800 (PST)
In-Reply-To: <1355176551.27891.57.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry Kravkov reported packet drops for GRE packets since GRO support
was added.

There is a race in gro_cell_poll() because we call napi_complete()
without any synchronization with a concurrent gro_cells_receive()

Once bug was triggered, we queued packets but did not schedule NAPI
poll.

We can fix this issue using the spinlock protected the napi_skbs queue,
as we have to hold it to perform skb dequeue anyway.

As we open-code skb_dequeue(), we no longer need to mask IRQS, as both
producer and consumer run under BH context.

Bug added in commit c9e6bc644e (net: add gro_cells infrastructure)

Reported-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---

David: I could reproduce the bug Dmitry reported, and have
  verified this patch fixes the issue.

 include/net/gro_cells.h |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 4fd8a4b..e5062c9 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -17,7 +17,6 @@ struct gro_cells {
 
 static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
 {
-	unsigned long flags;
 	struct gro_cell *cell = gcells->cells;
 	struct net_device *dev = skb->dev;
 
@@ -35,32 +34,37 @@ static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *s
 		return;
 	}
 
-	spin_lock_irqsave(&cell->napi_skbs.lock, flags);
+	/* We run in BH context */
+	spin_lock(&cell->napi_skbs.lock);
 
 	__skb_queue_tail(&cell->napi_skbs, skb);
 	if (skb_queue_len(&cell->napi_skbs) == 1)
 		napi_schedule(&cell->napi);
 
-	spin_unlock_irqrestore(&cell->napi_skbs.lock, flags);
+	spin_unlock(&cell->napi_skbs.lock);
 }
 
+/* called unser BH context */
 static inline int gro_cell_poll(struct napi_struct *napi, int budget)
 {
 	struct gro_cell *cell = container_of(napi, struct gro_cell, napi);
 	struct sk_buff *skb;
 	int work_done = 0;
 
+	spin_lock(&cell->napi_skbs.lock);
 	while (work_done < budget) {
-		skb = skb_dequeue(&cell->napi_skbs);
+		skb = __skb_dequeue(&cell->napi_skbs);
 		if (!skb)
 			break;
-
+		spin_unlock(&cell->napi_skbs.lock);
 		napi_gro_receive(napi, skb);
 		work_done++;
+		spin_lock(&cell->napi_skbs.lock);
 	}
 
 	if (work_done < budget)
 		napi_complete(napi);
+	spin_unlock(&cell->napi_skbs.lock);
 	return work_done;
 }
 

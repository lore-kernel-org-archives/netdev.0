From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: ipgre rss is broken since gro
Date: Mon, 10 Dec 2012 13:55:51 -0800
Message-ID: <1355176551.27891.57.camel@edumazet-glaptop>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
	 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
	 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
	 <1355158471.27891.44.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC32A1@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45737 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab2LJVzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 16:55:53 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so2345121pad.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 13:55:53 -0800 (PST)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFC32A1@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 19:20 +0000, Dmitry Kravkov wrote:

> Yep, this resolved the issue - Interface is functional after 3 and 100 TCP connections. Thanks
>    
> 

I guess its only lowering probability of the race.

Could you try instead the following patch ?

I'll address the queue_mapping separately for net-next

Thanks

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
 

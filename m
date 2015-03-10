From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] drivers: atm: nicstar: remove ifdef'd out skb destructors
Date: Tue, 10 Mar 2015 04:56:53 +0100
Message-ID: <1425959813-23290-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45007 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750882AbbCJEfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 00:35:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove dead code.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index b7e1cc0..ddc4ceb 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -73,9 +73,6 @@
 #undef GENERAL_DEBUG
 #undef EXTRA_DEBUG
 
-#undef NS_USE_DESTRUCTORS	/* For now keep this undefined unless you know
-				   you're going to use only raw ATM */
-
 /* Do not touch these */
 
 #ifdef TX_DEBUG
@@ -138,11 +135,6 @@ static void process_tsq(ns_dev * card);
 static void drain_scq(ns_dev * card, scq_info * scq, int pos);
 static void process_rsq(ns_dev * card);
 static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe);
-#ifdef NS_USE_DESTRUCTORS
-static void ns_sb_destructor(struct sk_buff *sb);
-static void ns_lb_destructor(struct sk_buff *lb);
-static void ns_hb_destructor(struct sk_buff *hb);
-#endif /* NS_USE_DESTRUCTORS */
 static void recycle_rx_buf(ns_dev * card, struct sk_buff *skb);
 static void recycle_iovec_rx_bufs(ns_dev * card, struct iovec *iov, int count);
 static void recycle_iov_buf(ns_dev * card, struct sk_buff *iovb);
@@ -2169,9 +2161,6 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 			} else {
 				skb_put(skb, len);
 				dequeue_sm_buf(card, skb);
-#ifdef NS_USE_DESTRUCTORS
-				skb->destructor = ns_sb_destructor;
-#endif /* NS_USE_DESTRUCTORS */
 				ATM_SKB(skb)->vcc = vcc;
 				__net_timestamp(skb);
 				vcc->push(vcc, skb);
@@ -2190,9 +2179,6 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 				} else {
 					skb_put(sb, len);
 					dequeue_sm_buf(card, sb);
-#ifdef NS_USE_DESTRUCTORS
-					sb->destructor = ns_sb_destructor;
-#endif /* NS_USE_DESTRUCTORS */
 					ATM_SKB(sb)->vcc = vcc;
 					__net_timestamp(sb);
 					vcc->push(vcc, sb);
@@ -2208,9 +2194,6 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 					atomic_inc(&vcc->stats->rx_drop);
 				} else {
 					dequeue_lg_buf(card, skb);
-#ifdef NS_USE_DESTRUCTORS
-					skb->destructor = ns_lb_destructor;
-#endif /* NS_USE_DESTRUCTORS */
 					skb_push(skb, NS_SMBUFSIZE);
 					skb_copy_from_linear_data(sb, skb->data,
 								  NS_SMBUFSIZE);
@@ -2322,9 +2305,6 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 					     card->index);
 #endif /* EXTRA_DEBUG */
 				ATM_SKB(hb)->vcc = vcc;
-#ifdef NS_USE_DESTRUCTORS
-				hb->destructor = ns_hb_destructor;
-#endif /* NS_USE_DESTRUCTORS */
 				__net_timestamp(hb);
 				vcc->push(vcc, hb);
 				atomic_inc(&vcc->stats->rx);
@@ -2337,68 +2317,6 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 
 }
 
-#ifdef NS_USE_DESTRUCTORS
-
-static void ns_sb_destructor(struct sk_buff *sb)
-{
-	ns_dev *card;
-	u32 stat;
-
-	card = (ns_dev *) ATM_SKB(sb)->vcc->dev->dev_data;
-	stat = readl(card->membase + STAT);
-	card->sbfqc = ns_stat_sfbqc_get(stat);
-	card->lbfqc = ns_stat_lfbqc_get(stat);
-
-	do {
-		sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
-		if (sb == NULL)
-			break;
-		NS_PRV_BUFTYPE(sb) = BUF_SM;
-		skb_queue_tail(&card->sbpool.queue, sb);
-		skb_reserve(sb, NS_AAL0_HEADER);
-		push_rxbufs(card, sb);
-	} while (card->sbfqc < card->sbnr.min);
-}
-
-static void ns_lb_destructor(struct sk_buff *lb)
-{
-	ns_dev *card;
-	u32 stat;
-
-	card = (ns_dev *) ATM_SKB(lb)->vcc->dev->dev_data;
-	stat = readl(card->membase + STAT);
-	card->sbfqc = ns_stat_sfbqc_get(stat);
-	card->lbfqc = ns_stat_lfbqc_get(stat);
-
-	do {
-		lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
-		if (lb == NULL)
-			break;
-		NS_PRV_BUFTYPE(lb) = BUF_LG;
-		skb_queue_tail(&card->lbpool.queue, lb);
-		skb_reserve(lb, NS_SMBUFSIZE);
-		push_rxbufs(card, lb);
-	} while (card->lbfqc < card->lbnr.min);
-}
-
-static void ns_hb_destructor(struct sk_buff *hb)
-{
-	ns_dev *card;
-
-	card = (ns_dev *) ATM_SKB(hb)->vcc->dev->dev_data;
-
-	while (card->hbpool.count < card->hbnr.init) {
-		hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
-		if (hb == NULL)
-			break;
-		NS_PRV_BUFTYPE(hb) = BUF_NONE;
-		skb_queue_tail(&card->hbpool.queue, hb);
-		card->hbpool.count++;
-	}
-}
-
-#endif /* NS_USE_DESTRUCTORS */
-
 static void recycle_rx_buf(ns_dev * card, struct sk_buff *skb)
 {
 	if (unlikely(NS_PRV_BUFTYPE(skb) == BUF_NONE)) {
@@ -2427,9 +2345,6 @@ static void recycle_iov_buf(ns_dev * card, struct sk_buff *iovb)
 static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 {
 	skb_unlink(sb, &card->sbpool.queue);
-#ifdef NS_USE_DESTRUCTORS
-	if (card->sbfqc < card->sbnr.min)
-#else
 	if (card->sbfqc < card->sbnr.init) {
 		struct sk_buff *new_sb;
 		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
@@ -2440,7 +2355,6 @@ static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 		}
 	}
 	if (card->sbfqc < card->sbnr.init)
-#endif /* NS_USE_DESTRUCTORS */
 	{
 		struct sk_buff *new_sb;
 		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
@@ -2455,9 +2369,6 @@ static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb)
 {
 	skb_unlink(lb, &card->lbpool.queue);
-#ifdef NS_USE_DESTRUCTORS
-	if (card->lbfqc < card->lbnr.min)
-#else
 	if (card->lbfqc < card->lbnr.init) {
 		struct sk_buff *new_lb;
 		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
@@ -2468,7 +2379,6 @@ static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb)
 		}
 	}
 	if (card->lbfqc < card->lbnr.init)
-#endif /* NS_USE_DESTRUCTORS */
 	{
 		struct sk_buff *new_lb;
 		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
-- 
2.0.5

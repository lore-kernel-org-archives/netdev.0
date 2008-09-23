From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7]: atm: idt77252: Use generic SKB queue management
 instead of home-grown scheme.
Date: Mon, 22 Sep 2008 19:12:34 -0700 (PDT)
Message-ID: <20080922.191234.193380455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754069AbYIWCMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8B77AC8C185
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


atm: idt77252: Use generic SKB queue management instead of home-grown scheme.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/idt77252.c |   32 +++++++++-----------------------
 drivers/atm/idt77252.h |    4 +---
 2 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 3a504e9..e33ae00 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1114,11 +1114,8 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 
 	rpp = &vc->rcv.rx_pool;
 
+	__skb_queue_tail(&rpp->queue, skb);
 	rpp->len += skb->len;
-	if (!rpp->count++)
-		rpp->first = skb;
-	*rpp->last = skb;
-	rpp->last = &skb->next;
 
 	if (stat & SAR_RSQE_EPDU) {
 		unsigned char *l1l2;
@@ -1145,7 +1142,7 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 			atomic_inc(&vcc->stats->rx_err);
 			return;
 		}
-		if (rpp->count > 1) {
+		if (skb_queue_len(&rpp->queue) > 1) {
 			struct sk_buff *sb;
 
 			skb = dev_alloc_skb(rpp->len);
@@ -1161,12 +1158,9 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 				dev_kfree_skb(skb);
 				return;
 			}
-			sb = rpp->first;
-			for (i = 0; i < rpp->count; i++) {
+			skb_queue_walk(&rpp->queue, sb)
 				memcpy(skb_put(skb, sb->len),
 				       sb->data, sb->len);
-				sb = sb->next;
-			}
 
 			recycle_rx_pool_skb(card, rpp);
 
@@ -1180,7 +1174,6 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 			return;
 		}
 
-		skb->next = NULL;
 		flush_rx_pool(card, rpp);
 
 		if (!atm_charge(vcc, skb->truesize)) {
@@ -1918,25 +1911,18 @@ recycle_rx_skb(struct idt77252_dev *card, struct sk_buff *skb)
 static void
 flush_rx_pool(struct idt77252_dev *card, struct rx_pool *rpp)
 {
+	skb_queue_head_init(&rpp->queue);
 	rpp->len = 0;
-	rpp->count = 0;
-	rpp->first = NULL;
-	rpp->last = &rpp->first;
 }
 
 static void
 recycle_rx_pool_skb(struct idt77252_dev *card, struct rx_pool *rpp)
 {
-	struct sk_buff *skb, *next;
-	int i;
+	struct sk_buff *skb, *tmp;
 
-	skb = rpp->first;
-	for (i = 0; i < rpp->count; i++) {
-		next = skb->next;
-		skb->next = NULL;
+	skb_queue_walk_safe(&rpp->queue, skb, tmp)
 		recycle_rx_skb(card, skb);
-		skb = next;
-	}
+
 	flush_rx_pool(card, rpp);
 }
 
@@ -2537,7 +2523,7 @@ idt77252_close(struct atm_vcc *vcc)
 		waitfor_idle(card);
 		spin_unlock_irqrestore(&card->cmd_lock, flags);
 
-		if (vc->rcv.rx_pool.count) {
+		if (skb_queue_len(&vc->rcv.rx_pool.queue) != 0) {
 			DPRINTK("%s: closing a VC with pending rx buffers.\n",
 				card->name);
 
@@ -2970,7 +2956,7 @@ close_card_oam(struct idt77252_dev *card)
 			waitfor_idle(card);
 			spin_unlock_irqrestore(&card->cmd_lock, flags);
 
-			if (vc->rcv.rx_pool.count) {
+			if (skb_queue_len(&vc->rcv.rx_pool.queue) != 0) {
 				DPRINTK("%s: closing a VC "
 					"with pending rx buffers.\n",
 					card->name);
diff --git a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
index e83eaf1..5042bb2 100644
--- a/drivers/atm/idt77252.h
+++ b/drivers/atm/idt77252.h
@@ -173,10 +173,8 @@ struct scq_info
 };
 
 struct rx_pool {
-	struct sk_buff		*first;
-	struct sk_buff		**last;
+	struct sk_buff_head	queue;
 	unsigned int		len;
-	unsigned int		count;
 };
 
 struct aal1 {
-- 
1.5.6.5


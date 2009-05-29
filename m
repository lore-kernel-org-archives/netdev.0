From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/10]: atm: Use SKB queue and list helpers instead of doing
 it by-hand.
Date: Fri, 29 May 2009 01:40:16 -0700 (PDT)
Message-ID: <20090529.014016.22993674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756767AbZE2IkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/atm/br2684.c |   26 +++++++++-----------------
 net/atm/clip.c   |   27 ++++++++-------------------
 2 files changed, 17 insertions(+), 36 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 3100a89..bfa8fa9 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -445,9 +445,10 @@ free_skb:
  */
 static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 {
+	struct sk_buff_head queue;
 	int err;
 	struct br2684_vcc *brvcc;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *tmp;
 	struct sk_buff_head *rq;
 	struct br2684_dev *brdev;
 	struct net_device *net_dev;
@@ -505,29 +506,20 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	barrier();
 	atmvcc->push = br2684_push;
 
+	__skb_queue_head_init(&queue);
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 
 	spin_lock_irqsave(&rq->lock, flags);
-	if (skb_queue_empty(rq)) {
-		skb = NULL;
-	} else {
-		/* NULL terminate the list.  */
-		rq->prev->next = NULL;
-		skb = rq->next;
-	}
-	rq->prev = rq->next = (struct sk_buff *)rq;
-	rq->qlen = 0;
+	skb_queue_splice_init(rq, &queue);
 	spin_unlock_irqrestore(&rq->lock, flags);
 
-	while (skb) {
-		struct sk_buff *next = skb->next;
+	skb_queue_walk_safe(&queue, skb, tmp) {
+		struct net_device *dev = skb->dev;
 
-		skb->next = skb->prev = NULL;
-		br2684_push(atmvcc, skb);
-		skb->dev->stats.rx_bytes -= skb->len;
-		skb->dev->stats.rx_packets--;
+		dev->stats.rx_bytes -= skb->len;
+		dev->stats.rx_packets--;
 
-		skb = next;
+		br2684_push(atmvcc, skb);
 	}
 	__module_get(THIS_MODULE);
 	return 0;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 3dc0a3a..5597b87 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -445,9 +445,9 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int clip_mkip(struct atm_vcc *vcc, int timeout)
 {
+	struct sk_buff_head *rq, queue;
 	struct clip_vcc *clip_vcc;
-	struct sk_buff *skb;
-	struct sk_buff_head *rq;
+	struct sk_buff *skb, *tmp;
 	unsigned long flags;
 
 	if (!vcc->push)
@@ -469,39 +469,28 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 	vcc->push = clip_push;
 	vcc->pop = clip_pop;
 
+	__skb_queue_head_init(&queue);
 	rq = &sk_atm(vcc)->sk_receive_queue;
 
 	spin_lock_irqsave(&rq->lock, flags);
-	if (skb_queue_empty(rq)) {
-		skb = NULL;
-	} else {
-		/* NULL terminate the list.  */
-		rq->prev->next = NULL;
-		skb = rq->next;
-	}
-	rq->prev = rq->next = (struct sk_buff *)rq;
-	rq->qlen = 0;
+	skb_queue_splice_init(rq, &queue);
 	spin_unlock_irqrestore(&rq->lock, flags);
 
 	/* re-process everything received between connection setup and MKIP */
-	while (skb) {
-		struct sk_buff *next = skb->next;
-
-		skb->next = skb->prev = NULL;
+	skb_queue_walk_safe(&queue, skb, tmp) {
 		if (!clip_devs) {
 			atm_return(vcc, skb->truesize);
 			kfree_skb(skb);
 		} else {
+			struct net_device *dev = skb->dev;
 			unsigned int len = skb->len;
 
 			skb_get(skb);
 			clip_push(vcc, skb);
-			skb->dev->stats.rx_packets--;
-			skb->dev->stats.rx_bytes -= len;
+			dev->stats.rx_packets--;
+			dev->stats.rx_bytes -= len;
 			kfree_skb(skb);
 		}
-
-		skb = next;
 	}
 	return 0;
 }
-- 
1.6.3


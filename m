From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/10]: econet: Use SKB queue and list helpers instead of
 doing it by-hand.
Date: Fri, 29 May 2009 01:40:20 -0700 (PDT)
Message-ID: <20090529.014020.135721424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757350AbZE2IkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/econet/af_econet.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 6f479fa..8121bf0 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -901,15 +901,10 @@ static void aun_tx_ack(unsigned long seq, int result)
 	struct ec_cb *eb;
 
 	spin_lock_irqsave(&aun_queue_lock, flags);
-	skb = skb_peek(&aun_queue);
-	while (skb && skb != (struct sk_buff *)&aun_queue)
-	{
-		struct sk_buff *newskb = skb->next;
+	skb_queue_walk(&aun_queue, skb) {
 		eb = (struct ec_cb *)&skb->cb;
 		if (eb->seq == seq)
 			goto foundit;
-
-		skb = newskb;
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
 	printk(KERN_DEBUG "AUN: unknown sequence %ld\n", seq);
@@ -982,23 +977,18 @@ static void aun_data_available(struct sock *sk, int slen)
 
 static void ab_cleanup(unsigned long h)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 	unsigned long flags;
 
 	spin_lock_irqsave(&aun_queue_lock, flags);
-	skb = skb_peek(&aun_queue);
-	while (skb && skb != (struct sk_buff *)&aun_queue)
-	{
-		struct sk_buff *newskb = skb->next;
+	skb_queue_walk_safe(&aun_queue, skb, n) {
 		struct ec_cb *eb = (struct ec_cb *)&skb->cb;
-		if ((jiffies - eb->start) > eb->timeout)
-		{
+		if ((jiffies - eb->start) > eb->timeout) {
 			tx_result(skb->sk, eb->cookie,
 				  ECTYPE_TRANSMIT_NOT_PRESENT);
 			skb_unlink(skb, &aun_queue);
 			kfree_skb(skb);
 		}
-		skb = newskb;
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
 
-- 
1.6.3


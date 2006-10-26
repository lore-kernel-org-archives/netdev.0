From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/8] netpoll per device txq
Date: Thu, 26 Oct 2006 15:46:51 -0700
Message-ID: <20061026225645.834331783@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16571 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423718AbWJZXBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:06 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-per-dev.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the netpoll beast got really busy, it tended to clog
things, so it stored them for later. But the beast was putting
all it's skb's in one basket. This was bad because maybe some
pipes were clogged and others were not.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netpoll.h |    2 +
 net/core/netpoll.c      |   50 ++++++++++++++----------------------------------
 2 files changed, 17 insertions(+), 35 deletions(-)

--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -33,6 +33,8 @@ struct netpoll_info {
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
+	struct sk_buff_head txq;
+	struct work_struct tx_work;
 };
 
 void netpoll_poll(struct netpoll *np);
--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -38,10 +38,6 @@
 
 static struct sk_buff_head skb_pool;
 
-static DEFINE_SPINLOCK(queue_lock);
-static int queue_depth;
-static struct sk_buff *queue_head, *queue_tail;
-
 static atomic_t trapped;
 
 #define NETPOLL_RX_ENABLED  1
@@ -56,46 +52,25 @@ static void arp_reply(struct sk_buff *sk
 
 static void queue_process(void *p)
 {
-	unsigned long flags;
+	struct netpoll_info *npinfo = p;
 	struct sk_buff *skb;
 
-	while (queue_head) {
-		spin_lock_irqsave(&queue_lock, flags);
-
-		skb = queue_head;
-		queue_head = skb->next;
-		if (skb == queue_tail)
-			queue_head = NULL;
-
-		queue_depth--;
-
-		spin_unlock_irqrestore(&queue_lock, flags);
-
+	while ((skb = skb_dequeue(&npinfo->txq)))
 		dev_queue_xmit(skb);
-	}
-}
 
-static DECLARE_WORK(send_queue, queue_process, NULL);
+}
 
 void netpoll_queue(struct sk_buff *skb)
 {
-	unsigned long flags;
+	struct net_device *dev = skb->dev;
+	struct netpoll_info *npinfo = dev->npinfo;
 
-	if (queue_depth == MAX_QUEUE_DEPTH) {
-		__kfree_skb(skb);
-		return;
+	if (!npinfo)
+		kfree_skb(skb);
+	else {
+		skb_queue_tail(&npinfo->txq, skb);
+		schedule_work(&npinfo->tx_work);
 	}
-
-	spin_lock_irqsave(&queue_lock, flags);
-	if (!queue_head)
-		queue_head = skb;
-	else
-		queue_tail->next = skb;
-	queue_tail = skb;
-	queue_depth++;
-	spin_unlock_irqrestore(&queue_lock, flags);
-
-	schedule_work(&send_queue);
 }
 
 static int checksum_udp(struct sk_buff *skb, struct udphdr *uh,
@@ -649,6 +624,9 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->tries = MAX_RETRIES;
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
+		skb_queue_head_init(&npinfo->txq);
+		INIT_WORK(&npinfo->tx_work, queue_process, npinfo);
+
 		atomic_set(&npinfo->refcnt, 1);
 	} else {
 		npinfo = ndev->npinfo;
@@ -771,6 +749,8 @@ void netpoll_cleanup(struct netpoll *np)
 			np->dev->npinfo = NULL;
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				skb_queue_purge(&npinfo->arp_tx);
+ 				skb_queue_purge(&npinfo->txq);
+ 				flush_scheduled_work();
 
 				kfree(npinfo);
 			}

--
Stephen Hemminger <shemminger@osdl.org>


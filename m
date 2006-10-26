From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/8] netpoll: skb private pool management
Date: Thu, 26 Oct 2006 15:46:49 -0700
Message-ID: <20061026225645.482978803@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16059 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423684AbWJZXBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-skb-pool.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was a dark and stormy night when Steve first saw the
netpoll beast. The beast was odd, and misshapen but not
extremely ugly.

"Let me take off one of your warts" he said. This wart
is where you tried to make an skb list yourself. If the
beast had ever run out of memory, he would have stupefied
himself unnecessarily.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/core/netpoll.c |   52 +++++++++++++++++++---------------------------------
 1 file changed, 19 insertions(+), 33 deletions(-)

--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -36,9 +36,7 @@
 #define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 #define MAX_RETRIES 20000
 
-static DEFINE_SPINLOCK(skb_list_lock);
-static int nr_skbs;
-static struct sk_buff *skbs;
+static struct sk_buff_head skb_pool;
 
 static DEFINE_SPINLOCK(queue_lock);
 static int queue_depth;
@@ -188,19 +186,14 @@ void netpoll_poll(struct netpoll *np)
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
-	unsigned long flags;
 
-	spin_lock_irqsave(&skb_list_lock, flags);
-	while (nr_skbs < MAX_SKBS) {
+	while (skb_queue_len(&skb_pool) < MAX_SKBS) {
 		skb = alloc_skb(MAX_SKB_SIZE, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		skb->next = skbs;
-		skbs = skb;
-		nr_skbs++;
+		skb_queue_tail(&skb_pool, skb);
 	}
-	spin_unlock_irqrestore(&skb_list_lock, flags);
 }
 
 static void zap_completion_queue(void)
@@ -229,38 +222,25 @@ static void zap_completion_queue(void)
 	put_cpu_var(softnet_data);
 }
 
-static struct sk_buff * find_skb(struct netpoll *np, int len, int reserve)
+static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
-	int once = 1, count = 0;
-	unsigned long flags;
-	struct sk_buff *skb = NULL;
+	int count = 0;
+	struct sk_buff *skb;
 
 	zap_completion_queue();
+	refill_skbs();
 repeat:
-	if (nr_skbs < MAX_SKBS)
-		refill_skbs();
 
 	skb = alloc_skb(len, GFP_ATOMIC);
-
-	if (!skb) {
-		spin_lock_irqsave(&skb_list_lock, flags);
-		skb = skbs;
-		if (skb) {
-			skbs = skb->next;
-			skb->next = NULL;
-			nr_skbs--;
-		}
-		spin_unlock_irqrestore(&skb_list_lock, flags);
-	}
+	if (!skb)
+		skb = skb_dequeue(&skb_pool);
 
 	if(!skb) {
-		count++;
-		if (once && (count == 1000000)) {
-			printk("out of netpoll skbs!\n");
-			once = 0;
+		if (++count < 10) {
+			netpoll_poll(np);
+			goto repeat;
 		}
-		netpoll_poll(np);
-		goto repeat;
+		return NULL;
 	}
 
 	atomic_set(&skb->users, 1);
@@ -764,6 +744,12 @@ int netpoll_setup(struct netpoll *np)
 	return -1;
 }
 
+static int __init netpoll_init(void) {
+	skb_queue_head_init(&skb_pool);
+	return 0;
+}
+core_initcall(netpoll_init);
+
 void netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;

--
Stephen Hemminger <shemminger@osdl.org>


From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/8] netpoll: skb private pool management
Date: Thu, 26 Oct 2006 19:29:34 -0700
Message-ID: <20061026192934.58c20e2a@localhost.localdomain>
References: <20061026225645.482978803@osdl.org>
	<20061026.171247.133285493.davem@davemloft.net>
	<20061026180402.32c1c511@localhost.localdomain>
	<20061026.180812.34605098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49547 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946124AbWJ0CaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 22:30:21 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061026.180812.34605098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was a dark and stormy night when Steve first saw the
netpoll beast. The beast was odd, and misshapen but not
extremely ugly.

"Let me take off one of your warts" he said. This wart
is where you tried to make an skb list yourself. If the
beast had ever run out of memory, he would have stupefied
himself unnecessarily.

The first try was painful, so he tried again till the bleeding
stopped.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/core/netpoll.c |   53 +++++++++++++++++++++--------------------------------
 1 file changed, 21 insertions(+), 32 deletions(-)

--- netpoll.orig/net/core/netpoll.c	2006-10-26 19:12:36.000000000 -0700
+++ netpoll/net/core/netpoll.c	2006-10-26 19:16:05.000000000 -0700
@@ -36,9 +36,7 @@
 #define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 #define MAX_RETRIES 20000
 
-static DEFINE_SPINLOCK(skb_list_lock);
-static int nr_skbs;
-static struct sk_buff *skbs;
+static struct sk_buff_head skb_pool;
 
 static DEFINE_SPINLOCK(queue_lock);
 static int queue_depth;
@@ -190,17 +188,15 @@
 	struct sk_buff *skb;
 	unsigned long flags;
 
-	spin_lock_irqsave(&skb_list_lock, flags);
-	while (nr_skbs < MAX_SKBS) {
+	spin_lock_irqsave(&skb_pool->lock, flags);
+	while (skb_pool.qlen < MAX_SKBS) {
 		skb = alloc_skb(MAX_SKB_SIZE, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		skb->next = skbs;
-		skbs = skb;
-		nr_skbs++;
+		__skb_queue_tail(&skb_pool, skb);
 	}
-	spin_unlock_irqrestore(&skb_list_lock, flags);
+	spin_unlock_irqrestore(&skb_pool->lock, flags);
 }
 
 static void zap_completion_queue(void)
@@ -229,38 +225,25 @@
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
@@ -764,6 +747,12 @@
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

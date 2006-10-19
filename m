From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] netpoll: use skb_buff_head for skb cache
Date: Thu, 19 Oct 2006 10:15:44 -0700
Message-ID: <20061019171814.497048492@osdl.org>
References: <20061019171541.062261760@osdl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946263AbWJSRTy@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-freelist.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private skb cache should be managed with normal skb_buff_head rather
than a DIY queue. If pool is exhausted, don't print anything that just
makes the problem worse. After a number of attempts, punt and drop
the message (callers handle it already).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/core/netpoll.c |   55 +++++++++++++++++++++--------------------------------
 1 file changed, 22 insertions(+), 33 deletions(-)

--- linux-2.6.orig/net/core/netpoll.c	2006-10-19 09:49:03.000000000 -0700
+++ linux-2.6/net/core/netpoll.c	2006-10-19 10:06:39.000000000 -0700
@@ -36,9 +36,7 @@
 #define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 #define MAX_RETRIES 20000
 
-static DEFINE_SPINLOCK(skb_list_lock);
-static int nr_skbs;
-static struct sk_buff *skbs;
+static struct sk_buff_head skb_list;
 
 static atomic_t trapped;
 
@@ -51,6 +49,7 @@
 
 static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
+static void refill_skbs(void);
 
 static void netpoll_run(unsigned long arg)
 {
@@ -79,6 +78,7 @@
 			break;
 		}
 	}
+	refill_skbs();
 }
 
 static int checksum_udp(struct sk_buff *skb, struct udphdr *uh,
@@ -169,19 +169,14 @@
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
-	unsigned long flags;
 
-	spin_lock_irqsave(&skb_list_lock, flags);
-	while (nr_skbs < MAX_SKBS) {
+	while (skb_queue_len(&skb_list) < MAX_SKBS) {
 		skb = alloc_skb(MAX_SKB_SIZE, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		skb->next = skbs;
-		skbs = skb;
-		nr_skbs++;
+		skb_queue_tail(&skb_list, skb);
 	}
-	spin_unlock_irqrestore(&skb_list_lock, flags);
 }
 
 static void zap_completion_queue(void)
@@ -210,37 +205,24 @@
 	put_cpu_var(softnet_data);
 }
 
-static struct sk_buff * find_skb(struct netpoll *np, int len, int reserve)
+static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
-	int once = 1, count = 0;
-	unsigned long flags;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
+	int tries = 0;
 
 	zap_completion_queue();
-repeat:
-	if (nr_skbs < MAX_SKBS)
-		refill_skbs();
 
+repeat:
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
+		skb = skb_dequeue(&skb_list);
 
 	if(!skb) {
-		count++;
-		if (once && (count == 1000000)) {
-			printk("out of netpoll skbs!\n");
-			once = 0;
-		}
+		if (++tries > MAX_RETRIES)
+			return NULL;
+
 		netpoll_poll(np);
+		tasklet_schedule(&np->dev->npinfo->tx_task);
 		goto repeat;
 	}
 
@@ -589,6 +571,13 @@
 	return -1;
 }
 
+static __init int netpoll_init(void)
+{
+	skb_queue_head_init(&skb_list);
+	return 0;
+}
+core_initcall(netpoll_init);
+
 int netpoll_setup(struct netpoll *np)
 {
 	struct net_device *ndev = NULL;

--

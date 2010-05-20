From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: remove zap_completion_queue
Date: Thu, 20 May 2010 11:16:03 +0200
Message-ID: <1274346963.4046.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38957 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab0ETJQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 05:16:08 -0400
Received: by fxm10 with SMTP id 10so3279921fxm.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 02:16:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll does an interesting work in zap_completion_queue(), but this was
before we did skb orphaning before delivering packets to device.

It now makes sense to add a test in dev_kfree_skb_irq() to not queue a
skb if already orphaned, and to remove netpoll zap_completion_queue() as
a bonus.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c     |    4 +++-
 net/core/netpoll.c |   31 -------------------------------
 2 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6c82065..37f1641 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1578,7 +1578,9 @@ EXPORT_SYMBOL(__netif_schedule);
 
 void dev_kfree_skb_irq(struct sk_buff *skb)
 {
-	if (atomic_dec_and_test(&skb->users)) {
+	if (!skb->destructor)
+		dev_kfree_skb(skb);
+	else if (atomic_dec_and_test(&skb->users)) {
 		struct softnet_data *sd;
 		unsigned long flags;
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94825b1..e034342 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -49,7 +49,6 @@ static atomic_t trapped;
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
-static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
 static unsigned int carrier_timeout = 4;
@@ -197,7 +196,6 @@ void netpoll_poll_dev(struct net_device *dev)
 
 	service_arp_queue(dev->npinfo);
 
-	zap_completion_queue();
 }
 
 void netpoll_poll(struct netpoll *np)
@@ -221,40 +219,11 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
-static void zap_completion_queue(void)
-{
-	unsigned long flags;
-	struct softnet_data *sd = &get_cpu_var(softnet_data);
-
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
-
-		local_irq_save(flags);
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
-		local_irq_restore(flags);
-
-		while (clist != NULL) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
-			if (skb->destructor) {
-				atomic_inc(&skb->users);
-				dev_kfree_skb_any(skb); /* put this one back */
-			} else {
-				__kfree_skb(skb);
-			}
-		}
-	}
-
-	put_cpu_var(softnet_data);
-}
-
 static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
 	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
 	refill_skbs();
 repeat:
 



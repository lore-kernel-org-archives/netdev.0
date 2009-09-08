From: DDD <Dongdong.deng@windriver.com>
Subject: [PATCH 1/1] netpoll: fix race between skb_queue_len and skb_dequeue
Date: Tue, 08 Sep 2009 15:49:49 +0800
Message-ID: <1252396189.16528.19.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60925 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbZIHHgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 03:36:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This race will break the messages order.

Sequence of events in the problem case:

Assume there is one skb "A" in skb_queue and the next action of
netpoll_send_skb() is: sending out "B" skb.
The right order of messages should be: send A first, then send B.

But as following orders, it will send B first, then send A.

  CPU0                             CPU1
  queue_process()                  netpoll_send_skb(B)
  A = skb_dequeue()
  /****
  A was removed from skb_queue,
  so skb_queue_len = 0
  ****/

                                   Check skb_queue_len == 0 Yes
                                   sendout (B)

  sendout (A)

The solution is to introduce the txq_skbuff_len in netpoll_info struct.
The txq_skbuff_len will keep the skb queue lenght utill the skb was sent out,
so that this race condition will gone.

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
---
 include/linux/netpoll.h |    1 +
 net/core/netpoll.c      |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 2524267..3757141 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -27,6 +27,7 @@ struct netpoll_info {
 	atomic_t refcnt;
 	int rx_flags;
 	spinlock_t rx_lock;
+	__u32 txq_skbuff_len;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 	struct sk_buff_head txq;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 1b76eb1..6d22426 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -78,11 +78,14 @@ static void queue_process(struct work_struct *work)
 			__netif_tx_unlock(txq);
 			local_irq_restore(flags);
 
+			npinfo->txq_skbuff_len = skb_queue_len(&npinfo->txq);
 			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
 		__netif_tx_unlock(txq);
 		local_irq_restore(flags);
+
+		npinfo->txq_skbuff_len = skb_queue_len(&npinfo->txq);
 	}
 }
 
@@ -291,7 +294,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	}
 
 	/* don't get messages out of order, and no recursion */
-	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
+	if (npinfo->txq_skbuff_len == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
 		unsigned long flags;
 
@@ -329,7 +332,8 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 	if (status != NETDEV_TX_OK) {
 		skb_queue_tail(&npinfo->txq, skb);
-		schedule_delayed_work(&npinfo->tx_work,0);
+		npinfo->txq_skbuff_len = skb_queue_len(&npinfo->txq);
+		schedule_delayed_work(&npinfo->tx_work, 0);
 	}
 }
 
-- 
1.6.0.4



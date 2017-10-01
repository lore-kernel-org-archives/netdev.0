From: Michael Witten <mfwitten@gmail.com>
Subject: [PATCH net 3/3] net: skb_queue_purge(): lock/unlock the queue only once
Date: Sun, 01 Oct 2017 22:19:20 -0000
Message-ID: <ccfa23a0f76c4c9ebd07fc991db2f829-mfwitten@gmail.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
            <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Sat, 9 Sep 2017 05:50:23 +0000
Hitherto, the queue's lock has been locked/unlocked every time
an item is dequeued; this seems not only inefficient, but also
incorrect, as the whole point of `skb_queue_purge()' is to clear
the queue, presumably without giving any other thread a chance to
manipulate the queue in the interim.

With this commit, the queue's lock is locked/unlocked only once
when `skb_queue_purge()' is called, and in a way that disables
the IRQs for only a minimal amount of time.

This is achieved by atomically re-initializing the queue (thereby
clearing it), and then freeing each of the items as though it were
enqueued in a private queue that doesn't require locking.

Signed-off-by: Michael Witten <mfwitten@gmail.com>
---
 net/core/skbuff.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 68065d7d383f..bd26b0bde784 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2825,18 +2825,28 @@ struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list)
 EXPORT_SYMBOL(skb_dequeue_tail);
 
 /**
- *	skb_queue_purge - empty a list
- *	@list: list to empty
+ *	skb_queue_purge - empty a queue
+ *	@q: the queue to empty
  *
- *	Delete all buffers on an &sk_buff list. Each buffer is removed from
- *	the list and one reference dropped. This function takes the list
- *	lock and is atomic with respect to other list locking functions.
+ *	Dequeue and free each socket buffer that is in @q.
+ *
+ *	This function is atomic with respect to other queue-locking functions.
  */
-void skb_queue_purge(struct sk_buff_head *list)
+void skb_queue_purge(struct sk_buff_head *q)
 {
-	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
+	unsigned long flags;
+	struct sk_buff *skb, *next, *head = (struct sk_buff *)q;
+
+	spin_lock_irqsave(&q->lock, flags);
+	skb = q->next;
+	__skb_queue_head_init(q);
+	spin_unlock_irqrestore(&q->lock, flags);
+
+	while (skb != head) {
+		next = skb->next;
 		kfree_skb(skb);
+		skb = next;
+	}
 }
 EXPORT_SYMBOL(skb_queue_purge);
 
-- 
2.14.1

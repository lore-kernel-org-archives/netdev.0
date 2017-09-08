From: Michael Witten <mfwitten@gmail.com>
Subject: [PATCH 3/3] net: skb_queue_purge(): lock/unlock the list only once
Date: Fri, 08 Sep 2017 05:06:30 -0000
Message-ID: <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Thu, 7 Sep 2017 20:07:40 +0000
With this commit, the list's lock is locked/unlocked only once
for the duration of `skb_queue_purge()'.

Hitherto, the list's lock has been locked/unlocked every time
an item is dequeued; this seems not only inefficient, but also
incorrect, as the whole point of `skb_queue_purge()' is to clear
the list, presumably without giving anything else a chance to
manipulate the list in the interim.

Signed-off-by: Michael Witten <mfwitten@gmail.com>
---
 net/core/skbuff.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 68065d7d383f..66c0731a2a5f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2834,9 +2834,13 @@ EXPORT_SYMBOL(skb_dequeue_tail);
  */
 void skb_queue_purge(struct sk_buff_head *list)
 {
+	unsigned long flags;
 	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
+
+	spin_lock_irqsave(&list->lock, flags);
+	while ((skb = __skb_dequeue(list)) != NULL)
 		kfree_skb(skb);
+	spin_unlock_irqrestore(&list->lock, flags);
 }
 EXPORT_SYMBOL(skb_queue_purge);
 
-- 
2.14.1

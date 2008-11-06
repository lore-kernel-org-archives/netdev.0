From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] nets: fix problem of using lock
Date: Thu, 6 Nov 2008 18:41:03 +0800
Message-ID: <20081106104103.GA29787@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:53549 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453AbYKFKlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 05:41:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/core/skbuff.c: void skb_queue_purge(struct sk_buff_head *list)

This function should takes the the list lock, because the operation to
this list shoule be atomic. And __skb_queue_purge()  (in
include/linux/skbuff.c) real delete the buffers in the list.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/core/skbuff.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ebb6b94..3b89fb1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1834,9 +1834,11 @@ struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list)
  */
 void skb_queue_purge(struct sk_buff_head *list)
 {
-	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
-		kfree_skb(skb);
+	unsigned long flags;
+
+	spin_lock_irqsave(&list->lock, flags);
+	__skb_queue_purge(list);
+	spin_unlock_irqrestore(&list->lock, flags);
 }
 
 /**
-- 
1.5.6.3


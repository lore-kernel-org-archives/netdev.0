From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7]: net: Add new interfaces for SKB list light-weight
 init and splicing.
Date: Mon, 22 Sep 2008 19:12:36 -0700 (PDT)
Message-ID: <20080922.191236.216829858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754058AbYIWCMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5B848C8C185
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add new interfaces for SKB list light-weight init and splicing.

This will be used by subsequent changesets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   96 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 94 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index aa80ad9..027b061 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -660,6 +660,22 @@ static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
 	return list_->qlen;
 }
 
+/**
+ *	__skb_queue_head_init - initialize non-spinlock portions of sk_buff_head
+ *	@list: queue to initialize
+ *
+ *	This initializes only the list and queue length aspects of
+ *	an sk_buff_head object.  This allows to initialize the list
+ *	aspects of an sk_buff_head without reinitializing things like
+ *	the spinlock.  It can also be used for on-stack sk_buff_head
+ *	objects where the spinlock is known to not be used.
+ */
+static inline void __skb_queue_head_init(struct sk_buff_head *list)
+{
+	list->prev = list->next = (struct sk_buff *)list;
+	list->qlen = 0;
+}
+
 /*
  * This function creates a split out lock class for each invocation;
  * this is needed for now since a whole lot of users of the skb-queue
@@ -671,8 +687,7 @@ static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
 static inline void skb_queue_head_init(struct sk_buff_head *list)
 {
 	spin_lock_init(&list->lock);
-	list->prev = list->next = (struct sk_buff *)list;
-	list->qlen = 0;
+	__skb_queue_head_init(list);
 }
 
 static inline void skb_queue_head_init_class(struct sk_buff_head *list,
@@ -699,6 +714,83 @@ static inline void __skb_insert(struct sk_buff *newsk,
 	list->qlen++;
 }
 
+static inline void __skb_queue_splice(const struct sk_buff_head *list,
+				      struct sk_buff *prev,
+				      struct sk_buff *next)
+{
+	struct sk_buff *first = list->next;
+	struct sk_buff *last = list->prev;
+
+	first->prev = prev;
+	prev->next = first;
+
+	last->next = next;
+	next->prev = last;
+}
+
+/**
+ *	skb_queue_splice - join two skb lists, this is designed for stacks
+ *	@list: the new list to add
+ *	@head: the place to add it in the first list
+ */
+static inline void skb_queue_splice(const struct sk_buff_head *list,
+				    struct sk_buff_head *head)
+{
+	if (!skb_queue_empty(list)) {
+		__skb_queue_splice(list, (struct sk_buff *) head, head->next);
+		head->qlen = list->qlen;
+	}
+}
+
+/**
+ *	skb_queue_splice - join two skb lists and reinitialise the emptied list
+ *	@list: the new list to add
+ *	@head: the place to add it in the first list
+ *
+ *	The list at @list is reinitialised
+ */
+static inline void skb_queue_splice_init(struct sk_buff_head *list,
+					 struct sk_buff_head *head)
+{
+	if (!skb_queue_empty(list)) {
+		__skb_queue_splice(list, (struct sk_buff *) head, head->next);
+		head->qlen = list->qlen;
+		__skb_queue_head_init(list);
+	}
+}
+
+/**
+ *	skb_queue_splice_tail - join two skb lists, each list being a queue
+ *	@list: the new list to add
+ *	@head: the place to add it in the first list
+ */
+static inline void skb_queue_splice_tail(const struct sk_buff_head *list,
+					 struct sk_buff_head *head)
+{
+	if (!skb_queue_empty(list)) {
+		__skb_queue_splice(list, head->prev, (struct sk_buff *) head);
+		head->qlen = list->qlen;
+	}
+}
+
+/**
+ *	skb_queue_splice_tail - join two skb lists and reinitialise the emptied list
+ *	@list: the new list to add
+ *	@head: the place to add it in the first list
+ *
+ *	Each of the lists is a queue.
+ *	The list at @list is reinitialised
+ */
+static inline void skb_queue_splice_tail_init(struct sk_buff_head *list,
+					      struct sk_buff_head *head)
+{
+	if (!skb_queue_empty(list)) {
+		__skb_queue_splice(list, head->prev, (struct sk_buff *) head);
+		head->qlen = list->qlen;
+		__skb_queue_head_init(list);
+	}
+}
+
 /**
  *	__skb_queue_after - queue a buffer at the list head
  *	@list: list to use
-- 
1.5.6.5


From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [NET] [Patch 0/4]: Removing some redundancies in skbuff.h
Date: Mon, 14 Apr 2008 08:00:56 +0100
Message-ID: <20080414070056.GB4431@gerrit.erg.abdn.ac.uk>
References: <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk> <20080413.234453.118301281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36253 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752421AbYDNHBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 03:01:25 -0400
Content-Disposition: inline
In-Reply-To: <20080413.234453.118301281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| These don't apply to net-2.6.26, which is where I'd like to apply them.
Oops, sorry -- they were relative to netdev-2.6. 

I have re-spun them to match 2.6.26. Hope it is okay that I attach them below.

Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.


--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001--NET-__skb_dequeue-skb_peek-__skb_unlink.patch"

>From 9d79ffef978f8a3a0d8592ee77876d8c70d50b22 Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Apr 2008 09:58:11 +0100
Subject: [PATCH 1/4] [SKB]: __skb_dequeue = skb_peek + __skb_unlink

By rearranging the order of declarations, __skb_dequeue() is expressed in terms of

 * skb_peek() and
 * __skb_unlink(),

thus in effect mirroring the analogue implementation of __skb_dequeue_tail().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   47 ++++++++++++++++-------------------------------
 1 file changed, 16 insertions(+), 31 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -734,35 +734,6 @@ static inline void __skb_queue_tail(stru
 	next->prev  = prev->next = newsk;
 }
 
-
-/**
- *	__skb_dequeue - remove from the head of the queue
- *	@list: list to dequeue from
- *
- *	Remove the head of the list. This function does not take any locks
- *	so must be used with appropriate locks held only. The head item is
- *	returned or %NULL if the list is empty.
- */
-extern struct sk_buff *skb_dequeue(struct sk_buff_head *list);
-static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
-{
-	struct sk_buff *next, *prev, *result;
-
-	prev = (struct sk_buff *) list;
-	next = prev->next;
-	result = NULL;
-	if (next != prev) {
-		result	     = next;
-		next	     = next->next;
-		list->qlen--;
-		next->prev   = prev;
-		prev->next   = next;
-		result->next = result->prev = NULL;
-	}
-	return result;
-}
-
-
 /*
  *	Insert a packet on a list.
  */
@@ -803,8 +774,22 @@ static inline void __skb_unlink(struct s
 	prev->next = next;
 }
 
-
-/* XXX: more streamlined implementation */
+/**
+ *	__skb_dequeue - remove from the head of the queue
+ *	@list: list to dequeue from
+ *
+ *	Remove the head of the list. This function does not take any locks
+ *	so must be used with appropriate locks held only. The head item is
+ *	returned or %NULL if the list is empty.
+ */
+extern struct sk_buff *skb_dequeue(struct sk_buff_head *list);
+static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
+{
+	struct sk_buff *skb = skb_peek(list);
+	if (skb)
+		__skb_unlink(skb, list);
+	return skb;
+}
 
 /**
  *	__skb_dequeue_tail - remove from the tail of the queue

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002--NET-__skb_queue_after-prev-__skb_insert-prev.patch"

>From dc9fd09e90df840e1ab450187fe0a7573bf6188f Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Apr 2008 10:27:59 +0100
Subject: [PATCH 2/4] [SKB]: __skb_queue_after(prev) = __skb_insert(prev, prev->next)

By reordering, __skb_queue_after() is expressed in terms of __skb_insert().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   34 ++++++++++++----------------------
 1 file changed, 12 insertions(+), 22 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -663,11 +663,21 @@ static inline void skb_queue_head_init_c
 }
 
 /*
- *	Insert an sk_buff at the start of a list.
+ *	Insert an sk_buff on a list.
  *
  *	The "__skb_xxxx()" functions are the non-atomic ones that
  *	can only be called with interrupts disabled.
  */
+extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
+static inline void __skb_insert(struct sk_buff *newsk,
+				struct sk_buff *prev, struct sk_buff *next,
+				struct sk_buff_head *list)
+{
+	newsk->next = next;
+	newsk->prev = prev;
+	next->prev  = prev->next = newsk;
+	list->qlen++;
+}
 
 /**
  *	__skb_queue_after - queue a buffer at the list head
@@ -684,13 +694,7 @@ static inline void __skb_queue_after(str
 				     struct sk_buff *prev,
 				     struct sk_buff *newsk)
 {
-	struct sk_buff *next;
-	list->qlen++;
-
-	next = prev->next;
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
+	__skb_insert(newsk, prev, prev->next, list);
 }
 
 /**
@@ -735,20 +739,6 @@ static inline void __skb_queue_tail(stru
 }
 
 /*
- *	Insert a packet on a list.
- */
-extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
-static inline void __skb_insert(struct sk_buff *newsk,
-				struct sk_buff *prev, struct sk_buff *next,
-				struct sk_buff_head *list)
-{
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
-	list->qlen++;
-}
-
-/*
  *	Place a packet after a given packet in a list.
  */
 extern void	   skb_append(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0003--SKB-__skb_append-__skb_queue_after-with-differe.patch"

>From a5e0843f5230166e19f8a8a00668ebaf49d265bb Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Apr 2008 10:35:55 +0100
Subject: [PATCH 3/4] [SKB]: __skb_append = __skb_queue_after 

This expresses __skb_append in terms of __skb_queue_after, exploiting that

  __skb_append(old, new, list) = __skb_queue_after(list, old, new).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   12 +++---------
 include/net/tcp.h      |    2 +-
 net/core/skbuff.c      |    2 +-
 net/ipv4/tcp_input.c   |    2 +-
 4 files changed, 6 insertions(+), 12 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -697,6 +697,9 @@ static inline void __skb_queue_after(str
 	__skb_insert(newsk, prev, prev->next, list);
 }
 
+extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
+		       struct sk_buff_head *list);
+
 /**
  *	__skb_queue_head - queue a buffer at the list head
  *	@list: list to use
@@ -739,15 +742,6 @@ static inline void __skb_queue_tail(stru
 }
 
 /*
- *	Place a packet after a given packet in a list.
- */
-extern void	   skb_append(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
-static inline void __skb_append(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list)
-{
-	__skb_insert(newsk, old, old->next, list);
-}
-
-/*
  * remove sk_buff from list. _Must_ be called atomically, and with
  * the list known..
  */
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1860,7 +1860,7 @@ void skb_append(struct sk_buff *old, str
 	unsigned long flags;
 
 	spin_lock_irqsave(&list->lock, flags);
-	__skb_append(old, newsk, list);
+	__skb_queue_after(list, old, newsk);
 	spin_unlock_irqrestore(&list->lock, flags);
 }
 
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1247,7 +1247,7 @@ static inline void tcp_insert_write_queu
 						struct sk_buff *buff,
 						struct sock *sk)
 {
-	__skb_append(skb, buff, &sk->sk_write_queue);
+	__skb_queue_after(&sk->sk_write_queue, skb, buff);
 }
 
 /* Insert skb between prev and next on the write queue of sk.  */
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3968,7 +3968,7 @@ drop:
 		u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
 		if (seq == TCP_SKB_CB(skb1)->end_seq) {
-			__skb_append(skb1, skb, &tp->out_of_order_queue);
+			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 
 			if (!tp->rx_opt.num_sacks ||
 			    tp->selective_acks[0].end_seq != seq)

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0004--SKB-__skb_queue_tail-__skb_insert-before.patch"

>From 37003619fde1a199353305ea758cf6ca836707bc Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Apr 2008 10:51:39 +0100
Subject: [PATCH 4/4] [SKB]: __skb_queue_tail = __skb_insert before

This expresses __skb_queue_tail() in terms of __skb_insert(),
using __skb_insert_before() as auxiliary function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -700,6 +700,13 @@ static inline void __skb_queue_after(str
 extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
 		       struct sk_buff_head *list);
 
+static inline void __skb_queue_before(struct sk_buff_head *list,
+				      struct sk_buff *next,
+				      struct sk_buff *newsk)
+{
+	__skb_insert(newsk, next->prev, next, list);
+}
+
 /**
  *	__skb_queue_head - queue a buffer at the list head
  *	@list: list to use
@@ -731,14 +738,7 @@ extern void skb_queue_tail(struct sk_buf
 static inline void __skb_queue_tail(struct sk_buff_head *list,
 				   struct sk_buff *newsk)
 {
-	struct sk_buff *prev, *next;
-
-	list->qlen++;
-	next = (struct sk_buff *)list;
-	prev = next->prev;
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
+	__skb_queue_before(list, (struct sk_buff *)list, newsk);
 }
 
 /*

--xHFwDpU9dbj6ez1V--

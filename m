From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/4] [SKB]: __skb_dequeue = skb_peek + __skb_unlink
Date: Mon, 14 Apr 2008 07:11:07 +0100
Message-ID: <1208153470-9847-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <skbuff_h_small_patchset>
 <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753876AbYDNGLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 02:11:22 -0400
In-Reply-To: <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
@@ -728,35 +728,6 @@ static inline void __skb_queue_tail(stru
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
@@ -797,8 +768,22 @@ static inline void __skb_unlink(struct s
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


The University of Aberdeen is a charity registered in Scotland, No SC013683.


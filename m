From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/4] [SKB]: __skb_queue_after(prev) = __skb_insert(prev, prev->next)
Date: Mon, 14 Apr 2008 07:11:08 +0100
Message-ID: <1208153470-9847-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <skbuff_h_small_patchset>
 <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753864AbYDNGLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 02:11:21 -0400
In-Reply-To: <1208153470-9847-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By reordering, __skb_queue_after() is expressed in terms of __skb_insert().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   34 ++++++++++++----------------------
 1 file changed, 12 insertions(+), 22 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -657,11 +657,21 @@ static inline void skb_queue_head_init_c
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
@@ -678,13 +688,7 @@ static inline void __skb_queue_after(str
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
@@ -729,20 +733,6 @@ static inline void __skb_queue_tail(stru
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


The University of Aberdeen is a charity registered in Scotland, No SC013683.


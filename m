From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/4] [SKB]: __skb_append = __skb_queue_after
Date: Mon, 14 Apr 2008 07:11:09 +0100
Message-ID: <1208153470-9847-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <skbuff_h_small_patchset>
 <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754030AbYDNGLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 02:11:24 -0400
In-Reply-To: <1208153470-9847-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
@@ -691,6 +691,9 @@ static inline void __skb_queue_after(str
 	__skb_insert(newsk, prev, prev->next, list);
 }
 
+extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
+		       struct sk_buff_head *list);
+
 /**
  *	__skb_queue_head - queue a buffer at the list head
  *	@list: list to use
@@ -733,15 +736,6 @@ static inline void __skb_queue_tail(stru
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
@@ -1766,7 +1766,7 @@ void skb_append(struct sk_buff *old, str
 	unsigned long flags;
 
 	spin_lock_irqsave(&list->lock, flags);
-	__skb_append(old, newsk, list);
+	__skb_queue_after(list, old, newsk);
 	spin_unlock_irqrestore(&list->lock, flags);
 }
 
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1237,7 +1237,7 @@ static inline void tcp_insert_write_queu
 						struct sk_buff *buff,
 						struct sock *sk)
 {
-	__skb_append(skb, buff, &sk->sk_write_queue);
+	__skb_queue_after(&sk->sk_write_queue, skb, buff);
 }
 
 /* Insert skb between prev and next on the write queue of sk.  */
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3999,7 +3999,7 @@ drop:
 		u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
 		if (seq == TCP_SKB_CB(skb1)->end_seq) {
-			__skb_append(skb1, skb, &tp->out_of_order_queue);
+			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 
 			if (!tp->rx_opt.num_sacks ||
 			    tp->selective_acks[0].end_seq != seq)


The University of Aberdeen is a charity registered in Scotland, No SC013683.


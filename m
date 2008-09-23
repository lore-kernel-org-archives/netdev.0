From: David Miller <davem@davemloft.net>
Subject: [PATCH]: tcp: Use SKB queue handling interfaces instead of by-hand
 versions.
Date: Tue, 23 Sep 2008 01:07:07 -0700 (PDT)
Message-ID: <20080923.010707.209241926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751573AbYIWIHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:07:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 50AC8C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:07:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp: Use SKB queue handling interfaces instead of by-hand versions.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |   40 +++++++++++++++-------------------------
 1 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c5327e..12c9b4f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1181,49 +1181,45 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 
 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_write_queue.next;
-	if (skb == (struct sk_buff *) &sk->sk_write_queue)
-		return NULL;
-	return skb;
+	return skb_peek(&sk->sk_write_queue);
 }
 
 static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_write_queue.prev;
-	if (skb == (struct sk_buff *) &sk->sk_write_queue)
-		return NULL;
-	return skb;
+	return skb_peek_tail(&sk->sk_write_queue);
 }
 
 static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_buff *skb)
 {
-	return skb->next;
+	return skb_queue_next(&sk->sk_write_queue, skb);
 }
 
 #define tcp_for_write_queue(skb, sk)					\
-		for (skb = (sk)->sk_write_queue.next;			\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
+	skb_queue_walk(&(sk)->sk_write_queue, skb)
 
 #define tcp_for_write_queue_from(skb, sk)				\
-		for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
-		     skb = skb->next)
+	skb_queue_walk_from(&(sk)->sk_write_queue, skb)
 
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
-		for (tmp = skb->next;					\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = tmp, tmp = skb->next)
+	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
 }
 
+static inline bool tcp_skb_is_last(const struct sock *sk,
+				   const struct sk_buff *skb)
+{
+	return skb_queue_is_last(&sk->sk_write_queue, skb);
+}
+
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
-	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
+	if (tcp_skb_is_last(sk, skb))
 		sk->sk_send_head = NULL;
+	else
+		sk->sk_send_head = tcp_write_queue_next(sk, skb);
 }
 
 static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
@@ -1284,12 +1280,6 @@ static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
-static inline bool tcp_skb_is_last(const struct sock *sk,
-				   const struct sk_buff *skb)
-{
-	return skb_queue_is_last(&sk->sk_write_queue, skb);
-}
-
 static inline int tcp_write_queue_empty(struct sock *sk)
 {
 	return skb_queue_empty(&sk->sk_write_queue);
-- 
1.5.6.5


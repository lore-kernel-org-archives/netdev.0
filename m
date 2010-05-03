From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] unix/garbage: kill copy of the skb queue walker
Date: Mon, 3 May 2010 16:22:18 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005031620130.7041@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1659868478-1272892939=:7041"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45049 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758658Ab0ECNWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 09:22:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1659868478-1272892939=:7041
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

Worse yet, it seems that its arguments were in reverse order. Also
remove one related helper which seems hardly worth keeping.

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/unix/garbage.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 14c22c3..c8df6fd 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -153,15 +153,6 @@ void unix_notinflight(struct file *fp)
 	}
 }
 
-static inline struct sk_buff *sock_queue_head(struct sock *sk)
-{
-	return (struct sk_buff *)&sk->sk_receive_queue;
-}
-
-#define receive_queue_for_each_skb(sk, next, skb) \
-	for (skb = sock_queue_head(sk)->next, next = skb->next; \
-	     skb != sock_queue_head(sk); skb = next, next = skb->next)
-
 static void scan_inflight(struct sock *x, void (*func)(struct unix_sock *),
 			  struct sk_buff_head *hitlist)
 {
@@ -169,7 +160,7 @@ static void scan_inflight(struct sock *x, void (*func)(struct unix_sock *),
 	struct sk_buff *next;
 
 	spin_lock(&x->sk_receive_queue.lock);
-	receive_queue_for_each_skb(x, next, skb) {
+	skb_queue_walk_safe(&x->sk_receive_queue, skb, next) {
 		/*
 		 *	Do we have file descriptors ?
 		 */
@@ -225,7 +216,7 @@ static void scan_children(struct sock *x, void (*func)(struct unix_sock *),
 		 * and perform a scan on them as well.
 		 */
 		spin_lock(&x->sk_receive_queue.lock);
-		receive_queue_for_each_skb(x, next, skb) {
+		skb_queue_walk_safe(&x->sk_receive_queue, skb, next) {
 			u = unix_sk(skb->sk);
 
 			/*
-- 
1.5.6.3

--8323329-1659868478-1272892939=:7041--

From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/3][UNIX] Convert socks to unix_socks in scan_inflight, not
 in callbacks
Date: Wed, 07 Nov 2007 16:56:21 +0300
Message-ID: <4731C405.6010203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58027 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754932AbXKGN4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 08:56:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The scan_inflight() routine scans through the unix sockets and calls
some passed callback. The fact is that all these callbacks work with
the unix_sock objects, not the sock ones, so make this conversion in
the scan_inflight() before calling the callbacks.

This removes one unneeded variable from the inc_inflight_move_tail().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 399717e..ebdff3d 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -161,7 +161,7 @@ static inline struct sk_buff *sock_queue_head(struct sock *sk)
 	for (skb = sock_queue_head(sk)->next, next = skb->next; \
 	     skb != sock_queue_head(sk); skb = next, next = skb->next)
 
-static void scan_inflight(struct sock *x, void (*func)(struct sock *),
+static void scan_inflight(struct sock *x, void (*func)(struct unix_sock *),
 			  struct sk_buff_head *hitlist)
 {
 	struct sk_buff *skb;
@@ -185,9 +185,9 @@ static void scan_inflight(struct sock *x, void (*func)(struct sock *),
 				 *	if it indeed does so
 				 */
 				struct sock *sk = unix_get_socket(*fp++);
-				if(sk) {
+				if (sk) {
 					hit = true;
-					func(sk);
+					func(unix_sk(sk));
 				}
 			}
 			if (hit && hitlist != NULL) {
@@ -199,7 +199,7 @@ static void scan_inflight(struct sock *x, void (*func)(struct sock *),
 	spin_unlock(&x->sk_receive_queue.lock);
 }
 
-static void scan_children(struct sock *x, void (*func)(struct sock *),
+static void scan_children(struct sock *x, void (*func)(struct unix_sock *),
 			  struct sk_buff_head *hitlist)
 {
 	if (x->sk_state != TCP_LISTEN)
@@ -235,20 +235,18 @@ static void scan_children(struct sock *x, void (*func)(struct sock *),
 	}
 }
 
-static void dec_inflight(struct sock *sk)
+static void dec_inflight(struct unix_sock *usk)
 {
-	atomic_dec(&unix_sk(sk)->inflight);
+	atomic_dec(&usk->inflight);
 }
 
-static void inc_inflight(struct sock *sk)
+static void inc_inflight(struct unix_sock *usk)
 {
-	atomic_inc(&unix_sk(sk)->inflight);
+	atomic_inc(&usk->inflight);
 }
 
-static void inc_inflight_move_tail(struct sock *sk)
+static void inc_inflight_move_tail(struct unix_sock *u)
 {
-	struct unix_sock *u = unix_sk(sk);
-
 	atomic_inc(&u->inflight);
 	/*
 	 * If this is still a candidate, move it to the end of the
-- 
1.5.3.4


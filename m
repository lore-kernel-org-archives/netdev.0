From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 5/6] l2tp: close sessions in ip socket destroy callback
Date: Fri, 15 Feb 2013 10:25:18 +0000
Message-ID: <1360923919-7203-6-git-send-email-tparkin@katalix.com>
References: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34092 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161232Ab3BOKZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:25:36 -0500
In-Reply-To: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_core hooks UDP's .destroy handler to gain advance warning of a tunnel
socket being closed from userspace.  We need to do the same thing for
IP-encapsualtion sockets.

---
 net/l2tp/l2tp_ip.c  |    6 ++++++
 net/l2tp/l2tp_ip6.c |    7 +++++++
 2 files changed, 13 insertions(+)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index f7ac8f4..338262d 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -229,10 +229,16 @@ static void l2tp_ip_close(struct sock *sk, long timeout)
 static void l2tp_ip_destroy_sock(struct sock *sk)
 {
 	struct sk_buff *skb;
+	struct l2tp_tunnel *tunnel = l2tp_sock_to_tunnel(sk);
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
 		kfree_skb(skb);
 
+	if (tunnel) {
+		l2tp_tunnel_closeall(tunnel);
+		sock_put(sk);
+	}
+
 	sk_refcnt_debug_dec(sk);
 }
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 8ee4a86..b745a40 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -242,10 +242,17 @@ static void l2tp_ip6_close(struct sock *sk, long timeout)
 
 static void l2tp_ip6_destroy_sock(struct sock *sk)
 {
+	struct l2tp_tunnel *tunnel = l2tp_sock_to_tunnel(sk);
+
 	lock_sock(sk);
 	ip6_flush_pending_frames(sk);
 	release_sock(sk);
 
+	if (tunnel) {
+		l2tp_tunnel_closeall(tunnel);
+		sock_put(sk);
+	}
+
 	inet6_destroy_sock(sk);
 }
 
-- 
1.7.9.5

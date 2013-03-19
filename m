From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 04/12] l2tp: close sessions in ip socket destroy callback
Date: Tue, 19 Mar 2013 16:11:15 +0000
Message-ID: <1363709483-24021-5-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36144 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932764Ab3CSQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:30 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_core hooks UDP's .destroy handler to gain advance warning of a tunnel
socket being closed from userspace.  We need to do the same thing for
IP-encapsulation sockets.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c  |    6 ++++++
 net/l2tp/l2tp_ip6.c |    7 +++++++
 2 files changed, 13 insertions(+)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 7f41b70..571db8d 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -228,10 +228,16 @@ static void l2tp_ip_close(struct sock *sk, long timeout)
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
index 41f2f81..c74f5a9 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -241,10 +241,17 @@ static void l2tp_ip6_close(struct sock *sk, long timeout)
 
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

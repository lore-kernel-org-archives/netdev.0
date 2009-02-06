From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Fri, 6 Feb 2009 22:51:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902062247500.31842@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1185510479-1233953477=:31842"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54323 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbZBFUvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 15:51:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1185510479-1233953477=:31842
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


$ diff-funcs xs_udp_write_space net/sunrpc/xprtsock.c
net/sunrpc/xprtsock.c xs_tcp_write_space
 --- net/sunrpc/xprtsock.c:xs_udp_write_space()
 +++ net/sunrpc/xprtsock.c:xs_tcp_write_space()
@@ -1,4 +1,4 @@
- * xs_udp_write_space - callback invoked when socket buffer space
+ * xs_tcp_write_space - callback invoked when socket buffer space
  *                             becomes available
  * @sk: socket whose state has changed
  *
@@ -7,12 +7,12 @@
  * progress, otherwise we'll waste resources thrashing kernel_sendmsg
  * with a bunch of small requests.
  */
-static void xs_udp_write_space(struct sock *sk)
+static void xs_tcp_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);

-	/* from net/core/sock.c:sock_def_write_space */
-	if (sock_writeable(sk)) {
+	/* from net/core/stream.c:sk_stream_write_space */
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
 		struct socket *sock;
 		struct rpc_xprt *xprt;


$ codiff net/sunrpc/xprtsock.o net/sunrpc/xprtsock.o.new
net/sunrpc/xprtsock.c:
  xs_tcp_write_space | -163
  xs_udp_write_space | -163
 2 functions changed, 326 bytes removed

net/sunrpc/xprtsock.c:
  xs_write_space | +179
 1 function changed, 179 bytes added

net/sunrpc/xprtsock.o.new:
 3 functions changed, 179 bytes added, 326 bytes removed, diff: -147

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/sunrpc/xprtsock.c |   53 +++++++++++++++++++-----------------------------
 1 files changed, 21 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5cbb404..b49e434 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1215,6 +1215,23 @@ out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
+static void xs_write_space(struct sock *sk)
+{
+	struct socket *sock;
+	struct rpc_xprt *xprt;
+
+	if (unlikely(!(sock = sk->sk_socket)))
+		return;
+	clear_bit(SOCK_NOSPACE, &sock->flags);
+
+	if (unlikely(!(xprt = xprt_from_sock(sk))))
+		return;
+	if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
+		return;
+
+	xprt_write_space(xprt);
+}
+
 /**
  * xs_udp_write_space - callback invoked when socket buffer space
  *                             becomes available
@@ -1230,23 +1247,9 @@ static void xs_udp_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 
 	/* from net/core/sock.c:sock_def_write_space */
-	if (sock_writeable(sk)) {
-		struct socket *sock;
-		struct rpc_xprt *xprt;
-
-		if (unlikely(!(sock = sk->sk_socket)))
-			goto out;
-		clear_bit(SOCK_NOSPACE, &sock->flags);
-
-		if (unlikely(!(xprt = xprt_from_sock(sk))))
-			goto out;
-		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
-			goto out;
-
-		xprt_write_space(xprt);
-	}
+	if (sock_writeable(sk))
+		xs_write_space(sk);
 
- out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
@@ -1265,23 +1268,9 @@ static void xs_tcp_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 
 	/* from net/core/stream.c:sk_stream_write_space */
-	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
-		struct socket *sock;
-		struct rpc_xprt *xprt;
-
-		if (unlikely(!(sock = sk->sk_socket)))
-			goto out;
-		clear_bit(SOCK_NOSPACE, &sock->flags);
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+		xs_write_space(sk);
 
-		if (unlikely(!(xprt = xprt_from_sock(sk))))
-			goto out;
-		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
-			goto out;
-
-		xprt_write_space(xprt);
-	}
-
- out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
-- 
1.5.6.5

---696208474-1185510479-1233953477=:31842--

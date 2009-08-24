From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 1/3] Set socket flags on restore using sock_setsockopt() where possible (v2)
Date: Mon, 24 Aug 2009 10:28:02 -0700
Message-ID: <1251134884-24491-2-git-send-email-danms@us.ibm.com>
References: <1251134884-24491-1-git-send-email-danms@us.ibm.com>
Cc: orenl@librato.com, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:44149 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752956AbZHXRZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:25:09 -0400
In-Reply-To: <1251134884-24491-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fail on the TIMESTAMPING_* flags for the moment, with a TODO in place to
handle them later.

Also remove other explicit flag checks because they're no longer copied
blindly into the socket object, so existing checks will be sufficient.

Changes in v2:
 - Avoid removing the sock->sk_socket check before sync'ing the socket.flags
 - Rename sock_rst_flags() to sock_restore_flags()
 - Rebase on top of Oren's cleanup patch

Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 net/checkpoint.c |  113 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 102 insertions(+), 11 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index c64483e..fdbf8e7 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -178,10 +178,6 @@ static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
 	if (!ckpt_validate_errno(h->sock.err))
 		return -EINVAL;
 
-	/* None of our supported types use this flag */
-	if (h->sock.flags & SOCK_DESTROY)
-		return -EINVAL;
-
 	return 0;
 }
 
@@ -238,11 +234,97 @@ static int sock_cptrst_bufopts(int op, struct sock *sk,
 	return 0;
 }
 
+static int sock_restore_flags(struct socket *sock,
+                             struct ckpt_hdr_socket *h)
+{
+       int ret;
+       int v = 1;
+       unsigned long sk_flags = h->sock.flags;
+       unsigned long sock_flags = h->socket.flags;
+
+       if (test_and_clear_bit(SOCK_URGINLINE, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_OOBINLINE,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_KEEPOPEN, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_BROADCAST, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_BROADCAST,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_RCVTSTAMP, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_RCVTSTAMPNS, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_DBG, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_DEBUG,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_LOCALROUTE, &sk_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_DONTROUTE,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       if (test_and_clear_bit(SOCK_PASSCRED, &sock_flags)) {
+               ret = sock_setsockopt(sock, SOL_SOCKET, SO_PASSCRED,
+                                     (char *)&v, sizeof(v));
+               if (ret)
+                       return ret;
+       }
+
+       /* TODO: Handle SOCK_TIMESTAMPING_* flags */
+       if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
+           test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
+               ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
+               return -ENOSYS;
+       }
+
+       /* Anything that is still set in the flags that isn't part of
+        * our protocol's default set, indicates an error
+        */
+       if (sk_flags & ~sock->sk->sk_flags) {
+               ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
+               return -EINVAL;
+       }
+
+       return 0;
+}
+
 static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 		       struct ckpt_hdr_socket *h, int op)
 {
 	if (sk->sk_socket) {
-		CKPT_COPY(op, h->socket.flags, sk->sk_socket->flags);
 		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
 	}
 
@@ -259,12 +341,6 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 	CKPT_COPY(op, h->sock.state, sk->sk_state);
 	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
 
-	/* TODO:
-	 * Break out setting each of the flags to use setsockopt() or
-	 * perform proper security check
-	 */
-	CKPT_COPY(op, h->sock.flags, sk->sk_flags);
-
 	if (sock_cptrst_bufopts(op, sk, h))
 		return -EINVAL;
 
@@ -298,6 +374,21 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 		return -EINVAL;
 	}
 
+	if (op == CKPT_CPT) {
+		h->sock.flags = sk->sk_flags;
+		h->socket.flags = sk->sk_socket->flags;
+	} else {
+		int ret;
+		mm_segment_t old_fs;
+
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = sock_restore_flags(sk->sk_socket, h);
+		set_fs(old_fs);
+		if (ret)
+			return ret;
+	}
+
 	if ((h->socket.state == SS_CONNECTED) &&
 	    (h->sock.state != TCP_ESTABLISHED)) {
 		ckpt_debug("socket/sock in inconsistent state: %i/%i",
-- 
1.6.2.5


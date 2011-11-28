From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: optimize socket timestamping
Date: Mon, 28 Nov 2011 23:04:18 +0100
Message-ID: <1322517858.2970.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53094 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1K1WEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 17:04:22 -0500
Received: by eaak14 with SMTP id k14so2293859eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 14:04:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can test/set multiple bits from sk_flags at once, to shorten a bit
socket setup/dismantle phase.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c |   27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 1606913..9777da86 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -276,14 +276,14 @@ static void sock_warn_obsolete_bsdism(const char *name)
 	}
 }
 
-static void sock_disable_timestamp(struct sock *sk, int flag)
+#define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
+
+static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
 {
-	if (sock_flag(sk, flag)) {
-		sock_reset_flag(sk, flag);
-		if (!sock_flag(sk, SOCK_TIMESTAMP) &&
-		    !sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE)) {
+	if (sk->sk_flags & flags) {
+		sk->sk_flags &= ~flags;
+		if (!(sk->sk_flags & SK_FLAGS_TIMESTAMP))
 			net_disable_timestamp();
-		}
 	}
 }
 
@@ -689,7 +689,7 @@ set_rcvbuf:
 					      SOCK_TIMESTAMPING_RX_SOFTWARE);
 		else
 			sock_disable_timestamp(sk,
-					       SOCK_TIMESTAMPING_RX_SOFTWARE);
+					       (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SOFTWARE,
 				  val & SOF_TIMESTAMPING_SOFTWARE);
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE,
@@ -1187,8 +1187,7 @@ static void __sk_free(struct sock *sk)
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 	}
 
-	sock_disable_timestamp(sk, SOCK_TIMESTAMP);
-	sock_disable_timestamp(sk, SOCK_TIMESTAMPING_RX_SOFTWARE);
+	sock_disable_timestamp(sk, SK_FLAGS_TIMESTAMP);
 
 	if (atomic_read(&sk->sk_omem_alloc))
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
@@ -1326,8 +1325,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		if (newsk->sk_prot->sockets_allocated)
 			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
 
-		if (sock_flag(newsk, SOCK_TIMESTAMP) ||
-		    sock_flag(newsk, SOCK_TIMESTAMPING_RX_SOFTWARE))
+		if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
 	}
 out:
@@ -2165,16 +2163,15 @@ EXPORT_SYMBOL(sock_get_timestampns);
 void sock_enable_timestamp(struct sock *sk, int flag)
 {
 	if (!sock_flag(sk, flag)) {
+		unsigned long previous_flags = sk->sk_flags;
+
 		sock_set_flag(sk, flag);
 		/*
 		 * we just set one of the two flags which require net
 		 * time stamping, but time stamping might have been on
 		 * already because of the other one
 		 */
-		if (!sock_flag(sk,
-				flag == SOCK_TIMESTAMP ?
-				SOCK_TIMESTAMPING_RX_SOFTWARE :
-				SOCK_TIMESTAMP))
+		if (!(previous_flags & SK_FLAGS_TIMESTAMP))
 			net_enable_timestamp();
 	}
 }

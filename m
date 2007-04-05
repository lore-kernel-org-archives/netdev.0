From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Uninline tcp_done
Date: Thu, 5 Apr 2007 12:44:03 +0200
Message-ID: <200704051244.03511.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:41164 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966079AbXDEKoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 06:44:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The function is quite big and has several call sites and nothing
to collapse by compiler optimization on inlining.

Besides it's nicer to read in a in .c file.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.21-rc3-net/include/net/tcp.h
===================================================================
--- linux-2.6.21-rc3-net.orig/include/net/tcp.h
+++ linux-2.6.21-rc3-net/include/net/tcp.h
@@ -918,21 +918,7 @@ static inline void tcp_set_state(struct 
 #endif	
 }
 
-static inline void tcp_done(struct sock *sk)
-{
-	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
-		TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
-
-	tcp_set_state(sk, TCP_CLOSE);
-	tcp_clear_xmit_timers(sk);
-
-	sk->sk_shutdown = SHUTDOWN_MASK;
-
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_state_change(sk);
-	else
-		inet_csk_destroy_sock(sk);
-}
+extern void tcp_done(struct sock *sk);
 
 static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 {
Index: linux-2.6.21-rc3-net/net/ipv4/tcp.c
===================================================================
--- linux-2.6.21-rc3-net.orig/net/ipv4/tcp.c
+++ linux-2.6.21-rc3-net/net/ipv4/tcp.c
@@ -2372,6 +2372,23 @@ void __tcp_put_md5sig_pool(void)
 EXPORT_SYMBOL(__tcp_put_md5sig_pool);
 #endif
 
+void tcp_done(struct sock *sk)
+{
+	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
+		TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
+
+	tcp_set_state(sk, TCP_CLOSE);
+	tcp_clear_xmit_timers(sk);
+
+	sk->sk_shutdown = SHUTDOWN_MASK;
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_state_change(sk);
+	else
+		inet_csk_destroy_sock(sk);
+}
+EXPORT_SYMBOL_GPL(tcp_done);
+
 extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
 

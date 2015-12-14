From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v5 4/4] net: diag: Support destroying TCP sockets.
Date: Tue, 15 Dec 2015 02:29:57 +0900
Message-ID: <1450114197-73779-5-git-send-email-lorenzo@google.com>
References: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
 <1450114197-73779-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36050 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbbLNRae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:30:34 -0500
Received: by pfbu66 with SMTP id u66so64341190pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 09:30:34 -0800 (PST)
In-Reply-To: <1450114197-73779-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements SOCK_DESTROY for TCP sockets. It causes all
blocking calls on the socket to fail fast with ECONNABORTED and
causes a protocol close of the socket. It informs the other end
of the connection by sending a RST, i.e., initiating a TCP ABORT
as per RFC 793. ECONNABORTED was chosen for consistency with
FreeBSD.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/tcp.h   |  4 ++++
 net/ipv4/Kconfig    | 13 +++++++++++++
 net/ipv4/tcp.c      | 34 ++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_diag.c | 19 +++++++++++++++++++
 net/ipv4/tcp_ipv4.c |  3 +++
 net/ipv6/tcp_ipv6.c |  3 +++
 6 files changed, 76 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f80e74c..505cef5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1170,6 +1170,10 @@ void tcp_set_state(struct sock *sk, int state);
 
 void tcp_done(struct sock *sk);
 
+#if CONFIG_INET_DIAG_DESTROY
+int tcp_abort(struct sock *sk);
+#endif
+
 static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 {
 	rx_opt->dsack = 0;
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 416dfa0..31c4496 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -436,6 +436,19 @@ config INET_UDP_DIAG
 	  Support for UDP socket monitoring interface used by the ss tool.
 	  If unsure, say Y.
 
+config INET_DIAG_DESTROY
+	bool "INET: allow privileged process to administratively close sockets"
+	depends on INET_DIAG && (IPV6 || IPV6=n)
+	default n
+	---help---
+	  Provides a SOCK_DESTROY operation that allows privileged processes
+	  (e.g., a connection manager or a network administration tool such as
+	  ss) to close sockets opened by other processes. Closing a socket in
+	  this way interrupts any blocking read/writes/connect operations on
+	  the socket and causes future socket calls to behave as if the socket
+	  had been disconnected.
+	  If unsure, say N.
+
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c82cca1..fc5068d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3080,6 +3080,40 @@ void tcp_done(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_done);
 
+#ifdef CONFIG_INET_DIAG_DESTROY
+int tcp_abort(struct sock *sk)
+{
+	if (!sk_fullsock(sk)) {
+		sock_gen_put(sk);
+		return -EOPNOTSUPP;
+	}
+
+	/* Don't race with userspace socket closes such as tcp_close. */
+	lock_sock(sk);
+
+	/* Don't race with BH socket closes such as inet_csk_listen_stop. */
+	local_bh_disable();
+	bh_lock_sock(sk);
+
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		sk->sk_err = ECONNABORTED;
+		/* This barrier is coupled with smp_rmb() in tcp_poll() */
+		smp_wmb();
+		sk->sk_error_report(sk);
+		if (tcp_need_reset(sk->sk_state))
+			tcp_send_active_reset(sk, GFP_ATOMIC);
+		tcp_done(sk);
+	}
+
+	bh_unlock_sock(sk);
+	local_bh_enable();
+	release_sock(sk);
+	sock_put(sk);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tcp_abort);
+#endif
+
 extern struct tcp_congestion_ops tcp_reno;
 
 static __initdata unsigned long thash_entries;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index b316040..8d435f17 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -10,6 +10,8 @@
  */
 
 #include <linux/module.h>
+#include <linux/net.h>
+#include <linux/sock_diag.h>
 #include <linux/inet_diag.h>
 
 #include <linux/tcp.h>
@@ -46,12 +48,29 @@ static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
 
+#ifdef CONFIG_INET_DIAG_DESTROY
+static int tcp_diag_destroy(struct sk_buff *in_skb,
+			    const struct inet_diag_req_v2 *req)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct sock *sk = inet_diag_find_one_icsk(net, &tcp_hashinfo, req);
+
+	if (IS_ERR(sk))
+		return PTR_ERR(sk);
+
+	return sock_diag_destroy(sk);
+}
+#endif
+
 static const struct inet_diag_handler tcp_diag_handler = {
 	.dump		 = tcp_diag_dump,
 	.dump_one	 = tcp_diag_dump_one,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.destroy	 = tcp_diag_destroy,
+#endif
 };
 
 static int __init tcp_diag_init(void)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index db00343..5e28bf1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2342,6 +2342,9 @@ struct proto tcp_prot = {
 	.destroy_cgroup		= tcp_destroy_cgroup,
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.diag_destroy		= tcp_abort,
+#endif
 };
 EXPORT_SYMBOL(tcp_prot);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c16e3fb..289c5db 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1890,6 +1890,9 @@ struct proto tcpv6_prot = {
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
 	.clear_sk		= tcp_v6_clear_sk,
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.diag_destroy		= tcp_abort,
+#endif
 };
 
 static const struct inet6_protocol tcpv6_protocol = {
-- 
2.6.0.rc2.230.g3dd15c0

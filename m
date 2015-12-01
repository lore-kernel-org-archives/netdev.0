From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v3 4/4] net: diag: Support destroying TCP sockets.
Date: Tue,  1 Dec 2015 11:32:27 +0900
Message-ID: <1448937147-38043-5-git-send-email-lorenzo@google.com>
References: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
 <1448937147-38043-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35750 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755689AbbLACcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 21:32:51 -0500
Received: by pacej9 with SMTP id ej9so204749807pac.2
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 18:32:51 -0800 (PST)
In-Reply-To: <1448937147-38043-1-git-send-email-lorenzo@google.com>
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
 net/ipv4/Kconfig    | 13 +++++++++++++
 net/ipv4/tcp_diag.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

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
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index b316040..31d3e0c 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/net.h>
 #include <linux/inet_diag.h>
 
 #include <linux/tcp.h>
@@ -46,12 +47,57 @@ static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
 
+#if IS_ENABLED(CONFIG_INET_DIAG_DESTROY)
+static int tcp_diag_destroy(struct sk_buff *in_skb,
+			    const struct inet_diag_req_v2 *req)
+{
+	struct sock *sk;
+	struct net *net = sock_net(in_skb->sk);
+
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+
+	sk = inet_diag_find_one_icsk(net, &tcp_hashinfo, req);
+	if (IS_ERR(sk))
+		return PTR_ERR(sk);
+
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
+		smp_wmb();  /* Be consistent with tcp_reset */
+		sk->sk_err = ECONNABORTED;
+		sk->sk_error_report(sk);
+		tcp_send_active_reset(sk, GFP_ATOMIC);
+		tcp_done(sk);
+	}
+
+	bh_unlock_sock(sk);
+	local_bh_enable();
+	release_sock(sk);
+	sock_put(sk);
+	return 0;
+}
+#endif
+
 static const struct inet_diag_handler tcp_diag_handler = {
 	.dump		 = tcp_diag_dump,
 	.dump_one	 = tcp_diag_dump_one,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
+#if IS_ENABLED(CONFIG_INET_DIAG_DESTROY)
+	.destroy	 = tcp_diag_destroy,
+#endif
 };
 
 static int __init tcp_diag_init(void)
-- 
2.6.0.rc2.230.g3dd15c0

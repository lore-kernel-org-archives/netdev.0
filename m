From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH 4/4] net: diag: Support destroying TCP sockets.
Date: Wed, 18 Nov 2015 10:43:44 +0900
Message-ID: <1447811024-8553-5-git-send-email-lorenzo@google.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35595 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687AbbKRBoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:44:23 -0500
Received: by pacej9 with SMTP id ej9so26804894pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:44:23 -0800 (PST)
In-Reply-To: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements SOCK_DESTROY for TCP sockets. It causes all
blocking calls on the socket to fail fast with ETIMEDOUT, which
is the same thing that would eventually happen if the socket was
left stuck on an IP address that the host no longer has.

Change-Id: Icce9db8b832e84c9b6477e5a901c927b942f2bb9
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/tcp_diag.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index b316040..867159c 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/net.h>
 #include <linux/inet_diag.h>
 
 #include <linux/tcp.h>
@@ -46,12 +47,52 @@ static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
 
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
+		sk->sk_err = ETIMEDOUT;
+		sk->sk_error_report(sk);
+		tcp_done(sk);
+	}
+
+	bh_unlock_sock(sk);
+	local_bh_enable();
+	release_sock(sk);
+	sock_put(sk);
+	return 0;
+}
+
 static const struct inet_diag_handler tcp_diag_handler = {
 	.dump		 = tcp_diag_dump,
 	.dump_one	 = tcp_diag_dump_one,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
+	.destroy	 = tcp_diag_destroy,
 };
 
 static int __init tcp_diag_init(void)
-- 
2.6.0.rc2.230.g3dd15c0

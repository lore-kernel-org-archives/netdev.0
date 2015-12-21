From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: tcp: deal with listen sockets properly in tcp_abort.
Date: Tue, 22 Dec 2015 00:03:44 +0900
Message-ID: <1450710224-91722-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, tom@herbertland.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34236 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbLUPD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 10:03:56 -0500
Received: by mail-pf0-f172.google.com with SMTP id u7so43520769pfb.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 07:03:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing a listen socket, tcp_abort currently calls
tcp_done without clearing the request queue. If the socket has a
child socket that is established but not yet accepted, the child
socket is then left without a parent, causing a leak.

Fix this by setting the socket state to TCP_CLOSE and calling
inet_csk_listen_stop with the socket lock held, like tcp_close
does.

Tested using net_test. With this patch, calling SOCK_DESTROY on a
listen socket that has an established but not yet accepted child
socket results in the parent and the child being closed, such
that they no longer appear in sock_diag dumps.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/tcp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cc7aaa5..7bb1b09 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3099,6 +3099,11 @@ int tcp_abort(struct sock *sk, int err)
 	/* Don't race with userspace socket closes such as tcp_close. */
 	lock_sock(sk);
 
+	if (sk->sk_state == TCP_LISTEN) {
+		tcp_set_state(sk, TCP_CLOSE);
+		inet_csk_listen_stop(sk);
+	}
+
 	/* Don't race with BH socket closes such as inet_csk_listen_stop. */
 	local_bh_disable();
 	bh_lock_sock(sk);
-- 
2.6.0.rc2.230.g3dd15c0

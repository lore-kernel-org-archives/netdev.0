From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: diag: add support for request sockets to
 tcp_abort()
Date: Thu, 17 Dec 2015 16:14:11 -0800
Message-ID: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35443 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbLRAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 19:14:13 -0500
Received: by mail-pa0-f50.google.com with SMTP id jx14so21609741pad.2
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 16:14:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Adding support for SYN_RECV request sockets to tcp_abort()
is quite easy after our tcp listener rewrite.

Note that we also need to better handle listeners, or we might
leak not yet accepted children, because of a missing
inet_csk_listen_stop() call.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/tcp.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2c0e340518d2..cc7aaa507abf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3083,6 +3083,15 @@ EXPORT_SYMBOL_GPL(tcp_done);
 int tcp_abort(struct sock *sk, int err)
 {
 	if (!sk_fullsock(sk)) {
+		if (sk->sk_state == TCP_NEW_SYN_RECV) {
+			struct request_sock *req = inet_reqsk(sk);
+
+			local_bh_disable();
+			inet_csk_reqsk_queue_drop_and_put(req->rsk_listener,
+							  req);
+			local_bh_enable();
+			return 0;
+		}
 		sock_gen_put(sk);
 		return -EOPNOTSUPP;
 	}

From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] tcp: fix potential double free issue for fastopen_req
Date: Wed,  1 Mar 2017 13:29:48 -0800
Message-ID: <20170301212948.96840-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36300 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753279AbdCBATX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 19:19:23 -0500
Received: by mail-pf0-f173.google.com with SMTP id x66so15885642pfb.3
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 16:19:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

tp->fastopen_req could potentially be double freed if a malicious
user does the following:
1. Enable TCP_FASTOPEN_CONNECT sockopt and do a connect() on the socket.
2. Call connect() with AF_UNSPEC to disconnect the socket.
3. Make this socket a listening socket by calling listen().
4. Accept incoming connections and generate child sockets. All child
   sockets will get a copy of the pointer of fastopen_req.
5. Call close() on all sockets. fastopen_req will get freed multiple
   times.

Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index da385ae997a3..cf4555581282 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1110,9 +1110,14 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	flags = (msg->msg_flags & MSG_DONTWAIT) ? O_NONBLOCK : 0;
 	err = __inet_stream_connect(sk->sk_socket, msg->msg_name,
 				    msg->msg_namelen, flags, 1);
-	inet->defer_connect = 0;
-	*copied = tp->fastopen_req->copied;
-	tcp_free_fastopen_req(tp);
+	/* fastopen_req could already be freed in __inet_stream_connect
+	 * if the connection times out or gets rst
+	 */
+	if (tp->fastopen_req) {
+		*copied = tp->fastopen_req->copied;
+		tcp_free_fastopen_req(tp);
+		inet->defer_connect = 0;
+	}
 	return err;
 }
 
@@ -2318,6 +2323,10 @@ int tcp_disconnect(struct sock *sk, int flags)
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
 
+	/* Clean up fastopen related fields */
+	tcp_free_fastopen_req(tp);
+	inet->defer_connect = 0;
+
 	WARN_ON(inet->inet_num && !icsk->icsk_bind_hash);
 
 	sk->sk_error_report(sk);
-- 
2.12.0.rc1.440.g5b76565f74-goog

From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 2/3] tcp: check repair before fastopen in tcp_sendmsg
Date: Fri, 21 Mar 2014 17:33:00 +0400
Message-ID: <1395408781-8145-3-git-send-email-avagin@openvz.org>
References: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23187 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760989AbaCUNdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 09:33:40 -0400
In-Reply-To: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all it is logical.

And I found that sk_stream_wait_connect can be called if a socket
isn't in the TCP_ESTABLISHED state. In this case we get -EPIPE.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 267adb7..4cd0e87 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1084,6 +1084,23 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	lock_sock(sk);
 
 	flags = msg->msg_flags;
+
+	if (unlikely(tp->repair)) {
+		err = -EINVAL;
+		if (tp->repair_queue == TCP_NO_QUEUE)
+			goto out_err;
+
+		if (sk->sk_state != TCP_ESTABLISHED)
+			goto out_err;
+
+		if (tp->repair_queue == TCP_RECV_QUEUE) {
+			copied = tcp_send_rcvq(sk, msg, size);
+			goto out;
+		}
+
+		/* 'common' sending to sendq */
+	}
+
 	if (flags & MSG_FASTOPEN) {
 		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
 		if (err == -EINPROGRESS && copied_syn > 0)
@@ -1105,22 +1122,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			goto do_error;
 	}
 
-	if (unlikely(tp->repair)) {
-		err = -EINVAL;
-		if (tp->repair_queue == TCP_NO_QUEUE)
-			goto out_err;
-
-		if (sk->sk_state != TCP_ESTABLISHED)
-			goto out_err;
-
-		if (tp->repair_queue == TCP_RECV_QUEUE) {
-			copied = tcp_send_rcvq(sk, msg, size);
-			goto out;
-		}
-
-		/* 'common' sending to sendq */
-	}
-
 	/* This should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
-- 
1.8.5.3

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net-tcp: fastopen: fix high order allocations
Date: Thu, 20 Feb 2014 10:09:18 -0800
Message-ID: <1392919758.2316.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59611 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbaBTSJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:09:21 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so2260610pad.0
        for <netdev@vger.kernel.org>; Thu, 20 Feb 2014 10:09:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch fixes two bugs in fastopen :

1) The tcp_sendmsg(...,  @size) argument was ignored.

   Code was relying on user not fooling the kernel with iovec mismatches

2) When MTU is about 64KB, tcp_send_syn_data() attempts order-5
allocations, which are likely to fail when memory gets fragmented.

Fixes: 783237e8daf13 ("net-tcp: Fast Open client - sending SYN-data")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |    3 ++-
 net/ipv4/tcp.c        |    8 +++++---
 net/ipv4/tcp_output.c |    7 ++++++-
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 56fc366da6d5..8c4dd63134d4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1303,7 +1303,8 @@ struct tcp_fastopen_request {
 	/* Fast Open cookie. Size 0 means a cookie request */
 	struct tcp_fastopen_cookie	cookie;
 	struct msghdr			*data;  /* data in MSG_FASTOPEN */
-	u16				copied;	/* queued in tcp_connect() */
+	size_t				size;
+	int				copied;	/* queued in tcp_connect() */
 };
 void tcp_free_fastopen_req(struct tcp_sock *tp);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9f3a2db9109e..97c8f5620c43 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1044,7 +1044,8 @@ void tcp_free_fastopen_req(struct tcp_sock *tp)
 	}
 }
 
-static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg, int *size)
+static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
+				int *copied, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int err, flags;
@@ -1059,11 +1060,12 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg, int *size)
 	if (unlikely(tp->fastopen_req == NULL))
 		return -ENOBUFS;
 	tp->fastopen_req->data = msg;
+	tp->fastopen_req->size = size;
 
 	flags = (msg->msg_flags & MSG_DONTWAIT) ? O_NONBLOCK : 0;
 	err = __inet_stream_connect(sk->sk_socket, msg->msg_name,
 				    msg->msg_namelen, flags);
-	*size = tp->fastopen_req->copied;
+	*copied = tp->fastopen_req->copied;
 	tcp_free_fastopen_req(tp);
 	return err;
 }
@@ -1083,7 +1085,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	flags = msg->msg_flags;
 	if (flags & MSG_FASTOPEN) {
-		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn);
+		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
 		if (err == -EINPROGRESS && copied_syn > 0)
 			goto out;
 		else if (err)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3be16727f058..09805817627b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2908,7 +2908,12 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	space = __tcp_mtu_to_mss(sk, inet_csk(sk)->icsk_pmtu_cookie) -
 		MAX_TCP_OPTION_SPACE;
 
-	syn_data = skb_copy_expand(syn, skb_headroom(syn), space,
+	space = min_t(size_t, space, fo->size);
+
+	/* limit to order-0 allocations */
+	space = min_t(size_t, space, SKB_MAX_HEAD(MAX_TCP_HEADER));
+
+	syn_data = skb_copy_expand(syn, MAX_TCP_HEADER, space,
 				   sk->sk_allocation);
 	if (syn_data == NULL)
 		goto fallback;

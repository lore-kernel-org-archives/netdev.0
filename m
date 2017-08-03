From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v4 8/9] tcp: enable MSG_ZEROCOPY
Date: Thu,  3 Aug 2017 16:29:44 -0400
Message-ID: <20170803202945.70750-9-willemdebruijn.kernel@gmail.com>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:38633 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbdHCU3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 16:29:55 -0400
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Enable support for MSG_ZEROCOPY to the TCP stack. TSO and GSO are
both supported. Only data sent to remote destinations is sent without
copying. Packets looped onto a local destination have their payload
copied to avoid unbounded latency.

Tested:
  A 10x TCP_STREAM between two hosts showed a reduction in netserver
  process cycles by up to 70%, depending on packet size. Systemwide,
  savings are of course much less pronounced, at up to 20% best case.

  msg_zerocopy.sh 4 tcp:

  without zerocopy
    tx=121792 (7600 MB) txc=0 zc=n
    rx=60458 (7600 MB)

  with zerocopy
    tx=286257 (17863 MB) txc=286257 zc=y
    rx=140022 (17863 MB)

  This test opens a pair of sockets over veth, one one calls send with
  64KB and optionally MSG_ZEROCOPY and on the other reads the initial
  bytes. The receiver truncates, so this is strictly an upper bound on
  what is achievable. It is more representative of sending data out of
  a physical NIC (when payload is not touched, either).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9dd6f4dba9b1..71b25567e787 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1165,6 +1165,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct ubuf_info *uarg = NULL;
 	struct sk_buff *skb;
 	struct sockcm_cookie sockc;
 	int flags, err, copied = 0;
@@ -1174,6 +1175,26 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 	long timeo;
 
 	flags = msg->msg_flags;
+
+	if (flags & MSG_ZEROCOPY && size) {
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			err = -EINVAL;
+			goto out_err;
+		}
+
+		skb = tcp_send_head(sk) ? tcp_write_queue_tail(sk) : NULL;
+		uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
+		if (!uarg) {
+			err = -ENOBUFS;
+			goto out_err;
+		}
+
+		/* skb may be freed in main loop, keep extra ref on uarg */
+		sock_zerocopy_get(uarg);
+		if (!(sk_check_csum_caps(sk) && sk->sk_route_caps & NETIF_F_SG))
+			uarg->zerocopy = 0;
+	}
+
 	if (unlikely(flags & MSG_FASTOPEN || inet_sk(sk)->defer_connect)) {
 		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
 		if (err == -EINPROGRESS && copied_syn > 0)
@@ -1297,7 +1318,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 			err = skb_add_data_nocache(sk, skb, &msg->msg_iter, copy);
 			if (err)
 				goto do_fault;
-		} else {
+		} else if (!uarg || !uarg->zerocopy) {
 			bool merge = true;
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page_frag *pfrag = sk_page_frag(sk);
@@ -1335,6 +1356,13 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 				page_ref_inc(pfrag->page);
 			}
 			pfrag->offset += copy;
+		} else {
+			err = skb_zerocopy_iter_stream(sk, skb, msg, copy, uarg);
+			if (err == -EMSGSIZE || err == -EEXIST)
+				goto new_segment;
+			if (err < 0)
+				goto do_error;
+			copy = err;
 		}
 
 		if (!copied)
@@ -1381,6 +1409,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	}
 out_nopush:
+	sock_zerocopy_put(uarg);
 	return copied + copied_syn;
 
 do_fault:
@@ -1397,6 +1426,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 	if (copied + copied_syn)
 		goto out;
 out_err:
+	sock_zerocopy_put_abort(uarg);
 	err = sk_stream_error(sk, flags, err);
 	/* make sure we wake any epoll edge trigger waiter */
 	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
-- 
2.14.0.rc1.383.gd1ce394fe2-goog

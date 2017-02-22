From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 08/12] tcp: enable sendmsg zerocopy
Date: Wed, 22 Feb 2017 11:38:57 -0500
Message-ID: <20170222163901.90834-9-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33897 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbdBVQjU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:20 -0500
Received: by mail-qt0-f196.google.com with SMTP id x35so1065210qtc.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:20 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Enable support for MSG_ZEROCOPY to the TCP stack. Data that is
sent to a remote host will be zerocopy. TSO and GSO are supported.

Tested:
  A 10x TCP_STREAM between two hosts showed a reduction in netserver
  process cycles by up to 70%, depending on packet size. Systemwide,
  savings are of course much less pronounced, at up to 20% best case.

  loopback test snd_zerocopy_lo -t -z produced:

  without zerocopy (-t):
    rx=102852 (6418 MB) tx=102852 txc=0
    rx=213216 (13305 MB) tx=213216 txc=0
    rx=325266 (20298 MB) tx=325266 txc=0
    rx=437082 (27275 MB) tx=437082 txc=0

  with zerocopy (-t -z):
    rx=238446 (14880 MB) tx=238446 txc=238434
    rx=500076 (31207 MB) tx=500076 txc=500060
    rx=763728 (47660 MB) tx=763728 txc=763706
    rx=1028184 (64163 MB) tx=1028184 txc=1028156

  This test opens a pair of local sockets, one one calls sendmsg with
  64KB and optionally MSG_ZEROCOPY and on the other reads the initial
  bytes. The receiver truncates, so this is strictly an upper bound on
  what is achievable. It is more representative of sending data out of
  a physical NIC (when payload is not touched, either).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp.c | 37 ++++++++++++++++++++++++++++++++++---
 1 file changed, 34 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index da385ae997a3..4884f4ff14d2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1051,13 +1051,17 @@ static int linear_payload_sz(bool first_skb)
 	return 0;
 }
 
-static int select_size(const struct sock *sk, bool sg, bool first_skb)
+static int select_size(const struct sock *sk, bool sg, bool first_skb,
+		       bool zerocopy)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	int tmp = tp->mss_cache;
 
 	if (sg) {
 		if (sk_can_gso(sk)) {
+			if (zerocopy)
+				return 0;
+
 			tmp = linear_payload_sz(first_skb);
 		} else {
 			int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
@@ -1121,6 +1125,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	struct sockcm_cookie sockc;
+	struct ubuf_info *uarg = NULL;
 	int flags, err, copied = 0;
 	int mss_now = 0, size_goal, copied_syn = 0;
 	bool process_backlog = false;
@@ -1190,6 +1195,21 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
+	if (sg && (flags & MSG_ZEROCOPY) && size && !uarg) {
+		skb = tcp_send_head(sk) ? tcp_write_queue_tail(sk) : NULL;
+		uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
+		if (!uarg) {
+			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+				goto out_err;
+			uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
+			if (!uarg) {
+				err = -ENOBUFS;
+				goto out_err;
+			}
+		}
+		sock_zerocopy_get(uarg);
+	}
+
 	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
@@ -1217,7 +1237,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			}
 			first_skb = skb_queue_empty(&sk->sk_write_queue);
 			skb = sk_stream_alloc_skb(sk,
-						  select_size(sk, sg, first_skb),
+						  select_size(sk, sg, first_skb, uarg),
 						  sk->sk_allocation,
 						  first_skb);
 			if (!skb)
@@ -1253,7 +1273,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			err = skb_add_data_nocache(sk, skb, &msg->msg_iter, copy);
 			if (err)
 				goto do_fault;
-		} else {
+		} else if (!uarg) {
 			bool merge = true;
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page_frag *pfrag = sk_page_frag(sk);
@@ -1291,6 +1311,15 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 				page_ref_inc(pfrag->page);
 			}
 			pfrag->offset += copy;
+		} else {
+			err = skb_zerocopy_add_frags_iter(sk, skb,
+							  &msg->msg_iter,
+							  copy, uarg);
+			if (err == -EMSGSIZE || err == -EEXIST)
+				goto new_segment;
+			if (err < 0)
+				goto do_error;
+			copy = err;
 		}
 
 		if (!copied)
@@ -1337,6 +1366,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	}
 out_nopush:
+	sock_zerocopy_put(uarg);
 	release_sock(sk);
 	return copied + copied_syn;
 
@@ -1354,6 +1384,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	if (copied + copied_syn)
 		goto out;
 out_err:
+	sock_zerocopy_put_abort(uarg);
 	err = sk_stream_error(sk, flags, err);
 	/* make sure we wake any epoll edge trigger waiter */
 	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
-- 
2.11.0.483.g087da7b7c-goog

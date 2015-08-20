From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 05/10] tcp: enable sendmsg zerocopy
Date: Thu, 20 Aug 2015 10:36:44 -0400
Message-ID: <1440081408-12302-6-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36453 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbbHTOg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:56 -0400
Received: by qkep139 with SMTP id p139so16167350qke.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:55 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Enable support for MSG_ZEROCOPY to the TCP stack. Data that is
sent to a remote host will be zerocopy. TSO and GSO are supported.

Tested:
  A 10x TCP_STREAM between two hosts showed a reduction in netserver
  process cycles by up to 70%, depending on packet size. Systemwide,
  savings are of course much less pronounced, at up to 20% best case.

  loopback test //net/socket:snd_zerocopy_lo -t -z produced:

  without zerocopy (-t):
    rx=93294 (5821 MB) tx=93294 txc=0
    rx=196194 (12243 MB) tx=196194 txc=0
    rx=297942 (18592 MB) tx=297942 txc=0
    rx=397752 (24821 MB) tx=397752 txc=0

  with zerocopy (-t -z):
    rx=200813 (12531 MB) tx=200814 txc=200799
    rx=426605 (26622 MB) tx=426606 txc=426585
    rx=645959 (40310 MB) tx=645960 txc=645933
    rx=877799 (54778 MB) tx=877800 txc=877765

  This test opens a pair of local sockets, one one calls sendmsg with
  64KB and optionally MSG_ZEROCOPY and on the other reads the initial
  bytes. The receiver truncates, so this is strictly an upper bound on
  what is achievable. It is more representative of sending data out of
  a physical NIC (when payload is not touched, either).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 45534a5..3711786 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1024,13 +1024,16 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 }
 EXPORT_SYMBOL(tcp_sendpage);
 
-static inline int select_size(const struct sock *sk, bool sg)
+static inline int select_size(const struct sock *sk, bool sg, bool zerocopy)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	int tmp = tp->mss_cache;
 
 	if (sg) {
 		if (sk_can_gso(sk)) {
+			if (zerocopy)
+				return 0;
+
 			/* Small frames wont use a full page:
 			 * Payload will immediately follow tcp header.
 			 */
@@ -1085,6 +1088,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
+	struct ubuf_info *uarg = NULL;
 	int flags, err, copied = 0;
 	int mss_now = 0, size_goal, copied_syn = 0;
 	bool sg;
@@ -1140,6 +1144,17 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
+	if (sg && (flags & MSG_ZEROCOPY) && size) {
+		skb = tcp_send_head(sk) ? tcp_write_queue_tail(sk) : NULL;
+		uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
+		if (!uarg) {
+			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+				goto out_err;
+			uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
+		}
+		sock_zerocopy_get(uarg);
+	}
+
 	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
@@ -1160,7 +1175,7 @@ new_segment:
 				goto wait_for_sndbuf;
 
 			skb = sk_stream_alloc_skb(sk,
-						  select_size(sk, sg),
+						  select_size(sk, sg, uarg),
 						  sk->sk_allocation,
 						  skb_queue_empty(&sk->sk_write_queue));
 			if (!skb)
@@ -1195,7 +1210,7 @@ new_segment:
 			err = skb_add_data_nocache(sk, skb, &msg->msg_iter, copy);
 			if (err)
 				goto do_fault;
-		} else {
+		} else if (!uarg) {
 			bool merge = true;
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page_frag *pfrag = sk_page_frag(sk);
@@ -1233,6 +1248,15 @@ new_segment:
 				get_page(pfrag->page);
 			}
 			pfrag->offset += copy;
+		} else {
+			err = skb_zerocopy_add_frags_iter(sk, skb,
+							  &msg->msg_iter,
+							  copy, uarg);
+			if (err == -EMSGSIZE)
+				goto new_segment;
+			if (err < 0)
+				goto do_error;
+			copy = err;
 		}
 
 		if (!copied)
@@ -1275,6 +1299,7 @@ out:
 	if (copied)
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 out_nopush:
+	sock_zerocopy_put(uarg);
 	release_sock(sk);
 	return copied + copied_syn;
 
@@ -1292,6 +1317,7 @@ do_error:
 	if (copied + copied_syn)
 		goto out;
 out_err:
+	sock_zerocopy_put_abort(uarg);
 	err = sk_stream_error(sk, flags, err);
 	/* make sure we wake any epoll edge trigger waiter */
 	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
-- 
2.5.0.276.gf5e568e

From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 08/18] convert tcp_sendmsg() to iov_iter primitives
Date: Sat, 31 Jan 2015 03:56:34 +0000
Message-ID: <1422676604-18533-8-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54995 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756811AbbAaD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:46 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

patch is actually smaller than it seems to be - most of it is unindenting
the inner loop body in tcp_sendmsg() itself...

the bit in tcp_input.c is going to get reverted very soon - that's what
memcpy_from_msg() will become, but not in this commit; let's keep it
reasonably contained...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/sock.h    |  18 ++--
 net/ipv4/tcp.c        | 233 +++++++++++++++++++++++---------------------------
 net/ipv4/tcp_input.c  |   2 +-
 net/ipv4/tcp_output.c |  11 ++-
 4 files changed, 123 insertions(+), 141 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1534149..1e45e59 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1803,27 +1803,25 @@ static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
 }
 
 static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
-					   char __user *from, char *to,
+					   struct iov_iter *from, char *to,
 					   int copy, int offset)
 {
 	if (skb->ip_summed == CHECKSUM_NONE) {
-		int err = 0;
-		__wsum csum = csum_and_copy_from_user(from, to, copy, 0, &err);
-		if (err)
-			return err;
+		__wsum csum = 0;
+		if (csum_and_copy_from_iter(to, copy, &csum, from) != copy)
+			return -EFAULT;
 		skb->csum = csum_block_add(skb->csum, csum, offset);
 	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
-		if (!access_ok(VERIFY_READ, from, copy) ||
-		    __copy_from_user_nocache(to, from, copy))
+		if (copy_from_iter_nocache(to, copy, from) != copy)
 			return -EFAULT;
-	} else if (copy_from_user(to, from, copy))
+	} else if (copy_from_iter(to, copy, from) != copy)
 		return -EFAULT;
 
 	return 0;
 }
 
 static inline int skb_add_data_nocache(struct sock *sk, struct sk_buff *skb,
-				       char __user *from, int copy)
+				       struct iov_iter *from, int copy)
 {
 	int err, offset = skb->len;
 
@@ -1835,7 +1833,7 @@ static inline int skb_add_data_nocache(struct sock *sk, struct sk_buff *skb,
 	return err;
 }
 
-static inline int skb_copy_to_page_nocache(struct sock *sk, char __user *from,
+static inline int skb_copy_to_page_nocache(struct sock *sk, struct iov_iter *from,
 					   struct sk_buff *skb,
 					   struct page *page,
 					   int off, int copy)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3075723..9d72a0f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1067,11 +1067,10 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
-	const struct iovec *iov;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	int iovlen, flags, err, copied = 0;
-	int mss_now = 0, size_goal, copied_syn = 0, offset = 0;
+	int flags, err, copied = 0;
+	int mss_now = 0, size_goal, copied_syn = 0;
 	bool sg;
 	long timeo;
 
@@ -1084,7 +1083,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			goto out;
 		else if (err)
 			goto out_err;
-		offset = copied_syn;
 	}
 
 	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
@@ -1118,8 +1116,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 
 	/* Ok commence sending. */
-	iovlen = msg->msg_iter.nr_segs;
-	iov = msg->msg_iter.iov;
 	copied = 0;
 
 	err = -EPIPE;
@@ -1128,151 +1124,134 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
-	while (--iovlen >= 0) {
-		size_t seglen = iov->iov_len;
-		unsigned char __user *from = iov->iov_base;
+	while (iov_iter_count(&msg->msg_iter)) {
+		int copy = 0;
+		int max = size_goal;
 
-		iov++;
-		if (unlikely(offset > 0)) {  /* Skip bytes copied in SYN */
-			if (offset >= seglen) {
-				offset -= seglen;
-				continue;
-			}
-			seglen -= offset;
-			from += offset;
-			offset = 0;
+		skb = tcp_write_queue_tail(sk);
+		if (tcp_send_head(sk)) {
+			if (skb->ip_summed == CHECKSUM_NONE)
+				max = mss_now;
+			copy = max - skb->len;
 		}
 
-		while (seglen > 0) {
-			int copy = 0;
-			int max = size_goal;
-
-			skb = tcp_write_queue_tail(sk);
-			if (tcp_send_head(sk)) {
-				if (skb->ip_summed == CHECKSUM_NONE)
-					max = mss_now;
-				copy = max - skb->len;
-			}
-
-			if (copy <= 0) {
+		if (copy <= 0) {
 new_segment:
-				/* Allocate new segment. If the interface is SG,
-				 * allocate skb fitting to single page.
-				 */
-				if (!sk_stream_memory_free(sk))
-					goto wait_for_sndbuf;
+			/* Allocate new segment. If the interface is SG,
+			 * allocate skb fitting to single page.
+			 */
+			if (!sk_stream_memory_free(sk))
+				goto wait_for_sndbuf;
 
-				skb = sk_stream_alloc_skb(sk,
-							  select_size(sk, sg),
-							  sk->sk_allocation);
-				if (!skb)
-					goto wait_for_memory;
+			skb = sk_stream_alloc_skb(sk,
+						  select_size(sk, sg),
+						  sk->sk_allocation);
+			if (!skb)
+				goto wait_for_memory;
 
-				/*
-				 * Check whether we can use HW checksum.
-				 */
-				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
-					skb->ip_summed = CHECKSUM_PARTIAL;
+			/*
+			 * Check whether we can use HW checksum.
+			 */
+			if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
+				skb->ip_summed = CHECKSUM_PARTIAL;
 
-				skb_entail(sk, skb);
-				copy = size_goal;
-				max = size_goal;
+			skb_entail(sk, skb);
+			copy = size_goal;
+			max = size_goal;
 
-				/* All packets are restored as if they have
-				 * already been sent. skb_mstamp isn't set to
-				 * avoid wrong rtt estimation.
-				 */
-				if (tp->repair)
-					TCP_SKB_CB(skb)->sacked |= TCPCB_REPAIRED;
-			}
+			/* All packets are restored as if they have
+			 * already been sent. skb_mstamp isn't set to
+			 * avoid wrong rtt estimation.
+			 */
+			if (tp->repair)
+				TCP_SKB_CB(skb)->sacked |= TCPCB_REPAIRED;
+		}
 
-			/* Try to append data to the end of skb. */
-			if (copy > seglen)
-				copy = seglen;
-
-			/* Where to copy to? */
-			if (skb_availroom(skb) > 0) {
-				/* We have some space in skb head. Superb! */
-				copy = min_t(int, copy, skb_availroom(skb));
-				err = skb_add_data_nocache(sk, skb, from, copy);
-				if (err)
-					goto do_fault;
-			} else {
-				bool merge = true;
-				int i = skb_shinfo(skb)->nr_frags;
-				struct page_frag *pfrag = sk_page_frag(sk);
-
-				if (!sk_page_frag_refill(sk, pfrag))
-					goto wait_for_memory;
-
-				if (!skb_can_coalesce(skb, i, pfrag->page,
-						      pfrag->offset)) {
-					if (i == MAX_SKB_FRAGS || !sg) {
-						tcp_mark_push(tp, skb);
-						goto new_segment;
-					}
-					merge = false;
-				}
+		/* Try to append data to the end of skb. */
+		if (copy > iov_iter_count(&msg->msg_iter))
+			copy = iov_iter_count(&msg->msg_iter);
+
+		/* Where to copy to? */
+		if (skb_availroom(skb) > 0) {
+			/* We have some space in skb head. Superb! */
+			copy = min_t(int, copy, skb_availroom(skb));
+			err = skb_add_data_nocache(sk, skb, &msg->msg_iter, copy);
+			if (err)
+				goto do_fault;
+		} else {
+			bool merge = true;
+			int i = skb_shinfo(skb)->nr_frags;
+			struct page_frag *pfrag = sk_page_frag(sk);
+
+			if (!sk_page_frag_refill(sk, pfrag))
+				goto wait_for_memory;
 
-				copy = min_t(int, copy, pfrag->size - pfrag->offset);
-
-				if (!sk_wmem_schedule(sk, copy))
-					goto wait_for_memory;
-
-				err = skb_copy_to_page_nocache(sk, from, skb,
-							       pfrag->page,
-							       pfrag->offset,
-							       copy);
-				if (err)
-					goto do_error;
-
-				/* Update the skb. */
-				if (merge) {
-					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
-				} else {
-					skb_fill_page_desc(skb, i, pfrag->page,
-							   pfrag->offset, copy);
-					get_page(pfrag->page);
+			if (!skb_can_coalesce(skb, i, pfrag->page,
+					      pfrag->offset)) {
+				if (i == MAX_SKB_FRAGS || !sg) {
+					tcp_mark_push(tp, skb);
+					goto new_segment;
 				}
-				pfrag->offset += copy;
+				merge = false;
 			}
 
-			if (!copied)
-				TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
+			copy = min_t(int, copy, pfrag->size - pfrag->offset);
 
-			tp->write_seq += copy;
-			TCP_SKB_CB(skb)->end_seq += copy;
-			tcp_skb_pcount_set(skb, 0);
+			if (!sk_wmem_schedule(sk, copy))
+				goto wait_for_memory;
 
-			from += copy;
-			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0) {
-				tcp_tx_timestamp(sk, skb);
-				goto out;
+			err = skb_copy_to_page_nocache(sk, &msg->msg_iter, skb,
+						       pfrag->page,
+						       pfrag->offset,
+						       copy);
+			if (err)
+				goto do_error;
+
+			/* Update the skb. */
+			if (merge) {
+				skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
+			} else {
+				skb_fill_page_desc(skb, i, pfrag->page,
+						   pfrag->offset, copy);
+				get_page(pfrag->page);
 			}
+			pfrag->offset += copy;
+		}
 
-			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
-				continue;
+		if (!copied)
+			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
+
+		tp->write_seq += copy;
+		TCP_SKB_CB(skb)->end_seq += copy;
+		tcp_skb_pcount_set(skb, 0);
+
+		copied += copy;
+		if (!iov_iter_count(&msg->msg_iter)) {
+			tcp_tx_timestamp(sk, skb);
+			goto out;
+		}
 
-			if (forced_push(tp)) {
-				tcp_mark_push(tp, skb);
-				__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
-			} else if (skb == tcp_send_head(sk))
-				tcp_push_one(sk, mss_now);
+		if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 			continue;
 
+		if (forced_push(tp)) {
+			tcp_mark_push(tp, skb);
+			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
+		} else if (skb == tcp_send_head(sk))
+			tcp_push_one(sk, mss_now);
+		continue;
+
 wait_for_sndbuf:
-			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
-			if (copied)
-				tcp_push(sk, flags & ~MSG_MORE, mss_now,
-					 TCP_NAGLE_PUSH, size_goal);
+		if (copied)
+			tcp_push(sk, flags & ~MSG_MORE, mss_now,
+				 TCP_NAGLE_PUSH, size_goal);
 
-			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
-				goto do_error;
+		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+			goto do_error;
 
-			mss_now = tcp_send_mss(sk, &size_goal, flags);
-		}
+		mss_now = tcp_send_mss(sk, &size_goal, flags);
 	}
 
 out:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 71fb37c..93c7482 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4368,7 +4368,7 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
 		goto err_free;
 
-	if (memcpy_from_msg(skb_put(skb, size), msg, size))
+	if (copy_from_iter(skb_put(skb, size), size, &msg->msg_iter) != size)
 		goto err_free;
 
 	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20ab06b..722c8bc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3055,7 +3055,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_request *fo = tp->fastopen_req;
-	int syn_loss = 0, space, err = 0;
+	int syn_loss = 0, space, err = 0, copied;
 	unsigned long last_syn_loss = 0;
 	struct sk_buff *syn_data;
 
@@ -3093,11 +3093,16 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 		goto fallback;
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
-	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
-					 fo->data->msg_iter.iov, 0, space))) {
+	copied = copy_from_iter(skb_put(syn_data, space), space,
+				&fo->data->msg_iter);
+	if (unlikely(!copied)) {
 		kfree_skb(syn_data);
 		goto fallback;
 	}
+	if (copied != space) {
+		skb_trim(syn_data, copied);
+		space = copied;
+	}
 
 	/* No more data pending in inet_wait_for_connect() */
 	if (space == fo->size)
-- 
2.1.4

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v4 3/9] sock: add MSG_ZEROCOPY
Date: Thu,  3 Aug 2017 16:29:39 -0400
Message-ID: <20170803202945.70750-4-willemdebruijn.kernel@gmail.com>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36423 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdHCU3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 16:29:52 -0400
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The kernel supports zerocopy sendmsg in virtio and tap. Expand the
infrastructure to support other socket types. Introduce a completion
notification channel over the socket error queue. Notifications are
returned with ee_origin SO_EE_ORIGIN_ZEROCOPY. ee_errno is 0 to avoid
blocking the send/recv path on receiving notifications.

Add reference counting, to support the skb split, merge, resize and
clone operations possible with SOCK_STREAM and other socket types.

The patch does not yet modify any datapaths.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h        |  60 +++++++++++++++++++
 include/linux/socket.h        |   1 +
 include/net/sock.h            |   2 +
 include/uapi/linux/errqueue.h |   3 +
 net/core/datagram.c           |  55 ++++++++++-------
 net/core/skbuff.c             | 133 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c               |   2 +
 7 files changed, 235 insertions(+), 21 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2f64e2bbb592..59cff7aa494e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -429,6 +429,7 @@ enum {
 	SKBTX_SCHED_TSTAMP = 1 << 6,
 };
 
+#define SKBTX_ZEROCOPY_FRAG	(SKBTX_DEV_ZEROCOPY | SKBTX_SHARED_FRAG)
 #define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP    | \
 				 SKBTX_SCHED_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
@@ -445,8 +446,28 @@ struct ubuf_info {
 	void (*callback)(struct ubuf_info *, bool zerocopy_success);
 	void *ctx;
 	unsigned long desc;
+	u16 zerocopy:1;
+	atomic_t refcnt;
 };
 
+#define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
+
+struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size);
+
+static inline void sock_zerocopy_get(struct ubuf_info *uarg)
+{
+	atomic_inc(&uarg->refcnt);
+}
+
+void sock_zerocopy_put(struct ubuf_info *uarg);
+void sock_zerocopy_put_abort(struct ubuf_info *uarg);
+
+void sock_zerocopy_callback(struct ubuf_info *uarg, bool success);
+
+int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
+			     struct msghdr *msg, int len,
+			     struct ubuf_info *uarg);
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -1214,6 +1235,45 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
 	return &skb_shinfo(skb)->hwtstamps;
 }
 
+static inline struct ubuf_info *skb_zcopy(struct sk_buff *skb)
+{
+	bool is_zcopy = skb && skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY;
+
+	return is_zcopy ? skb_uarg(skb) : NULL;
+}
+
+static inline void skb_zcopy_set(struct sk_buff *skb, struct ubuf_info *uarg)
+{
+	if (skb && uarg && !skb_zcopy(skb)) {
+		sock_zerocopy_get(uarg);
+		skb_shinfo(skb)->destructor_arg = uarg;
+		skb_shinfo(skb)->tx_flags |= SKBTX_ZEROCOPY_FRAG;
+	}
+}
+
+/* Release a reference on a zerocopy structure */
+static inline void skb_zcopy_clear(struct sk_buff *skb, bool zerocopy)
+{
+	struct ubuf_info *uarg = skb_zcopy(skb);
+
+	if (uarg) {
+		uarg->zerocopy = uarg->zerocopy && zerocopy;
+		sock_zerocopy_put(uarg);
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_ZEROCOPY_FRAG;
+	}
+}
+
+/* Abort a zerocopy operation and revert zckey on error in send syscall */
+static inline void skb_zcopy_abort(struct sk_buff *skb)
+{
+	struct ubuf_info *uarg = skb_zcopy(skb);
+
+	if (uarg) {
+		sock_zerocopy_put_abort(uarg);
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_ZEROCOPY_FRAG;
+	}
+}
+
 /**
  *	skb_queue_empty - check if a queue is empty
  *	@list: queue head
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8b13db5163cc..8ad963cdc88c 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -287,6 +287,7 @@ struct ucred {
 #define MSG_BATCH	0x40000 /* sendmmsg(): more messages coming */
 #define MSG_EOF         MSG_FIN
 
+#define MSG_ZEROCOPY	0x4000000	/* Use user data in kernel path */
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exec for file
 					   descriptor received through
diff --git a/include/net/sock.h b/include/net/sock.h
index 0f778d3c4300..fe1a0bc25cd3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -294,6 +294,7 @@ struct sock_common {
   *	@sk_stamp: time stamp of last packet received
   *	@sk_tsflags: SO_TIMESTAMPING socket options
   *	@sk_tskey: counter to disambiguate concurrent tstamp requests
+  *	@sk_zckey: counter to order MSG_ZEROCOPY notifications
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
   *	@sk_frag: cached page frag
@@ -462,6 +463,7 @@ struct sock {
 	u16			sk_tsflags;
 	u8			sk_shutdown;
 	u32			sk_tskey;
+	atomic_t		sk_zckey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 #ifdef CONFIG_SECURITY
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1f444a..78fdf52d6b2f 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -18,10 +18,13 @@ struct sock_extended_err {
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
 #define SO_EE_ORIGIN_TXSTATUS	4
+#define SO_EE_ORIGIN_ZEROCOPY	5
 #define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
+#define SO_EE_CODE_ZEROCOPY_COPIED	1
+
 /**
  *	struct scm_timestamping - timestamps exposed through cmsg
  *
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647bd91b3..2f3277945d35 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -573,27 +573,12 @@ int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 }
 EXPORT_SYMBOL(skb_copy_datagram_from_iter);
 
-/**
- *	zerocopy_sg_from_iter - Build a zerocopy datagram from an iov_iter
- *	@skb: buffer to copy
- *	@from: the source to copy from
- *
- *	The function will first copy up to headlen, and then pin the userspace
- *	pages and build frags through them.
- *
- *	Returns 0, -EFAULT or -EMSGSIZE.
- */
-int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
+int __zerocopy_sg_from_iter(struct sock *sk, struct sk_buff *skb,
+			    struct iov_iter *from, size_t length)
 {
-	int len = iov_iter_count(from);
-	int copy = min_t(int, skb_headlen(skb), len);
-	int frag = 0;
+	int frag = skb_shinfo(skb)->nr_frags;
 
-	/* copy up to skb headlen */
-	if (skb_copy_datagram_from_iter(skb, 0, from, copy))
-		return -EFAULT;
-
-	while (iov_iter_count(from)) {
+	while (length && iov_iter_count(from)) {
 		struct page *pages[MAX_SKB_FRAGS];
 		size_t start;
 		ssize_t copied;
@@ -603,18 +588,24 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 		if (frag == MAX_SKB_FRAGS)
 			return -EMSGSIZE;
 
-		copied = iov_iter_get_pages(from, pages, ~0U,
+		copied = iov_iter_get_pages(from, pages, length,
 					    MAX_SKB_FRAGS - frag, &start);
 		if (copied < 0)
 			return -EFAULT;
 
 		iov_iter_advance(from, copied);
+		length -= copied;
 
 		truesize = PAGE_ALIGN(copied + start);
 		skb->data_len += copied;
 		skb->len += copied;
 		skb->truesize += truesize;
-		refcount_add(truesize, &skb->sk->sk_wmem_alloc);
+		if (sk && sk->sk_type == SOCK_STREAM) {
+			sk->sk_wmem_queued += truesize;
+			sk_mem_charge(sk, truesize);
+		} else {
+			refcount_add(truesize, &skb->sk->sk_wmem_alloc);
+		}
 		while (copied) {
 			int size = min_t(int, copied, PAGE_SIZE - start);
 			skb_fill_page_desc(skb, frag++, pages[n], start, size);
@@ -625,6 +616,28 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(__zerocopy_sg_from_iter);
+
+/**
+ *	zerocopy_sg_from_iter - Build a zerocopy datagram from an iov_iter
+ *	@skb: buffer to copy
+ *	@from: the source to copy from
+ *
+ *	The function will first copy up to headlen, and then pin the userspace
+ *	pages and build frags through them.
+ *
+ *	Returns 0, -EFAULT or -EMSGSIZE.
+ */
+int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
+{
+	int copy = min_t(int, skb_headlen(skb), iov_iter_count(from));
+
+	/* copy up to skb headlen */
+	if (skb_copy_datagram_from_iter(skb, 0, from, copy))
+		return -EFAULT;
+
+	return __zerocopy_sg_from_iter(NULL, skb, from, ~0U);
+}
 EXPORT_SYMBOL(zerocopy_sg_from_iter);
 
 static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a95877a8ac8b..0603e44950da 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -915,6 +915,139 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
+{
+	struct ubuf_info *uarg;
+	struct sk_buff *skb;
+
+	WARN_ON_ONCE(!in_task());
+
+	skb = sock_omalloc(sk, 0, GFP_KERNEL);
+	if (!skb)
+		return NULL;
+
+	BUILD_BUG_ON(sizeof(*uarg) > sizeof(skb->cb));
+	uarg = (void *)skb->cb;
+
+	uarg->callback = sock_zerocopy_callback;
+	uarg->desc = atomic_inc_return(&sk->sk_zckey) - 1;
+	uarg->zerocopy = 1;
+	atomic_set(&uarg->refcnt, 0);
+	sock_hold(sk);
+
+	return uarg;
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_alloc);
+
+static inline struct sk_buff *skb_from_uarg(struct ubuf_info *uarg)
+{
+	return container_of((void *)uarg, struct sk_buff, cb);
+}
+
+void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
+{
+	struct sk_buff *skb = skb_from_uarg(uarg);
+	struct sock_exterr_skb *serr;
+	struct sock *sk = skb->sk;
+	u16 id = uarg->desc;
+
+	if (sock_flag(sk, SOCK_DEAD))
+		goto release;
+
+	serr = SKB_EXT_ERR(skb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = 0;
+	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
+	serr->ee.ee_data = id;
+	if (!success)
+		serr->ee.ee_code |= SO_EE_CODE_ZEROCOPY_COPIED;
+
+	skb_queue_tail(&sk->sk_error_queue, skb);
+	skb = NULL;
+
+	sk->sk_error_report(sk);
+
+release:
+	consume_skb(skb);
+	sock_put(sk);
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
+
+void sock_zerocopy_put(struct ubuf_info *uarg)
+{
+	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+		if (uarg->callback)
+			uarg->callback(uarg, uarg->zerocopy);
+		else
+			consume_skb(skb_from_uarg(uarg));
+	}
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_put);
+
+void sock_zerocopy_put_abort(struct ubuf_info *uarg)
+{
+	if (uarg) {
+		struct sock *sk = skb_from_uarg(uarg)->sk;
+
+		atomic_dec(&sk->sk_zckey);
+
+		/* sock_zerocopy_put expects a ref. Most sockets take one per
+		 * skb, which is zero on abort. tcp_sendmsg holds one extra, to
+		 * avoid an skb send inside the main loop triggering uarg free.
+		 */
+		if (sk->sk_type != SOCK_STREAM)
+			atomic_inc(&uarg->refcnt);
+
+		sock_zerocopy_put(uarg);
+	}
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_put_abort);
+
+extern int __zerocopy_sg_from_iter(struct sock *sk, struct sk_buff *skb,
+				   struct iov_iter *from, size_t length);
+
+int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
+			     struct msghdr *msg, int len,
+			     struct ubuf_info *uarg)
+{
+	struct iov_iter orig_iter = msg->msg_iter;
+	int err, orig_len = skb->len;
+
+	err = __zerocopy_sg_from_iter(sk, skb, &msg->msg_iter, len);
+	if (err == -EFAULT || (err == -EMSGSIZE && skb->len == orig_len)) {
+		/* Streams do not free skb on error. Reset to prev state. */
+		msg->msg_iter = orig_iter;
+		___pskb_trim(skb, orig_len);
+		return err;
+	}
+
+	skb_zcopy_set(skb, uarg);
+	return skb->len - orig_len;
+}
+EXPORT_SYMBOL_GPL(skb_zerocopy_iter_stream);
+
+/* unused only until next patch in the series; will remove attribute */
+static int __attribute__((unused))
+	   skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
+			      gfp_t gfp_mask)
+{
+	if (skb_zcopy(orig)) {
+		if (skb_zcopy(nskb)) {
+			/* !gfp_mask callers are verified to !skb_zcopy(nskb) */
+			if (!gfp_mask) {
+				WARN_ON_ONCE(1);
+				return -ENOMEM;
+			}
+			if (skb_uarg(nskb) == skb_uarg(orig))
+				return 0;
+			if (skb_copy_ubufs(nskb, GFP_ATOMIC))
+				return -EIO;
+		}
+		skb_zcopy_set(nskb, skb_uarg(orig));
+	}
+	return 0;
+}
+
 /**
  *	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
  *	@skb: the skb to modify
diff --git a/net/core/sock.c b/net/core/sock.c
index 1261880bdcc8..e8b696858cad 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1670,6 +1670,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		atomic_set(&newsk->sk_drops, 0);
 		newsk->sk_send_head	= NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
+		atomic_set(&newsk->sk_zckey, 0);
 
 		sock_reset_flag(newsk, SOCK_DONE);
 
@@ -2722,6 +2723,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
 	sk->sk_stamp = SK_DEFAULT_STAMP;
+	atomic_set(&sk->sk_zckey, 0);
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	sk->sk_napi_id		=	0;
-- 
2.14.0.rc1.383.gd1ce394fe2-goog

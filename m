From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 03/12] sock: add generic socket zerocopy
Date: Wed, 22 Feb 2017 11:38:52 -0500
Message-ID: <20170222163901.90834-4-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33519 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754871AbdBVQjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:13 -0500
Received: by mail-qk0-f195.google.com with SMTP id x71so1186456qkb.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:13 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
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
 include/linux/skbuff.h        |  46 ++++++++++++++++
 include/linux/socket.h        |   1 +
 include/net/sock.h            |   2 +
 include/uapi/linux/errqueue.h |   1 +
 net/core/datagram.c           |  35 ++++++++----
 net/core/skbuff.c             | 120 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c               |   2 +
 7 files changed, 196 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 69ccd2636911..c99538b258c9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -390,6 +390,7 @@ enum {
 	SKBTX_SCHED_TSTAMP = 1 << 6,
 };
 
+#define SKBTX_ZEROCOPY_FRAG	(SKBTX_DEV_ZEROCOPY | SKBTX_SHARED_FRAG)
 #define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP    | \
 				 SKBTX_SCHED_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
@@ -406,8 +407,27 @@ struct ubuf_info {
 	void (*callback)(struct ubuf_info *, bool zerocopy_success);
 	void *ctx;
 	unsigned long desc;
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
+
+void sock_zerocopy_callback(struct ubuf_info *uarg, bool success);
+
+bool skb_zerocopy_alloc(struct sk_buff *skb, size_t size);
+int skb_zerocopy_add_frags_iter(struct sock *sk, struct sk_buff *skb,
+				struct iov_iter *iter, int len,
+				struct ubuf_info *uarg);
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -1230,6 +1250,32 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
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
+	if (uarg) {
+		sock_zerocopy_get(uarg);
+		skb_shinfo(skb)->destructor_arg = uarg;
+		skb_shinfo(skb)->tx_flags |= SKBTX_ZEROCOPY_FRAG;
+	}
+}
+
+static inline void skb_zcopy_clear(struct sk_buff *skb)
+{
+	struct ubuf_info *uarg = skb_zcopy(skb);
+
+	if (uarg) {
+		sock_zerocopy_put(uarg);
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	}
+}
+
 /**
  *	skb_queue_empty - check if a queue is empty
  *	@list: queue head
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 082027457825..c2d6ec354bee 100644
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
index c1a8b2cbc75e..74ad7d7c5eed 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -288,6 +288,7 @@ struct sock_common {
   *	@sk_stamp: time stamp of last packet received
   *	@sk_tsflags: SO_TIMESTAMPING socket options
   *	@sk_tskey: counter to disambiguate concurrent tstamp requests
+  *	@sk_zckey: counter to order MSG_ZEROCOPY notifications
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
   *	@sk_frag: cached page frag
@@ -455,6 +456,7 @@ struct sock {
 	u16			sk_tsflags;
 	u8			sk_shutdown;
 	u32			sk_tskey;
+	atomic_t		sk_zckey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 #ifdef CONFIG_SECURITY
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1f444a..0f15a77c9e39 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -18,6 +18,7 @@ struct sock_extended_err {
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
 #define SO_EE_ORIGIN_TXSTATUS	4
+#define SO_EE_ORIGIN_ZEROCOPY	5
 #define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ea633342ab0d..79db53c6bcf4 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -564,17 +564,12 @@ EXPORT_SYMBOL(skb_copy_datagram_from_iter);
  *
  *	Returns 0, -EFAULT or -EMSGSIZE.
  */
-int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
+int __zerocopy_sg_from_iter(struct sock *sk, struct sk_buff *skb,
+			    struct iov_iter *from, size_t length)
 {
-	int len = iov_iter_count(from);
-	int copy = min_t(int, skb_headlen(skb), len);
-	int frag = 0;
-
-	/* copy up to skb headlen */
-	if (skb_copy_datagram_from_iter(skb, 0, from, copy))
-		return -EFAULT;
+	int frag = skb_shinfo(skb)->nr_frags;
 
-	while (iov_iter_count(from)) {
+	while (length && iov_iter_count(from)) {
 		struct page *pages[MAX_SKB_FRAGS];
 		size_t start;
 		ssize_t copied;
@@ -584,18 +579,24 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
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
-		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		if (sk && sk->sk_type == SOCK_STREAM) {
+			sk->sk_wmem_queued += truesize;
+			sk_mem_charge(sk, truesize);
+		} else {
+			atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		}
 		while (copied) {
 			int size = min_t(int, copied, PAGE_SIZE - start);
 			skb_fill_page_desc(skb, frag++, pages[n], start, size);
@@ -606,6 +607,18 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(__zerocopy_sg_from_iter);
+
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
index 67e4216fca01..d566f85a7690 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -932,6 +932,126 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+/* must only be called from process context */
+struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
+{
+	struct sk_buff *skb;
+	struct ubuf_info *uarg;
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
+	struct sock_exterr_skb *serr;
+	struct sk_buff *skb = skb_from_uarg(uarg);
+	struct sock *sk = skb->sk;
+	u16 id = uarg->desc;
+
+	serr = SKB_EXT_ERR(skb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = 0;
+	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
+	serr->ee.ee_data = id;
+
+	skb_queue_tail(&sk->sk_error_queue, skb);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_error_report(sk);
+
+	sock_put(sk);
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
+
+void sock_zerocopy_put(struct ubuf_info *uarg)
+{
+	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+		if (uarg->callback)
+			uarg->callback(uarg, true);
+		else
+			consume_skb(skb_from_uarg(uarg));
+	}
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_put);
+
+bool skb_zerocopy_alloc(struct sk_buff *skb, size_t size)
+{
+	struct ubuf_info *uarg;
+
+	uarg = sock_zerocopy_alloc(skb->sk, size);
+	if (!uarg)
+		return false;
+
+	skb_zcopy_set(skb, uarg);
+	return true;
+}
+EXPORT_SYMBOL_GPL(skb_zerocopy_alloc);
+
+extern int __zerocopy_sg_from_iter(struct sock *sk, struct sk_buff *skb,
+				   struct iov_iter *from, size_t length);
+
+int skb_zerocopy_add_frags_iter(struct sock *sk, struct sk_buff *skb,
+				struct iov_iter *iter, int len,
+				struct ubuf_info *uarg)
+{
+	struct ubuf_info *orig_uarg = skb_zcopy(skb);
+	struct iov_iter orig_iter = *iter;
+	int ret, orig_len = skb->len;
+
+	if (orig_uarg && orig_uarg != uarg)
+		return -EEXIST;
+
+	ret = __zerocopy_sg_from_iter(sk, skb, iter, len);
+	if (ret && (ret != -EMSGSIZE || skb->len == orig_len)) {
+		*iter = orig_iter;
+		___pskb_trim(skb, orig_len);
+		return ret;
+	}
+
+	if (!orig_uarg)
+		skb_zcopy_set(skb, uarg);
+
+	return skb->len - orig_len;
+}
+EXPORT_SYMBOL_GPL(skb_zerocopy_add_frags_iter);
+
+/* unused only until next patch in the series; will remove attribute */
+static int __attribute__((unused))
+	   skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
+			      gfp_t gfp_mask)
+{
+	if (skb_zcopy(orig)) {
+		if (skb_zcopy(nskb)) {
+			/* !gfp_mask callers are verified to !skb_zcopy(nskb) */
+			BUG_ON(!gfp_mask);
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
index 57a7da46ac52..8f8203565ac4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1526,6 +1526,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		atomic_set(&newsk->sk_drops, 0);
 		newsk->sk_send_head	= NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
+		atomic_set(&newsk->sk_zckey, 0);
 
 		sock_reset_flag(newsk, SOCK_DONE);
 		skb_queue_head_init(&newsk->sk_error_queue);
@@ -2524,6 +2525,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
 	sk->sk_stamp = ktime_set(-1L, 0);
+	atomic_set(&sk->sk_zckey, 0);
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	sk->sk_napi_id		=	0;
-- 
2.11.0.483.g087da7b7c-goog

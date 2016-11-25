From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 4/5] net/socket: add helpers for recvmmsg
Date: Fri, 25 Nov 2016 16:39:55 +0100
Message-ID: <56ac598a3f8b677d58cc9fec5470df230c6d1f70.1480086321.git.pabeni@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754930AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

_skb_try_recv_datagram_batch dequeues multiple skb's from the
socket's receive queue, and runs the bulk_destructor callback under
the receive queue lock.

recvmmsg_ctx_from_user retrieves msghdr information from userspace,
and sets up the kernelspace context for processing one datagram.

recvmmsg_ctx_to_user copies to userspace the results of processing one
datagram.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 20 ++++++++++++++++
 include/net/sock.h     | 19 +++++++++++++++
 net/core/datagram.c    | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/socket.c           | 60 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 164 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fb..5672045 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1598,6 +1598,20 @@ static inline void __skb_insert(struct sk_buff *newsk,
 	list->qlen++;
 }
 
+static inline void __skb_queue_unsplice(struct sk_buff *first,
+					struct sk_buff *last,
+					unsigned int n,
+					struct sk_buff_head *queue)
+{
+	struct sk_buff *next = last->next, *prev = first->prev;
+
+	queue->qlen -= n;
+	last->next = NULL;
+	first->prev = NULL;
+	next->prev = prev;
+	prev->next = next;
+}
+
 static inline void __skb_queue_splice(const struct sk_buff_head *list,
 				      struct sk_buff *prev,
 				      struct sk_buff *next)
@@ -3032,6 +3046,12 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 
 int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				const struct sk_buff *skb);
+struct sk_buff *__skb_try_recv_datagram_batch(struct sock *sk,
+					      unsigned int flags,
+					      unsigned int batch,
+					      void (*bulk_destructor)(
+						     struct sock *sk, int size),
+					      int *err);
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
 					void (*destructor)(struct sock *sk,
 							   struct sk_buff *skb),
diff --git a/include/net/sock.h b/include/net/sock.h
index 11126f4..3daf63a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1534,6 +1534,25 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc);
 
+struct recvmmsg_ctx {
+	struct iovec		iovstack[UIO_FASTIOV];
+	struct msghdr		msg_sys;
+	struct sockaddr __user	*uaddr;
+	struct sockaddr_storage	addr;
+	unsigned long		cmsg_ptr;
+	struct iovec		*iov;
+};
+
+int recvmmsg_ctx_from_user(struct sock *sk, struct mmsghdr __user *mmsg,
+			   unsigned int flags, int nosec,
+			   struct recvmmsg_ctx *ctx);
+int recvmmsg_ctx_to_user(struct mmsghdr __user **mmsg, int len,
+			 unsigned int flags, struct recvmmsg_ctx *ctx);
+static inline void recvmmsg_ctx_free(struct recvmmsg_ctx *ctx)
+{
+	kfree(ctx->iov);
+}
+
 static inline bool sock_recvmmsg_timeout(struct timespec *timeout,
 					 struct timespec64 end_time)
 {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 49816af..90d1aa2 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -301,6 +301,71 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
 }
 EXPORT_SYMBOL(skb_recv_datagram);
 
+/**
+ *	__skb_try_recv_datagram_batch - Receive a batch of datagram skbuff
+ *	@sk: socket
+ *	@flags: MSG_ flags
+ *	@batch: maximum batch length
+ *	@bulk_destructor: invoked under the receive lock on successful dequeue
+ *	@err: error code returned
+ *	@last: set to last peeked message to inform the wait function
+ *	       what to look for when peeking
+ *
+ * like __skb_try_recv_datagram, but dequeue a full batch up to the specified
+ * max length. Returned skbs are linked and the list is NULL terminated.
+ * Peeking is not supported.
+ */
+struct sk_buff *__skb_try_recv_datagram_batch(struct sock *sk,
+					      unsigned int flags,
+					      unsigned int batch,
+					      void (*bulk_destructor)(
+						     struct sock *sk, int size),
+					      int *err)
+{
+	unsigned int datagrams = 0, totalsize = 0;
+	struct sk_buff *skb, *last, *first;
+	struct sk_buff_head *queue;
+
+	*err = sock_error(sk);
+	if (*err)
+		return NULL;
+
+	queue = &sk->sk_receive_queue;
+	spin_lock_bh(&queue->lock);
+	for (;;) {
+		if (!skb_queue_empty(queue))
+			break;
+
+		spin_unlock_bh(&queue->lock);
+
+		if (!sk_can_busy_loop(sk) ||
+		    !sk_busy_loop(sk, flags & MSG_DONTWAIT))
+			goto no_packets;
+
+		spin_lock_bh(&queue->lock);
+	}
+
+	last = (struct sk_buff *)queue;
+	first = (struct sk_buff *)queue->next;
+	skb_queue_walk(queue, skb) {
+		last = skb;
+		totalsize += skb->truesize;
+		if (++datagrams == batch)
+			break;
+	}
+	__skb_queue_unsplice(first, last, datagrams, queue);
+
+	if (bulk_destructor)
+		bulk_destructor(sk, totalsize);
+	spin_unlock_bh(&queue->lock);
+	return first;
+
+no_packets:
+	*err = -EAGAIN;
+	return NULL;
+}
+EXPORT_SYMBOL(__skb_try_recv_datagram_batch);
+
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
 	consume_skb(skb);
diff --git a/net/socket.c b/net/socket.c
index 49e6cd6..ceb627b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2220,6 +2220,66 @@ long __sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
  *     Linux recvmmsg interface
  */
 
+int recvmmsg_ctx_from_user(struct sock *sk, struct mmsghdr __user *mmsg,
+			   unsigned int flags, int nosec,
+			   struct recvmmsg_ctx *ctx)
+{
+	struct user_msghdr __user *msg = (struct user_msghdr __user *)mmsg;
+	struct compat_msghdr __user *msg_compat;
+	ssize_t err;
+
+	ctx->iov = ctx->iovstack;
+	msg_compat = (struct compat_msghdr __user *)mmsg;
+	err = copy_msghdr_from_user_gen(&ctx->msg_sys, flags, msg_compat, msg,
+					&ctx->uaddr, &ctx->iov, &ctx->addr);
+	if (err < 0) {
+		ctx->iov = NULL;
+		return err;
+	}
+
+	ctx->cmsg_ptr = (unsigned long)ctx->msg_sys.msg_control;
+	ctx->msg_sys.msg_flags = flags & MSG_CMSG_MASK;
+
+	/* We assume all kernel code knows the size of sockaddr_storage */
+	ctx->msg_sys.msg_namelen = 0;
+
+	if (nosec)
+		return 0;
+
+	return security_socket_recvmsg(sk->sk_socket, &ctx->msg_sys,
+				      msg_data_left(&ctx->msg_sys), flags);
+}
+
+int recvmmsg_ctx_to_user(struct mmsghdr __user **mmsg_ptr, int len,
+			 unsigned int flags, struct recvmmsg_ctx *ctx)
+{
+	struct compat_mmsghdr __user *mmsg_compat;
+	struct mmsghdr __user *mmsg = *mmsg_ptr;
+	int err;
+
+	mmsg_compat = (struct compat_mmsghdr __user *)mmsg;
+	err = copy_msghdr_to_user_gen(&ctx->msg_sys, flags,
+				      &mmsg_compat->msg_hdr, &mmsg->msg_hdr,
+				      ctx->uaddr, &ctx->addr, ctx->cmsg_ptr);
+	if (err)
+		return err;
+
+	if (MSG_CMSG_COMPAT & flags) {
+		err = __put_user(len, &mmsg_compat->msg_len);
+		if (err < 0)
+			return err;
+
+		*mmsg_ptr = (struct mmsghdr __user *)(mmsg_compat + 1);
+	} else {
+		err = put_user(len, &mmsg->msg_len);
+		if (err < 0)
+			return err;
+
+		*mmsg_ptr = mmsg + 1;
+	}
+	return err;
+}
+
 static int __proto_recvmmsg(struct socket *sock, struct mmsghdr __user *ummsg,
 			    unsigned int *vlen, unsigned int flags,
 			    struct timespec *timeout,
-- 
1.8.3.1

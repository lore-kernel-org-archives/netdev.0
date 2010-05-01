From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 074/100] c/r: add support for listening INET sockets (v2)
Date: Sat,  1 May 2010 10:15:56 -0400
Message-ID: <1272723382-19470-75-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Smith <danms@us.ibm.com>

This is an incremental step towards supporting checkpoint/restart on
AF_INET sockets.  In this scenario, any sockets that were in TCP_LISTEN
state are restored as they were.  Any that were connected are forced to
TCP_CLOSE.  This should cover a range of use cases that involve
applications that are tolerant of such an interruption.

Changelog [v21]:
  - Do not include checkpoint_hdr.h explicitly
Changelog [v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changes in v2:
 - Fix whitespace
 - Fix return in inet_checkpoint() on failed ckpt_hdr_get_type()
 - Fix garbage free on error path of inet_read_buffer()
 - Fix unnecessary ret=0 in inet_read_buffers()
 - Add inet_precheck() (like unix) to validate the address lengths (and
   more later)

Cc: netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 Documentation/checkpoint/readme.txt |   21 ++++
 include/linux/checkpoint_hdr.h      |   15 +++
 include/net/inet_common.h           |   13 +++
 net/checkpoint.c                    |    9 ++
 net/ipv4/Makefile                   |    1 +
 net/ipv4/af_inet.c                  |    6 +
 net/ipv4/checkpoint.c               |  189 +++++++++++++++++++++++++++++++++++
 7 files changed, 254 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv4/checkpoint.c

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index 4fa5560..2548bb4 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -344,6 +344,27 @@ we will be forced to more carefully review each of those features.
 However, this can be controlled with a sysctl-variable.
 
 
+Sockets
+=======
+
+For AF_UNIX sockets, both endpoints must be within the checkpointed
+task set to maintain a connected state after restart.  UNIX sockets
+that are in the process of passing a descriptor will cause the
+checkpoint to fail with -EBUSY indicating a transient state that
+cannot be checkpointed.  Listening sockets with an unaccepted peer
+will also cause an -EBUSY result.
+
+AF_INET sockets with endpoints outside the checkpointed task set may
+remain open if care is taken to avoid TCP timeouts and resets.
+Careful use of a virtual IP address can help avoid emission of an RST
+to the non-checkpointed endpoint.  If desired, the
+RESTART_SOCK_LISTENONLY flag may be passed to the restart syscall
+which will cause all connected AF_INET sockets to be closed during the
+restore process.  Listening sockets will still be restored to their
+original state, which makes this mode a candidate for something like
+an HTTP server.
+
+
 Kernel interfaces
 =================
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2be2d2c..07934ee 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/un.h>
+#include <linux/in.h>
 
 #ifndef CONFIG_CHECKPOINT
 #error linux/checkpoint_hdr.h included directly (without CONFIG_CHECKPOINT)
@@ -21,10 +22,14 @@
 
 #else /* __KERNEL__ */
 
+#else
+
 #include <sys/types.h>
 #include <linux/types.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <sys/un.h>
+#include <netinet/in.h>
 
 #endif
 
@@ -159,6 +164,8 @@ enum {
 #define CKPT_HDR_SOCKET_FRAG CKPT_HDR_SOCKET_FRAG
 	CKPT_HDR_SOCKET_UNIX,
 #define CKPT_HDR_SOCKET_UNIX CKPT_HDR_SOCKET_UNIX
+	CKPT_HDR_SOCKET_INET,
+#define CKPT_HDR_SOCKET_INET CKPT_HDR_SOCKET_INET
 
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
@@ -577,6 +584,14 @@ struct ckpt_hdr_socket_unix {
 	struct sockaddr_un raddr;
 } __attribute__ ((aligned(8)));
 
+struct ckpt_hdr_socket_inet {
+	struct ckpt_hdr h;
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr_in laddr;
+	struct sockaddr_in raddr;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_file_socket {
 	struct ckpt_hdr_file common;
 	__s32 sock_objref;
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 18c7732..bf04e6e 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -45,6 +45,19 @@ extern int			inet_ctl_sock_create(struct sock **sk,
 						     unsigned char protocol,
 						     struct net *net);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
+extern int inet_collect(struct ckpt_ctx *ctx, struct socket *sock);
+extern int inet_restore(struct ckpt_ctx *cftx, struct socket *sock,
+			struct ckpt_hdr_socket *h);
+#else
+#define inet_checkpoint NULL
+#define inet_collect NULL
+#define inet_restore NULL
+#endif /* CONFIG_CHECKPOINT */
+
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
 	sk_release_kernel(sk);
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9116d7a..d972044 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -930,6 +930,15 @@ static void *restore_sock(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto err;
 
+	if ((h->sock_common.family == AF_INET) &&
+	    (h->sock.state != TCP_LISTEN)) {
+		/* Temporary hack to enable restore of TCP_LISTEN sockets
+		 * while forcing anything else to a closed state
+		 */
+		sock->sk->sk_state = TCP_CLOSE;
+		sock->state = SS_UNCONNECTED;
+	}
+
 	ckpt_hdr_put(ctx, h);
 	return sock->sk;
  err:
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 80ff87c..c00d8ce 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f713574..8b7d3dd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -876,6 +876,9 @@ const struct proto_ops inet_stream_ops = {
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
 	.splice_read	   = tcp_splice_read,
+	.checkpoint        = inet_checkpoint,
+	.restore           = inet_restore,
+	.collect           = inet_collect,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
@@ -902,6 +905,9 @@ const struct proto_ops inet_dgram_ops = {
 	.recvmsg	   = sock_common_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.checkpoint        = inet_checkpoint,
+	.restore           = inet_restore,
+	.collect           = inet_collect,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
new file mode 100644
index 0000000..0b62a15
--- /dev/null
+++ b/net/ipv4/checkpoint.c
@@ -0,0 +1,189 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author(s): Dan Smith <danms@us.ibm.com>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/namei.h>
+#include <linux/tcp.h>
+#include <linux/in.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <net/tcp_states.h>
+#include <net/tcp.h>
+
+struct dq_sock {
+	struct ckpt_ctx *ctx;
+	struct sock *sk;
+};
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	struct sock *sk;
+};
+
+int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct ckpt_hdr_socket_inet *in;
+	int ret;
+
+	in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
+	if (!in)
+		return -EINVAL;
+
+	ret = ckpt_sock_getnames(ctx, sock,
+				(struct sockaddr *)&in->laddr, &in->laddr_len,
+				(struct sockaddr *)&in->raddr, &in->raddr_len);
+	if (ret)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
+ out:
+	ckpt_hdr_put(ctx, in);
+
+	return ret;
+}
+
+int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	return ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
+}
+
+static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct sk_buff *skb = NULL;
+
+	skb = sock_restore_skb(ctx);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	skb_queue_tail(queue, skb);
+	return skb->len;
+}
+
+static int inet_read_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct ckpt_hdr_socket_queue *h;
+	int ret = 0;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	for (i = 0; i < h->skb_count; i++) {
+		ret = inet_read_buffer(ctx, queue);
+		ckpt_debug("read inet buffer %i: %i", i, ret);
+		if (ret < 0)
+			goto out;
+
+		if (ret > h->total_bytes) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "Buffers exceeded claim");
+			goto out;
+		}
+
+		h->total_bytes -= ret;
+	}
+
+	ret = h->skb_count;
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int inet_deferred_restore_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *sk = dq->sk;
+	int ret;
+
+	ret = inet_read_buffers(ctx, &sk->sk_receive_queue);
+	ckpt_debug("(R) inet_read_buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = inet_read_buffers(ctx, &sk->sk_write_queue);
+	ckpt_debug("(W) inet_read_buffers: %i\n", ret);
+
+	return ret;
+}
+
+static int inet_defer_restore_buffers(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk = sk;
+
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      inet_deferred_restore_buffers, NULL);
+}
+
+static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
+{
+	if (in->laddr_len > sizeof(struct sockaddr_in)) {
+		ckpt_debug("laddr_len is too big\n");
+		return -EINVAL;
+	}
+
+	if (in->raddr_len > sizeof(struct sockaddr_in)) {
+		ckpt_debug("raddr_len is too big\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int inet_restore(struct ckpt_ctx *ctx,
+		 struct socket *sock,
+		 struct ckpt_hdr_socket *h)
+{
+	struct ckpt_hdr_socket_inet *in;
+	int ret = 0;
+
+	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
+	if (IS_ERR(in))
+		return PTR_ERR(in);
+
+	ret = inet_precheck(sock, in);
+	if (ret < 0)
+		goto out;
+
+	/* Listening sockets and those that are closed but have a local
+	 * address need to call bind()
+	 */
+	if ((h->sock.state == TCP_LISTEN) ||
+	    ((h->sock.state == TCP_CLOSE) && (in->laddr_len > 0))) {
+		sock->sk->sk_reuse = 2;
+		inet_sk(sock->sk)->freebind = 1;
+		ret = sock->ops->bind(sock,
+				      (struct sockaddr *)&in->laddr,
+				      in->laddr_len);
+		ckpt_debug("inet bind: %i\n", ret);
+		if (ret < 0)
+			goto out;
+
+		if (h->sock.state == TCP_LISTEN) {
+			ret = sock->ops->listen(sock, h->sock.backlog);
+			ckpt_debug("inet listen: %i\n", ret);
+			if (ret < 0)
+				goto out;
+		}
+	} else {
+		if (!sock_flag(sock->sk, SOCK_DEAD))
+			ret = inet_defer_restore_buffers(ctx, sock->sk);
+	}
+ out:
+	ckpt_hdr_put(ctx, in);
+
+	return ret;
+}
+
-- 
1.6.3.3

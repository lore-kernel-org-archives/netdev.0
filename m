From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Tue,  7 Jul 2009 12:26:15 -0700
Message-ID: <1246994776-1882-2-git-send-email-danms@us.ibm.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246994776-1882-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports socketpair()s, path-based, and
abstract sockets.

Changes in v5:
  - Change laddr and raddr buffers in socket header to be long enough
    for INET6 addresses
  - Place socket.c and sock.h function definitions inside #ifdef
    CONFIG_CHECKPOINT
  - Add explicit check in sock_unix_makeaddr() to refuse if the
    checkpoint image specifies an addr length of 0
  - Split sock_unix_restart() into a few pieces to facilitate:
  - Changed behavior of the unix restore code so that unlinked LISTEN
    sockets don't do a bind()...unlink()
  - Save the base path of a bound socket's path so that we can chdir()
    to the base before bind() if it is a relative path
  - Call bind() for any socket that is not established but has a
    non-zero-length local address
  - Enforce the current sysctl limit on socket buffer size during restart
    unless the user holds CAP_NET_ADMIN
  - Unlink a path-based socket before calling bind()

Changes in v4:
  - Changed the signdness of rcvlowat, rcvtimeo, sndtimeo, and backlog
    to match their struct sock definitions.  This should avoid issues
    with sign extension.
  - Add a sock_cptrst_verify() function to be run at restore time to
    validate several of the values in the checkpoint image against
    limits, flag masks, etc.
  - Write an error string with ctk_write_err() in the obscure cases
  - Don't write socket buffers for listen sockets
  - Sanity check address lengths before we agree to allocate memory
  - Check the result of inserting the peer object in the objhash on
    restart
  - Check return value of sock_cptrst() on restart
  - Change logic in remote getname() phase of checkpoint to not fail for
    closed (et al) sockets
  - Eliminate the memory copy while reading socket buffers on restart

Changes in v3:
  - Move sock_file_checkpoint() above sock_file_restore()
  - Change __sock_file_*() functions to do_sock_file_*()
  - Adjust some of the struct cr_hdr_socket alignment
  - Improve the sock_copy_buffers() algorithm to avoid locking the source
    queue for the entire operation
  - Fix alignment in the socket header struct(s)
  - Move the per-protocol structure (ckpt_hdr_socket_un) out of the
    common socket header and read/write it separately
  - Fix missing call to sock_cptrst() in restore path
  - Break out the socket joining into another function
  - Fix failure to restore the socket address thus fixing getname()
  - Check the state values on restart
  - Fix case of state being TCP_CLOSE, which allows dgram sockets to be
    properly connected (if appropriate) to their peer and maintain the
    sockaddr for getname() operation
  - Fix restoring a listening socket that has been unlink()'d
  - Fix checkpointing sockets with an in-flight FD-passing SKB.  Fail
    with EBUSY.
  - Fix checkpointing listening sockets with an unaccepted connection.
    Fail with EBUSY.
  - Changed 'un' to 'unix' in function and structure names

Changes in v2:
  - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
    to be rather common in other uses of skb_copy())
  - Move the ckpt_hdr_socket structure definition to linux/socket.h
  - Fix whitespace issue
  - Move sock_file_checkpoint() to net/socket.c for symmetry

Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   27 ++
 include/linux/checkpoint_hdr.h |   13 +
 include/linux/socket.h         |   62 ++++
 include/net/sock.h             |   11 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  732 ++++++++++++++++++++++++++++++++++++++++
 net/socket.c                   |   86 +++++
 8 files changed, 940 insertions(+), 0 deletions(-)
 create mode 100644 net/checkpoint.c

diff --git a/checkpoint/files.c b/checkpoint/files.c
index c32b95b..176d3fd 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 
 /**************************************************************************
@@ -519,6 +520,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_PIPE,
 		.restore = pipe_file_restore,
 	},
+	/* socket */
+	{
+		.file_name = "SOCKET",
+		.file_type = CKPT_FILE_SOCKET,
+		.restore = sock_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index f604655..17686b5 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -20,6 +20,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -264,6 +265,22 @@ static int obj_groupinfo_users(void *ptr)
 	return atomic_read(&((struct group_info *) ptr)->usage);
 }
 
+static int obj_sock_grab(void *ptr)
+{
+	sock_hold((struct sock *) ptr);
+	return 0;
+}
+
+static void obj_sock_drop(void *ptr)
+{
+	sock_put((struct sock *) ptr);
+}
+
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -391,6 +408,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* sock object */
+	{
+		.obj_name = "SOCKET",
+		.obj_type = CKPT_OBJ_SOCK,
+		.ref_drop = obj_sock_drop,
+		.ref_grab = obj_sock_grab,
+		.ref_users = obj_sock_users,
+		.checkpoint = sock_file_checkpoint,
+		.restore = sock_file_restore,
+	},
 };
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 37bae3d..f59b071 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -88,6 +88,12 @@ enum {
 
 	CKPT_HDR_SIGHAND = 601,
 
+	CKPT_HDR_FD_SOCKET = 601,
+	CKPT_HDR_SOCKET,
+	CKPT_HDR_SOCKET_BUFFERS,
+	CKPT_HDR_SOCKET_BUFFER,
+	CKPT_HDR_SOCKET_UNIX,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -121,6 +127,7 @@ enum obj_type {
 	CKPT_OBJ_CRED,
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
+	CKPT_OBJ_SOCK,
 	CKPT_OBJ_MAX
 };
 
@@ -316,6 +323,7 @@ enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
+	CKPT_FILE_SOCKET,
 	CKPT_FILE_MAX
 };
 
@@ -339,6 +347,11 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_socket {
+	struct ckpt_hdr_file common;
+	__u16 family;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_file_pipe_state {
 	struct ckpt_hdr h;
 	__s32 pipe_len;
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..e7d64eb 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
 #include <linux/uio.h>			/* iovec support		*/
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
+#include <linux/checkpoint_hdr.h>	/* ckpt_hdr			*/
 
 #ifdef __KERNEL__
 # ifdef CONFIG_PROC_FS
@@ -323,5 +324,66 @@ extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *ka
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
 #endif
+
+#define CKPT_UNIX_LINKED 1
+#define CKPT_UNIX_HASCWD 2
+struct ckpt_hdr_socket_unix {
+	struct ckpt_hdr h;
+	__u32 this;
+	__u32 peer;
+	__u32 flags;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	struct ckpt_socket { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct ckpt_sock_common { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u16 family;
+		__u8 state;
+		__u8 reuse;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct ckpt_sock { /* struct sock */
+		__s64 rcvlowat;
+		__s64 rcvtimeo;
+		__s64 sndtimeo;
+		__u64 flags;
+		__u64 lingertime;
+
+		__u32 err;
+		__u32 err_soft;
+		__u32 priority;
+		__s32 rcvbuf;
+		__s32 sndbuf;
+		__u16 type;
+		__s16 backlog;
+
+		__u8 protocol;
+		__u8 state;
+		__u8 shutdown;
+		__u8 userlocks;
+		__u8 no_check;
+	} sock __attribute__ ((aligned(8)));
+
+	/* common to all supported families */
+	__u32 laddr_len;
+	__u32 raddr_len;
+	/* inet6 socket addresses are the largest, at 28 bytes */
+	char laddr[28];
+	char raddr[28];
+
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+} __attribute__ ((aligned(8)));
+
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..1657655 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1482,4 +1482,15 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+#ifdef CONFIG_CHECKPOINT
+/* Checkpoint/Restart Functions */
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
+extern void *sock_file_restore(struct ckpt_ctx *);
+extern struct socket *do_sock_file_restore(struct ckpt_ctx *,
+					   struct ckpt_hdr_socket *);
+extern int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+#endif
+
 #endif	/* _SOCK_H */
diff --git a/net/Makefile b/net/Makefile
index 9e00a55..c226ed1 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -65,3 +65,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
new file mode 100644
index 0000000..0ff1656
--- /dev/null
+++ b/net/checkpoint.c
@@ -0,0 +1,732 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/socket.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/namei.h>
+#include <linux/syscalls.h>
+#include <linux/sched.h>
+#include <linux/fs_struct.h>
+
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* Size of an empty struct sockaddr_un */
+#define UNIX_LEN_EMPTY 2
+
+static inline int sock_unix_need_cwd(struct sockaddr_un *a)
+{
+	return (a->sun_path[0] != '/');
+}
+
+static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
+{
+	int count = 0;
+	struct sk_buff *skb;
+
+	skb_queue_walk(from, skb) {
+		struct sk_buff *tmp;
+
+		tmp = dev_alloc_skb(skb->len);
+		if (!tmp)
+			return -ENOMEM;
+
+		spin_lock(&from->lock);
+		skb_morph(tmp, skb);
+		spin_unlock(&from->lock);
+
+		skb_queue_tail(to, tmp);
+		count++;
+	}
+
+	return count;
+}
+
+static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				struct sk_buff_head *queue)
+{
+	struct sk_buff *skb;
+	int ret = 0;
+
+	skb_queue_walk(queue, skb) {
+		if (UNIXCB(skb).fp) {
+			ckpt_write_err(ctx, "fd-passing is not supported");
+			return -EBUSY;
+		}
+
+		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
+					  CKPT_HDR_SOCKET_BUFFER);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	struct sk_buff_head tmpq;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
+	if (!h)
+		goto out;
+
+	skb_queue_head_init(&tmpq);
+
+	h->skb_count = sock_copy_buffers(queue, &tmpq);
+	if (h->skb_count < 0) {
+		ret = h->skb_count;
+		goto out;
+	}
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (!ret)
+		ret = __sock_write_buffers(ctx, &tmpq);
+
+ out:
+	ckpt_hdr_put(ctx, h);
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
+			       struct sock *sock,
+			       const char *sockpath)
+{
+	struct path path;
+	char *buf;
+	char *fqpath;
+	char *delim;
+	int offset;
+	int ret = -ENOENT;
+
+	buf = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	path.dentry = unix_sk(sock)->dentry;
+	path.mnt = unix_sk(sock)->mnt;
+
+	fqpath = d_path(&path, buf, PATH_MAX);
+	if (!fqpath)
+		goto out;
+
+	offset = strlen(fqpath) - strlen(sockpath);
+	if (offset <= 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	delim = &fqpath[offset];
+	*delim = '\0';
+
+	ret = ckpt_write_obj_type(ctx, fqpath, strlen(fqpath),
+				  CKPT_HDR_FILE_NAME);
+ out:
+	kfree(buf);
+	return ret;
+}
+
+static char *sock_unix_read_cwd(struct ckpt_ctx *ctx)
+{
+	char *path;
+	char *hpath;
+	struct ckpt_hdr *h;
+
+	h = ckpt_read_buf_type(ctx, PATH_MAX, CKPT_HDR_FILE_NAME);
+	hpath = (char *) (h + 1);
+	if (IS_ERR(h))
+		return (char *) h;
+
+	path = kzalloc(strlen(hpath) + 1, GFP_KERNEL);
+	if (!path) {
+		path = ERR_PTR(ENOMEM);
+		goto out;
+	}
+
+	memcpy(path, hpath, strlen(hpath));
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return path;
+}
+
+static int sock_unix_checkpoint(struct ckpt_ctx *ctx,
+			        struct sock *sock,
+			        struct ckpt_hdr_socket *h)
+{
+	struct unix_sock *sk = unix_sk(sock);
+	struct unix_sock *pr = unix_sk(sk->peer);
+	struct ckpt_hdr_socket_unix *un;
+	int new;
+	int ret = -ENOMEM;
+
+	if ((sock->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&sock->sk_receive_queue)) {
+		ckpt_write_err(ctx, "listening socket has unaccepted peers");
+		return -EBUSY;
+	}
+
+	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (!un)
+		goto out;
+
+	if (sk->dentry && (sk->dentry->d_inode->i_nlink > 0))
+		un->flags |= CKPT_UNIX_LINKED;
+
+	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
+	if (un->this < 0)
+		goto out;
+
+	if (sk->peer)
+		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
+	else
+		un->peer = 0;
+
+	if (un->peer < 0) {
+		ret = un->peer;
+		goto out;
+	}
+
+ 	if ((sk->dentry) && sock_unix_need_cwd((struct sockaddr_un *) h->laddr))
+		un->flags |= CKPT_UNIX_HASCWD;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
+	if (ret < 0)
+		goto out;
+
+	if (un->flags & CKPT_UNIX_HASCWD) {
+		struct sockaddr_un *un = (struct sockaddr_un *) h->laddr;
+		ret = sock_unix_write_cwd(ctx, sock, un->sun_path);
+	}
+ out:
+	ckpt_hdr_put(ctx, un);
+
+	return ret;
+}
+
+static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
+{
+	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
+		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
+
+	if (h->sock.shutdown & ~SHUTDOWN_MASK)
+		return -EINVAL;
+	if (h->sock.userlocks & ~userlocks_mask)
+		return -EINVAL;
+	if (h->sock.sndtimeo < 0)
+		return -EINVAL;
+	if (h->sock.rcvtimeo < 0)
+		return -EINVAL;
+	if ((h->sock.userlocks & SOCK_SNDBUF_LOCK) &&
+	    ((h->sock.sndbuf < SOCK_MIN_SNDBUF) ||
+	     (h->sock.sndbuf > sysctl_wmem_max)))
+		return -EINVAL;
+	if ((h->sock.userlocks & SOCK_RCVBUF_LOCK) &&
+	    ((h->sock.rcvbuf < SOCK_MIN_RCVBUF) ||
+	     (h->sock.rcvbuf > sysctl_rmem_max)))
+		return -EINVAL;
+	if ((h->sock.flags & SOCK_LINGER) &&
+	    (h->sock.lingertime > MAX_SCHEDULE_TIMEOUT))
+		return -EINVAL;
+	/* Current highest errno is ~530; this should provide some sanity */
+	if ((h->sock.err < 0) || (h->sock.err > 1024))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sock_cptrst(struct ckpt_ctx *ctx,
+		       struct sock *sock,
+		       struct ckpt_hdr_socket *h,
+		       int op)
+{
+	if (sock->sk_socket) {
+		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
+		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
+	}
+
+	CKPT_COPY(op, h->sock_common.reuse, sock->sk_reuse);
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
+
+	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sock->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
+	CKPT_COPY(op, h->sock.priority, sock->sk_priority);
+	CKPT_COPY(op, h->sock.rcvlowat, sock->sk_rcvlowat);
+	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
+	CKPT_COPY(op, h->sock.rcvtimeo, sock->sk_rcvtimeo);
+	CKPT_COPY(op, h->sock.sndtimeo, sock->sk_sndtimeo);
+	CKPT_COPY(op, h->sock.rcvbuf, sock->sk_rcvbuf);
+	CKPT_COPY(op, h->sock.sndbuf, sock->sk_sndbuf);
+	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
+	CKPT_COPY(op, h->sock.lingertime, sock->sk_lingertime);
+	CKPT_COPY(op, h->sock.type, sock->sk_type);
+	CKPT_COPY(op, h->sock.state, sock->sk_state);
+
+	if ((h->socket.state == SS_CONNECTED) &&
+	    (h->sock.state != TCP_ESTABLISHED)) {
+		ckpt_write_err(ctx, "socket/sock in inconsistent state: %i/%i",
+			       h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->sock.state < TCP_ESTABLISHED) ||
+		   (h->sock.state >= TCP_MAX_STATES)) {
+		ckpt_write_err(ctx, "sock in invalid state: %i", h->sock.state);
+		return -EINVAL;
+	} else if ((h->socket.state < SS_FREE) ||
+		   (h->socket.state > SS_DISCONNECTING)) {
+		ckpt_write_err(ctx, "socket in invalid state: %i",
+			       h->socket.state);
+		return -EINVAL;
+	}
+
+	if (op == CKPT_CPT)
+		return sock_cptrst_verify(h);
+	else
+		return 0;
+}
+
+int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct socket *socket = file->private_data;
+	struct sock *sock = socket->sk;
+	struct ckpt_hdr_socket *h;
+	int ret = 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (!h)
+		return -ENOMEM;
+
+	h->laddr_len = sizeof(h->laddr);
+	h->raddr_len = sizeof(h->raddr);
+
+	if (socket->ops->getname(socket, (struct sockaddr *)&h->laddr,
+				 &h->laddr_len, 0)) {
+		ckpt_write_err(ctx, "Unable to getname of local");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (socket->ops->getname(socket, (struct sockaddr *)&h->raddr,
+				 &h->raddr_len, 1)) {
+		if ((sock->sk_type != SOCK_DGRAM) &&
+		    (sock->sk_state == TCP_ESTABLISHED)) {
+			ckpt_write_err(ctx, "Unable to getname of remote");
+			ret = -EINVAL;
+			goto out;
+		}
+		h->raddr_len = 0;
+	}
+
+	ret = sock_cptrst(ctx, sock, h, CKPT_CPT);
+	if (ret)
+		goto out;
+
+	if (sock->sk_family == AF_UNIX) {
+		ret = sock_unix_checkpoint(ctx, sock, h);
+		if (ret)
+			goto out;
+	} else {
+		ckpt_write_err(ctx, "unsupported socket family %i",
+			       sock->sk_family);
+		ret = EINVAL;
+		goto out;
+	}
+
+	if (sock->sk_state != TCP_LISTEN) {
+		ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
+		if (ret)
+			goto out;
+
+		ret = sock_write_buffers(ctx, &sock->sk_write_queue);
+		if (ret)
+			goto out;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int sock_read_buffer(struct ckpt_ctx *ctx,
+			    struct sock *sock,
+			    struct sk_buff **skb)
+{
+	struct ckpt_hdr h;
+	int ret = 0;
+	int len;
+
+	len = _ckpt_read_hdr_type(ctx, &h, CKPT_HDR_SOCKET_BUFFER);
+	if (len < 0)
+		return len;
+
+	if (len > SKB_MAX_ALLOC) {
+		ckpt_debug("Socket buffer too big (%i > %lu)",
+			   len, SKB_MAX_ALLOC);
+		return -ENOSPC;
+	}
+
+	*skb = sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);
+	if (*skb == NULL)
+		return ENOMEM;
+
+	ret = _ckpt_read_payload(ctx, &h, skb_put(*skb, len));
+
+	return ret;
+}
+
+static int sock_read_buffers(struct ckpt_ctx *ctx,
+			     struct sock *sock,
+			     struct sk_buff_head *queue,
+			     uint32_t skb_limit)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	int ret = 0;
+	int i;
+	uint32_t total = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
+	if (IS_ERR(h)) {
+		ret = PTR_ERR(h);
+		goto out;
+	}
+
+	for (i = 0; i < h->skb_count; i++) {
+		struct sk_buff *skb = NULL;
+
+		ret = sock_read_buffer(ctx, sock, &skb);
+		if (ret)
+			break;
+
+		skb_queue_tail(queue, skb);
+
+		total += skb->len;
+		if (skb_limit && (total > skb_limit)) {
+			ckpt_write_err(ctx,
+				       "Socket buffers exceeded limit of %u",
+				       total);
+			ret = -ENOSPC;
+			goto out;
+		}
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static struct unix_address *sock_unix_makeaddr(struct sockaddr_un *sun_addr,
+					       unsigned len)
+{
+	struct unix_address *addr;
+
+	if (len > UNIX_PATH_MAX)
+		return ERR_PTR(ENOSPC);
+	else if (len == 0)
+		return ERR_PTR(ENOSPC);
+
+	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
+	if (!addr)
+		return ERR_PTR(ENOMEM);
+
+	memcpy(addr->name, sun_addr, len);
+	addr->len = len;
+	atomic_set(&addr->refcnt, 1);
+
+	return addr;
+}
+
+static int sock_unix_join(struct sock *a,
+			  struct sock *b,
+			  struct ckpt_hdr_socket *h)
+{
+	struct unix_address *addr;
+
+	sock_hold(a);
+	sock_hold(b);
+
+	unix_sk(a)->peer = b;
+	unix_sk(b)->peer = a;
+
+	a->sk_peercred.pid = task_tgid_vnr(current);
+	current_euid_egid(&a->sk_peercred.uid,
+			  &a->sk_peercred.gid);
+
+	b->sk_peercred.pid = task_tgid_vnr(current);
+	current_euid_egid(&b->sk_peercred.uid,
+			  &b->sk_peercred.gid);
+
+	if (h->laddr_len == UNIX_LEN_EMPTY)
+		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->raddr,
+					  h->raddr_len);
+	else if (h->raddr_len == UNIX_LEN_EMPTY)
+		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->laddr,
+					  h->laddr_len);
+	if (IS_ERR(addr))
+	    return PTR_ERR(addr);
+
+	atomic_inc(&addr->refcnt); /* Held by both ends */
+	unix_sk(a)->addr = unix_sk(b)->addr = addr;
+
+	return 0;
+}
+
+static int sock_unix_restart_connected(struct ckpt_ctx *ctx,
+				       struct ckpt_hdr_socket *h,
+				       struct ckpt_hdr_socket_unix *un,
+				       struct socket *socket)
+{
+	struct sock *this = socket->sk;
+	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
+	int ret;
+
+	if (!IS_ERR(peer)) {
+		/* We're last, so join with peer */
+		ret = sock_unix_join(this, peer, h);
+	} else if (PTR_ERR(peer) == -EINVAL) {
+		/* We're first, so add our socket and wait for peer */
+		ret = ckpt_obj_insert(ctx, socket->sk, un->this, CKPT_OBJ_SOCK);
+		if (ret >= 0)
+			ret = 0;
+	} else {
+		ret = PTR_ERR(peer);
+	}
+
+	return ret;
+}
+
+static int sock_unix_unlink(const char *name)
+{
+	struct path spath;
+	struct path ppath;
+	int ret;
+
+	ret = kern_path(name, 0, &spath);
+	if (ret)
+		return ret;
+
+	ret = kern_path(name, LOOKUP_PARENT, &ppath);
+	if (ret)
+		goto out_s;
+
+	if (!spath.dentry) {
+		ckpt_debug("No dentry found for %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	if (!ppath.dentry || !ppath.dentry->d_inode) {
+		ckpt_debug("No inode for parent of %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	ret = vfs_unlink(ppath.dentry->d_inode, spath.dentry);
+ out_p:
+	path_put(&ppath);
+ out_s:
+	path_put(&spath);
+
+	return ret;
+}
+
+/* Call bind() for socket, optionally changing (temporarily) to @path first
+ * if non-NULL
+ */
+static int sock_unix_chdir_and_bind(struct socket *socket,
+				    const char *path,
+				    struct sockaddr *addr,
+				    unsigned long addrlen)
+{
+	struct sockaddr_un *un = (struct sockaddr_un *)addr;
+	int ret;
+	struct path cur;
+	struct path dir;
+
+	if (path) {
+		ckpt_debug("switching to cwd %s for unix bind", path);
+
+		ret = kern_path(path, 0, &dir);
+		if (ret)
+			return ret;
+
+		ret = inode_permission(dir.dentry->d_inode,
+				       MAY_EXEC | MAY_ACCESS);
+		if (ret)
+			goto out;
+
+		write_lock(&current->fs->lock);
+		cur = current->fs->pwd;
+		current->fs->pwd = dir;
+		write_unlock(&current->fs->lock);
+	}
+
+	ret = sock_unix_unlink(un->sun_path);
+	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
+	if ((ret != 0) && (ret != ENOENT))
+		goto out;
+
+	ret = socket->ops->bind(socket, addr, addrlen);
+
+	if (path) {
+		write_lock(&current->fs->lock);
+		current->fs->pwd = cur;
+		write_unlock(&current->fs->lock);
+	}
+ out:
+	if (path)
+		path_put(&dir);
+
+	return ret;
+}
+
+static int sock_unix_fakebind(struct socket *socket,
+			      struct sockaddr_un *addr,
+			      unsigned long len)
+{
+	struct unix_address *uaddr;
+
+	uaddr = sock_unix_makeaddr(addr, len);
+	if (IS_ERR(uaddr))
+		return PTR_ERR(uaddr);
+
+	unix_sk(socket->sk)->addr = uaddr;
+
+	return 0;
+}
+
+static int sock_unix_bind(struct ckpt_hdr_socket *h,
+			  struct ckpt_hdr_socket_unix *un,
+			  struct socket *socket,
+			  const char *path)
+{
+	struct sockaddr *addr = (struct sockaddr *)&h->laddr;
+	struct sockaddr_un *uaddr = (struct sockaddr_un *)addr;
+	unsigned long len = h->laddr_len;
+
+	if (!(un->flags & CKPT_UNIX_LINKED))
+		return sock_unix_fakebind(socket, uaddr, len);
+	else if (uaddr->sun_path[0])
+		return sock_unix_chdir_and_bind(socket, path, addr, len);
+	else
+		return socket->ops->bind(socket, addr, len);
+}
+
+static int sock_unix_restart(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_socket *h,
+			     struct socket *socket)
+{
+	struct ckpt_hdr_socket_unix *un;
+	int ret = -EINVAL;
+	char *cwd = NULL;
+
+	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (IS_ERR(un))
+		return PTR_ERR(un);
+
+	if (un->peer < 0)
+		goto out;
+
+	if (un->flags & CKPT_UNIX_HASCWD) {
+		cwd = sock_unix_read_cwd(ctx);
+		if (IS_ERR(cwd)) {
+			ret = PTR_ERR(cwd);
+			goto out;
+		}
+	}
+
+	if ((h->sock.state != TCP_ESTABLISHED) && h->laddr_len) {
+		ret = sock_unix_bind(h, un, socket, cwd);
+		if (ret)
+			goto out;
+	}
+
+	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
+		ret = sock_unix_restart_connected(ctx, h, un, socket);
+	else if (h->sock.state == TCP_LISTEN)
+		ret = socket->ops->listen(socket, h->sock.backlog);
+	else
+		ckpt_write_err(ctx, "unsupported UNIX socket state %i",
+			       h->sock.state);
+ out:
+	ckpt_hdr_put(ctx, un);
+	kfree(cwd);
+	return ret;
+}
+
+struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_socket *h)
+{
+	struct socket *socket;
+	int ret;
+
+	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	if (h->sock_common.family == AF_UNIX) {
+		ret = sock_unix_restart(ctx, h, socket);
+		ckpt_debug("sock_unix_restart: %i\n", ret);
+	} else {
+		ckpt_write_err(ctx, "unsupported family %i\n",
+			       h->sock_common.family);
+		ret = -EINVAL;
+	}
+
+	if (ret)
+		goto out;
+
+	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
+	if (ret)
+		goto out;
+
+	if (h->sock.state != TCP_LISTEN) {
+		struct sock *sk = socket->sk;
+		uint32_t rlimit = sysctl_rmem_max;
+		uint32_t wlimit = sysctl_wmem_max;
+
+		if (capable(CAP_NET_ADMIN))
+			rlimit = wlimit = 0;
+
+		ret = sock_read_buffers(ctx, socket->sk, &sk->sk_receive_queue,
+					rlimit);
+		if (ret)
+			goto out;
+
+		ret = sock_read_buffers(ctx, socket->sk, &sk->sk_write_queue,
+					wlimit);
+		if (ret)
+			goto out;
+	}
+ out:
+	if (ret) {
+		sock_release(socket);
+		socket = ERR_PTR(ret);
+	}
+
+	return socket;
+}
+
diff --git a/net/socket.c b/net/socket.c
index 791d71a..97950d6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -96,6 +96,9 @@
 #include <net/sock.h>
 #include <linux/netfilter.h>
 
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -140,6 +143,9 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =   sock_file_checkpoint,
+#endif
 };
 
 /*
@@ -415,6 +421,86 @@ int sock_map_fd(struct socket *sock, int flags)
 	return fd;
 }
 
+#ifdef CONFIG_CHECKPOINT
+int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_file_socket *h;
+	int ret;
+	struct file *file = ptr;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = do_sock_file_checkpoint(ctx, file);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static struct file *sock_alloc_attach_fd(struct socket *socket)
+{
+	struct file *file;
+	int err;
+
+	file = get_empty_filp();
+	if (!file)
+		return ERR_PTR(ENOMEM);
+
+	err = sock_attach_fd(socket, file, 0);
+	if (err < 0) {
+		put_filp(file);
+		file = ERR_PTR(err);
+	}
+
+	return file;
+}
+
+void *sock_file_restore(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_socket *h = NULL;
+	struct socket *socket = NULL;
+	struct file *file = NULL;
+	int err;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (IS_ERR(h))
+		return h;
+
+	socket = do_sock_file_restore(ctx, h);
+	if (IS_ERR(socket)) {
+		err = PTR_ERR(socket);
+		goto err_put;
+	}
+
+	file = sock_alloc_attach_fd(socket);
+	if (IS_ERR(file)) {
+		err = PTR_ERR(file);
+		goto err_release;
+	}
+
+	ckpt_hdr_put(ctx, h);
+
+	return file;
+
+ err_release:
+	sock_release(socket);
+ err_put:
+	ckpt_hdr_put(ctx, h);
+
+	return ERR_PTR(err);
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
-- 
1.6.2.2

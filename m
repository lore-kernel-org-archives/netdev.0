From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH] c/r: Add AF_UNIX support (v10)
Date: Wed, 12 Aug 2009 13:02:29 -0700
Message-ID: <1250107349-31960-1-git-send-email-danms@us.ibm.com>
Cc: containers@lists.osdl.org, Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: orenl@librato.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:53185 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753679AbZHLUAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 16:00:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports socketpair()s, path-based, and
abstract sockets.

Changes in v10:
  - Moved header structure definitions back to checkpoint_hdr.h
  - Moved AF_UNIX checkpoint/restart code to net/unix/checkpoint.c
  - Make sock_unix_*() functions only compile if CONFIG_UNIX=y
  - Add TODO for CONFIG_UNIX=m case

Changes in v9:
  - Fix double-free of skb's in the list and target holding queue in the
    error path of sock_copy_buffers()
  - Adjust use of ckpt_read_string() to match new signature

Changes in v8:
  - Fix stale dev_alloc_skb() from before the conversion to skb_clone()
  - Fix a couple of broken error paths
  - Fix memory leak of kvec.iov_base on successful return from sendmsg()
  - Fix condition for deciding when to run sock_cptrst_verify()
  - Fix buffer queue copy algorithm to hold the lock during walk(s)
  - Log the errno when either getname() or getpeer() fails
  - Add comments about ancillary messages in the UNIX queue
  - Add TODO comments for credential restore and flags via setsockopt()
  - Add TODO comment about strangely-connected dgram sockets and the use
    of sendmsg(peer)

Changes in v7:
  - Fix failure to free iov_base in error path of sock_read_buffer()
  - Change sock_read_buffer() to use _ckpt_read_obj_type() to get the
    header length and then use ckpt_kread() directly to read the payload
  - Change sock_read_buffers() to sock_unix_read_buffers() and break out
    some common functionality to better accommodate the subsequent INET
    patch
  - Generalize sock_unix_getnames() into sock_getnames() so INET can use it
  - Change skb_morph() to skb_clone() which uses the more common path and
    still avoids the copy
  - Add check to validate the socket type before creating socket
    on restore
  - Comment the CAP_NET_ADMIN override in sock_read_buffer_hdr
  - Strengthen the comment about priming the buffer limits
  - Change the objhash functions to deny direct checkpoint of sockets and
    remove the reference counting function
  - Change SOCKET_BUFFERS to SOCKET_QUEUE
  - Change this,peer objrefs to signed integers
  - Remove names from internal socket structures
  - Fix handling of sock_copy_buffers() result
  - Use ckpt_fill_fname() instead of d_path() for writing CWD
  - Use sock_getname() and sock_getpeer() for proper security hookage
  - Return -ENOSYS for unsupported socket families in checkpoint and restart
  - Use sock_setsockopt() and sock_getsockopt() where possible to save and
    restore socket option values
  - Check for SOCK_DESTROY flag in the global verify function because none
    of our supported socket types use it
  - Check for SOCK_USE_WRITE_QUEUE in AF_UNIX restore function because
    that flag should not be used on such a socket
  - Check socket state in UNIX restart path to validate the subset of valid
    values

Changes in v6:
  - Moved the socket addresses to the per-type header
  - Eliminated the HASCWD flag
  - Remove use of ckpt_write_err() in restart paths
  - Change the order in which buffers are read so that we can set the
    socket's limit equal to the size of the image's buffers (if appropriate)
    and then restore the original values afterwards.
  - Use the ckpt_validate_errno() helper
  - Add a check to make sure that we didn't restore a (UNIX) socket with
    any skb's in the send buffer
  - Fix up sock_unix_join() to not leave addr uninitialized for socketpair
  - Remove inclusion of checkpoint_hdr.h in the socket files
  - Make sock_unix_write_cwd() use ckpt_write_string() and use the new
    ckpt_read_string() for reading the cwd
  - Use the restored realcred credentials in sock_unix_join()
  - Fix error path of the chdir_and_bind
  - Change the algorithm for reloading the socket buffers to use sendmsg()
    on the socket's peer for better accounting
  - For DGRAM sockets, check the backlog value against the system max
    to avoid letting a restart bypass the overloaded queue length
  - Use sock_bind() instead of sock->ops->bind() to gain the security hook
  - Change "restart" to "restore" in some of the function names

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

Cc: Oren Laaden <orenl@cs.columbia.edu>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   19 ++
 include/linux/checkpoint.h     |   10 +
 include/linux/checkpoint_hdr.h |   72 ++++++
 include/net/af_unix.h          |   32 +++
 include/net/sock.h             |   11 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  438 +++++++++++++++++++++++++++++++++
 net/socket.c                   |   85 +++++++
 net/unix/Makefile              |    1 +
 net/unix/checkpoint.c          |  524 ++++++++++++++++++++++++++++++++++++++++
 11 files changed, 1201 insertions(+), 0 deletions(-)
 create mode 100644 net/checkpoint.c
 create mode 100644 net/unix/checkpoint.c

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 7aecac9..8729e00 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 
 /**************************************************************************
@@ -565,6 +566,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_FIFO,
 		.restore = fifo_file_restore,
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
index a2fb278..4bfa1d8 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -20,6 +20,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -234,6 +235,17 @@ static void obj_groupinfo_drop(void *ptr)
 	put_group_info((struct group_info *) ptr);
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
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -356,6 +368,13 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* sock object */
+	{
+		.obj_name = "SOCKET",
+		.obj_type = CKPT_OBJ_SOCK,
+		.ref_drop = obj_sock_drop,
+		.ref_grab = obj_sock_grab,
+	},
 };
 
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 60b230e..8a492e4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -29,6 +29,7 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
+#include <net/sock.h>
 
 /* ckpt_ctx: kflags */
 #define CKPT_CTX_CHECKPOINT_BIT		0
@@ -78,6 +79,15 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+/* socket functions */
+extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
+			      struct socket *socket,
+			      struct sockaddr *loc, unsigned *loc_len,
+			      struct sockaddr *rem, unsigned *rem_len);
+extern struct ckpt_hdr_socket_queue *
+ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
+			  uint32_t *bufsize);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4b85956..829ff2d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -12,6 +12,8 @@
 
 #include <linux/types.h>
 #include <linux/utsname.h>
+#include <linux/socket.h>
+#include <linux/un.h>
 
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
@@ -88,6 +90,12 @@ enum {
 
 	CKPT_HDR_SIGHAND = 601,
 
+	CKPT_HDR_FD_SOCKET = 701,
+	CKPT_HDR_SOCKET,
+	CKPT_HDR_SOCKET_QUEUE,
+	CKPT_HDR_SOCKET_BUFFER,
+	CKPT_HDR_SOCKET_UNIX,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -122,6 +130,7 @@ enum obj_type {
 	CKPT_OBJ_CRED,
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
+	CKPT_OBJ_SOCK,
 	CKPT_OBJ_MAX
 };
 
@@ -327,6 +336,7 @@ enum file_type {
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
 	CKPT_FILE_FIFO,
+	CKPT_FILE_SOCKET,
 	CKPT_FILE_MAX
 };
 
@@ -350,6 +360,10 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_socket {
+	struct ckpt_hdr_file common;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_utsns {
 	struct ckpt_hdr h;
 	char sysname[__NEW_UTS_LEN + 1];
@@ -504,6 +518,64 @@ struct ckpt_hdr_ipc_sem {
 	__u32 sem_nsems;
 } __attribute__((aligned(8)));
 
+#define CKPT_UNIX_LINKED 1
+struct ckpt_hdr_socket_unix {
+	struct ckpt_hdr h;
+	__s32 this;
+	__s32 peer;
+	__u32 flags;
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr_un laddr;
+	struct sockaddr_un raddr;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	struct { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u32 reuse;
+		__u16 family;
+		__u8 state;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct { /* struct sock */
+		__s64 rcvlowat;
+		__u64 flags;
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
+
+		struct linger linger;
+		struct timeval rcvtimeo;
+		struct timeval sndtimeo;
+
+	} sock __attribute__ ((aligned(8)));
+
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_queue {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+	__u32 total_bytes;
+} __attribute__ ((aligned(8)));
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1614d78..7aef51b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -68,4 +68,36 @@ static inline int unix_sysctl_register(struct net *net) { return 0; }
 static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 #endif
+
+#ifdef CONFIG_CHECKPOINT
+
+#ifdef CONFIG_UNIX_MODULE
+/* FIXME: Our current scheme won't work with CONFIG_UNIX=m */
+#error "CONFIG_UNIX=m not currently supported by CONFIG_CHECKPOINT"
+#endif
+
+#ifdef CONFIG_UNIX
+extern int sock_unix_checkpoint(struct ckpt_ctx *ctx,
+				struct socket *socket,
+				struct ckpt_hdr_socket *h);
+extern int sock_unix_restore(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_socket *h,
+			     struct socket *socket);
+#else
+static inline int sock_unix_checkpoint(struct ckpt_ctx *ctx,
+				       struct socket *socket,
+				       struct ckpt_hdr_socket *h)
+{
+	return -ENOSYS;
+}
+
+static inline int sock_unix_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_socket *h,
+				    struct socket *socket)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_UNIX */
+#endif /* CONFIG_CHECKPOINT */
+
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 43b9599..da75f2f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1640,4 +1640,15 @@ extern int sysctl_optmem_max;
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
index ba324ae..91d12fe 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -66,3 +66,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
new file mode 100644
index 0000000..ebbd68a
--- /dev/null
+++ b/net/checkpoint.c
@@ -0,0 +1,438 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author: Dan Smith <danms@us.ibm.com>
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
+static int sock_copy_buffers(struct sk_buff_head *from,
+			     struct sk_buff_head *to,
+			     uint32_t *total_bytes)
+{
+	int count1 = 0;
+	int count2 = 0;
+	int i;
+	struct sk_buff *skb;
+	struct sk_buff **skbs;
+
+	*total_bytes = 0;
+
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb)
+		count1++;
+	spin_unlock(&from->lock);
+
+	skbs = kzalloc(sizeof(*skbs) * count1, GFP_KERNEL);
+	if (!skbs)
+		return -ENOMEM;
+
+	for (i = 0; i < count1;  i++) {
+		skbs[i] = dev_alloc_skb(0);
+		if (!skbs[i])
+			goto err;
+	}
+
+	i = 0;
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb) {
+		if (++count2 > count1)
+			break; /* The queue changed as we read it */
+
+		skb_morph(skbs[i], skb);
+		skb_queue_tail(to, skbs[i]);
+
+		*total_bytes += skb->len;
+		i++;
+	}
+	spin_unlock(&from->lock);
+
+	if (count1 != count2)
+		goto err;
+
+	kfree(skbs);
+
+	return count1;
+ err:
+	while (skb_dequeue(to))
+		; /* Pull all the buffers out of the queue */
+	for (i = 0; i < count1; i++)
+		kfree_skb(skbs[i]);
+	kfree(skbs);
+
+	return -EAGAIN;
+}
+
+static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				struct sk_buff_head *queue)
+{
+	struct sk_buff *skb;
+	int ret = 0;
+
+	skb_queue_walk(queue, skb) {
+		/* FIXME: This could be a false positive for non-unix
+		 *        buffers, so add a type check here in the
+		 *        future
+		 */
+		if (UNIXCB(skb).fp) {
+			ckpt_write_err(ctx, "fd-passing is not supported");
+			return -EBUSY;
+		}
+
+		/* The other ancillary messages are always present
+		 * unlike descriptors.  Even though we can't detect
+		 * them and fail the checkpoint, we're not at risk
+		 * because we don't save out (or restore) the control
+		 * information contained in the skb.
+		 */
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
+	struct ckpt_hdr_socket_queue *h;
+	struct sk_buff_head tmpq;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (!h)
+		return -ENOMEM;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &h->total_bytes);
+	if (ret < 0)
+		goto out;
+
+	h->skb_count = ret;
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
+int ckpt_sock_getnames(struct ckpt_ctx *ctx,
+		       struct socket *socket,
+		       struct sockaddr *loc, unsigned *loc_len,
+		       struct sockaddr *rem, unsigned *rem_len)
+{
+	int ret;
+
+	ret = sock_getname(socket, loc, loc_len);
+	if (ret) {
+		ckpt_write_err(ctx, "Unable to getname of local: %i", ret);
+		return -EINVAL;
+	}
+
+	ret = sock_getpeer(socket, rem, rem_len);
+	if (ret) {
+		if ((socket->sk->sk_type != SOCK_DGRAM) &&
+		    (socket->sk->sk_state == TCP_ESTABLISHED)) {
+			ckpt_write_err(ctx, "Unable to getname of remote: %i",
+				       ret);
+			return -EINVAL;
+		}
+		*rem_len = 0;
+	}
+
+	return 0;
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
+	if (!ckpt_validate_errno(h->sock.err))
+		return -EINVAL;
+
+	/* None of our supported types use this flag */
+	if (h->sock.flags & SOCK_DESTROY)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sock_cptrst_opt(int op, struct socket *socket,
+			   int optname, char *opt, int len)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+
+	if (op == CKPT_CPT)
+		ret = sock_getsockopt(socket, SOL_SOCKET, optname, opt, &len);
+	else
+		ret = sock_setsockopt(socket, SOL_SOCKET, optname, opt, len);
+
+	set_fs(fs);
+
+	return ret;
+}
+
+#define CKPT_COPY_SOPT(op, sock, name, opt) \
+	sock_cptrst_opt(op, sock->sk_socket, name, (char *)opt, sizeof(*opt))
+
+static int sock_cptrst_bufopts(int op, struct sock *sock,
+			       struct ckpt_hdr_socket *h)
+
+{
+	if (CKPT_COPY_SOPT(op, sock, SO_RCVBUF, &h->sock.rcvbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sock, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
+			ckpt_debug("Failed to set SO_RCVBUF");
+			return -EINVAL;
+		}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_SNDBUF, &h->sock.sndbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sock, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
+			ckpt_debug("Failed to set SO_SNDBUF");
+			return -EINVAL;
+		}
+
+	/* It's silly that we have to fight ourselves here, but
+	 * sock_setsockopt() doubles the initial value, so divide here
+	 * to store the user's value and avoid doubling on restart
+	 */
+	if ((op == CKPT_CPT) && (h->sock.rcvbuf != SOCK_MIN_RCVBUF))
+		h->sock.rcvbuf >>= 1;
+
+	if ((op == CKPT_CPT) && (h->sock.sndbuf != SOCK_MIN_SNDBUF))
+		h->sock.sndbuf >>= 1;
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
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
+
+	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sock->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
+	CKPT_COPY(op, h->sock.type, sock->sk_type);
+	CKPT_COPY(op, h->sock.state, sock->sk_state);
+	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
+
+	/* TODO:
+	 * Break out setting each of the flags to use setsockopt() or
+	 * perform proper security check
+	 */
+	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
+
+	if (sock_cptrst_bufopts(op, sock, h))
+		return -EINVAL;
+
+	if (CKPT_COPY_SOPT(op, sock, SO_REUSEADDR, &h->sock_common.reuse)) {
+		ckpt_debug("Failed to set SO_REUSEADDR");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_PRIORITY, &h->sock.priority)) {
+		ckpt_debug("Failed to set SO_PRIORITY");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_RCVLOWAT, &h->sock.rcvlowat)) {
+		ckpt_debug("Failed to set SO_RCVLOWAT");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_LINGER, &h->sock.linger)) {
+		ckpt_debug("Failed to set SO_LINGER");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_SNDTIMEO, &h->sock.sndtimeo)) {
+		ckpt_debug("Failed to set SO_SNDTIMEO");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sock, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
+		ckpt_debug("Failed to set SO_RCVTIMEO");
+		return -EINVAL;
+	}
+
+	if ((h->socket.state == SS_CONNECTED) &&
+	    (h->sock.state != TCP_ESTABLISHED)) {
+		ckpt_debug("socket/sock in inconsistent state: %i/%i",
+			   h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->sock.state < TCP_ESTABLISHED) ||
+		   (h->sock.state >= TCP_MAX_STATES)) {
+		ckpt_debug("sock in invalid state: %i", h->sock.state);
+		return -EINVAL;
+	} else if ((h->socket.state < SS_FREE) ||
+		   (h->socket.state > SS_DISCONNECTING)) {
+		ckpt_debug("socket in invalid state: %i",
+			   h->socket.state);
+		return -EINVAL;
+	}
+
+	if (op == CKPT_RST)
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
+	ret = sock_cptrst(ctx, sock, h, CKPT_CPT);
+	if (ret)
+		goto out;
+
+	if (sock->sk_family == AF_UNIX) {
+		ret = sock_unix_checkpoint(ctx, socket, h);
+		if (ret)
+			goto out;
+	} else {
+		ckpt_write_err(ctx, "unsupported socket family %i",
+			       sock->sk_family);
+		ret = -ENOSYS;
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
+struct ckpt_hdr_socket_queue *ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
+							uint32_t *bufsize)
+{
+	struct ckpt_hdr_socket_queue *h;
+	int err = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (IS_ERR(h))
+		return h;
+
+	if (!bufsize) {
+		if (h->total_bytes != 0) {
+			ckpt_debug("Expected empty buffer, got %u\n",
+				   h->total_bytes);
+			err = -EINVAL;
+		}
+	} else if (h->total_bytes > *bufsize) {
+		/* NB: We let CAP_NET_ADMIN override the system buffer limit
+		 *     as setsockopt() does
+		 */
+		if (capable(CAP_NET_ADMIN))
+			*bufsize = h->total_bytes;
+		else {
+			ckpt_debug("Buffer total %u exceeds limit %u\n",
+			   h->total_bytes, *bufsize);
+			err = -EINVAL;
+		}
+	}
+
+	if (err) {
+		ckpt_hdr_put(ctx, h);
+		return ERR_PTR(err);
+	} else
+		return h;
+}
+
+struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_socket *h)
+{
+	struct socket *socket;
+	int ret;
+
+	if ((h->sock.type != SOCK_DGRAM) && (h->sock.type != SOCK_STREAM)) {
+		ckpt_debug("Socket type %i not supported", h->sock.type);
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	if (h->sock_common.family == AF_UNIX) {
+		ret = sock_unix_restore(ctx, h, socket);
+		ckpt_debug("sock_unix_restore: %i\n", ret);
+	} else {
+		ckpt_debug("unsupported family %i\n", h->sock_common.family);
+		ret = -ENOSYS;
+	}
+
+	if (ret)
+		goto out;
+
+	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
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
index 65e7698..8732fe2 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -96,6 +96,8 @@
 #include <net/sock.h>
 #include <linux/netfilter.h>
 
+#include <linux/checkpoint.h>
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -140,6 +142,9 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =   sock_file_checkpoint,
+#endif
 };
 
 /*
@@ -415,6 +420,86 @@ int sock_map_fd(struct socket *sock, int flags)
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
diff --git a/net/unix/Makefile b/net/unix/Makefile
index b852a2b..fbff1e6 100644
--- a/net/unix/Makefile
+++ b/net/unix/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_UNIX)	+= unix.o
 
 unix-y			:= af_unix.o garbage.o
 unix-$(CONFIG_SYSCTL)	+= sysctl_net_unix.o
+unix-$(CONFIG_CHECKPOINT) += checkpoint.o
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
new file mode 100644
index 0000000..007899b
--- /dev/null
+++ b/net/unix/checkpoint.c
@@ -0,0 +1,524 @@
+#include <linux/namei.h>
+#include <linux/file.h>
+#include <linux/fs_struct.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+#define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
+
+static inline int sock_unix_need_cwd(struct sockaddr_un *addr,
+				     unsigned long len)
+{
+	return (!UNIX_ADDR_EMPTY(len)) &&
+		addr->sun_path[0] &&
+		(addr->sun_path[0] != '/');
+}
+
+static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
+			       struct sock *sock,
+			       const char *sockpath)
+{
+	struct path path;
+	char *buf;
+	char *fqpath;
+	int offset;
+	int len = PATH_MAX;
+	int ret = -ENOENT;
+
+	buf = kmalloc(len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	path.dentry = unix_sk(sock)->dentry;
+	path.mnt = unix_sk(sock)->mnt;
+
+	fqpath = ckpt_fill_fname(&path, &ctx->fs_mnt, buf, &len);
+	if (IS_ERR(fqpath)) {
+		ret = PTR_ERR(fqpath);
+		goto out;
+	}
+
+	offset = strlen(fqpath) - strlen(sockpath);
+	if (offset <= 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	fqpath[offset] = '\0';
+
+	ckpt_debug("writing socket directory: %s\n", fqpath);
+	ret = ckpt_write_string(ctx, fqpath, strlen(fqpath));
+ out:
+	kfree(buf);
+	return ret;
+}
+
+int sock_unix_checkpoint(struct ckpt_ctx *ctx,
+			 struct socket *socket,
+			 struct ckpt_hdr_socket *h)
+{
+	struct unix_sock *sk = unix_sk(socket->sk);
+	struct unix_sock *pr = unix_sk(sk->peer);
+	struct ckpt_hdr_socket_unix *un;
+	int new;
+	int ret = -ENOMEM;
+
+	if ((socket->sk->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&socket->sk->sk_receive_queue)) {
+		ckpt_write_err(ctx, "listening socket has unaccepted peers");
+		return -EBUSY;
+	}
+
+	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (!un)
+		return -EINVAL;
+
+	ret = ckpt_sock_getnames(ctx, socket,
+				 (struct sockaddr *)&un->laddr, &un->laddr_len,
+				 (struct sockaddr *)&un->raddr, &un->raddr_len);
+	if (ret)
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
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
+	if (ret < 0)
+		goto out;
+
+	if (sock_unix_need_cwd(&un->laddr, un->laddr_len))
+		ret = sock_unix_write_cwd(ctx, socket->sk, un->laddr.sun_path);
+ out:
+	ckpt_hdr_put(ctx, un);
+
+	return ret;
+}
+
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct msghdr msg;
+	struct kvec kvec;
+	int ret = 0;
+	int len;
+
+	memset(&msg, 0, sizeof(msg));
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_SOCKET_BUFFER);
+	if (len < 0)
+		return len;
+
+	if (len > SKB_MAX_ALLOC) {
+		ckpt_debug("Socket buffer too big (%i > %lu)",
+			   len, SKB_MAX_ALLOC);
+		return -ENOSPC;
+	}
+
+	kvec.iov_len = len;
+	kvec.iov_base = kmalloc(len, GFP_KERNEL);
+	if (!kvec.iov_base)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, kvec.iov_base, len);
+	if (ret < 0)
+		goto out;
+
+	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);
+	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
+	if ((ret > 0) && (ret != len))
+		ret = -ENOMEM;
+ out:
+	kfree(kvec.iov_base);
+
+	return ret;
+}
+
+static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
+				  struct sock *sock,
+				  uint32_t *bufsize)
+{
+	uint8_t sock_shutdown;
+	struct ckpt_hdr_socket_queue *h;
+ 	int ret = 0;
+	int i;
+
+	h = ckpt_sock_read_buffer_hdr(ctx, bufsize);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* If peer is shutdown, unshutdown it for this process */
+	sock_shutdown = sock->sk_shutdown;
+	sock->sk_shutdown &= ~SHUTDOWN_MASK;
+
+	for (i = 0; i < h->skb_count; i++) {
+		ret = sock_read_buffer_sendmsg(ctx, sock);
+		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
+		if (ret < 0)
+			break;
+
+		if (ret > h->total_bytes) {
+			ckpt_debug("Buffers exceeded claim");
+			ret = -EINVAL;
+			break;
+		}
+
+		h->total_bytes -= ret;
+		ret = 0;
+	}
+
+	sock->sk_shutdown = sock_shutdown;
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
+	if (len > sizeof(struct sockaddr_un))
+		return ERR_PTR(-EINVAL);
+
+	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
+	if (!addr)
+		return ERR_PTR(-ENOMEM);
+
+	memcpy(addr->name, sun_addr, len);
+	addr->len = len;
+	atomic_set(&addr->refcnt, 1);
+
+	return addr;
+}
+
+static int sock_unix_join(struct ckpt_ctx *ctx,
+			  struct sock *a,
+			  struct sock *b,
+			  struct ckpt_hdr_socket_unix *un)
+{
+	struct unix_address *addr = NULL;
+
+	/* FIXME: Do we need to call some security hooks here? */
+
+	sock_hold(a);
+	sock_hold(b);
+
+	unix_sk(a)->peer = b;
+	unix_sk(b)->peer = a;
+
+	/* TODO:
+	 * Checkpoint the credentials, restore them here if the values match
+	 * the restored creds or we may_setuid()
+	 */
+
+	a->sk_peercred.pid = task_tgid_vnr(current);
+	a->sk_peercred.uid = ctx->realcred->uid;
+	a->sk_peercred.gid = ctx->realcred->gid;
+
+	b->sk_peercred.pid = a->sk_peercred.pid;
+	b->sk_peercred.uid = a->sk_peercred.uid;
+	b->sk_peercred.gid = a->sk_peercred.gid;
+
+	if (!UNIX_ADDR_EMPTY(un->raddr_len))
+		addr = sock_unix_makeaddr(&un->raddr, un->raddr_len);
+	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
+		addr = sock_unix_makeaddr(&un->laddr, un->laddr_len);
+
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
+	else if (addr) {
+		atomic_inc(&addr->refcnt); /* Held by both ends */
+		unix_sk(a)->addr = unix_sk(b)->addr = addr;
+	}
+
+	return 0;
+}
+
+static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
+				       struct ckpt_hdr_socket *h,
+				       struct ckpt_hdr_socket_unix *un,
+				       struct socket *socket)
+{
+	struct sock *this = ckpt_obj_fetch(ctx, un->this, CKPT_OBJ_SOCK);
+	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
+	struct socket *tmp = NULL;
+	int ret;
+
+	if (!IS_ERR(this) && !IS_ERR(peer)) {
+		/* We're last */
+		struct socket *old = this->sk_socket;
+
+		old->sk = NULL;
+		sock_release(old);
+		sock_graft(this, socket);
+
+	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {
+		/* We're first */
+		int family = socket->sk->sk_family;
+		int type = socket->sk->sk_type;
+
+		ret = sock_create(family, type, 0, &tmp);
+		ckpt_debug("sock_create: %i\n", ret);
+		if (ret)
+			goto out;
+
+		this = socket->sk;
+		peer = tmp->sk;
+
+		ret = ckpt_obj_insert(ctx, this, un->this, CKPT_OBJ_SOCK);
+		if (ret < 0)
+			goto out;
+
+		ret = ckpt_obj_insert(ctx, peer, un->peer, CKPT_OBJ_SOCK);
+		if (ret < 0)
+			goto out;
+
+		ret = sock_unix_join(ctx, this, peer, un);
+		ckpt_debug("sock_unix_join: %i\n", ret);
+		if (ret)
+			goto out;
+
+	} else {
+		ckpt_debug("Order Error\n");
+		ret = PTR_ERR(this);
+		goto out;
+	}
+
+	/* Prime the socket's buffer limit with the maximum.  These will be
+	 * overwritten with the values in the checkpoint stream in a later
+	 * phase.
+	 */
+	peer->sk_userlocks |= SOCK_SNDBUF_LOCK;
+	peer->sk_sndbuf = sysctl_wmem_max;
+
+	/* Read my buffers and sendmsg() them back to me via my peer */
+
+	/* TODO: handle the unconnected case, as well, as the case
+	 *       where sendto() has been used on some of the buffers
+	 */
+
+	ret = sock_unix_read_buffers(ctx, peer, &peer->sk_sndbuf);
+	ckpt_debug("sock_unix_read_buffers: %i\n", ret);
+	if (ret)
+		goto out;
+
+	/* Read peer's buffers and expect 0 */
+	ret = sock_unix_read_buffers(ctx, peer, NULL);
+ out:
+	if (tmp && ret)
+		sock_release(tmp);
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
+	if ((ret == 0) || (ret == -ENOENT))
+		ret = sock_bind(socket, addr, addrlen);
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
+	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
+	unsigned long len = un->laddr_len;
+
+	if (!un->laddr.sun_path[0])
+		return sock_bind(socket, addr, len);
+	else if (!(un->flags & CKPT_UNIX_LINKED))
+		return sock_unix_fakebind(socket, &un->laddr, len);
+	else
+		return sock_unix_chdir_and_bind(socket, path, addr, len);
+}
+
+/* Some easy pre-flight checks before we get underway */
+static int sock_unix_precheck(struct socket *socket,
+			      struct ckpt_hdr_socket *h)
+{
+	struct net *net = sock_net(socket->sk);
+
+	if ((h->socket.state == SS_CONNECTING) ||
+	    (h->socket.state == SS_DISCONNECTING) ||
+	    (h->socket.state == SS_FREE)) {
+		ckpt_debug("AF_UNIX socket can't be SS_(DIS)CONNECTING");
+		return -EINVAL;
+	}
+
+	/* AF_UNIX overloads the backlog setting to define the maximum
+	 * queue length for DGRAM sockets.  Make sure we don't let the
+	 * caller exceed that value on restart.
+	 */
+	if ((h->sock.type == SOCK_DGRAM) &&
+	    (h->sock.backlog > net->unx.sysctl_max_dgram_qlen)) {
+		ckpt_debug("DGRAM backlog of %i exceeds system max of %i\n",
+			   h->sock.backlog, net->unx.sysctl_max_dgram_qlen);
+		return -EINVAL;
+	}
+
+	if (h->sock.flags & SOCK_USE_WRITE_QUEUE) {
+		ckpt_debug("AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int sock_unix_restore(struct ckpt_ctx *ctx,
+		      struct ckpt_hdr_socket *h,
+		      struct socket *socket)
+{
+	struct ckpt_hdr_socket_unix *un;
+	int ret = -EINVAL;
+	char *cwd = NULL;
+
+	ret = sock_unix_precheck(socket, h);
+	if (ret)
+		return ret;
+
+	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (IS_ERR(un))
+		return PTR_ERR(un);
+
+	if (un->peer < 0)
+		goto out;
+
+	if (sock_unix_need_cwd(&un->laddr, un->laddr_len)) {
+		cwd = ckpt_read_string(ctx, PATH_MAX);
+		if (IS_ERR(cwd)) {
+			ret = PTR_ERR(cwd);
+			goto out;
+		}
+	}
+
+	if ((h->sock.state != TCP_ESTABLISHED) &&
+	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
+		ret = sock_unix_bind(h, un, socket, cwd);
+		if (ret)
+			goto out;
+	}
+
+	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
+		ret = sock_unix_restore_connected(ctx, h, un, socket);
+	else if (h->sock.state == TCP_LISTEN)
+		ret = socket->ops->listen(socket, h->sock.backlog);
+	else
+		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
+ out:
+	ckpt_hdr_put(ctx, un);
+	kfree(cwd);
+	return ret;
+}
+
-- 
1.6.2.5


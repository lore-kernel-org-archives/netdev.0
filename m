From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 28 Jul 2009 12:54:58 -0400
Message-ID: <4A6F2D62.9040005@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248295301-30930-6-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Hi Dan,

Dan Smith wrote:
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports socketpair()s, path-based, and
> abstract sockets.
> 
> Changes in v6:
>   - Moved the socket addresses to the per-type header
>   - Eliminated the HASCWD flag
>   - Remove use of ckpt_write_err() in restart paths
>   - Change the order in which buffers are read so that we can set the
>     socket's limit equal to the size of the image's buffers (if appropriate)
>     and then restore the original values afterwards.
>   - Use the ckpt_validate_errno() helper
>   - Add a check to make sure that we didn't restore a (UNIX) socket with
>     any skb's in the send buffer
>   - Fix up sock_unix_join() to not leave addr uninitialized for socketpair
>   - Remove inclusion of checkpoint_hdr.h in the socket files
>   - Make sock_unix_write_cwd() use ckpt_write_string() and use the new
>     ckpt_read_string() for reading the cwd
>   - Use the restored realcred credentials in sock_unix_join()
>   - Fix error path of the chdir_and_bind
>   - Change the algorithm for reloading the socket buffers to use sendmsg()
>     on the socket's peer for better accounting
>   - For DGRAM sockets, check the backlog value against the system max
>     to avoid letting a restart bypass the overloaded queue length
>   - Use sock_bind() instead of sock->ops->bind() to gain the security hook
>   - Change "restart" to "restore" in some of the function names
> 
> Changes in v5:
>   - Change laddr and raddr buffers in socket header to be long enough
>     for INET6 addresses
>   - Place socket.c and sock.h function definitions inside #ifdef
>     CONFIG_CHECKPOINT
>   - Add explicit check in sock_unix_makeaddr() to refuse if the
>     checkpoint image specifies an addr length of 0
>   - Split sock_unix_restart() into a few pieces to facilitate:
>   - Changed behavior of the unix restore code so that unlinked LISTEN
>     sockets don't do a bind()...unlink()
>   - Save the base path of a bound socket's path so that we can chdir()
>     to the base before bind() if it is a relative path
>   - Call bind() for any socket that is not established but has a
>     non-zero-length local address
>   - Enforce the current sysctl limit on socket buffer size during restart
>     unless the user holds CAP_NET_ADMIN
>   - Unlink a path-based socket before calling bind()

[...]

 > +static int obj_sock_grab(void *ptr)
> +{
> +	sock_hold((struct sock *) ptr);
> +	return 0;
> +}
> +
> +static void obj_sock_drop(void *ptr)
> +{
> +	sock_put((struct sock *) ptr);
> +}
> +
> +static int obj_sock_users(void *ptr)
> +{
> +	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
> +}
> +

obj_sock_users() is only required for objects that are to be
tested for leaks in full container checkpoint. I don't think
it's needed, because the relation sock <-> file is 1-to-1.
(If it were, then you would also need to collect sockets).

>  static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  	/* ignored object */
>  	{
> @@ -367,6 +384,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_groupinfo,
>  		.restore = restore_groupinfo,
>  	},
> +	/* sock object */
> +	{
> +		.obj_name = "SOCKET",
> +		.obj_type = CKPT_OBJ_SOCK,
> +		.ref_drop = obj_sock_drop,
> +		.ref_grab = obj_sock_grab,
> +		.ref_users = obj_sock_users,
		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		      scratch this one

> +		.checkpoint = sock_file_checkpoint,
> +		.restore = sock_file_restore,

These two should be 'checkpoint_bad' and 'restore_bad' respsectively.
Sockets are handled via files, not as independent objects.

(Actually, I will remove checkpoint_bad and restore_bad and modify
checkpoint_obj() and restore_obj() to fail if the respective method
is NULL).

> +	},
>  };
>  
>  
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 8b7ca46..e542ff5 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -88,6 +88,12 @@ enum {
>  
>  	CKPT_HDR_SIGHAND = 601,
>  
> +	CKPT_HDR_FD_SOCKET = 701,
> +	CKPT_HDR_SOCKET,
> +	CKPT_HDR_SOCKET_BUFFERS,
> +	CKPT_HDR_SOCKET_BUFFER,

Nit: I already got confused a few times because of the similar names.
Perhaps change CKPT_HDR_SOCKET_BUFFERS to CKPT_HDR_SOCKET_QUEUE (and
adjust the header name accordingly).

> +	CKPT_HDR_SOCKET_UNIX,
> +
>  	CKPT_HDR_TAIL = 9001,
>  
>  	CKPT_HDR_ERROR = 9999,
> @@ -122,6 +128,7 @@ enum obj_type {
>  	CKPT_OBJ_CRED,
>  	CKPT_OBJ_USER,
>  	CKPT_OBJ_GROUPINFO,
> +	CKPT_OBJ_SOCK,
>  	CKPT_OBJ_MAX
>  };
>  
> @@ -326,6 +333,7 @@ enum file_type {
>  	CKPT_FILE_IGNORE = 0,
>  	CKPT_FILE_GENERIC,
>  	CKPT_FILE_PIPE,
> +	CKPT_FILE_SOCKET,
>  	CKPT_FILE_MAX
>  };
>  
> @@ -349,6 +357,11 @@ struct ckpt_hdr_file_pipe {
>  	__s32 pipe_objref;
>  } __attribute__((aligned(8)));
>  
> +struct ckpt_hdr_file_socket {
> +	struct ckpt_hdr_file common;
> +	__u16 family;
> +} __attribute__((aligned(8)));
> +
>  struct ckpt_hdr_file_pipe_state {
>  	struct ckpt_hdr h;
>  	__s32 pipe_len;
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 3b461df..cd675dd 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
>  #include <linux/uio.h>			/* iovec support		*/
>  #include <linux/types.h>		/* pid_t			*/
>  #include <linux/compiler.h>		/* __user			*/
> +#include <linux/checkpoint.h>		/* struct ckpt_hdr              */
>  
>  #ifdef __KERNEL__
>  # ifdef CONFIG_PROC_FS
> @@ -328,5 +329,67 @@ extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *ka
>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>  
>  #endif
> +
> +#ifdef CONFIG_CHECKPOINT
> +#include <linux/un.h>                   /* sockaddr_un			*/

Unless/until we decide otherwise, let's keep all ckpt_hdr_xxx
definitions in a single place -- checkpoint_hdr.h

> +
> +#define CKPT_UNIX_LINKED 1
> +struct ckpt_hdr_socket_unix {
> +	struct ckpt_hdr h;
> +	__u32 this;
> +	__u32 peer;

For objrefs please use __s32.

> +	__u32 flags;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +	struct sockaddr_un laddr;
> +	struct sockaddr_un raddr;
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket {
> +	struct ckpt_hdr h;
> +
> +	struct ckpt_socket { /* struct socket */

Unless you intend to use the struct name 'ckpt_socket' elsewhere,
can we get rid of it (leaving only 'struct {') ?

> +		__u64 flags;
> +		__u8 state;
> +	} socket __attribute__ ((aligned(8)));
> +
> +	struct ckpt_sock_common { /* struct sock_common */

Here too.

> +		__u32 bound_dev_if;
> +		__u16 family;
> +		__u8 state;
> +		__u8 reuse;
> +	} sock_common __attribute__ ((aligned(8)));
> +
> +	struct ckpt_sock { /* struct sock */

And here.

> +		__s64 rcvlowat;
> +		__s64 rcvtimeo;
> +		__s64 sndtimeo;
> +		__u64 flags;
> +		__u64 lingertime;
> +
> +		__u32 err;
> +		__u32 err_soft;
> +		__u32 priority;
> +		__s32 rcvbuf;
> +		__s32 sndbuf;
> +		__u16 type;
> +		__s16 backlog;
> +
> +		__u8 protocol;
> +		__u8 state;
> +		__u8 shutdown;
> +		__u8 userlocks;
> +		__u8 no_check;
> +	} sock __attribute__ ((aligned(8)));
> +
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__u32 skb_count;
> +	__u32 total_bytes;
> +} __attribute__ ((aligned(8)));
> +#endif /* CONFIG_CHECKPOINT */
> +
>  #endif /* not kernel and not glibc */
>  #endif /* _LINUX_SOCKET_H */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d435dc1..4043cd2 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1608,4 +1608,15 @@ extern int sysctl_optmem_max;
>  extern __u32 sysctl_wmem_default;
>  extern __u32 sysctl_rmem_default;
>  
> +#ifdef CONFIG_CHECKPOINT
> +/* Checkpoint/Restart Functions */
> +struct ckpt_ctx;
> +struct ckpt_hdr_socket;
> +extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
> +extern void *sock_file_restore(struct ckpt_ctx *);
> +extern struct socket *do_sock_file_restore(struct ckpt_ctx *,
> +					   struct ckpt_hdr_socket *);
> +extern int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> +#endif
> +
>  #endif	/* _SOCK_H */
> diff --git a/net/Makefile b/net/Makefile
> index ba324ae..91d12fe 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -66,3 +66,5 @@ ifeq ($(CONFIG_NET),y)
>  obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
>  endif
>  obj-$(CONFIG_WIMAX)		+= wimax/
> +
> +obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> new file mode 100644
> index 0000000..748d3aa
> --- /dev/null
> +++ b/net/checkpoint.c
> @@ -0,0 +1,779 @@
> +/*
> + *  Copyright 2009 IBM Corporation
> + *
> + *  Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + */
> +
> +#include <linux/socket.h>
> +#include <linux/mount.h>
> +#include <linux/file.h>
> +#include <linux/namei.h>
> +#include <linux/syscalls.h>
> +#include <linux/sched.h>
> +#include <linux/fs_struct.h>
> +
> +#include <net/af_unix.h>
> +#include <net/tcp_states.h>
> +
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +
> +#define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
> +
> +static inline int sock_unix_need_cwd(struct sockaddr_un *addr,
> +				     unsigned long len)
> +{
> +	return (!UNIX_ADDR_EMPTY(len)) &&
> +		addr->sun_path[0] &&
> +		(addr->sun_path[0] != '/');
> +}
> +
> +static int sock_copy_buffers(struct sk_buff_head *from,
> +			     struct sk_buff_head *to,
> +			     uint32_t *total_bytes)
> +{
> +	int count = 0;
> +	struct sk_buff *skb;
> +
> +	*total_bytes = 0;
> +
> +	skb_queue_walk(from, skb) {
> +		struct sk_buff *tmp;
> +
> +		tmp = dev_alloc_skb(skb->len);
> +		if (!tmp)
> +			return -ENOMEM;
> +
> +		spin_lock(&from->lock);
> +		skb_morph(tmp, skb);
> +		spin_unlock(&from->lock);
> +
> +		skb_queue_tail(to, tmp);
> +		count++;
> +		*total_bytes += tmp->len;
> +	}
> +
> +	return count;
> +}
> +
> +static int __sock_write_buffers(struct ckpt_ctx *ctx,
> +				struct sk_buff_head *queue)
> +{
> +	struct sk_buff *skb;
> +	int ret = 0;
> +
> +	skb_queue_walk(queue, skb) {
> +		if (UNIXCB(skb).fp) {
> +			ckpt_write_err(ctx, "fd-passing is not supported");
> +			return -EBUSY;
> +		}
> +
> +		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
> +					  CKPT_HDR_SOCKET_BUFFER);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	struct sk_buff_head tmpq;
> +	int ret = -ENOMEM;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (!h)
> +		goto out;
> +
> +	skb_queue_head_init(&tmpq);
> +
> +	h->skb_count = sock_copy_buffers(queue, &tmpq, &h->total_bytes);
> +	if (h->skb_count < 0) {

h->skb_count is unsigned...

> +		ret = h->skb_count;
> +		goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (!ret)
> +		ret = __sock_write_buffers(ctx, &tmpq);
> +
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	__skb_queue_purge(&tmpq);
> +
> +	return ret;
> +}
> +
> +static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
> +			       struct sock *sock,
> +			       const char *sockpath)
> +{
> +	struct path path;
> +	char *buf;
> +	char *fqpath;
> +	int offset;
> +	int ret = -ENOENT;
> +
> +	buf = kmalloc(PATH_MAX, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	path.dentry = unix_sk(sock)->dentry;
> +	path.mnt = unix_sk(sock)->mnt;
> +
> +	fqpath = d_path(&path, buf, PATH_MAX);
> +	if (!fqpath)
> +		goto out;

Can you use fill_name() from checkpoint/file.c ?  rename it to
ckpt_fill_name() or something when you export it.

> +
> +	offset = strlen(fqpath) - strlen(sockpath);
> +	if (offset <= 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	fqpath[offset] = '\0';
> +
> +	ckpt_debug("writing socket directory: %s\n", fqpath);
> +	ret = ckpt_write_string(ctx, fqpath, strlen(fqpath));
> + out:
> +	kfree(buf);
> +	return ret;
> +}
> +
> +static int sock_unix_getnames(struct ckpt_ctx *ctx,
> +			      struct ckpt_hdr_socket_unix *un,
> +			      struct socket *socket)
> +{
> +	struct sockaddr *loc = (struct sockaddr *)&un->laddr;
> +	struct sockaddr *rem = (struct sockaddr *)&un->raddr;
> +
> +	if (socket->ops->getname(socket, loc, &un->laddr_len, 0)) {
> +		ckpt_write_err(ctx, "Unable to getname of local");
> +		return -EINVAL;
> +	}

This direct call to ->getname skips security checks through
getsockname(). You may want to refactor sys_getsockname() similar
to sys_bind().

> +
> +	if (socket->ops->getname(socket, rem, &un->raddr_len, 1)) {
> +		if ((socket->sk->sk_type != SOCK_DGRAM) &&
> +		    (socket->sk->sk_state == TCP_ESTABLISHED)) {
> +			ckpt_write_err(ctx, "Unable to getname of remote");
> +			return -EINVAL;
> +		}

And here it skips security checks through sys_getppername().

> +		un->raddr_len = 0;
> +	}
> +
> +	return 0;
> +}
> +
> +static int sock_unix_checkpoint(struct ckpt_ctx *ctx,
> +			        struct socket *socket,
> +			        struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(socket->sk);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	struct ckpt_hdr_socket_unix *un;
> +	int new;
> +	int ret = -ENOMEM;
> +
> +	if ((socket->sk->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&socket->sk->sk_receive_queue)) {
> +		ckpt_write_err(ctx, "listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> +
> +	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (!un)
> +		goto out;
> +
> +	ret = sock_unix_getnames(ctx, un, socket);
> +	if (ret)
> +		goto out;
> +
> +	if (sk->dentry && (sk->dentry->d_inode->i_nlink > 0))
> +		un->flags |= CKPT_UNIX_LINKED;
> +
> +	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> +	if (un->this < 0)
> +		goto out;

un->this is unsigned... but the real fix is to make un->this __s32
as noted above.

> +
> +	if (sk->peer)
> +		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> +	else
> +		un->peer = 0;
> +
> +	if (un->peer < 0) {

ditto.

> +		ret = un->peer;
> +		goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
> +	if (ret < 0)
> +		goto out;
> +
> +	if (sock_unix_need_cwd(&un->laddr, un->laddr_len))
> +		ret = sock_unix_write_cwd(ctx, socket->sk, un->laddr.sun_path);
> + out:
> +	ckpt_hdr_put(ctx, un);
> +
> +	return ret;
> +}
> +
> +static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
> +{
> +	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
> +		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
> +
> +	if (h->sock.shutdown & ~SHUTDOWN_MASK)
> +		return -EINVAL;
> +	if (h->sock.userlocks & ~userlocks_mask)
> +		return -EINVAL;
> +	if (h->sock.sndtimeo < 0)
> +		return -EINVAL;
> +	if (h->sock.rcvtimeo < 0)
> +		return -EINVAL;

Forgot sock.rcvlowat ?

> +	if ((h->sock.userlocks & SOCK_SNDBUF_LOCK) &&
> +	    ((h->sock.sndbuf < SOCK_MIN_SNDBUF) ||
> +	     (h->sock.sndbuf > sysctl_wmem_max)))
> +		return -EINVAL;

At least for afunix, if the user did not explicitly set the sndbuf,
then userlocks won't have SOCK_SNDBUF_LOCK set.

Also, if userlocks in the image doesn't have SOCK_SNDBUF_LOCK, then
the sndbuf value isn't checked ?

> +	if ((h->sock.userlocks & SOCK_RCVBUF_LOCK) &&
> +	    ((h->sock.rcvbuf < SOCK_MIN_RCVBUF) ||
> +	     (h->sock.rcvbuf > sysctl_rmem_max)))
> +		return -EINVAL;

ditto.

> +	if ((h->sock.flags & SOCK_LINGER) &&
> +	    (h->sock.lingertime > MAX_SCHEDULE_TIMEOUT))
> +		return -EINVAL;

Regardless of SOCK_LINGER flag, lingertime should never exceed that
maximum value.

What about verifying sock.flags itself ?
In doing that, some options may assume/require some state --
- SOCK_USE_WRITE_QUEUE only used in ipv4/ipv6/sctp
- SOCK_DESTROY only used in some protocols

Perhaps sanitize sock.flags per protocol ?

> +	if (!ckpt_validate_errno(h->sock.err))
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static int sock_cptrst(struct ckpt_ctx *ctx,
> +		       struct sock *sock,
> +		       struct ckpt_hdr_socket *h,
> +		       int op)
> +{
> +	if (sock->sk_socket) {
> +		CKPT_COPY(op, h->socket.flags, sock->sk_socket->flags);
> +		CKPT_COPY(op, h->socket.state, sock->sk_socket->state);
> +	}
> +
> +	CKPT_COPY(op, h->sock_common.reuse, sock->sk_reuse);
> +	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
> +	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
> +
> +	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
> +	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
> +	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
> +	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
> +	CKPT_COPY(op, h->sock.err, sock->sk_err);
> +	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
> +	CKPT_COPY(op, h->sock.priority, sock->sk_priority);
> +	CKPT_COPY(op, h->sock.rcvlowat, sock->sk_rcvlowat);
> +	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
> +	CKPT_COPY(op, h->sock.rcvtimeo, sock->sk_rcvtimeo);
> +	CKPT_COPY(op, h->sock.sndtimeo, sock->sk_sndtimeo);
> +	CKPT_COPY(op, h->sock.rcvbuf, sock->sk_rcvbuf);
> +	CKPT_COPY(op, h->sock.sndbuf, sock->sk_sndbuf);
> +	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
> +	CKPT_COPY(op, h->sock.lingertime, sock->sk_lingertime);
> +	CKPT_COPY(op, h->sock.type, sock->sk_type);
> +	CKPT_COPY(op, h->sock.state, sock->sk_state);

Many of these direct copy into the socket and sock effectively
bypass security checks that take place in {get,set}sockopt(),
either explicitly (e.g. sk_sndtimeo) or implicitly (e.g.
SOCK_LINGER in sock.flags, reflecting SO_LINGER option).

This applies both to checkpoint (potentially bypassing permission
of the checkpointer to view this data) and restart (bypassing
permissions of user to set these values).

The alternative is to use socksetopt/sockgetopt for those
values that should be subject to security checks.

> +
> +	if ((h->socket.state == SS_CONNECTED) &&
> +	    (h->sock.state != TCP_ESTABLISHED)) {
> +		ckpt_debug("socket/sock in inconsistent state: %i/%i",
> +			   h->socket.state, h->sock.state);
> +		return -EINVAL;

There should also be per-protocol consistency checks. E.g. afunix
cannot be in socket.state == SS_{DIS,}CONNECTING

> +	} else if ((h->sock.state < TCP_ESTABLISHED) ||
> +		   (h->sock.state >= TCP_MAX_STATES)) {
> +		ckpt_debug("sock in invalid state: %i", h->sock.state);
> +		return -EINVAL;
> +	} else if ((h->socket.state < SS_FREE) ||
> +		   (h->socket.state > SS_DISCONNECTING)) {
> +		ckpt_debug("socket in invalid state: %i",
> +			   h->socket.state);
> +		return -EINVAL;
> +	}
> +
> +	if (op == CKPT_CPT)
> +		return sock_cptrst_verify(h);
> +	else
> +		return 0;
> +}
> +
> +int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	struct socket *socket = file->private_data;
> +	struct sock *sock = socket->sk;
> +	struct ckpt_hdr_socket *h;
> +	int ret = 0;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	ret = sock_cptrst(ctx, sock, h, CKPT_CPT);
> +	if (ret)
> +		goto out;
> +
> +	if (sock->sk_family == AF_UNIX) {
> +		ret = sock_unix_checkpoint(ctx, socket, h);
> +		if (ret)
> +			goto out;
> +	} else {
> +		ckpt_write_err(ctx, "unsupported socket family %i",
> +			       sock->sk_family);
> +		ret = EINVAL;
		     ^^^^
		     - !!!
Better yet: -ENOSYS ?

> +		goto out;
> +	}
> +
> +	if (sock->sk_state != TCP_LISTEN) {
> +		ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
> +		if (ret)
> +			goto out;
> +
> +		ret = sock_write_buffers(ctx, &sock->sk_write_queue);
> +		if (ret)
> +			goto out;
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static int sock_read_buffer(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct ckpt_hdr h;
> +	struct msghdr msg;
> +	struct kvec kvec;
> +	int ret = 0;
> +	int len;
> +
> +	memset(&msg, 0, sizeof(msg));
> +
> +	len = _ckpt_read_hdr_type(ctx, &h, CKPT_HDR_SOCKET_BUFFER);
> +	if (len < 0)
> +		return len;
> +
> +	if (len > SKB_MAX_ALLOC) {
> +		ckpt_debug("Socket buffer too big (%i > %lu)",
> +			   len, SKB_MAX_ALLOC);
> +		return -ENOSPC;
> +	}
> +
> +	kvec.iov_len = len;
> +	kvec.iov_base = kmalloc(len, GFP_KERNEL);
> +	if (!kvec.iov_base)
> +		return -ENOMEM;
> +
> +	ret = _ckpt_read_payload(ctx, &h, kvec.iov_base);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);

Is it possible to avoid the extra copy using splice() instead ?

> +	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
> +	if ((ret > 0) && (ret != len))
> +		ret = -ENOMEM;
> + out:
> +	return ret;
> +}
> +
> +static int sock_read_buffers(struct ckpt_ctx *ctx, struct sock *sock,
> +			     uint32_t *bufsize)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int ret = 0;
> +	int i;
> +	uint32_t total = 0;
> +	uint8_t sock_shutdown;
> +
> +	/* If peer is shutdown, unshutdown it for this process */
> +	sock_shutdown = sock->sk_shutdown;
> +	sock->sk_shutdown &= ~SHUTDOWN_MASK;

SOCK_DEAD in sk->flags may also pose a problem.
(Do we at all need to checkpoint and/or restore SOCK_DEAD ?!)

> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (IS_ERR(h)) {
> +		ret = PTR_ERR(h);
> +		goto out;
> +	}
> +
> +	if (!bufsize) {
> +		if (h->total_bytes != 0) {
> +			ckpt_debug("Expected empty buffer, got %u\n",
> +				   h->total_bytes);
> +			ret = -EINVAL;
> +		}
> +		goto out;
> +	} else if (h->total_bytes > *bufsize) {
> +		if (capable(CAP_NET_ADMIN))
> +			*bufsize = h->total_bytes;

Hmm... this test is quite hidden here - maybe a fat comment
with a reference to why it's here and what it is doing ?

> +		else {
> +			ckpt_debug("Buffer total %u exceeds limit %u\n",
> +			   h->total_bytes, *bufsize);
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +	}
> +
> +	for (i = 0; i < h->skb_count; i++) {
> +		ret = sock_read_buffer(ctx, sock);
> +		ckpt_debug("read buffer %i: %i\n", i, ret);
> +		if (ret < 0)
> +			break;
> +
> +		total += ret;
> +		if (total > h->total_bytes) {

What if 'total' overflows (for CAP_NET_ADMIN) ?   perhaps:
		if (total > h->total_bytes || total < ret) {

> +			ckpt_debug("Buffers exceeded claimed %u", total);
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +	}
> +
> +	if (total == h->total_bytes)
> +		ret = 0;
> +	else {
> +		ckpt_debug("Inconsistent total buffer size %u != %u\n",
> +			   total, h->total_bytes);
> +		ret = -EINVAL;
> +	}
> + out:
> +	sock->sk_shutdown = sock_shutdown;
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static struct unix_address *sock_unix_makeaddr(struct sockaddr_un *sun_addr,
> +					       unsigned len)
> +{
> +	struct unix_address *addr;
> +
> +	if (len > sizeof(struct sockaddr_un))
> +		return ERR_PTR(-EINVAL);
> +
> +	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
> +	if (!addr)
> +		return ERR_PTR(-ENOMEM);
> +
> +	memcpy(addr->name, sun_addr, len);
> +	addr->len = len;
> +	atomic_set(&addr->refcnt, 1);
> +
> +	return addr;
> +}
> +
> +static int sock_unix_join(struct ckpt_ctx *ctx,
> +			  struct sock *a,
> +			  struct sock *b,
> +			  struct ckpt_hdr_socket_unix *un)
> +{
> +	struct unix_address *addr = NULL;
> +
> +	sock_hold(a);
> +	sock_hold(b);
> +
> +	unix_sk(a)->peer = b;
> +	unix_sk(b)->peer = a;
> +
> +	a->sk_peercred.pid = task_tgid_vnr(current);
> +	a->sk_peercred.uid = ctx->realcred->uid;
> +	a->sk_peercred.gid = ctx->realcred->gid;
> +
> +	b->sk_peercred.pid = a->sk_peercred.pid;
> +	b->sk_peercred.uid = a->sk_peercred.uid;
> +	b->sk_peercred.gid = a->sk_peercred.gid;
> +

Does the following bypass security checks for sys_connect() ?

> +	if (!UNIX_ADDR_EMPTY(un->raddr_len))
> +		addr = sock_unix_makeaddr(&un->raddr, un->raddr_len);
> +	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
> +		addr = sock_unix_makeaddr(&un->laddr, un->laddr_len);
> +
> +	if (IS_ERR(addr))
> +		return PTR_ERR(addr);
> +	else if (addr) {
> +		atomic_inc(&addr->refcnt); /* Held by both ends */
> +		unix_sk(a)->addr = unix_sk(b)->addr = addr;
> +	}
> +
> +	return 0;
> +}
> +
> +static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
> +				       struct ckpt_hdr_socket *h,
> +				       struct ckpt_hdr_socket_unix *un,
> +				       struct socket *socket)
> +{
> +	struct sock *this = ckpt_obj_fetch(ctx, un->this, CKPT_OBJ_SOCK);
> +	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
> +	struct socket *tmp = NULL;
> +	int ret;
> +
> +	if (!IS_ERR(this) && !IS_ERR(peer)) {
> +		/* We're last */
> +		struct socket *old = this->sk_socket;
> +
> +		old->sk = NULL;
> +		sock_release(old);
> +		sock_graft(this, socket);
> +
> +	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {
> +		/* We're first */
> +		int family = socket->sk->sk_family;
> +		int type = socket->sk->sk_type;
> +
> +		ret = sock_create(family, type, 0, &tmp);
> +		ckpt_debug("sock_create: %i\n", ret);
> +		if (ret)
> +			goto out;
> +
> +		this = socket->sk;
> +		peer = tmp->sk;
> +
> +		ret = ckpt_obj_insert(ctx, this, un->this, CKPT_OBJ_SOCK);
> +		if (ret < 0)
> +			goto out;
> +
> +		ret = ckpt_obj_insert(ctx, peer, un->peer, CKPT_OBJ_SOCK);
> +		if (ret < 0)
> +			goto out;
> +
> +		ret = sock_unix_join(ctx, this, peer, un);
> +		ckpt_debug("sock_unix_join: %i\n", ret);
> +		if (ret)
> +			goto out;
> +
> +	} else {
> +		ckpt_debug("Order Error\n");
> +		ret = PTR_ERR(this);
> +		goto out;
> +	}
> +
> +	/* Prime the socket's buffer limit with the maximum */
> +	peer->sk_userlocks |= SOCK_SNDBUF_LOCK;
> +	peer->sk_sndbuf = sysctl_wmem_max;

I suppose this meant to be temporary ?

> +
> +	/* Read my buffers and sendmsg() then back to me via my peer */
> +	ret = sock_read_buffers(ctx, peer, &peer->sk_sndbuf);
> +	ckpt_debug("sock_read_buffers: %i\n", ret);
> +	if (ret)
> +		goto out;
> +
> +	/* Read peer's buffers and expect 0 */
> +	ret = sock_read_buffers(ctx, peer, NULL);

It is indeed a good idea to make it generic for all sockets, but I
suspect the way sock_read_buffers() works will only be suitable for
afunix, and perhaps for in-container inet4/6 (by "in-container" I
mean that both sides of the connection are in the checkpoint image).

> + out:
> +	if (tmp && ret)
> +		sock_release(tmp);
> +
> +	return ret;
> +}
> +
> +static int sock_unix_unlink(const char *name)
> +{
> +	struct path spath;
> +	struct path ppath;
> +	int ret;
> +
> +	ret = kern_path(name, 0, &spath);
> +	if (ret)
> +		return ret;
> +
> +	ret = kern_path(name, LOOKUP_PARENT, &ppath);
> +	if (ret)
> +		goto out_s;
> +
> +	if (!spath.dentry) {
> +		ckpt_debug("No dentry found for %s\n", name);
> +		ret = -ENOENT;
> +		goto out_p;
> +	}
> +
> +	if (!ppath.dentry || !ppath.dentry->d_inode) {
> +		ckpt_debug("No inode for parent of %s\n", name);
> +		ret = -ENOENT;
> +		goto out_p;
> +	}
> +
> +	ret = vfs_unlink(ppath.dentry->d_inode, spath.dentry);
> + out_p:
> +	path_put(&ppath);
> + out_s:
> +	path_put(&spath);
> +
> +	return ret;
> +}
> +
> +/* Call bind() for socket, optionally changing (temporarily) to @path first
> + * if non-NULL
> + */
> +static int sock_unix_chdir_and_bind(struct socket *socket,
> +				    const char *path,
> +				    struct sockaddr *addr,
> +				    unsigned long addrlen)
> +{
> +	struct sockaddr_un *un = (struct sockaddr_un *)addr;
> +	int ret;
> +	struct path cur;
> +	struct path dir;
> +
> +	if (path) {
> +		ckpt_debug("switching to cwd %s for unix bind", path);
> +
> +		ret = kern_path(path, 0, &dir);
> +		if (ret)
> +			return ret;
> +
> +		ret = inode_permission(dir.dentry->d_inode,
> +				       MAY_EXEC | MAY_ACCESS);
> +		if (ret)
> +			goto out;
> +
> +		write_lock(&current->fs->lock);
> +		cur = current->fs->pwd;
> +		current->fs->pwd = dir;
> +		write_unlock(&current->fs->lock);
> +	}
> +
> +	ret = sock_unix_unlink(un->sun_path);
> +	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
> +	if ((ret == 0) || (ret == -ENOENT))
> +		ret = sock_bind(socket, addr, addrlen);
> +
> +	if (path) {
> +		write_lock(&current->fs->lock);
> +		current->fs->pwd = cur;
> +		write_unlock(&current->fs->lock);
> +	}
> + out:
> +	if (path)
> +		path_put(&dir);
> +
> +	return ret;
> +}
> +
> +static int sock_unix_fakebind(struct socket *socket,
> +			      struct sockaddr_un *addr,
> +			      unsigned long len)
> +{
> +	struct unix_address *uaddr;
> +
> +	uaddr = sock_unix_makeaddr(addr, len);
> +	if (IS_ERR(uaddr))
> +		return PTR_ERR(uaddr);
> +
> +	unix_sk(socket->sk)->addr = uaddr;
> +
> +	return 0;
> +}
> +
> +static int sock_unix_bind(struct ckpt_hdr_socket *h,
> +			  struct ckpt_hdr_socket_unix *un,
> +			  struct socket *socket,
> +			  const char *path)
> +{
> +	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
> +	unsigned long len = un->laddr_len;
> +
> +	if (!un->laddr.sun_path[0])
> +		return sock_bind(socket, addr, len);
> +	else if (!(un->flags & CKPT_UNIX_LINKED))
> +		return sock_unix_fakebind(socket, &un->laddr, len);
> +	else
> +		return sock_unix_chdir_and_bind(socket, path, addr, len);
> +}
> +
> +static int sock_unix_restore(struct ckpt_ctx *ctx,
> +			     struct ckpt_hdr_socket *h,
> +			     struct socket *socket)
> +{
> +	struct ckpt_hdr_socket_unix *un;
> +	int ret = -EINVAL;
> +	char *cwd = NULL;
> +	struct net *net = sock_net(socket->sk);
> +
> +	/* AF_UNIX overloads the backlog setting to define the maximum
> +	 * queue length for DGRAM sockets.  Make sure we don't let the
> +	 * caller exceed that value on restart.
> +	 */
> +	if ((h->sock.type == SOCK_DGRAM) &&
> +	    (h->sock.backlog > net->unx.sysctl_max_dgram_qlen)) {
> +		ckpt_debug("DGRAM backlog of %i exceeds system max of %i\n",
> +			   h->sock.backlog, net->unx.sysctl_max_dgram_qlen);
> +		return -EINVAL;
> +	}
> +
> +	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (IS_ERR(un))
> +		return PTR_ERR(un);
> +
> +	if (un->peer < 0)
> +		goto out;
> +
> +	if (sock_unix_need_cwd(&un->laddr, un->laddr_len)) {
> +		ret = ckpt_read_string(ctx, &cwd, PATH_MAX);
> +		ckpt_debug("read cwd(%i): %s\n", ret, cwd);
> +		if (ret)
> +			goto out;
> +	}
> +
> +	if ((h->sock.state != TCP_ESTABLISHED) &&
> +	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
> +		ret = sock_unix_bind(h, un, socket, cwd);
> +		if (ret)
> +			goto out;
> +	}
> +

Hmm... does the code below work well with dgram sockets who received
data from the peer, and then the peer died (before checkpoint) ?

> +	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
> +		ret = sock_unix_restore_connected(ctx, h, un, socket);
> +	else if (h->sock.state == TCP_LISTEN)
> +		ret = socket->ops->listen(socket, h->sock.backlog);
> +	else
> +		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
> + out:
> +	ckpt_hdr_put(ctx, un);
> +	kfree(cwd);
> +	return ret;
> +}
> +
> +struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
> +				    struct ckpt_hdr_socket *h)
> +{
> +	struct socket *socket;
> +	int ret;
> +
> +	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
> +	if (ret < 0)
> +		return ERR_PTR(ret);
> +
> +	if (h->sock_common.family == AF_UNIX) {
> +		ret = sock_unix_restore(ctx, h, socket);
> +		ckpt_debug("sock_unix_restore: %i\n", ret);
> +	} else {
> +		ckpt_debug("unsupported family %i\n", h->sock_common.family);
> +		ret = -EINVAL;
> +	}
> +
> +	if (ret)
> +		goto out;
> +
> +	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
> + out:
> +	if (ret) {
> +		sock_release(socket);
> +		socket = ERR_PTR(ret);
> +	}
> +
> +	return socket;
> +}
> +
> diff --git a/net/socket.c b/net/socket.c
> index 017f6e6..ff556fc 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -96,6 +96,8 @@
>  #include <net/sock.h>
>  #include <linux/netfilter.h>
>  
> +#include <linux/checkpoint.h>
> +
>  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
>  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			 unsigned long nr_segs, loff_t pos);
> @@ -140,6 +142,9 @@ static const struct file_operations socket_file_ops = {
>  	.sendpage =	sock_sendpage,
>  	.splice_write = generic_splice_sendpage,
>  	.splice_read =	sock_splice_read,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint =   sock_file_checkpoint,
> +#endif
>  };
>  
>  /*
> @@ -415,6 +420,86 @@ int sock_map_fd(struct socket *sock, int flags)
>  	return fd;
>  }
>  
> +#ifdef CONFIG_CHECKPOINT
> +int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct ckpt_hdr_file_socket *h;
> +	int ret;
> +	struct file *file = ptr;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->common.f_type = CKPT_FILE_SOCKET;
> +
> +	ret = checkpoint_file_common(ctx, file, &h->common);
> +	if (ret < 0)
> +		goto out;
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = do_sock_file_checkpoint(ctx, file);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +static struct file *sock_alloc_attach_fd(struct socket *socket)

Nit: I think this name is misleading - sock_attach_fd() itself is
already and should have been sock_attach_file() IMHO - so perhaps
s/fd/file here ?

> +{
> +	struct file *file;
> +	int err;
> +
> +	file = get_empty_filp();
> +	if (!file)
> +		return ERR_PTR(ENOMEM);
> +
> +	err = sock_attach_fd(socket, file, 0);
> +	if (err < 0) {
> +		put_filp(file);
> +		file = ERR_PTR(err);
> +	}
> +
> +	return file;
> +}
> +
> +void *sock_file_restore(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_socket *h = NULL;
> +	struct socket *socket = NULL;
> +	struct file *file = NULL;
> +	int err;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> +	if (IS_ERR(h))
> +		return h;
> +
> +	socket = do_sock_file_restore(ctx, h);
> +	if (IS_ERR(socket)) {
> +		err = PTR_ERR(socket);
> +		goto err_put;
> +	}
> +
> +	file = sock_alloc_attach_fd(socket);
> +	if (IS_ERR(file)) {
> +		err = PTR_ERR(file);
> +		goto err_release;
> +	}
> +
> +	ckpt_hdr_put(ctx, h);
> +
> +	return file;
> +
> + err_release:
> +	sock_release(socket);
> + err_put:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ERR_PTR(err);
> +}
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static struct socket *sock_from_file(struct file *file, int *err)
>  {
>  	if (file->f_op == &socket_file_ops)

Oren.

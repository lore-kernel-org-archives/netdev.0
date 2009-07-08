From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 02:32:34 -0400
Message-ID: <4A543D82.5080408@cs.columbia.edu>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246994776-1882-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Definitely making good progress !

Dan Smith wrote:
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports socketpair()s, path-based, and
> abstract sockets.
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

> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 421afb4..e7d64eb 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
>  #include <linux/uio.h>			/* iovec support		*/
>  #include <linux/types.h>		/* pid_t			*/
>  #include <linux/compiler.h>		/* __user			*/
> +#include <linux/checkpoint_hdr.h>	/* ckpt_hdr			*/

Re: recent thread about archs that don't support checkpoint,
   #include <linux/checkpoint.h>

(The fix will be on ckpt-v17).

>  
>  #ifdef __KERNEL__
>  # ifdef CONFIG_PROC_FS
> @@ -323,5 +324,66 @@ extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *ka
>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>  
>  #endif
> +
> +#define CKPT_UNIX_LINKED 1
> +#define CKPT_UNIX_HASCWD 2
> +struct ckpt_hdr_socket_unix {
> +	struct ckpt_hdr h;
> +	__u32 this;
> +	__u32 peer;
> +	__u32 flags;
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket {
> +	struct ckpt_hdr h;
> +
> +	struct ckpt_socket { /* struct socket */
> +		__u64 flags;
> +		__u8 state;
> +	} socket __attribute__ ((aligned(8)));
> +
> +	struct ckpt_sock_common { /* struct sock_common */
> +		__u32 bound_dev_if;
> +		__u16 family;
> +		__u8 state;
> +		__u8 reuse;
> +	} sock_common __attribute__ ((aligned(8)));
> +
> +	struct ckpt_sock { /* struct sock */
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
> +	/* common to all supported families */
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +	/* inet6 socket addresses are the largest, at 28 bytes */

UNIX_PATH_MAX = 108 ...  and then add sizeof(short) ?

Do you also validate the {l,r}addr_len value per socket type
at restore ?

Also, since the socket address depends on the socket type,
maybe move to ckpt_hdr_socket_unix ?  (will also shave a few
bytes off non-af-unix sockets... :p)

> +	char laddr[28];
> +	char raddr[28];
> +
> +} __attribute__ ((aligned(8)));

[...]

> +
> +/* Size of an empty struct sockaddr_un */
> +#define UNIX_LEN_EMPTY 2
			  ^^^
			sizeof(short) ?

[...]

> +
> +static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
> +			       struct sock *sock,
> +			       const char *sockpath)
> +{
> +	struct path path;
> +	char *buf;
> +	char *fqpath;
> +	char *delim;
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
> +
> +	offset = strlen(fqpath) - strlen(sockpath);
> +	if (offset <= 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	delim = &fqpath[offset];
> +	*delim = '\0';
> +
> +	ret = ckpt_write_obj_type(ctx, fqpath, strlen(fqpath),
> +				  CKPT_HDR_FILE_NAME);
> + out:
> +	kfree(buf);
> +	return ret;
> +}
> +
> +static char *sock_unix_read_cwd(struct ckpt_ctx *ctx)
> +{

Perhaps a generic char *ckpt_read_string() ?

> +	char *path;
> +	char *hpath;
> +	struct ckpt_hdr *h;
> +
> +	h = ckpt_read_buf_type(ctx, PATH_MAX, CKPT_HDR_FILE_NAME);
> +	hpath = (char *) (h + 1);
> +	if (IS_ERR(h))
> +		return (char *) h;
> +
> +	path = kzalloc(strlen(hpath) + 1, GFP_KERNEL);
> +	if (!path) {
> +		path = ERR_PTR(ENOMEM);
> +		goto out;
> +	}
> +
> +	memcpy(path, hpath, strlen(hpath));
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return path;
> +}
> +
> +static int sock_unix_checkpoint(struct ckpt_ctx *ctx,
> +			        struct sock *sock,
> +			        struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(sock);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	struct ckpt_hdr_socket_unix *un;
> +	int new;
> +	int ret = -ENOMEM;
> +
> +	if ((sock->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&sock->sk_receive_queue)) {
> +		ckpt_write_err(ctx, "listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> +
> +	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (!un)
> +		goto out;
> +
> +	if (sk->dentry && (sk->dentry->d_inode->i_nlink > 0))
> +		un->flags |= CKPT_UNIX_LINKED;
> +
> +	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> +	if (un->this < 0)
> +		goto out;
> +
> +	if (sk->peer)
> +		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> +	else
> +		un->peer = 0;
> +
> +	if (un->peer < 0) {
> +		ret = un->peer;
> +		goto out;
> +	}
> +
> + 	if ((sk->dentry) && sock_unix_need_cwd((struct sockaddr_un *) h->laddr))
> +		un->flags |= CKPT_UNIX_HASCWD;

Is this flag really needed ?  You can reuse sock_unix_need_cwd()
at restart.

> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
> +	if (ret < 0)
> +		goto out;
> +
> +	if (un->flags & CKPT_UNIX_HASCWD) {
> +		struct sockaddr_un *un = (struct sockaddr_un *) h->laddr;
> +		ret = sock_unix_write_cwd(ctx, sock, un->sun_path);
> +	}
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
> +	if ((h->sock.userlocks & SOCK_SNDBUF_LOCK) &&
> +	    ((h->sock.sndbuf < SOCK_MIN_SNDBUF) ||
> +	     (h->sock.sndbuf > sysctl_wmem_max)))
> +		return -EINVAL;
> +	if ((h->sock.userlocks & SOCK_RCVBUF_LOCK) &&
> +	    ((h->sock.rcvbuf < SOCK_MIN_RCVBUF) ||
> +	     (h->sock.rcvbuf > sysctl_rmem_max)))
> +		return -EINVAL;
> +	if ((h->sock.flags & SOCK_LINGER) &&
> +	    (h->sock.lingertime > MAX_SCHEDULE_TIMEOUT))
> +		return -EINVAL;
> +	/* Current highest errno is ~530; this should provide some sanity */
> +	if ((h->sock.err < 0) || (h->sock.err > 1024))
> +		return -EINVAL;

I guess there are/will be other places that call for errno
validation, so making an (inline) helper would be useful.

> +
> +	return 0;
> +}
> +

[...]

> +
> +static int sock_read_buffer(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct sk_buff **skb)
> +{
> +	struct ckpt_hdr h;
> +	int ret = 0;
> +	int len;
> +
> +	len = _ckpt_read_hdr_type(ctx, &h, CKPT_HDR_SOCKET_BUFFER);
> +	if (len < 0)
> +		return len;
> +
> +	if (len > SKB_MAX_ALLOC) {
> +		ckpt_debug("Socket buffer too big (%i > %solu)",
> +			   len, SKB_MAX_ALLOC);
> +		return -ENOSPC;
> +	}
> +
> +	*skb = sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);

I looked at the socket code again, and I suspect this is wrong.

Since this is called after the fields of the socket are restored,
need to be careful with certain settings. For instance, it will
fail if the socket is shutdown already; Perhaps on other conditions
too.

Also, it has some side-effects:

First, it modifies sk->sk_wmem_alloc, which is not what you want
when restoring the receive buffer.

Second, on the other hand, sk->sk_rmem_alloc isn't restored.

Third, it sets the sk->sk_destructor to sock_wfree(), of own socket,
which is not what happens, e.g., usually with af_unix sockets.

(if I understand the af_unix code correctly, when socket A sends to
socket B, then A->sk->sk_wmem_alloc is incremented, as well as
B->sk->sk_rmem_alloc, and when the app reads the data, the kernel
decreases B->sk->sk_rmem_alloc and finally the callback sock_wfree()
decreases A->sk->sk_wmem_alloc).

Forth, you restore the buffer after having restored sk_{snd,rcv}buf.
So if, for example, the app originally had sk_sndbuf=16K, then sent
16K (not read by peer), then set sk_sndbuf=4K -- restore will fail.

Fifth, unix domains sockets never hold actualy data in the sndbuf,
they only keep track of bytes allocated (sk_wmem_alloc), and the
data is always placed on the receiver's rcvbuf. If the checkpoint
image tells another story, report an error.

The problem stems from trying to imitate the network code instead
of reusing it - for example, by really sending data from the source
socket (or a dummy one, if original no longer exists) to the target
socket.

> +	if (*skb == NULL)
> +		return ENOMEM;
> +
> +	ret = _ckpt_read_payload(ctx, &h, skb_put(*skb, len));
> +
> +	return ret;
> +}
> +
> +static int sock_read_buffers(struct ckpt_ctx *ctx,
> +			     struct sock *sock,
> +			     struct sk_buff_head *queue,
> +			     uint32_t skb_limit)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int ret = 0;
> +	int i;
> +	uint32_t total = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (IS_ERR(h)) {
> +		ret = PTR_ERR(h);
> +		goto out;
> +	}
> +
> +	for (i = 0; i < h->skb_count; i++) {
> +		struct sk_buff *skb = NULL;
> +
> +		ret = sock_read_buffer(ctx, sock, &skb);
> +		if (ret)
> +			break;
> +
> +		skb_queue_tail(queue, skb);
> +
> +		total += skb->len;
> +		if (skb_limit && (total > skb_limit)) {
> +			ckpt_write_err(ctx,
> +				       "Socket buffers exceeded limit of %u",
> +				       total);
> +			ret = -ENOSPC;
> +			goto out;
> +		}
> +	}
> + out:
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
> +	if (len > UNIX_PATH_MAX)
> +		return ERR_PTR(ENOSPC);

-EINVAL ?  The input from checkpoint image is invalid -
someone must have messed with it.

> +	else if (len == 0)
> +		return ERR_PTR(ENOSPC);

Ditto.

Besides, I think this can't happen because you only call
sock_unix_bind(), below, if len was not zero so could leave a
BUG_ON just in case.

Actually, should require len > sizeof(short) ...

> +
> +	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
> +	if (!addr)
> +		return ERR_PTR(ENOMEM);
> +
> +	memcpy(addr->name, sun_addr, len);
> +	addr->len = len;
> +	atomic_set(&addr->refcnt, 1);
> +
> +	return addr;
> +}
> +
> +static int sock_unix_join(struct sock *a,
> +			  struct sock *b,
> +			  struct ckpt_hdr_socket *h)
> +{
> +	struct unix_address *addr;
> +
> +	sock_hold(a);
> +	sock_hold(b);
> +
> +	unix_sk(a)->peer = b;
> +	unix_sk(b)->peer = a;
> +
> +	a->sk_peercred.pid = task_tgid_vnr(current);
> +	current_euid_egid(&a->sk_peercred.uid,
> +			  &a->sk_peercred.gid);
> +
> +	b->sk_peercred.pid = task_tgid_vnr(current);
> +	current_euid_egid(&b->sk_peercred.uid,
> +			  &b->sk_peercred.gid);

The recent patchset has support for credentials, uid and gid.

> +
> +	if (h->laddr_len == UNIX_LEN_EMPTY)
> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->raddr,
> +					  h->raddr_len);
> +	else if (h->raddr_len == UNIX_LEN_EMPTY)
> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->laddr,
> +					  h->laddr_len);

If neither conditions holds, @addr will remain uninitialized.
(did the compiler not complain ?)

> +	if (IS_ERR(addr))
> +	    return PTR_ERR(addr);
> +
> +	atomic_inc(&addr->refcnt); /* Held by both ends */
> +	unix_sk(a)->addr = unix_sk(b)->addr = addr;
> +
> +	return 0;
> +}
> +
> +static int sock_unix_restart_connected(struct ckpt_ctx *ctx,
			^^^^^^^
Tiny nit:               restore

> +				       struct ckpt_hdr_socket *h,
> +				       struct ckpt_hdr_socket_unix *un,
> +				       struct socket *socket)
> +{
> +	struct sock *this = socket->sk;
> +	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
> +	int ret;
> +
> +	if (!IS_ERR(peer)) {
> +		/* We're last, so join with peer */
> +		ret = sock_unix_join(this, peer, h);
> +	} else if (PTR_ERR(peer) == -EINVAL) {
> +		/* We're first, so add our socket and wait for peer */
> +		ret = ckpt_obj_insert(ctx, socket->sk, un->this, CKPT_OBJ_SOCK);
> +		if (ret >= 0)
> +			ret = 0;
> +	} else {
> +		ret = PTR_ERR(peer);
> +	}
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

Bizarre, but still: is it possible that at restart time (and also
at checkpoint time) the pathname will not be accessible ?

Like: create socket, bind it to some mounted subtree, and then
force-un-mount the subtree. Of course, the socket will no longer
be reachable (to connect to) from then on. Now checkpoint. The
restart will fail - because the bind fails, but unnecessarily so :(

> +	ret = sock_unix_unlink(un->sun_path);
> +	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
> +	if ((ret != 0) && (ret != ENOENT))
> +		goto out;
		^^^^^^^^
		goto path;

FWIW, if it fails it restores the cwd. Just in case.

> +
> +	ret = socket->ops->bind(socket, addr, addrlen);
> +

    path:
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
> +	struct sockaddr *addr = (struct sockaddr *)&h->laddr;
> +	struct sockaddr_un *uaddr = (struct sockaddr_un *)addr;
> +	unsigned long len = h->laddr_len;
> +
> +	if (!(un->flags & CKPT_UNIX_LINKED))
> +		return sock_unix_fakebind(socket, uaddr, len);
> +	else if (uaddr->sun_path[0])
> +		return sock_unix_chdir_and_bind(socket, path, addr, len);
> +	else
> +		return socket->ops->bind(socket, addr, len);

Hmmm... abstract unix sockets have sk->dentry = NULL, so at checkpoint
time, sock_unix_checkpoint() will not set CKPT_UNIX_LINKED for them.
It will end up always doing fake-bind :(

> +}
> +
> +static int sock_unix_restart(struct ckpt_ctx *ctx,
			^^^^^^^
Tiny nit: 	        restore
> +			     struct ckpt_hdr_socket *h,
> +			     struct socket *socket)
> +{
> +	struct ckpt_hdr_socket_unix *un;
> +	int ret = -EINVAL;
> +	char *cwd = NULL;
> +
> +	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (IS_ERR(un))
> +		return PTR_ERR(un);
> +
> +	if (un->peer < 0)
> +		goto out;
> +
> +	if (un->flags & CKPT_UNIX_HASCWD) {

Can reuse sock_unix_need_crd() intead of flag ?

> +		cwd = sock_unix_read_cwd(ctx);
> +		if (IS_ERR(cwd)) {
> +			ret = PTR_ERR(cwd);
> +			goto out;
> +		}
> +	}
> +
> +	if ((h->sock.state != TCP_ESTABLISHED) && h->laddr_len) {

This is where you ensure that len for bind is cool...
But the test should be: h->laddr_len > sizeof(short)

And in sock_ckptrst() should fail if {l,r}addr_len < sizeof(short).
(Or if you move the addr data to the per-socket-type header, check
it there).

> +		ret = sock_unix_bind(h, un, socket, cwd);
> +		if (ret)
> +			goto out;
> +	}
> +
> +	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
> +		ret = sock_unix_restart_connected(ctx, h, un, socket);
> +	else if (h->sock.state == TCP_LISTEN)
> +		ret = socket->ops->listen(socket, h->sock.backlog);
> +	else
> +		ckpt_write_err(ctx, "unsupported UNIX socket state %i",
> +			       h->sock.state);
		^^^^^^^^^^^^^^
This can destroy your checkpoint image, if passed as a file (and
isn't redirected). Good only for checkpoint.

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
> +		ret = sock_unix_restart(ctx, h, socket);
> +		ckpt_debug("sock_unix_restart: %i\n", ret);
> +	} else {
> +		ckpt_write_err(ctx, "unsupported family %i\n",
> +			       h->sock_common.family);
		^^^^^^^^^^^^^^^
And here.

> +		ret = -EINVAL;
> +	}
> +
> +	if (ret)
> +		goto out;
> +
> +	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
> +	if (ret)
> +		goto out;
> +
> +	if (h->sock.state != TCP_LISTEN) {
> +		struct sock *sk = socket->sk;
> +		uint32_t rlimit = sysctl_rmem_max;
> +		uint32_t wlimit = sysctl_wmem_max;
> +
> +		if (capable(CAP_NET_ADMIN))
> +			rlimit = wlimit = 0;
> +
> +		ret = sock_read_buffers(ctx, socket->sk, &sk->sk_receive_queue,
> +					rlimit);
> +		if (ret)
> +			goto out;
> +
> +		ret = sock_read_buffers(ctx, socket->sk, &sk->sk_write_queue,
> +					wlimit);

Should expect empty write queues for af_unix.

> +		if (ret)
> +			goto out;
> +	}
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
> index 791d71a..97950d6 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -96,6 +96,9 @@
>  #include <net/sock.h>
>  #include <linux/netfilter.h>
>  
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>

Re: recent thread about archs that don't support checkpoint, remove
second include.

> +
>  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
>  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			 unsigned long nr_segs, loff_t pos);
> @@ -140,6 +143,9 @@ static const struct file_operations socket_file_ops = {
>  	.sendpage =	sock_sendpage,
>  	.splice_write = generic_splice_sendpage,
>  	.splice_read =	sock_splice_read,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint =   sock_file_checkpoint,
> +#endif
>  };

[...]

Ok, it's a long night. If some of the comments above turn out
to be nonsense -- kindly ignore...

Hopefully some of this will eventually evolve into a set of
unit tests :p

Oren.

From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 15:52:41 -0500
Message-ID: <20090804205241.GF10275@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54595 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300AbZHDUwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:52:49 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74KowN8003062
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 14:50:58 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74KqeGR118144
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 14:52:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74KqcgP000670
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 14:52:39 -0600
Content-Disposition: inline
In-Reply-To: <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
...
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
> +		tmp = skb_clone(skb, GFP_KERNEL);

Does this re-use of tmp make sense?  (It only would if dev_alloc_skb()
did a generic prealloc for any subsequent skb_clone() which i don't think
is the case)

Also, do you need any kind of lock on the queue to make this
walk safe, or do ensure below (sorry i'm slow and haven't gotten
there) that all tasks with an open fd for either end of this
sock are frozen?

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

what about UNIXCB(skb).creds and .secid?

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
> +	struct ckpt_hdr_socket_queue *h;
> +	struct sk_buff_head tmpq;
> +	int ret = -ENOMEM;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
> +	if (!h)
> +		goto out;

Again, you can't ckpt_hdr_put with a NULL h.

> +	skb_queue_head_init(&tmpq);
> +
> +	ret = sock_copy_buffers(queue, &tmpq, &h->total_bytes);
> +	if (ret < 0)
> +		goto out;
> +
> +	h->skb_count = ret;
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
> +	int len = PATH_MAX;
> +	int ret = -ENOENT;
> +
> +	buf = kmalloc(PATH_MAX, GFP_KERNEL);

sending len to kmalloc instead of PATH_MAX might be more future-proof...

> +	if (!buf)
> +		return -ENOMEM;
> +
> +	path.dentry = unix_sk(sock)->dentry;
> +	path.mnt = unix_sk(sock)->mnt;
> +
> +	fqpath = ckpt_fill_fname(&path, &ctx->fs_mnt, buf, &len);
> +	if (IS_ERR(fqpath)) {
> +		ret = PTR_ERR(fqpath);
> +		goto out;
> +	}
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

looks good.

> +static int sock_getnames(struct ckpt_ctx *ctx,
> +			 struct socket *socket,
> +			 struct sockaddr *loc, unsigned *loc_len,
> +			 struct sockaddr *rem, unsigned *rem_len)
> +{
> +	if (sock_getname(socket, loc, loc_len)) {
> +		ckpt_write_err(ctx, "Unable to getname of local");

maybe log the errno?

> +		return -EINVAL;
> +	}
> +
> +	if (sock_getpeer(socket, rem, rem_len)) {
> +		if ((socket->sk->sk_type != SOCK_DGRAM) &&
> +		    (socket->sk->sk_state == TCP_ESTABLISHED)) {
> +			ckpt_write_err(ctx, "Unable to getname of remote");
> +			return -EINVAL;
> +		}
> +		*rem_len = 0;
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
> +	ret = sock_getnames(ctx, socket,
> +			    (struct sockaddr *)&un->laddr, &un->laddr_len,
> +			    (struct sockaddr *)&un->raddr, &un->raddr_len);
> +	if (ret)
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
> +	if (!ckpt_validate_errno(h->sock.err))
> +		return -EINVAL;
> +
> +	/* None of our supported types use this flag */
> +	if (h->sock.flags & SOCK_DESTROY)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static int sock_cptrst_opt(int op, struct socket *socket,
> +			   int optname, char *opt, int len)
> +{
> +	mm_segment_t fs;
> +	int ret;
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +
> +	if (op == CKPT_CPT)
> +		ret = sock_getsockopt(socket, SOL_SOCKET, optname, opt, &len);
> +	else
> +		ret = sock_setsockopt(socket, SOL_SOCKET, optname, opt, len);
> +
> +	set_fs(fs);
> +
> +	return ret;
> +}
> +
> +#define CKPT_COPY_SOPT(op, sock, name, opt) \
> +	sock_cptrst_opt(op, sock->sk_socket, name, (char *)opt, sizeof(*opt))
> +
> +static int sock_cptrst_bufopts(int op, struct sock *sock,
> +			       struct ckpt_hdr_socket *h)
> +
> +{
> +	if (CKPT_COPY_SOPT(op, sock, SO_RCVBUF, &h->sock.rcvbuf))
> +		if ((op == CKPT_RST) &&
> +		    CKPT_COPY_SOPT(op, sock, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
> +			ckpt_debug("Failed to set SO_RCVBUF");
> +			return -EINVAL;
> +		}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_SNDBUF, &h->sock.sndbuf))
> +		if ((op == CKPT_RST) &&
> +		    CKPT_COPY_SOPT(op, sock, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
> +			ckpt_debug("Failed to set SO_SNDBUF");
> +			return -EINVAL;
> +		}
> +
> +	/* It's silly that we have to fight ourselves here, but
> +	 * sock_setsockopt() doubles the initial value, so divide here
> +	 * to store the user's value and avoid doubling on restart
> +	 */
> +	if ((op == CKPT_CPT) && (h->sock.rcvbuf != SOCK_MIN_RCVBUF))
> +		h->sock.rcvbuf >>= 1;
> +
> +	if ((op == CKPT_CPT) && (h->sock.sndbuf != SOCK_MIN_SNDBUF))
> +		h->sock.sndbuf >>= 1;
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
> +	CKPT_COPY(op, h->sock_common.bound_dev_if, sock->sk_bound_dev_if);
> +	CKPT_COPY(op, h->sock_common.family, sock->sk_family);
> +
> +	CKPT_COPY(op, h->sock.shutdown, sock->sk_shutdown);
> +	CKPT_COPY(op, h->sock.userlocks, sock->sk_userlocks);
> +	CKPT_COPY(op, h->sock.no_check, sock->sk_no_check);
> +	CKPT_COPY(op, h->sock.protocol, sock->sk_protocol);
> +	CKPT_COPY(op, h->sock.err, sock->sk_err);
> +	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
> +	CKPT_COPY(op, h->sock.backlog, sock->sk_max_ack_backlog);
> +	CKPT_COPY(op, h->sock.flags, sock->sk_flags);
> +	CKPT_COPY(op, h->sock.type, sock->sk_type);
> +	CKPT_COPY(op, h->sock.state, sock->sk_state);

It looks like the above provides a way around needing CAP_NET_ADMIN
to set SOCK_DBG in sock->sk_flags?  You can probably fix that by
masking it out here, and if a flag in the checkpoint image says
it was on originally, then set it below through setsockopt.

Sanity checking on sk_type, sk_state, backlog etc should probably also be
added.

I do like how you re-use setsockopt below to maintain security
and sanity checks on those fields.

> +
> +	if (sock_cptrst_bufopts(op, sock, h))
> +		return -EINVAL;
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_REUSEADDR, &h->sock_common.reuse)) {
> +		ckpt_debug("Failed to set SO_REUSEADDR");
> +		return -EINVAL;
> +	}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_PRIORITY, &h->sock.priority)) {
> +		ckpt_debug("Failed to set SO_PRIORITY");
> +		return -EINVAL;
> +	}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_RCVLOWAT, &h->sock.rcvlowat)) {
> +		ckpt_debug("Failed to set SO_RCVLOWAT");
> +		return -EINVAL;
> +	}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_LINGER, &h->sock.linger)) {
> +		ckpt_debug("Failed to set SO_LINGER");
> +		return -EINVAL;
> +	}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_SNDTIMEO, &h->sock.sndtimeo)) {
> +		ckpt_debug("Failed to set SO_SNDTIMEO");
> +		return -EINVAL;
> +	}
> +
> +	if (CKPT_COPY_SOPT(op, sock, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
> +		ckpt_debug("Failed to set SO_RCVTIMEO");
> +		return -EINVAL;
> +	}
> +
> +	if ((h->socket.state == SS_CONNECTED) &&
> +	    (h->sock.state != TCP_ESTABLISHED)) {
> +		ckpt_debug("socket/sock in inconsistent state: %i/%i",
> +			   h->socket.state, h->sock.state);
> +		return -EINVAL;
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
> +		ret = -ENOSYS;
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

(will go on from here later :)

-serge

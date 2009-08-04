From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 17:31:41 -0500
Message-ID: <20090804223141.GA14254@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:41099 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbZHDWbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 18:31:39 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74MN3ON018957
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:23:03 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74MVeT0206604
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:31:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74MVdsm020551
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:31:39 -0600
Content-Disposition: inline
In-Reply-To: <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):

> +static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct msghdr msg;
> +	struct kvec kvec;
> +	int ret = 0;
> +	int len;
> +
> +	memset(&msg, 0, sizeof(msg));
> +
> +	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_SOCKET_BUFFER);
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
> +	ret = ckpt_kread(ctx, kvec.iov_base, len);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);
> +	ckpt_debug("kernel_sendmsg(%i): %i\n", len, ret);
> +	if ((ret > 0) && (ret != len))
> +		ret = -ENOMEM;
> + out:
> +	if (ret)

why only free iov_base if ret!=0?

> +		kfree(kvec.iov_base);
> +
> +	return ret;
> +}
> +
> +static struct ckpt_hdr_socket_queue *sock_read_buffer_hdr(struct ckpt_ctx *ctx,
> +							   uint32_t *bufsize)
> +{
> +	struct ckpt_hdr_socket_queue *h;
> +	int err = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
> +	if (IS_ERR(h))
> +		return h;
> +
> +	if (!bufsize) {
> +		if (h->total_bytes != 0) {
> +			ckpt_debug("Expected empty buffer, got %u\n",
> +				   h->total_bytes);
> +			err = -EINVAL;
> +		}
> +	} else if (h->total_bytes > *bufsize) {
> +		/* NB: We let CAP_NET_ADMIN override the system buffer limit
> +		 *     as setsockopt() does
> +		 */
> +		if (capable(CAP_NET_ADMIN))
> +			*bufsize = h->total_bytes;
> +		else {
> +			ckpt_debug("Buffer total %u exceeds limit %u\n",
> +			   h->total_bytes, *bufsize);
> +			err = -EINVAL;
> +		}
> +	}
> +
> +	if (err) {
> +		ckpt_hdr_put(ctx, h);
> +		return ERR_PTR(err);
> +	} else
> +		return h;
> +}
> +
> +static int sock_unix_read_buffers(struct ckpt_ctx *ctx,
> +				  struct sock *sock,
> +				  uint32_t *bufsize)
> +{
> +	uint8_t sock_shutdown;
> +	struct ckpt_hdr_socket_queue *h;
> + 	int ret = 0;
> +	int i;
> +
> +	h = sock_read_buffer_hdr(ctx, bufsize);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	/* If peer is shutdown, unshutdown it for this process */
> +	sock_shutdown = sock->sk_shutdown;
> +	sock->sk_shutdown &= ~SHUTDOWN_MASK;
> +
> +	for (i = 0; i < h->skb_count; i++) {
> +		ret = sock_read_buffer_sendmsg(ctx, sock);
> +		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
> +		if (ret < 0)
> +			break;
> +
> +		if (ret > h->total_bytes) {
> +			ckpt_debug("Buffers exceeded claim");
> +			ret = -EINVAL;
> +			break;
> +		}
> +
> +		h->total_bytes -= ret;
> +		ret = 0;
> +	}
> +
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
> +	/* FIXME: Do we need to call some security hooks here? */
> +
> +	sock_hold(a);
> +	sock_hold(b);
> +
> +	unix_sk(a)->peer = b;
> +	unix_sk(b)->peer = a;
> +
> +	a->sk_peercred.pid = task_tgid_vnr(current);
> +	a->sk_peercred.uid = ctx->realcred->uid;

I don't know how much it matters, but of course root could
be restarting a set of tasks owned by several non-root uids,
and the peercred.uid's might need to be something other than
ctx->realcred->uid.  Or not?

> +	a->sk_peercred.gid = ctx->realcred->gid;
> +
> +	b->sk_peercred.pid = a->sk_peercred.pid;
> +	b->sk_peercred.uid = a->sk_peercred.uid;
> +	b->sk_peercred.gid = a->sk_peercred.gid;
> +

-serge

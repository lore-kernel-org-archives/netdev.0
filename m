From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 01/21] RDS: Socket interface
Date: Tue, 27 Jan 2009 15:08:40 +0300
Message-ID: <20090127120840.GC2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-2-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:48358 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbZA0MIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 07:08:53 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-2-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy.

On Mon, Jan 26, 2009 at 06:17:38PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +/* this is just used for stats gathering :/ */

Shouldn't this be some kind of per-cpu data?

> +static DEFINE_SPINLOCK(rds_sock_lock);
> +static unsigned long rds_sock_count;
> +static LIST_HEAD(rds_sock_list);
> +DECLARE_WAIT_QUEUE_HEAD(rds_poll_waitq);

Global list of all sockets? This does not scale, maybe it should be
groupped into hash table or be per-device?

> +static int rds_release(struct socket *sock)
> +{
> +	struct sock *sk = sock->sk;
> +	struct rds_sock *rs;
> +	unsigned long flags;
> +
> +	if (sk == NULL)
> +		goto out;
> +
> +	rs = rds_sk_to_rs(sk);
> +
> +	sock_orphan(sk);

Why is it needed getting socket is about to be freed?

> +	/* Note - rds_clear_recv_queue grabs rs_recv_lock, so
> +	 * that ensures the recv path has completed messing
> +	 * with the socket. */
> +	rds_clear_recv_queue(rs);
> +	rds_cong_remove_socket(rs);
> +	rds_remove_bound(rs);
> +	rds_send_drop_to(rs, NULL);
> +	rds_rdma_drop_keys(rs);
> +	rds_notify_queue_get(rs, NULL);
> +
> +	spin_lock_irqsave(&rds_sock_lock, flags);
> +	list_del_init(&rs->rs_item);
> +	rds_sock_count--;
> +	spin_unlock_irqrestore(&rds_sock_lock, flags);

Does RDS sockets work with high number of creation/destruction
workloads?
> +static unsigned int rds_poll(struct file *file, struct socket *sock,
> +			     poll_table *wait)
> +{
> +	struct sock *sk = sock->sk;
> +	struct rds_sock *rs = rds_sk_to_rs(sk);
> +	unsigned int mask = 0;
> +	unsigned long flags;
> +
> +	poll_wait(file, sk->sk_sleep, wait);
> +
> +	poll_wait(file, &rds_poll_waitq, wait);
> +

Are you absolutely sure that provided poll_table callback
will not do the bad things here? It is quite unusual to add several
different queues into the same head in the poll callback.
And shouldn't rds_poll_waitq be lock protected here?

> +	read_lock_irqsave(&rs->rs_recv_lock, flags);
> +	if (!rs->rs_cong_monitor) {
> +		/* When a congestion map was updated, we signal POLLIN for
> +		 * "historical" reasons. Applications can also poll for
> +		 * WRBAND instead. */
> +		if (rds_cong_updated_since(&rs->rs_cong_track))
> +			mask |= (POLLIN | POLLRDNORM | POLLWRBAND);
> +	} else {
> +		spin_lock(&rs->rs_lock);

Is there a possibility to have lock iteraction problem with above
rs_recv_lock read lock?

> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)

This should be dropped in the mainline tree.

> +/*
> + * XXX this probably still needs more work.. no INADDR_ANY, and rbtrees aren't
> + * particularly zippy.
> + *
> + * This is now called for every incoming frame so we arguably care much more
> + * about it than we used to.
> + */
> +static DEFINE_SPINLOCK(rds_bind_lock);
> +static struct rb_root rds_bind_tree = RB_ROOT;

Hash table with the appropriate size will have faster lookup/access
times btw.

> +static struct rds_sock *rds_bind_tree_walk(__be32 addr, __be16 port,
> +					   struct rds_sock *insert)
> +{
> +	struct rb_node **p = &rds_bind_tree.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct rds_sock *rs;
> +	u64 cmp;
> +	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
> +
> +	while (*p) {
> +		parent = *p;
> +		rs = rb_entry(parent, struct rds_sock, rs_bound_node);
> +
> +		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
> +		      be16_to_cpu(rs->rs_bound_port);
> +
> +		if (needle < cmp)

Should it use wrapping logic if some field overflows?

> +	rdsdebug("returning rs %p for %u.%u.%u.%u:%u\n", rs, NIPQUAD(addr),
> +		ntohs(port));

Iirc there is a new %pi4 or similar format id.

-- 
	Evgeniy Polyakov

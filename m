From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 11:29:42 +0100
Message-ID: <56E93596.90503@stressinduktion.org>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, santosh.shilimkar@oracle.com,
	eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41392 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934058AbcCPK3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 06:29:45 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 34BBD20D73
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:29:44 -0400 (EDT)
In-Reply-To: <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

some feedback.

On 15.03.2016 19:53, Sowmini Varadhan wrote:
> Add per-net sysctl tunables to set the size of sndbuf and
> rcvbuf on the kernel tcp socket.
>
> The tunables are added at /proc/sys/net/rds/tcp/rds_tcp_sndbuf
> and /proc/sys/net/rds/tcp/rds_tcp_rcvbuf.
>
> Since these values must be set before accept() or connect(),
> and there may be an arbitrary number of existing rds-tcp
> sockets when the tunable is modified. To make sure that all
> connections in the netns pick up the same value for the tunable,
> we reset existing rds-tcp connections in the netns, so that
> they can reconnect with the new parameters.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2; use sysctl instead of module param. Tunabes are now per netns,
>      and can be dynamically modified without restarting all namespaces.
> v3: review comments from Santosh Shilimkar,  Eric Dumazet
>
>   net/rds/tcp.c |  143 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
>   1 files changed, 134 insertions(+), 9 deletions(-)
>
> diff --git a/net/rds/tcp.c b/net/rds/tcp.c
> index ad60299..b720b25 100644
> --- a/net/rds/tcp.c
> +++ b/net/rds/tcp.c
> @@ -54,6 +54,28 @@ static struct kmem_cache *rds_tcp_conn_slab;
>
>   #define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
>
> +static int sndbuf_handler(struct ctl_table *ctl, int write,
> +			  void __user *buffer, size_t *lenp, loff_t *fpos);
> +static int rcvbuf_handler(struct ctl_table *ctl, int write,
> +			  void __user *buffer, size_t *lenp, loff_t *fpos);
> +static struct ctl_table rds_tcp_sysctl_table[] = {
> +	{
> +		.procname       = "rds_tcp_sndbuf",
> +		/* data is per-net pointer */
> +		.maxlen         = sizeof(int),
> +		.mode           = 0644,
> +		.proc_handler   = sndbuf_handler,
> +	},
> +	{
> +		.procname       = "rds_tcp_rcvbuf",
> +		/* data is per-net pointer */
> +		.maxlen         = sizeof(int),
> +		.mode           = 0644,
> +		.proc_handler   = rcvbuf_handler,
> +	},
> +	{ }
> +};

Normally we kmemdup a table per netns and update its data pointer, so we 
can reuse the proc_doint_minmax functions.

>   /* doing it this way avoids calling tcp_sk() */
>   void rds_tcp_nonagle(struct socket *sock)
>   {
> @@ -66,15 +88,6 @@ void rds_tcp_nonagle(struct socket *sock)
>   	set_fs(oldfs);
>   }
>
> -/* All module specific customizations to the RDS-TCP socket should be done in
> - * rds_tcp_tune() and applied after socket creation. In general these
> - * customizations should be tunable via module_param()
> - */
> -void rds_tcp_tune(struct socket *sock)
> -{
> -	rds_tcp_nonagle(sock);
> -}
> -
>   u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
>   {
>   	return tcp_sk(tc->t_sock->sk)->snd_nxt;
> @@ -272,8 +285,33 @@ static int rds_tcp_netid;
>   struct rds_tcp_net {
>   	struct socket *rds_tcp_listen_sock;
>   	struct work_struct rds_tcp_accept_w;
> +	struct ctl_table_header *rds_tcp_sysctl;
> +	int sndbuf_size;
> +	int rcvbuf_size;
>   };
>
> +/* All module specific customizations to the RDS-TCP socket should be done in
> + * rds_tcp_tune() and applied after socket creation.
> + */
> +void rds_tcp_tune(struct socket *sock)
> +{
> +	struct sock *sk = sock->sk;
> +	struct net *net = sock_net(sk);
> +	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +
> +	rds_tcp_nonagle(sock);
> +	lock_sock(sk);
> +	if (rtn->sndbuf_size > 0) {
> +		sk->sk_sndbuf = rtn->sndbuf_size;
> +		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
> +	}
> +	if (rtn->rcvbuf_size > 0) {
> +		sk->sk_sndbuf = rtn->rcvbuf_size;
> +		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> +	}
> +	release_sock(sk);
> +}
> +
>   static void rds_tcp_accept_worker(struct work_struct *work)
>   {
>   	struct rds_tcp_net *rtn = container_of(work,
> @@ -296,9 +334,17 @@ static __net_init int rds_tcp_init_net(struct net *net)
>   {
>   	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
>
> +	/* 0 value for {snd, rcv}buf_size implies we let the stack
> +	 * pick the default, and permit auto-tuning of buffer size.
> +	 */
> +	rtn->sndbuf_size = 0;
> +	rtn->rcvbuf_size = 0;
> +	rtn->rds_tcp_sysctl = register_net_sysctl(net, "net/rds/tcp",
> +						  rds_tcp_sysctl_table);

You should add proper error handling here?

>   	rtn->rds_tcp_listen_sock = rds_tcp_listen_init(net);
>   	if (!rtn->rds_tcp_listen_sock) {
>   		pr_warn("could not set up listen sock\n");
> +		unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
>   		return -EAFNOSUPPORT;
>   	}
>   	INIT_WORK(&rtn->rds_tcp_accept_w, rds_tcp_accept_worker);
> @@ -309,6 +355,7 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
>   {
>   	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
>
> +	unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
>   	/* If rds_tcp_exit_net() is called as a result of netns deletion,
>   	 * the rds_tcp_kill_sock() device notifier would already have cleaned
>   	 * up the listen socket, thus there is no work to do in this function.
> @@ -383,6 +430,84 @@ static struct notifier_block rds_tcp_dev_notifier = {
>   	.priority = -10, /* must be called after other network notifiers */
>   };
>
> +static int user_atoi(char __user *ubuf, size_t len)
> +{
> +	char buf[16];
> +	unsigned long ret;
> +	int err;
> +
> +	if (len > 15)
> +		return -EINVAL;
> +
> +	if (copy_from_user(buf, ubuf, len))
> +		return -EFAULT;
> +
> +	buf[len] = 0;
> +	err =  kstrtoul(buf, 0, &ret);
> +	if (err != 0)
> +		return -ERANGE;
> +	return  ret;
> +}
> +
> +/* when sysctl is used to modify some kernel socket parameters,this
> + * function  resets the RDS connections in that netns  so that we can
> + * restart with new parameters.  The assumption is that such reset
> + * events are few and far-between.
> + */
> +static void rds_tcp_sysctl_reset(struct net *net)
> +{
> +	struct rds_tcp_connection *tc, *_tc;
> +
> +	spin_lock_irq(&rds_tcp_conn_lock);
> +	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
> +		struct net *c_net = read_pnet(&tc->conn->c_net);
> +
> +		if (net != c_net || !tc->t_sock)
> +			continue;
> +
> +		rds_conn_drop(tc->conn); /* reconnect with new parameters */
> +	}
> +	spin_unlock_irq(&rds_tcp_conn_lock);
> +}
> +
> +static int sndbuf_handler(struct ctl_table *ctl, int write,
> +			  void __user *buffer, size_t *lenp, loff_t *fpos)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +	struct ctl_table tmp;
> +
> +	tmp = *ctl;
> +	tmp.data = &rtn->sndbuf_size;
> +	if (!write)
> +		return proc_dointvec(&tmp, write, buffer, lenp, fpos);
> +
> +	rtn->sndbuf_size = max_t(u32, user_atoi(buffer, *lenp) * 2,
> +				 SOCK_MIN_SNDBUF);

user_atoi does return negative error values (as you implemented it), I 
think you should check before, otherwise the signed to unsigned 
conversion can cause huge memory allocations.

Why actually implement user_atoi?

> +	rds_tcp_sysctl_reset(net);
> +
> +	return 0;
> +}
> +
> +static int rcvbuf_handler(struct ctl_table *ctl, int write,
> +			  void __user *buffer, size_t *lenp, loff_t *fpos)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +	struct ctl_table tmp;
> +
> +	tmp = *ctl;
> +	tmp.data = &rtn->rcvbuf_size;
> +	if (!write)
> +		return proc_dointvec(&tmp, write, buffer, lenp, fpos);
> +
> +	rtn->rcvbuf_size = max_t(u32, user_atoi(buffer, *lenp) * 2,
> +				 SOCK_MIN_RCVBUF);
> +	rds_tcp_sysctl_reset(net);
> +
> +	return 0;
> +}
> +
>   static void rds_tcp_exit(void)
>   {
>   	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
>

From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 09:38:05 -0700
Message-ID: <56E83A6D.6060904@oracle.com>
References: <20160315151248.GJ11063@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51335 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbcCOQiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 12:38:24 -0400
In-Reply-To: <20160315151248.GJ11063@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sowmini,

$subject
s/rds-tcp: /RDS: TCP:

On 3/15/2016 8:12 AM, Sowmini Varadhan wrote:
>
> Add per-net sysctl tunables to set the size of sndbuf and
> rcvbuf on the kernel tcp socket.
>
> The tunables are added at /proc/sys/net/rds/tcp/rds_tcp_sndbuf
> and /proc/sys/net/rds/tcp/rds_tcp_rcvbuf.
>
> These values must be set before accept() or connect(),
This will be hard to achieve with RDS being reconnect protocol
but since you have added a reset, the above no longer a
problem.

> and there may be an arbitrary number of existing rds-tcp
> sockets when the tunable is modified. To make sure that all
> connections in the netns pick up the same value for the tunable,
> we reset existing rds-tcp connections in the netns, so that
> they can reconnect with the new parameters.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: use sysctl instead of module param. Tunabes are now per netns,
>      and can be dynamically modified without restarting all namespaces.
>
>   net/rds/tcp.c |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
>   1 files changed, 129 insertions(+), 10 deletions(-)
>
> diff --git a/net/rds/tcp.c b/net/rds/tcp.c
> index ad60299..5d62fd2 100644
> --- a/net/rds/tcp.c
> +++ b/net/rds/tcp.c
> @@ -52,7 +52,27 @@ static LIST_HEAD(rds_tcp_conn_list);
>
>   static struct kmem_cache *rds_tcp_conn_slab;
>
> -#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
This seems to be unrelated change and left over from the
previous clean-up. Please do that in separate patch.

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
>
>   /* doing it this way avoids calling tcp_sk() */
>   void rds_tcp_nonagle(struct socket *sock)
> @@ -66,15 +86,6 @@ void rds_tcp_nonagle(struct socket *sock)
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
> @@ -272,8 +283,33 @@ static int rds_tcp_netid;
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
So value of 1 is allowed as well. There should be some
minimum default or multiple of it. Of course above check
can remain as is as long as you validate the user input
in handlers.

> @@ -296,6 +332,13 @@ static __net_init int rds_tcp_init_net(struct net *net)
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
>   	rtn->rds_tcp_listen_sock = rds_tcp_listen_init(net);
>   	if (!rtn->rds_tcp_listen_sock) {
>   		pr_warn("could not set up listen sock\n");
> @@ -309,6 +352,7 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
>   {
>   	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
>
> +	unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
>   	/* If rds_tcp_exit_net() is called as a result of netns deletion,
>   	 * the rds_tcp_kill_sock() device notifier would already have cleaned
>   	 * up the listen socket, thus there is no work to do in this function.
You need to unregister it on rds_tcp_listen_init() failure.

[...]

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
a next line will be good here.

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
> +	rtn->sndbuf_size = user_atoi(buffer, *lenp);
As mentioned above, you should make sure the buffer lengths are
legitimate.

Regards,
Santosh

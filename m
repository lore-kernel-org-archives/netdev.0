From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 10:30:37 -0700
Message-ID: <CALx6S35FKYvnQ4O2N+3sJonj-gKODEMTwW6yeNcj1mWG9EOeow@mail.gmail.com>
References: <20160315151248.GJ11063@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	santosh.shilimkar@oracle.com,
	"David S. Miller" <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34779 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbcCORaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 13:30:39 -0400
Received: by mail-io0-f175.google.com with SMTP id m184so32785350iof.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 10:30:38 -0700 (PDT)
In-Reply-To: <20160315151248.GJ11063@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2016 at 8:12 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> Add per-net sysctl tunables to set the size of sndbuf and
> rcvbuf on the kernel tcp socket.
>
> The tunables are added at /proc/sys/net/rds/tcp/rds_tcp_sndbuf
> and /proc/sys/net/rds/tcp/rds_tcp_rcvbuf.
>
> These values must be set before accept() or connect(),
> and there may be an arbitrary number of existing rds-tcp
> sockets when the tunable is modified. To make sure that all
> connections in the netns pick up the same value for the tunable,
> we reset existing rds-tcp connections in the netns, so that
> they can reconnect with the new parameters.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: use sysctl instead of module param. Tunabes are now per netns,
>     and can be dynamically modified without restarting all namespaces.
>
I still don't understand why you won't consider using netlink. sndbuf
and rcvbuf seem like just two of many arbitrary parameters that a user
might want to configure. I would think that being able to configure
the listener port (currently a fixed value), an address to bind to
(instead of always inaddr-any), or not automatically creating an RDS
listener in every namespace are at least as important configuration
parameters as these two.

Tom

>  net/rds/tcp.c |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 129 insertions(+), 10 deletions(-)
>
> diff --git a/net/rds/tcp.c b/net/rds/tcp.c
> index ad60299..5d62fd2 100644
> --- a/net/rds/tcp.c
> +++ b/net/rds/tcp.c
> @@ -52,7 +52,27 @@ static LIST_HEAD(rds_tcp_conn_list);
>
>  static struct kmem_cache *rds_tcp_conn_slab;
>
> -#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
> +static int sndbuf_handler(struct ctl_table *ctl, int write,
> +                         void __user *buffer, size_t *lenp, loff_t *fpos);
> +static int rcvbuf_handler(struct ctl_table *ctl, int write,
> +                         void __user *buffer, size_t *lenp, loff_t *fpos);
> +static struct ctl_table rds_tcp_sysctl_table[] = {
> +       {
> +               .procname       = "rds_tcp_sndbuf",
> +               /* data is per-net pointer */
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = sndbuf_handler,
> +       },
> +       {
> +               .procname       = "rds_tcp_rcvbuf",
> +               /* data is per-net pointer */
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = rcvbuf_handler,
> +       },
> +       { }
> +};
>
>  /* doing it this way avoids calling tcp_sk() */
>  void rds_tcp_nonagle(struct socket *sock)
> @@ -66,15 +86,6 @@ void rds_tcp_nonagle(struct socket *sock)
>         set_fs(oldfs);
>  }
>
> -/* All module specific customizations to the RDS-TCP socket should be done in
> - * rds_tcp_tune() and applied after socket creation. In general these
> - * customizations should be tunable via module_param()
> - */
> -void rds_tcp_tune(struct socket *sock)
> -{
> -       rds_tcp_nonagle(sock);
> -}
> -
>  u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
>  {
>         return tcp_sk(tc->t_sock->sk)->snd_nxt;
> @@ -272,8 +283,33 @@ static int rds_tcp_netid;
>  struct rds_tcp_net {
>         struct socket *rds_tcp_listen_sock;
>         struct work_struct rds_tcp_accept_w;
> +       struct ctl_table_header *rds_tcp_sysctl;
> +       int sndbuf_size;
> +       int rcvbuf_size;
>  };
>
> +/* All module specific customizations to the RDS-TCP socket should be done in
> + * rds_tcp_tune() and applied after socket creation.
> + */
> +void rds_tcp_tune(struct socket *sock)
> +{
> +       struct sock *sk = sock->sk;
> +       struct net *net = sock_net(sk);
> +       struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +
> +       rds_tcp_nonagle(sock);
> +       lock_sock(sk);
> +       if (rtn->sndbuf_size > 0) {
> +               sk->sk_sndbuf = rtn->sndbuf_size;
> +               sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
> +       }
> +       if (rtn->rcvbuf_size > 0) {
> +               sk->sk_rcvbuf = rtn->rcvbuf_size;
> +               sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> +       }
> +       release_sock(sk);
> +}
> +
>  static void rds_tcp_accept_worker(struct work_struct *work)
>  {
>         struct rds_tcp_net *rtn = container_of(work,
> @@ -296,6 +332,13 @@ static __net_init int rds_tcp_init_net(struct net *net)
>  {
>         struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
>
> +       /* 0 value for {snd, rcv}buf_size implies we let the stack
> +        * pick the default, and permit auto-tuning of buffer size.
> +        */
> +       rtn->sndbuf_size = 0;
> +       rtn->rcvbuf_size = 0;
> +       rtn->rds_tcp_sysctl = register_net_sysctl(net, "net/rds/tcp",
> +                                                 rds_tcp_sysctl_table);
>         rtn->rds_tcp_listen_sock = rds_tcp_listen_init(net);
>         if (!rtn->rds_tcp_listen_sock) {
>                 pr_warn("could not set up listen sock\n");
> @@ -309,6 +352,7 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
>  {
>         struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
>
> +       unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
>         /* If rds_tcp_exit_net() is called as a result of netns deletion,
>          * the rds_tcp_kill_sock() device notifier would already have cleaned
>          * up the listen socket, thus there is no work to do in this function.
> @@ -383,6 +427,81 @@ static struct notifier_block rds_tcp_dev_notifier = {
>         .priority = -10, /* must be called after other network notifiers */
>  };
>
> +static int user_atoi(char __user *ubuf, size_t len)
> +{
> +       char buf[16];
> +       unsigned long ret;
> +       int err;
> +
> +       if (len > 15)
> +               return -EINVAL;
> +
> +       if (copy_from_user(buf, ubuf, len))
> +               return -EFAULT;
> +
> +       buf[len] = 0;
> +       err =  kstrtoul(buf, 0, &ret);
> +       if (err != 0)
> +               return -ERANGE;
> +       return  ret;
> +}
> +
> +/* when sysctl is used to modify some kernel socket parameters,this
> + * function  resets the RDS connections in that netns  so that we can
> + * restart with new parameters.  The assumption is that such reset
> + * events are few and far-between.
> + */
> +static void rds_tcp_sysctl_reset(struct net *net)
> +{
> +       struct rds_tcp_connection *tc, *_tc;
> +
> +       spin_lock_irq(&rds_tcp_conn_lock);
> +       list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
> +               struct net *c_net = read_pnet(&tc->conn->c_net);
> +
> +               if (net != c_net || !tc->t_sock)
> +                       continue;
> +               rds_conn_drop(tc->conn); /* reconnect with new parameters */
> +       }
> +       spin_unlock_irq(&rds_tcp_conn_lock);
> +}
> +
> +static int sndbuf_handler(struct ctl_table *ctl, int write,
> +                         void __user *buffer, size_t *lenp, loff_t *fpos)
> +{
> +       struct net *net = current->nsproxy->net_ns;
> +       struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +       struct ctl_table tmp;
> +
> +       tmp = *ctl;
> +       tmp.data = &rtn->sndbuf_size;
> +       if (!write)
> +               return proc_dointvec(&tmp, write, buffer, lenp, fpos);
> +
> +       rtn->sndbuf_size = user_atoi(buffer, *lenp);
> +       rds_tcp_sysctl_reset(net);
> +
> +       return 0;
> +}
> +
> +static int rcvbuf_handler(struct ctl_table *ctl, int write,
> +                         void __user *buffer, size_t *lenp, loff_t *fpos)
> +{
> +       struct net *net = current->nsproxy->net_ns;
> +       struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +       struct ctl_table tmp;
> +
> +       tmp = *ctl;
> +       tmp.data = &rtn->rcvbuf_size;
> +       if (!write)
> +               return proc_dointvec(&tmp, write, buffer, lenp, fpos);
> +
> +       rtn->rcvbuf_size = user_atoi(buffer, *lenp);
> +       rds_tcp_sysctl_reset(net);
> +
> +       return 0;
> +}
> +
>  static void rds_tcp_exit(void)
>  {
>         rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
> --
> 1.7.1
>

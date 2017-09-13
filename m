From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Namespaceify tcp_fastopen knob
Date: Wed, 13 Sep 2017 05:44:34 -0700
Message-ID: <1505306674.15310.155.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505301598-12681-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Luca BRUNO <lucab@debian.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505301598-12681-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-13 at 19:19 +0800, Haishuang Yan wrote:
> Different namespace application might require enable TCP Fast Open
> feature independently of the host.
> 

Poor changelog, no actual description / list of sysctls that are moved
to per netns.

And looking at the patch, it seems your conversion is not complete.

So I will ask you to provide more evidence that you tested your patch
next time you submit it.

> Reported-by: Luca BRUNO <lucab@debian.org>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> ---
> Change since v2:
>   * Remove unrelated change by mistake
> ---
>  include/net/netns/ipv4.h   |  2 ++
>  include/net/tcp.h          |  1 -
>  net/ipv4/af_inet.c         |  7 ++++---
>  net/ipv4/sysctl_net_ipv4.c | 42 +++++++++++++++++++++---------------------
>  net/ipv4/tcp.c             |  4 ++--
>  net/ipv4/tcp_fastopen.c    | 13 ++++++-------
>  net/ipv4/tcp_ipv4.c        |  2 ++
>  7 files changed, 37 insertions(+), 34 deletions(-)
> 
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index 305e031..ea0953b 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -128,6 +128,8 @@ struct netns_ipv4 {
>  	struct inet_timewait_death_row tcp_death_row;
>  	int sysctl_max_syn_backlog;
>  	int sysctl_tcp_max_orphans;
> +	int sysctl_tcp_fastopen;
> +	unsigned int sysctl_tcp_fastopen_blackhole_timeout;
>  
>  #ifdef CONFIG_NET_L3_MASTER_DEV
>  	int sysctl_udp_l3mdev_accept;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index ac2d998..e4cc0dd 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -240,7 +240,6 @@
>  
> 
>  /* sysctl variables for tcp */
> -extern int sysctl_tcp_fastopen;
>  extern int sysctl_tcp_retrans_collapse;
>  extern int sysctl_tcp_stdurg;
>  extern int sysctl_tcp_rfc1337;
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index e31108e..309b849 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -195,7 +195,7 @@ int inet_listen(struct socket *sock, int backlog)
>  {
>  	struct sock *sk = sock->sk;
>  	unsigned char old_state;
> -	int err;
> +	int err, tcp_fastopen;
>  
>  	lock_sock(sk);
>  
> @@ -217,8 +217,9 @@ int inet_listen(struct socket *sock, int backlog)
>  		 * because the socket was in TCP_LISTEN state previously but
>  		 * was shutdown() rather than close().
>  		 */
> -		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
> -		    (sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
> +		tcp_fastopen =  sock_net(sk)->ipv4.sysctl_tcp_fastopen;
> +		if ((tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
> +		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
>  		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
>  			fastopen_queue_tune(sk, backlog);
>  			tcp_fastopen_init_key_once(true);
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 4f26c8d3..30ebeb9 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -394,27 +394,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
>  		.proc_handler	= proc_dointvec
>  	},
>  	{
> -		.procname	= "tcp_fastopen",
> -		.data		= &sysctl_tcp_fastopen,
> -		.maxlen		= sizeof(int),
> -		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> -	},
> -	{
> -		.procname	= "tcp_fastopen_key",
> -		.mode		= 0600,
> -		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
> -		.proc_handler	= proc_tcp_fastopen_key,
> -	},
> -	{
> -		.procname	= "tcp_fastopen_blackhole_timeout_sec",
> -		.data		= &sysctl_tcp_fastopen_blackhole_timeout,
> -		.maxlen		= sizeof(int),
> -		.mode		= 0644,
> -		.proc_handler	= proc_tfo_blackhole_detect_timeout,
> -		.extra1		= &zero,
> -	},
> -	{
>  		.procname	= "tcp_abort_on_overflow",
>  		.data		= &sysctl_tcp_abort_on_overflow,
>  		.maxlen		= sizeof(int),
> @@ -1085,6 +1064,27 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec
>  	},
> +	{
> +		.procname	= "tcp_fastopen",
> +		.data		= &init_net.ipv4.sysctl_tcp_fastopen,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "tcp_fastopen_key",

But proc_tcp_fastopen_key() is not per netns yet.



> +		.mode		= 0600,
> +		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
> +		.proc_handler	= proc_tcp_fastopen_key,
> +	},


As a reminder, net-next is closed.

Thanks.

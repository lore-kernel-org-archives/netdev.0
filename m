From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next ] tcp: add new parameter tcp_inherit_buffsize
 to control the initial buffer size for new passive connetion
Date: Tue, 02 May 2017 08:05:15 -0700
Message-ID: <1493737515.31837.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAPYxyxJYXA_maME_qnshnFdzwDUkU1PvgDBQMfH32EerfQJZxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?=E5=8D=95=E5=8D=AB?= <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33744 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750740AbdEBPFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:05:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id b23so17775309pfc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:05:18 -0700 (PDT)
In-Reply-To: <CAPYxyxJYXA_maME_qnshnFdzwDUkU1PvgDBQMfH32EerfQJZxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-02 at 12:57 +0800, 单卫 wrote:
> Current sndbuff/rcvbuff value of new passive connetion inherit from
> listen socket.
> After then, tcp_init_buffer_space() initial them with init_cwnd and 
> tcp_should_expand_sndbuf() adjust them according the new cwnd.
> 
> 
> But, For Operation & Maintenance engineer, can't control
> sndbuff/rcvbuff with 
> tcp_wmem/tcp_rmem sysctl parameter online. They need to migrate flows
> out 
> and migrate them in after restart services and turn sndbuff/rcvfuff
> up.
> 
> 
> This patch is useful for online servcie setting tcp_inherit_buffsize
> with 0.
> By default, keep be consistent whth before.
> 
> 
> Signed-off-by: Shan Wei <shanwei88@gmail.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    8 ++++++++
>  include/net/netns/ipv4.h               |    1 +
>  net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
>  net/ipv4/tcp_ipv4.c                    |    1 +
>  net/ipv4/tcp_minisocks.c               |    6 ++++++
>  5 files changed, 23 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/Documentation/networking/ip-sysctl.txt
> b/Documentation/networking/ip-sysctl.txt
> index 974ab47..3292bbf 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -308,6 +308,14 @@ tcp_frto - INTEGER
>  
>   By default it's enabled with a non-zero value. 0 disables F-RTO.
>  
> +tcp_inherit_buffsize - BOOLEAN
> + For a new passive TCP connection, can use current tcp_wmem/tcp_rmem
> + parameter to set initial snd/rcv buffer size. This is useful for
> online
> + services which no need to be restarted just set it with 0. By
> default,
> + new passive connection inherits snd/rcv buffer size from lister
> socket.
> +
> + Default: 1
> +
>  tcp_invalid_ratelimit - INTEGER
>   Limit the maximal rate for sending duplicate acknowledgments
>   in response to incoming TCP packets that are for an existing
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index cd686c4..1fc85bd 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -124,6 +124,7 @@ struct netns_ipv4 {
>   int sysctl_tcp_tw_reuse;
>   struct inet_timewait_death_row tcp_death_row;
>   int sysctl_max_syn_backlog;
> + int sysctl_tcp_inherit_buffsize;
>  
>  #ifdef CONFIG_NET_L3_MASTER_DEV
>   int sysctl_udp_l3mdev_accept;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 86957e9..58a8bec 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -1078,6 +1078,13 @@ static int
> proc_tfo_blackhole_detect_timeout(struct ctl_table *table,
>   .mode = 0644,
>   .proc_handler = proc_dointvec
>   },
> + {
> + .procname = "tcp_inherit_buffsize",
> + .data = &init_net.ipv4.sysctl_tcp_inherit_buffsize,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec
> + },
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   {
>   .procname = "fib_multipath_use_neigh",
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index cbbafe5..7a8a2bb 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2457,6 +2457,7 @@ static int __net_init tcp_sk_init(struct net
> *net)
>   net->ipv4.tcp_death_row.hashinfo = &tcp_hashinfo;
>  
>   net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
> + net->ipv4.sysctl_tcp_inherit_buffsize = 1;
>  
>   return 0;
>  fail:
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 8f6373b..6090d7e 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -474,6 +474,12 @@ struct sock *tcp_create_openreq_child(const
> struct sock *sk,
>   tcp_init_xmit_timers(newsk);
>   newtp->write_seq = newtp->pushed_seq = treq->snt_isn + 1;
>  
> + if (!(sock_net(newsk)->ipv4.sysctl_tcp_inherit_buffsize) &&
> + !(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
> + newsk->sk_sndbuf = sock_net(sk)->ipv4.sysctl_tcp_wmem[1];
> + newsk->sk_rcvbuf = sock_net(sk)->ipv4.sysctl_tcp_rmem[1];
> + }
> +

Hi Shan

1) Your patch never reached netdev, because it was sent in HTML format.

2) During Linus merge window, net-next is closed

I am not really convinced that we need this with TCP autotuning anyway.
Initial value of sk_sndbuf and sk_rcvbuf is really a hint.

How often do you really tweak /proc/sys/net/ipv4 files in production.

Please provide more information, like what actual values you change back
and forth.

Thanks.

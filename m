From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Date: Tue, 21 Feb 2017 10:43:32 -0300
Message-ID: <20170221134332.GA5052@kernel.org>
References: <CACT4Y+aZrpZ3JevLrg5i=nTzBAcVhKX9qmajyW5b-+xExwrCHg@mail.gmail.com>
 <20170221112740.661-1-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, syzkaller@googlegroups.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46056 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752574AbdBUNnj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 08:43:39 -0500
Content-Disposition: inline
In-Reply-To: <20170221112740.661-1-aryabinin@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Feb 21, 2017 at 02:27:40PM +0300, Andrey Ryabinin escreveu:
> DCCP doesn't purge timewait sockets on network namespace shutdown.
> So, after net namespace destroyed we could still have an active timer
> which will trigger use after free in tw_timer_handler():
> 
> 
> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
> timewait sockets on net namespace destruction and prevent above issue.

Please add this, to help stable kernels to pick this up

Fixes: b099ce2602d8 ("net: Batch inet_twsk_purge")
Cc: Eric W. Biederman <ebiederm@xmission.com> 

[acme@jouet linux]$ git describe b099ce2602d8
v2.6.32-rc8-1977-gb099ce2602d8

This one added the pernet operations related to network namespaces, but
then the one above got missed.

commit 72a2d6138224298a576bcdc33d7d0004de604856
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Sun Apr 13 22:29:13 2008 -0700

    [NETNS][DCCPV4]: Add dummy per-net operations.

----------------------------------

It looks ok, so please consider adding my:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo

> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  net/dccp/ipv4.c | 6 ++++++
>  net/dccp/ipv6.c | 6 ++++++
>  2 files changed, 12 insertions(+)
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index d859a5c..da7cb16 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -1018,9 +1018,15 @@ static void __net_exit dccp_v4_exit_net(struct net *net)
>  	inet_ctl_sock_destroy(net->dccp.v4_ctl_sk);
>  }
>  
> +static void __net_exit dccp_v4_exit_batch(struct list_head *net_exit_list)
> +{
> +	inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET);
> +}
> +
>  static struct pernet_operations dccp_v4_ops = {
>  	.init	= dccp_v4_init_net,
>  	.exit	= dccp_v4_exit_net,
> +	.exit_batch = dccp_v4_exit_batch,
>  };
>  
>  static int __init dccp_v4_init(void)
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index c4e879c..f3d8f92 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -1077,9 +1077,15 @@ static void __net_exit dccp_v6_exit_net(struct net *net)
>  	inet_ctl_sock_destroy(net->dccp.v6_ctl_sk);
>  }
>  
> +static void __net_exit dccp_v6_exit_batch(struct list_head *net_exit_list)
> +{
> +	inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET6);
> +}
> +
>  static struct pernet_operations dccp_v6_ops = {
>  	.init   = dccp_v6_init_net,
>  	.exit   = dccp_v6_exit_net,
> +	.exit_batch = dccp_v6_exit_batch,
>  };
>  
>  static int __init dccp_v6_init(void)
> -- 
> 2.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

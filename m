From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Fix inet6_init() cleanup order
Date: Sat, 16 Nov 2013 20:30:07 +0100
Message-ID: <20131116193007.GD16541@order.stressinduktion.org>
References: <5287C114.3040306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lorenzo@google.com, Fabio Estevam <fabio.estevam@freescale.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47329 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab3KPTaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 14:30:09 -0500
Content-Disposition: inline
In-Reply-To: <5287C114.3040306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sat, Nov 16, 2013 at 02:01:40PM -0500, Vlad Yasevich wrote:
> Commit 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
> 	net: ipv6: Add IPv6 support to the ping socket
> 
> introduced a change in the cleanup logic of inet6_init and
> has a bug in that ipv6_packet_cleanup() may not be called.
> Fix the cleanup ordering and add __maybe_unused to pingv6_exit
> since it may not be called if CONFIG_SYSCTL is turned off.
> 
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
> CC: Lorenzo Colitti <lorenzo@google.com>
> CC: Fabio Estevam <fabio.estevam@freescale.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  net/ipv6/af_inet6.c | 4 ++--
>  net/ipv6/ping.c     | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 6468bda..56ca35b 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -958,10 +958,10 @@ out:
>   #ifdef CONFIG_SYSCTL
>  sysctl_fail:
> -	ipv6_packet_cleanup();
> +	pingv6_exit();
>  #endif
>  pingv6_fail:
> -	pingv6_exit();
> +	ipv6_packet_cleanup();
>  ipv6_packet_fail:
>  	tcpv6_exit();
>  tcpv6_fail:

Your patch seems corrupt here:

$ patch -p1 < .git/rebase-apply/patch
patching file net/ipv6/af_inet6.c
patch: **** malformed patch at line 22: diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c

The logic here looks fine though.

> diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> index 8815e31..5da68ae 100644
> --- a/net/ipv6/ping.c
> +++ b/net/ipv6/ping.c
> @@ -263,7 +263,7 @@ int __init pingv6_init(void)
>  /* This never gets called because it's not possible to unload the ipv6
> module,
>   * but just in case.
>   */
> -void pingv6_exit(void)
> +void __maybe_unused pingv6_exit(void)
>  {
>  	pingv6_ops.ipv6_recv_error = dummy_ipv6_recv_error;
>  	pingv6_ops.ip6_datagram_recv_ctl = dummy_ip6_datagram_recv_ctl;

We only would need __maybe_unused if the function which generates
the warning is static in the same compilation unit. So this seems
unneccessary.

Thanks,

  Hannes

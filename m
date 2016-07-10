From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] tunnels: correct conditional build of MPLS
Date: Sun, 10 Jul 2016 10:12:24 +0900
Message-ID: <20160710011222.GA8268@penelope.isobedori.kobe.vergenet.net>
References: <1468110054-28646-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32886 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765AbcGJBM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 21:12:29 -0400
Received: by mail-pf0-f175.google.com with SMTP id i123so24146247pfg.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 18:12:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468110054-28646-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 09:20:54AM +0900, Simon Horman wrote:
> * If MPLS is not enabled then err_mpls is not needed
> * If IPV6 is not enabled then unregistering IPPROTO_IPV6 is not
>   needed in the error path and err_ipv6 is not needed
> * When unregistering IPPROTO_IPV6 the tunnel64_protocol structure
>   rather than the tunnel4_protocol structure should be used.
> * If neither MPLS nor IPV6 are enabled then unregistering IPPROTO_IPIP
>   is not needed in the error path
> 
> Fixes: 8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

I realised this still has some problems. I will send v2.

> ---
>  net/ipv4/tunnel4.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
> index 45cd4253583a..1dd098b890a7 100644
> --- a/net/ipv4/tunnel4.c
> +++ b/net/ipv4/tunnel4.c
> @@ -219,12 +219,16 @@ static int __init tunnel4_init(void)
>  #endif
>  	return 0;
>  
> -#if IS_ENABLED(CONFIG_IPV6)
> +#if IS_ENABLED(CONFIG_MPLS)
>  err_mpls:
> -	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPV6);
>  #endif
> +#if IS_ENABLED(CONFIG_IPV6)
> +	inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6);
>  err_ipv6:
> +#endif
> +#if IS_ENABLED(CONFIG_MPLS) || IS_ENABLED(CONFIG_IPV6)
>  	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
> +#endif
>  err_ipip:
>  	pr_err("%s: can't add protocol\n", __func__);
>  	return -EAGAIN;
> -- 
> 2.7.0.rc3.207.g0ac5344
> 

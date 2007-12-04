From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH][IPVS] Don't leak sysctl tables if the scheduler registration fails
Date: Tue, 4 Dec 2007 10:36:48 +0900
Message-ID: <20071204013647.GB28582@verge.net.au>
References: <4753D4C5.4040301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41687 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXLDBgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 20:36:51 -0500
Content-Disposition: inline
In-Reply-To: <4753D4C5.4040301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 01:04:53PM +0300, Pavel Emelyanov wrote:
> In case we load lblc or lblcr module we can leak some sysctl
> tables if the call to register_ip_vs_scheduler() fails.

This looks correct to me.

> I've looked at the register_ip_vs_scheduler() code and saw, that
> the only reason to fail is the name collision, so I think that
> with some 3rd party schedulers this becomes a relevant issue. No?

I guess so. Though presumably register_ip_vs_scheduler() could
have other modes of failure in the future.

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
> diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
> index b843a11..ad89644 100644
> --- a/net/ipv4/ipvs/ip_vs_lblc.c
> +++ b/net/ipv4/ipvs/ip_vs_lblc.c
> @@ -580,9 +580,14 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
>  
>  static int __init ip_vs_lblc_init(void)
>  {
> +	int ret;
> +
>  	INIT_LIST_HEAD(&ip_vs_lblc_scheduler.n_list);
>  	sysctl_header = register_sysctl_table(lblc_root_table);
> -	return register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
> +	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
> +	if (ret)
> +		unregister_sysctl_table(sysctl_header);
> +	return ret;
>  }
>  
>  
> diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
> index e5b323a..2a5ed85 100644
> --- a/net/ipv4/ipvs/ip_vs_lblcr.c
> +++ b/net/ipv4/ipvs/ip_vs_lblcr.c
> @@ -769,9 +769,14 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
>  
>  static int __init ip_vs_lblcr_init(void)
>  {
> +	int ret;
> +
>  	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
>  	sysctl_header = register_sysctl_table(lblcr_root_table);
> -	return register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
> +	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
> +	if (ret)
> +		unregister_sysctl_table(sysctl_header);
> +	return ret;
>  }
>  
>  

-- 
Horms


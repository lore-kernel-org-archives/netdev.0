From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] (6/6) ipvs -- get rid of skb_linearize
Date: Thu, 18 Sep 2003 00:53:46 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309180047490.15676-100000@penguin.linux-vs.org>
References: <20030916142350.1da23a4a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lvs-users@LinuxVirtualServer.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916142350.1da23a4a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hi,

On Tue, 16 Sep 2003, Stephen Hemminger wrote:

> Get rid of skb_linearize warnings, by using may_pull to get the
> header where needed.
> 

I am not sure if the calls of skb_share_check() are necessary, because
the ip_rcv has already done the skb share check for receiving packets. I 
don't know if other netfilter hooks can inject a shared skb.

Yes, we need to change IPVS to handle nonlinear skb as soon as possible, 
and remove these skb_linearize warnings.

Thanks,

Wensong

> diff -Nru a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
> --- a/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:11:17 2003
> +++ b/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:11:17 2003
> @@ -382,6 +382,10 @@
>  		return 0;
>  
>  	iph = skb->nh.iph;
> +	if (!pskb_may_pull(skb, (iph->ihl*4)+sizeof(*th)))
> +		return 0;
> +
> +	iph = skb->nh.iph;
>  	th = (struct tcphdr *)&(((char *)iph)[iph->ihl*4]);
>  
>  	/*
> @@ -436,6 +440,10 @@
>  	 *	this ip_vs_conn.
>  	 */
>  	if ((app = cp->app) == NULL)
> +		return 0;
> +
> +	iph = skb->nh.iph;
> +	if (!pskb_may_pull(skb, (iph->ihl*4)+sizeof(*th)))
>  		return 0;
>  
>  	iph = skb->nh.iph;
> diff -Nru a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> --- a/net/ipv4/ipvs/ip_vs_core.c	Tue Sep 16 14:11:17 2003
> +++ b/net/ipv4/ipvs/ip_vs_core.c	Tue Sep 16 14:11:17 2003
> @@ -526,11 +526,11 @@
>  		*skb_p = skb;
>  	}
>  
> -	if (skb_is_nonlinear(skb)) {
> -		if (skb_linearize(skb, GFP_ATOMIC) != 0)
> -			return NF_DROP;
> -		ip_send_check(skb->nh.iph);
> -	}
> +	if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
> +		return NF_STOLEN;
> +
> +	if (!pskb_may_pull(skb, sizeof(*iph) + sizeof(*icmph)))
> +		return NF_DROP;
>  
>  	iph = skb->nh.iph;
>  	ihl = iph->ihl << 2;
> @@ -726,11 +726,12 @@
>  	 * do final checksum checking.
>  	 */
>  
> -	if (unlikely(cp->app && !pp->slave && skb_is_nonlinear(skb))) {
> -		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
> +	if (unlikely(cp->app && !pp->slave)) {
> +		if (!(skb = skb_share_check(skb, GFP_ATOMIC))) {
>  			ip_vs_conn_put(cp);
> -			return NF_DROP;
> +			return NF_STOLEN;
>  		}
> +
>  		iph = skb->nh.iph;
>  		h.raw = (char*) iph + ihl;
>  	}
> @@ -816,12 +817,13 @@
>  	int	rc;
>  
>  	*related = 1;
> -	if (skb_is_nonlinear(skb)) {
> -		if (skb_linearize(skb, GFP_ATOMIC) != 0)
> -			return NF_DROP;
> -		ip_send_check(skb->nh.iph);
> -	}
> -
> +	if (!pskb_may_pull(skb, sizeof(*iph)))
> +		return NF_DROP;
> +	    
> +	iph = skb->nh.iph;
> +	if (!pskb_may_pull(skb, iph->ihl*4 + sizeof(*icmph)))
> +		return NF_DROP;
> +	    
>  	iph = skb->nh.iph;
>  	icmph = (struct icmphdr *)((char *)iph+(iph->ihl<<2));
>  	len = ntohs(iph->tot_len) - (iph->ihl<<2);
> diff -Nru a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
> --- a/net/ipv4/ipvs/ip_vs_xmit.c	Tue Sep 16 14:11:17 2003
> +++ b/net/ipv4/ipvs/ip_vs_xmit.c	Tue Sep 16 14:11:17 2003
> @@ -265,13 +265,20 @@
>  	 */
>  
>  	if (unlikely(cp->app && !pp->slave)) {
> -		if (skb_is_nonlinear(skb) &&
> -		    skb_linearize(skb, GFP_ATOMIC) != 0)
> -			return NF_DROP;
> +		if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
> +			return NF_STOLEN;
> +
>  	}
>  
> +	if (!pskb_may_pull(skb, sizeof(*iph)))
> +		goto tx_error;
> +
>  	iph = skb->nh.iph;
>  	ihl = iph->ihl << 2;
> +	if (!pskb_may_pull(skb, sizeof(*iph) + ihl))
> +		goto tx_error;
> +
> +	iph = skb->nh.iph;
>  	h.raw = (char*) iph + ihl;
>  	size = ntohs(iph->tot_len) - ihl;
>  
> 

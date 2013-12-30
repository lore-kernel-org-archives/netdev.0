From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Mon, 30 Dec 2013 03:17:54 +0100
Message-ID: <20131230021754.GA7718@order.stressinduktion.org>
References: <20131214091917.GB23563@order.stressinduktion.org> <1388303260-3668-1-git-send-email-yazzep@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: yazzep@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58134 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab3L3CR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 21:17:56 -0500
Content-Disposition: inline
In-Reply-To: <1388303260-3668-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 29, 2013 at 04:47:40PM +0900, yazzep@gmail.com wrote:

Subject: Re: [PATCH] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity

Please a space between addrconf: and fix.

> Fixed a problem with setting the lifetime of an IPv6
> address. When setting preferred_lft to a value not zero or
> infinity, while valid_lft is infinity(0xffffffff) preferred
> lifetime is set to forever and does not update. Therefore
> preferred lifetime never becomes deprecated. valid lifetime
> and preferred lifetime should be set independently, even if
> valid lifetime is infinity, preferred lifetime must expire
> correctly (meaning it must eventually become deprecated)
> 
> 
> Signed-off-by: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> ---
>  net/ipv6/addrconf.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index cd2d7d0..796d52a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3479,7 +3479,8 @@ restart:
>  					 &inet6_addr_lst[i], addr_lst) {
>  			unsigned long age;
>  
> -			if (ifp->flags & IFA_F_PERMANENT)
> +			if ((ifp->flags & IFA_F_PERMANENT) &&
> +			    (ifp->prefered_lft == INFINITY_LIFE_TIME))
>  				continue;

As in the first mail, a comment would be nice how permanent addresses where
prefered_lft != INFINITY_LIFE_TIME could come from.

Maybe we could also add this to the header file where IFA_F_PERMANENT is
declared. There was recently confusion about that with another patch.

>  			spin_lock(&ifp->lock);
> @@ -3504,8 +3505,12 @@ restart:
>  					ifp->flags |= IFA_F_DEPRECATED;
>  				}
>  
> -				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
> -					next = ifp->tstamp + ifp->valid_lft * HZ;
> +				if (ifp->valid_lft != INFINITY_LIFE_TIME) {
> +				    if (time_before(ifp->tstamp +
> +					    ifp->valid_lft * HZ, next))
> +						next = ifp->tstamp +
> +							 ifp->valid_lft * HZ;
> +				}

Please combine the two if-tests here (with &&).

>  
>  				spin_unlock(&ifp->lock);
>  
> @@ -3804,7 +3809,8 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
>  	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
>  		      ifa->idev->dev->ifindex);
>  
> -	if (!(ifa->flags&IFA_F_PERMANENT)) {
> +	if (!((ifa->flags&IFA_F_PERMANENT) &&
> +	      (ifa->prefered_lft == INFINITY_LIFE_TIME))) {
>  		preferred = ifa->prefered_lft;
>  		valid = ifa->valid_lft;
>  		if (preferred != INFINITY_LIFE_TIME) {

Otherwise the patch looks good and my testing showed no problems.

Thank you!

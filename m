From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Thu, 30 Sep 2010 13:49:37 +0200
Message-ID: <4CA47951.3050006@6wind.com>
References: <4CA208C9.1020800@6wind.com>	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>	 <1285749349.2615.27.camel@edumazet-laptop> <1285751929.2615.30.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54333 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab0I3Lto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 07:49:44 -0400
Received: by wyb28 with SMTP id 28so1751228wyb.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 04:49:43 -0700 (PDT)
In-Reply-To: <1285751929.2615.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch works well with my case.
In fact, it's more proper to returns an error to the daemon to let it 
knows that packet was not sent.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Regards,
Nicolas

Eric Dumazet wrote:
> I found following patch was enough to avoid route being created if
> device is down. This is still racy and needs more thinking.
> 
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ac6559c..1ee0b1a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2586,9 +2586,10 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
>  			goto out;
>  
>  		/* RACE: Check return value of inet_select_addr instead. */
> -		if (__in_dev_get_rtnl(dev_out) == NULL) {
> +		if (!(dev_out->flags & IFF_UP) || __in_dev_get_rtnl(dev_out) == NULL) {
>  			dev_put(dev_out);
> -			goto out;	/* Wrong error code */
> +			err = -ENETUNREACH;
> +			goto out;
>  		}
>  
>  		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
> 
> 


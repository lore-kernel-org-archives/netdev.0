From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: addrconf: Fix recursive spin lock call
Date: Mon, 01 Feb 2016 11:46:22 -0800
Message-ID: <1454355982.7627.185.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2cf017eba84341c95d22fda2952a3f6f.squirrel@www.codeaurora.org>
	 <1454355454.7627.183.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Kline <ek@google.com>, Netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34539 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbcBATqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 14:46:24 -0500
Received: by mail-pf0-f171.google.com with SMTP id o185so84099236pfb.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 11:46:23 -0800 (PST)
In-Reply-To: <1454355454.7627.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-02-01 at 11:37 -0800, Eric Dumazet wrote:

> I would rather try :
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 38eeddedfc21..d6b7ab07f914 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3538,6 +3538,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
>  {
>  	struct inet6_dev *idev = ifp->idev;
>  	struct net_device *dev = idev->dev;
> +	bool notify = false;
>  
>  	addrconf_join_solict(dev, &ifp->addr);
>  
> @@ -3583,7 +3584,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
>  			/* Because optimistic nodes can use this address,
>  			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
>  			 */
> -			ipv6_ifa_notify(RTM_NEWADDR, ifp);
> +			notify = true;
> +			in6_ifa_hold(ifp);

Actually the in6_ifa_hold() is not needed.

>  		}
>  	}
>  
> @@ -3591,6 +3593,10 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
>  out:
>  	spin_unlock(&ifp->lock);
>  	read_unlock_bh(&idev->lock);
> +	if (notify) {
> +		ipv6_ifa_notify(RTM_NEWADDR, ifp);
> +		in6_ifa_put(ifp);

And in6_ifa_put() not needed once in6_ifa_hold() is removed.

> +	}
>  }
>  
>  static void addrconf_dad_start(struct inet6_ifaddr *ifp)
> 
> 
> 

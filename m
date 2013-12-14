From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sat, 14 Dec 2013 10:19:17 +0100
Message-ID: <20131214091917.GB23563@order.stressinduktion.org>
References: <1386843347-2725-1-git-send-email-yazzep@gmail.com> <1386956028-3463-1-git-send-email-yazzep@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: yazzep@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54954 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab3LNJTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 04:19:19 -0500
Content-Disposition: inline
In-Reply-To: <1386956028-3463-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 14, 2013 at 02:33:48AM +0900, yazzep@gmail.com wrote:
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3c3425e..00c135b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -948,18 +948,21 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
>  					if (!onlink)
>  						onlink = -1;
>  
> -					spin_lock(&ifa->lock);
> -
> -					lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
> -					/*
> -					 * Note: Because this address is
> -					 * not permanent, lifetime <
> -					 * LONG_MAX / HZ here.
> -					 */
> -					if (time_before(expires,
> -							ifa->tstamp + lifetime * HZ))
> -						expires = ifa->tstamp + lifetime * HZ;
> -					spin_unlock(&ifa->lock);
> +					if (ifp->valid_lft !=
> +					    INFINITY_LIFE_TIME) {
> +						spin_lock(&ifa->lock);
> +
> +						lifetime = addrconf_timeout_fixup(
> +								ifa->valid_lft,	HZ);
> +						/* Note: because this address is
> +						 * not permanent, lifetime <
> +						 * LONG_MAX / HZ here.
> +						 */
> +						if (time_before(expires,
> +								ifa->tstamp + lifetime * HZ))
> +							expires = ifa->tstamp +	lifetime * HZ;
> +						spin_unlock(&ifa->lock);
> +					}

Sorry, this does not make sense to me. Below you remove the IFA_F_PERMANENT
expression and here you change code depending only on that flag. Is this meant
as a shortcut? Please explain, maybe I am missing something.

>  				}
>  			}
>  		}
> @@ -2415,7 +2418,6 @@ static int inet6_addr_add(struct net *net, int ifindex,
>  	} else {
>  		expires = 0;
>  		flags = 0;
> -		ifa_flags |= IFA_F_PERMANENT;

I find this very suspicious. IFA_F_PERMANENT may only be removed if valid_lft
!= inifinity and preferred_lft != infinity if at all (see below).

We have to be very careful here with interactions of prefix routes.

>  	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
> @@ -3497,8 +3499,12 @@ restart:
>  					ifp->flags |= IFA_F_DEPRECATED;
>  				}
>  
> -				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
> -					next = ifp->tstamp + ifp->valid_lft * HZ;
> +				if (ifp->valid_lft != INFINITY_LIFE_TIME) {
> +					if (time_before(ifp->tstamp +
> +							ifp->valid_lft * HZ, next))
> +						next = ifp->tstamp +
> +							ifp->valid_lft * HZ;
> +				}

You could reduce one level of indentation if you collapse those two conditions.

>  
>  				spin_unlock(&ifp->lock);
>  
> @@ -3635,7 +3641,6 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
>  	} else {
>  		expires = 0;
>  		flags = 0;
> -		ifa_flags |= IFA_F_PERMANENT;
>  	}

Ditto, I do think we cannot remove this flag unconditionally.

Actually, I don't think it is the correct way to remove the IFA_F_PERMANENT
here at all. We break the interaction with prefix routes and won't remove them
at the time of address deletion any more. This is definitely a no-go, sorry.

The prefix was added by hand and should get removed immediately if a user
removes the address (well actually it is an error we set up a prefix route in
the first place, but it is how things are now).

IMHO, the changes need to be made in addrconf_verify so that the route does
get marked as deprecated. Please check the places where we mark an interface
address as deprecated.

Thanks,

  Hannes

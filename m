From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Wed, 21 Apr 2010 23:34:29 +0200
Message-ID: <20100421213429.GA2799@midget.suse.cz>
References: <20100420174401.GB1334@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49011 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755363Ab0DUVed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 17:34:33 -0400
Content-Disposition: inline
In-Reply-To: <20100420174401.GB1334@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Apr 20, 2010 at 07:44:01PM +0200, Jiri Bohac wrote:
> What is the reason __ipv6_ifa_notify() calls dst_free() when
> ip6_del_rt() fails? I don't see a way ip6_del_rt() could fail
> with the dst still needing to be freed.

checked again and I still think that if ip6_del_rt() fails,
ifp->rt must have been freed already. Anybody with a
counterexample?

> I am just testing whether the following will help:
> 
> --- a/net/ipv6/addrconf.c	2010-04-17 00:12:32.000000000 +0200
> +++ b/net/ipv6/addrconf.c	2010-04-20 19:07:35.000000000 +0200
> @@ -3974,8 +3974,7 @@ static void __ipv6_ifa_notify(int event,
>  			addrconf_leave_anycast(ifp);
>  		addrconf_leave_solict(ifp->idev, &ifp->addr);
>  		dst_hold(&ifp->rt->u.dst);
> -		if (ip6_del_rt(ifp->rt))
> -			dst_free(&ifp->rt->u.dst);
> +		ip6_del_rt(ifp->rt);
>  		break;
>  	}
>  }

not surprisingly, it helps my case -- the race condition does not
happen and the resulting oopses disappears. Of course, this does
not prove the patch is correct.

Could anybody with more insight into the dst refcounting please
take a look? The code originally came from:

	Author: Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
	Date:   Wed Aug 18 05:25:16 2004 +0900

	    [IPV6] refer inet6 device via corresponding local route from address structure.

And has been modified later by:
	commit 4641e7a334adf6856300a98e7296dfc886c446af
	Author: Herbert Xu <herbert@gondor.apana.org.au>
	Date:   Thu Feb 2 16:55:45 2006 -0800

	    [IPV6]: Don't hold extra ref count in ipv6_ifa_notify

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ


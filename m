From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Log the explicit address that triggered DAD failure
Date: Thu, 13 Aug 2009 10:03:15 -0400
Message-ID: <4A841D23.8020703@hp.com>
References: <1250089107.6641.36.camel@fnki-nb00130>	 <4A836D70.1040702@hp.com> <1250151364.6641.75.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:12047 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbZHMODQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 10:03:16 -0400
In-Reply-To: <1250151364.6641.75.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
> On Wed, 2009-08-12 at 21:33 -0400, Brian Haley wrote:
> [...]
>> The other thing I've come across that is similar to this is the
>> issue that when DAD fails, /sbin/ip doesn't show that it did,
>> the address just stays in a tentative state forever:
>>
>>     inet6 dead:beef::1/64 scope global tentative 
>>        valid_lft forever preferred_lft forever
>>
>> Does anyone have an issue of adding a "dadfailed" flag to make
>> this more obvious:
>>
>>     inet6 dead:beef::1/64 scope global tentative dadfailed
>>        valid_lft forever preferred_lft forever
> 
> It looks like you would have to spend the last available bit in
> ifa_flags for that, not sure if that is worth it, how about setting it
> to tentative|deprecated instead?

Yes, I saw that it would be the last flag so I didn't know how that would
go over.  My other thought was to define a new flags structure that can
be passed in/out like IFA_CACHEINFO is.  It's a much larger patch...

> Some action should maybe also happen in the case that the address wasn't
> tentative anymore in ndisc_recv_na(). At least it should also log the
> address itself:
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 9eb68e9..1ba42bd 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -955,8 +955,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  		 */
>  		if (skb->pkt_type != PACKET_LOOPBACK)
>  			ND_PRINTK1(KERN_WARNING
> -			   "ICMPv6 NA: someone advertises our address on %s!\n",
> -			   ifp->idev->dev->name);
> +			   "ICMPv6 NA: someone advertises our address %pI6 on %s!\n",
> +			   &ifp->addr, ifp->idev->dev->name);
>  		in6_ifa_put(ifp);
>  		return;
>  	}

That looks good to me too, thanks.

-Brian

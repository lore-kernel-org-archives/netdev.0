From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: IPv6 and rt6_lookup()
Date: Thu, 02 Nov 2006 12:02:47 -0500
Message-ID: <454A24B7.1010109@hp.com>
References: <454A1BF7.6030500@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:43167 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751477AbWKBRCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 12:02:48 -0500
To: nicolas.dichtel@6wind.com
In-Reply-To: <454A1BF7.6030500@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas DICHTEL wrote:
> Hello,
> 
> Suppose that a host has autoconfiguration enabled. It will take RA to
> autoconfigure an IPv6 address. For example,
> 2001:0db8:3008:c1ca:2d0:b7ff:febb:4aee/64.
> This host will create a route entry for this onlink prefix (dst:
> 2001:0db8:3008:c1ca::/64)
> in the MAIN table with the lifetime present in prefix option in RA.
> Each time this host will receive a RA, it will update this lifetime. To
> do this,
> it will call rt6_lookup() (in addrconf_prefix_rcv()) to find the entry.
> 
> Now, suppose that our host joins this anycast group:
> "2001:0db8:3008:c1ca::0". A route

Hmm... you are configuring a subnet router anycast address on host and 
the implementation lets you do it?  That's not good.  I don't think
you sould be permitted to configure a subnet router anycast address
on a host that autoconfigures it's interface.

-vlad

> entry will be added in the LOCAL table (see addrconf_join_anycast()).
> Problem is that, next time our host will receive a RA and will perform a
> rt6_lookup(),
> this function will return the local entry (LOCAL table), and not the
> "dynamic" entry
> (MAIN table). Consequence is that the lifetime of the dynamic entry will
> never been updated,
> and so will expire, whereas the host will keep the corresponding address.
> 
> Maybe, when strict is set to 1 in rt6_lookup(), kernel must not return
> an anycast route.
> What about this patch ?
> 
> 
> Regards,
> Nicolas
> 
> [IPv6] Don't return anycast route when strict is enable
> 
> Signed-off-by: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c953466..51a8c1d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -248,6 +248,8 @@ static __inline__ struct rt6_info *rt6_d
>  			if (dev->ifindex == oif)
>  				return sprt;
>  			if (dev->flags & IFF_LOOPBACK) {
> +				if (strict && sprt->rt6i_flags & RTF_ANYCAST)
> +					continue;
>  				if (sprt->rt6i_idev == NULL ||
>  				    sprt->rt6i_idev->dev->ifindex != oif) {
>  					if (strict && oif)


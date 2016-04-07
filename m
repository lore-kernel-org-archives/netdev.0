From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH] possible bug in handling of ipv4 route caching
Date: Fri, 8 Apr 2016 00:20:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg>
References: <5706B250.1060303@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59077 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757447AbcDGVU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 17:20:29 -0400
In-Reply-To: <5706B250.1060303@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 7 Apr 2016, Chris Friesen wrote:

> Hi,
> 
> We think we may have found a bug in the handling of ipv4 route caching,
> and are curious what you think.
> 
> For local routes that require a particular output interface we do not
> want to cache the result.  Caching the result causes incorrect behaviour
> when there are multiple source addresses on the interface.  The end
> result being that if the intended recipient is waiting on that interface
> for the packet he won't receive it because it will be delivered on the
> loopback interface and the IP_PKTINFO ipi_ifindex will be set to the
> loopback interface as well.

	So, if we store some orig_oif in rt_iif that
is specific (cached in nexthop) to some device, this
orig_oif should match the device. The only case when
this is violated is when we redirect traffic to lo.
Any attempts to store eth1 in rt_iif for nexthop
cache for lo should be avoided.

> This can be tested by running a program such as "dhcp_release" which
> attempts to inject a packet on a particular interface so that it is
> received by another program on the same board.  The receiving process
> should see an IP_PKTINFO ipi_ifndex value of the source interface
> (e.g., eth1) instead of the loopback interface (e.g., lo).  The packet
> will still appear on the loopback interface in tcpdump but the important
> aspect is that the CMSG info is correct.
> 
> For what it's worth, here's a patch that we've applied locally to deal
> with the issue.
> 
> Chris
> 
> 
> 
> Signed-off-by: Allain Legacy <allain.legacy@windriver.com>
> Signed-off-by: Chris Friesen <chris.friesen@windriver.com>
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 02c6229..e965d4b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2045,6 +2045,17 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>  		 */
>  		if (fi && res->prefixlen < 4)
>  			fi = NULL;
> +	} else if ((type == RTN_LOCAL) && (orig_oif != 0)) {

	So, we can be more specific. Can this work?:

	} else if ((type == RTN_LOCAL) && (orig_oif != 0) &&
		   (orig_oif != dev_out->ifindex)) {

	I.e. we should allow to cache orig_oif=LOOPBACK_IFINDEX
but eth1 should not be cached.

> +		/* For local routes that require a particular output interface
> +                 * we do not want to cache the result.  Caching the result
> +                 * causes incorrect behaviour when there are multiple source
> +                 * addresses on the interface, the end result being that if the
> +                 * intended recipient is waiting on that interface for the
> +                 * packet he won't receive it because it will be delivered on
> +                 * the loopback interface and the IP_PKTINFO ipi_ifindex will
> +                 * be set to the loopback interface as well.
> +		 */
> +		fi = NULL;
>  	}
>  
>  	fnhe = NULL;

Regards

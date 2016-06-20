From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] net: ipv6: Move ip6_route_get_saddr to
 inline
Date: Mon, 20 Jun 2016 15:29:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E0170@AcuExch.aculab.com>
References: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
 <1466119466-3144-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'David Ahern' <dsa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:63237 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbcFTPfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 11:35:05 -0400
In-Reply-To: <1466119466-3144-2-git-send-email-dsa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Behalf Of David Ahern
> Sent: 17 June 2016 00:24
> VRF driver needs access to ip6_route_get_saddr code. Since it does
> little beyond ipv6_dev_get_saddr and ipv6_dev_get_saddr is already
> exported for modules move ip6_route_get_saddr to the header as an
> inline.
> 
> Code move only; no functional change.

Look a bit large for an inline.

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/net/ip6_route.h | 21 ++++++++++++++++++---
>  net/ipv6/route.c        | 17 -----------------
>  2 files changed, 18 insertions(+), 20 deletions(-)
> 
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index f55bf3d294aa..d97305d0e71f 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -18,6 +18,7 @@ struct route_info {
>  	__u8			prefix[0];	/* 0,8 or 16 */
>  };
> 
> +#include <net/addrconf.h>
>  #include <net/flow.h>
>  #include <net/ip6_fib.h>
>  #include <net/sock.h>
> @@ -88,9 +89,23 @@ int ip6_route_add(struct fib6_config *cfg);
>  int ip6_ins_rt(struct rt6_info *);
>  int ip6_del_rt(struct rt6_info *);
> 
> -int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
> -			const struct in6_addr *daddr, unsigned int prefs,
> -			struct in6_addr *saddr);
> +static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
> +				      const struct in6_addr *daddr,
> +				      unsigned int prefs,
> +				      struct in6_addr *saddr)
> +{
> +	struct inet6_dev *idev =
> +			rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
> +	int err = 0;
> +
> +	if (rt && rt->rt6i_prefsrc.plen)
> +		*saddr = rt->rt6i_prefsrc.addr;
> +	else
> +		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
> +					 daddr, prefs, saddr);
> +
> +	return err;
> +}
...

The above looks as though it might be:
	if (!rt)
		return ipv6_dev_get_saddr(net, NULL, dattr, prefs, saddr);
	if (!rt->rt6i_prefsrc.plen)
		return ipv6_dev_get_saddr(net, ip6_dst_idev((struct dst_entry *)rt)->dev, dattr, prefs, saddr);
	*saddr = rt->rt6i_prefsrc.addr;
	return 0;

which could inline to better code.
Alternatively just inline the fast path.

	David

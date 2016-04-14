From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Use passed in table for nexthop
 lookups
Date: Wed, 13 Apr 2016 21:41:51 -0400 (EDT)
Message-ID: <20160413.214151.2294488534397440295.davem@davemloft.net>
References: <1460052674-1204-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbcDNBlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 21:41:55 -0400
In-Reply-To: <1460052674-1204-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  7 Apr 2016 11:11:14 -0700

> Similar to 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
> for IPv4, if the route spec contains a table id use that to lookup the
> next hop first and fall back to a full lookup if it fails (per the fix
> 4c9bcd117918b ("net: Fix nexthop lookups")).
> @@ -1940,7 +1940,38 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
>  			if (!(gwa_type & IPV6_ADDR_UNICAST))
>  				goto out;
>  
> -			grt = rt6_lookup(net, gw_addr, NULL, cfg->fc_ifindex, 1);
> +			if (cfg->fc_table) {
> +				struct flowi6 fl6 = {
> +					.flowi6_oif = cfg->fc_ifindex,
> +					.daddr = *gw_addr,
> +					.saddr = cfg->fc_prefsrc,
> +				};
> +				struct fib6_table *table;
> +				int flags = 0;
> +
> +				err = -EHOSTUNREACH;
> +				table = fib6_get_table(net, cfg->fc_table);
> +				if (!table)
> +					goto out;
> +
> +				if (!ipv6_addr_any(&cfg->fc_prefsrc))
> +					flags |= RT6_LOOKUP_F_HAS_SADDR;
> +
> +				grt = ip6_pol_route(net, table, cfg->fc_ifindex,
> +						    &fl6, flags);
> +
> +				/* if table lookup failed, fall back
> +				 * to full lookup
> +				 */

This is semantically different from the referenced ipv4 change.

Lack of a matching table for cfg->fc_table does not result in a
failure on the ipv4 side.  It falls back in that case.

But here in this ipv6 patch, you do fail if fib6_get_table() gives
NULL.

One thing that drives me absolutely crazy is all of the subtle
semantic differences between our ipv4 and ipv6 stack, so I refuse to
knowingly add new such cases.

Therefore, please make the ipv6 behavior match exactly what ipv4
does.

Thanks.

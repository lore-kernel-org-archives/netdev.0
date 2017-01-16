From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/3] net: ipv6: Allow shorthand delete of
 all nexthops in multipath route
Date: Mon, 16 Jan 2017 07:48:55 -0800
Message-ID: <587CEB67.3040807@cumulusnetworks.com>
References: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com> <1484510826-2723-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34036 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAPPsx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 10:48:53 -0500
Received: by mail-pg0-f45.google.com with SMTP id 14so16522767pgg.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 07:48:53 -0800 (PST)
In-Reply-To: <1484510826-2723-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/15/17, 12:07 PM, David Ahern wrote:
> IPv4 allows multipath routes to be deleted using just the prefix and
> length. For example:
>     $ ip ro ls vrf red
>     unreachable default metric 8192
>     1.1.1.0/24
>         nexthop via 10.100.1.254  dev eth1 weight 1
>         nexthop via 10.11.200.2  dev eth11.200 weight 1
>     10.11.200.0/24 dev eth11.200 proto kernel scope link src 10.11.200.3
>     10.100.1.0/24 dev eth1 proto kernel scope link src 10.100.1.3
>
>     $ ip ro del 1.1.1.0/24 vrf red
>
>     $ ip ro ls vrf red
>     unreachable default metric 8192
>     10.11.200.0/24 dev eth11.200 proto kernel scope link src 10.11.200.3
>     10.100.1.0/24 dev eth1 proto kernel scope link src 10.100.1.3
>
> The same notation does not work with IPv6 because of how multipath routes
> are implemented for IPv6. For IPv6 only the first nexthop of a multipath
> route is deleted if the request contains only a prefix and length. This
> leads to unnecessary complexity in userspace dealing with IPv6 multipath
> routes.
>
> This patch allows all nexthops to be deleted without specifying each one
> in the delete request by passing a new flag, RTM_F_ALL_NEXTHOPS, in
> rtm_flags. Internally, this is done by walking the sibling list of the
> route matching the specifications given (prefix, length, metric, protocol,
> etc).
>
> With this patch (and an updated iproute2 command):
>     $  ip -6 ro ls vrf red
>     2001:db8::/120 via 2001:db8:1::62 dev eth1 metric 256  pref medium
>     2001:db8::/120 via 2001:db8:1::61 dev eth1 metric 256  pref medium
>     2001:db8::/120 via 2001:db8:1::60 dev eth1 metric 256  pref medium
>     2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
>     ...
>
>     $ ip -6 ro del vrf red 1111::1/120
>     $ ip -6 ro ls vrf red
>     2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
>     ...
>
> The flag is added to fib6_config by converting fc_type to a u16 (as
> noted fc_type only uses 8 bits). The new u16 hole is a bitmap with
> fc_delete_all_nexthop as the first bit.
>
> Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - switched example to rfc 3849 documentation address per request
> - changed delete loop to explicitly look at siblings list for
>   first route matching specs given (metric, protocol, etc)
>
>  include/net/ip6_fib.h          |  4 +++-
>  include/uapi/linux/rtnetlink.h |  1 +
>  net/ipv6/route.c               | 28 +++++++++++++++++++++++++---
>  3 files changed, 29 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index a74e2aa40ef4..11ab99e87c5f 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -37,7 +37,9 @@ struct fib6_config {
>  	int		fc_ifindex;
>  	u32		fc_flags;
>  	u32		fc_protocol;
> -	u32		fc_type;	/* only 8 bits are used */
> +	u16		fc_type;	/* only 8 bits are used */
> +	u16		fc_delete_all_nexthop : 1,
> +			__unused : 15;
>  
>  	struct in6_addr	fc_dst;
>  	struct in6_addr	fc_src;
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 8c93ad1ef9ab..7fb206bc42f9 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -276,6 +276,7 @@ enum rt_scope_t {
>  #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
>  #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
>  #define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
> +#define RTM_F_ALL_NEXTHOPS	0x2000	/* delete all nexthops (IPv6) */
>  
Do we really need the flag ?. It seems like delete with just prefix should delete all the routes in a multipath
route by default... (understand that you have it there to preserve existing behavior...for people who maybe relying on it. But this seems more like a bug fix. route replace went through a few such bug fixes "ipv6: fix ECMP route replacement"). ok with either approach.

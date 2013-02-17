From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v2 1/4] ipv6: introduce new type ipv6_addr_props
 to hold ipv6 address type and scope
Date: Sun, 17 Feb 2013 09:05:00 +0900
Message-ID: <51201EAC.6080604@linux-ipv6.org>
References: <20130216191008.GA23272@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, brian.haley@hp.com,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57735 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754700Ab3BQAFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 19:05:02 -0500
In-Reply-To: <20130216191008.GA23272@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:

> diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
> index d051e5f..99cb205 100644
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -6,75 +6,104 @@
>  #include <linux/export.h>
>  #include <net/ipv6.h>
>  
> -#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
> -
> -static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
> +static inline struct ipv6_addr_props ipv6_addr_mc_props(unsigned int scope)
>  {
>  	switch (scope) {
>  	case IPV6_ADDR_SCOPE_NODELOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
> -			IPV6_ADDR_LOOPBACK);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK,
> +			.scope = IPV6_ADDR_SCOPE_NODELOCAL
> +		};
>  	case IPV6_ADDR_SCOPE_LINKLOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL) |
> -			IPV6_ADDR_LINKLOCAL);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL,
> +			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
> +		};
>  	case IPV6_ADDR_SCOPE_SITELOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL) |
> -			IPV6_ADDR_SITELOCAL);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_SITELOCAL,
> +			.scope = IPV6_ADDR_SCOPE_SITELOCAL
> +		};
>  	}
> -	return IPV6_ADDR_SCOPE_TYPE(scope);
> +	return (struct ipv6_addr_props){
> +		.type = IPV6_ADDR_MULTICAST,
> +		.scope = scope
> +	};
>  }
>  
> -int __ipv6_addr_type(const struct in6_addr *addr)
> +struct ipv6_addr_props __ipv6_addr_props(const struct in6_addr *addr)
>  {
> -	__be32 st;
> -
> -	st = addr->s6_addr32[0];
> +	__be32 st = addr->s6_addr32[0];
>  
>  	/* Consider all addresses with the first three bits different of
>  	   000 and 111 as unicasts.
>  	 */
>  	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
>  	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
> -		return (IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_GLOBAL
> +		};
>  
>  	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
>  		/* multicast */
>  		/* addr-select 3.1 */
> -		return (IPV6_ADDR_MULTICAST |
> -			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
> +		return ipv6_addr_mc_props(IPV6_ADDR_MC_SCOPE(addr));
>  	}
>  
>  	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
> -		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));		/* addr-select 3.1 */
> +		/* addr-select 3.1 */
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
> +		};
>  	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
> -		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
> +		/* addr-select 3.1 */
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_SITELOCAL|IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_SITELOCAL,
> +		};
>  	if ((st & htonl(0xFE000000)) == htonl(0xFC000000))
> -		return (IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));			/* RFC 4193 */
> +		/* RFC 4193 */
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_GLOBAL,
> +		};
>  
>  	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
>  		if (addr->s6_addr32[2] == 0) {
>  			if (addr->s6_addr32[3] == 0)
> -				return IPV6_ADDR_ANY;
> +				return (struct ipv6_addr_props){
> +					.type = IPV6_ADDR_ANY
> +				};
>  
>  			if (addr->s6_addr32[3] == htonl(0x00000001))
> -				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
> -					IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));	/* addr-select 3.4 */
> +				/* addr-select 3.4 */
> +				return (struct ipv6_addr_props){
> +					.type = IPV6_ADDR_LOOPBACK|
> +						IPV6_ADDR_UNICAST,
> +					.scope = IPV6_ADDR_SCOPE_LINKLOCAL
> +				};
>  
> -			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
> -				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
> +			/* addr-select 3.3 */
> +			return (struct ipv6_addr_props){
> +				.type = IPV6_ADDR_COMPATv4|IPV6_ADDR_UNICAST,
> +				.scope = IPV6_ADDR_SCOPE_GLOBAL
> +			};
>  		}
>  
>  		if (addr->s6_addr32[2] == htonl(0x0000ffff))
> -			return (IPV6_ADDR_MAPPED |
> -				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
> +			/* addr-select 3.3 */
> +			return (struct ipv6_addr_props){
> +				.type = IPV6_ADDR_MAPPED,
> +				.scope = IPV6_ADDR_SCOPE_GLOBAL
> +			};
>  	}
>  
> -	return (IPV6_ADDR_UNICAST |
> -		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
> +	/* addr-select 3.4 */
> +	return (struct ipv6_addr_props){
> +		.type = IPV6_ADDR_UNICAST,
> +		.scope = IPV6_ADDR_SCOPE_GLOBAL
> +	};
>  }
> -EXPORT_SYMBOL(__ipv6_addr_type);
> -
> +EXPORT_SYMBOL(__ipv6_addr_props);

Sorry, I disagree.  This generates worse code.

--yoshfuji

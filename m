From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 4 Oct 2002 09:32:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210040902010.16205-100000@netcore.fi>
References: <20021004.015045.96199793.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021004.015045.96199793.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There seems to be __constant_htonl there too but this is just a nit, and 
shouldn't a showstopper in the review.

A few comments, mainly on the spec perspective below.

Are IPv4 addresses represented as mapped addresses (as they should by the 
spec at least)?

There seem to be some points at section 4 of the draft (e.g. for multicast
destinations, MUST only pick addresses on the outgoing interface) that may
be missing?

> +#ifndef IPV6_ADDR_MC_SCOPE
> +#define IPV6_ADDR_MC_SCOPE(a)	\
> +	((a)->s6_addr[1] & 0x0f)	/* XXX nonstandard */
> +#define __IPV6_ADDR_SCOPE_RESERVED	-2
> +#define __IPV6_ADDR_SCOPE_ANY		-1
> +#define IPV6_ADDR_SCOPE_NODELOCAL	0x01
> +#define IPV6_ADDR_SCOPE_LINKLOCAL	0x02
> +#define IPV6_ADDR_SCOPE_SITELOCAL	0x05
> +#define IPV6_ADDR_SCOPE_ORGLOCAL	0x08
> +#define IPV6_ADDR_SCOPE_GLOBAL		0x0e
> +#endif

Aren't these definitions header file material, perhaps (I'd guess they 
might be useful in other .c files too).

> +int ipv6_addrselect_scope(const struct in6_addr *addr)
> +{
> +	u32 st;
> +
> +	st = addr->s6_addr32[0];
> +
> +	if ((st & __constant_htonl(0xE0000000)) != __constant_htonl(0x00000000) &&
> +	    (st & __constant_htonl(0xE0000000)) != __constant_htonl(0xE0000000))
> +		return IPV6_ADDR_SCOPE_GLOBAL;
> +
> +	if ((st & __constant_htonl(0xFF000000)) == __constant_htonl(0xFF000000))
> +		return IPV6_ADDR_MC_SCOPE(addr);
> +        
> +	if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFE800000))
> +		return IPV6_ADDR_SCOPE_LINKLOCAL;
> +
> +	if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFEC00000))
> +		return IPV6_ADDR_SCOPE_SITELOCAL;

Something similar to this is done in addrconf.c:ipv6_addr_type, could 
there be more reuse?

> +	if ((st | addr->s6_addr32[1]) == 0) {
> +		if (addr->s6_addr32[2] == 0) {
> +			if (addr->s6_addr32[3] == 0)
> +				return __IPV6_ADDR_SCOPE_ANY;
> +
> +			if (addr->s6_addr32[3] == __constant_htonl(0x00000001))
> +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.4 */
> +
> +			return IPV6_ADDR_SCOPE_GLOBAL;			/* section 2.3 */
> +		}

You're referring to sections 3.4 and 3.3, I think (similar in other 
comments)

> +		if (addr->s6_addr32[2] == __constant_htonl(0x0000FFFF)) {
> +			if (addr->s6_addr32[3] == __constant_htonl(0xA9FF0000))
> +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.2 */

Shouldn't that be 0xA9FE0000 if you mean IPv4 zeroconf 169.254.0.0/16 ?
(that could be spelt out in a comment.)

> +			if (addr->s6_addr32[3] == __constant_htonl(0xAC000000)) {
> +				if (addr->s6_addr32[3] == __constant_htonl(0xAC100000))
> +					return IPV6_ADDR_SCOPE_SITELOCAL;	/* section 2.2 */

172.16.00 -- 172.31.255.255, not just 172.16.*.*

> +				return IPV6_ADDR_SCOPE_LINKLOCAL;	/* section 2.2 */
> +			}

I don't understand this, this was possibly supposed to be the case for 
127.0.0.0/8 which should be treated as link-local?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 16:58:59 +0100
Message-ID: <200711071658.59478.netdev@axxeo.de>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE3@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:2766 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177AbXKGP7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 10:59:14 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE3@XCH-NW-7V2.nw.nos.boeing.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fred,

some comments.

Templin, Fred L schrieb:
> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This is experimental support for the Intra-Site Automatic
> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> the SIT module, and is configured using the unmodified
> "ip" utility with device names beginning with: "isatap".
> 
> The following diffs are specific to the Linux 2.6.23
> kernel distribution.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 
> ---
> 
> --- linux-2.6.23/include/net/addrconf.h.orig	2007-10-09
> 13:31:38.000000000 -0700
> +++ linux-2.6.23/include/net/addrconf.h	2007-10-26 10:49:40.000000000
> -0700
> @@ -241,6 +241,34 @@ static inline int ipv6_addr_is_ll_all_ro
>  		addr->s6_addr32[3] == htonl(0x00000002));
>  }
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +static inline int ipv6_isatap_eui64(u8 *eui, __be32 *addr)
"addr" is only used for reading, not writing. No need to pass it as a pointer.

> +{
> +	__be32 ipv4 = ntohl(*addr);

ntohl(be32_value) != be32_value, so the _be32 attribution of ipv4 
is wrong here and sparse will scream.

> +
> +	eui[0] = 0;
> +
> +	/* Check for RFC3330 global address ranges */
> +	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
> +	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
> +	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> +	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> +	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
> +	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> +	    ((ipv4 >= 0xc6140000) && (ipv4 < 0xe0000000))) eui[0] |=
> 0x2;
> +

Instead of converting network to host byte order at runtime 
and comparing the results to constants, let the compiler convert
the constants to network byte order and compare in network order.

so use:

 if (((*addr >= htonl(0x01000000)) && (*addr < htonl(0x0a000000))) || ....

instead. The compiler will notice that "0x01000000" is a constant and will
use "_constant_htonl()" automatically.


> +	eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
> +	memcpy (eui+4, addr, 4);
> +	return (0);
> +}

Nitpick: 
	"return" is not a function. Please write "return 0;" instead.

> +
> +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> +{
> +       return (addr->s6_addr32[2] == __constant_htonl(0x02005EFE) ||
> +               addr->s6_addr32[2] == __constant_htonl(0x00005EFE));
> +}
> +#endif

The compiler will notice that "0x01000000" is a constant and will
use "_constant_htonl()" automatically. Please use simply htonl().


Best Regards

Ingo Oeser

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support (2)
Date: Fri, 09 Nov 2007 08:29:50 +0900 (JST)
Message-ID: <20071109.082950.122508269.yoshfuji@linux-ipv6.org>
References: <47337483.3080309@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: osprey67@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39761 "EHLO
	yue.st-paulia.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1762644AbXKIAAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 19:00:02 -0500
In-Reply-To: <47337483.3080309@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <47337483.3080309@yahoo.com> (at Thu, 08 Nov 2007 12:41:39 -0800), osprey67 <osprey67@yahoo.com> says:

> From: Fred L. Templin <osprey67@yahoo.com>
> 
> This is experimental support for the Intra-Site Automatic
> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> the SIT module, and is configured using the unmodified
> "ip" utility with device names beginning with: "isatap".
> 
> The following diffs are specific to the Linux 2.6.24-rc2
> kernel distribution.
> 
> Signed-off-by: Fred L. Templin <osprey67@yahoo.com>

Hmm...tabs are still mangled, and it's better to have your
official address.  Anyway...

> --- linux-2.6.24-rc2/include/net/addrconf.h.orig        2007-11-08 12:06:17.000000000 -0800
> +++ linux-2.6.24-rc2/include/net/addrconf.h     2007-11-08 08:27:24.000000000 -0800
> @@ -241,6 +241,37 @@ static inline int ipv6_addr_is_ll_all_ro
>                  addr->s6_addr32[3] == htonl(0x00000002));
>   }
> 
> +#if defined(CONFIG_IPV6_ISATAP)
> +static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
> +{
> +
> +       /* RFC3330 Special-Use IPv4 Addresses */
> +       eui[0] = (((addr & htonl(0xFF000000)) == htonl(0x00000000)) ||
> +                 ((addr & htonl(0xFF000000)) == htonl(0x0A000000)) ||
> +                 ((addr & htonl(0xFF000000)) == htonl(0x0D000000)) ||
> +                 ((addr & htonl(0xFF000000)) == htonl(0x18000000)) ||
> +                 ((addr & htonl(0xFF000000)) == htonl(0x7F000000)) ||
> +                 ((addr & htonl(0xFFFF0000)) == htonl(0xA9FE0000)) ||
> +                 ((addr & htonl(0xFFF00000)) == htonl(0xAC100000)) ||
> +                 ((addr & htonl(0xFFFFFF00)) == htonl(0xC0000200)) ||
> +                 ((addr & htonl(0xFFFFFF00)) == htonl(0xC0586300)) ||
> +                 ((addr & htonl(0xFFFF0000)) == htonl(0xC0A80000)) ||
> +                 ((addr & htonl(0xFFFE0000)) == htonl(0xC6120000)) ||
> +                 ((addr & htonl(0xF0000000)) == htonl(0xE0000000)) ||
> +                 ((addr & htonl(0xF0000000)) == htonl(0xF0000000))) ?
> +                       0x00 : 0x02;
> +
> +       eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
> +       memcpy (eui+4, &addr, 4);
> +       return 0;
> +}
> +

Please put this function in net/ipv6/addrconf.c as addrconf_ifid_isatap().

Please use MULTICAST, LOCALNET etc. (and probaly introduce new macro
for others).  IMHO, it's better to add a comment for each entry, e.g.,
	MULTICAST(addr) ||		/* 224.0.0.0/4 */
instead of
	((addr & htonl(0xF0000000)) == htonl(0xE0000000)) ||

> +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> +{
> +       return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
> +}
> +#endif
> +

ipv6_addr_isatap(), maybe (to align with ipv6_addr_any() etc.).

--yoshfuji

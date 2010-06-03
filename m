From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] net: Enable 64-bit net device statistics on 32-bit
 architectures
Date: Thu, 3 Jun 2010 11:47:38 -0700
Message-ID: <20100603114738.41256434@nehalam>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
	<1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479Ab0FCSrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 14:47:41 -0400
In-Reply-To: <1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Jun 2010 18:39:04 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> #if BITS_PER_LONG == 64
> +#define NET_DEVICE_STATS_DEFINE(name)	u64 name
> +#define RTNL_LINK_STATS64_READ(stats, name)				\
> +	ACCESS_ONCE((stats)->name)
> +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> +	ACCESS_ONCE((const u64 *)((const u8 *)(stats) + (offset)))
> +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> +	((u32)ACCESS_ONCE((stats)->name))
> +#else
> +#if defined(__LITTLE_ENDIAN)
> +#define NET_DEVICE_STATS_DEFINE(name)	u32 name, pad_ ## name
> +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> +	(ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset))) |	\
> +	 (u64)(*(const u32 *)((const u8 *)(stats) + (offset) + 4)) << 32)
> +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> +	(((const volatile u32 *)&(stats)->name)[0])
> +#else
> +#define NET_DEVICE_STATS_DEFINE(name)	u32 pad_ ## name, name
> +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> +	((u64)(*(const u32 *)((const u8 *)(stats) + (offset))) << 32 |	\
> +	 ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset) + 4)))
> +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> +	(((const volatile u32 *)&(stats)->name)[1])
> +#endif
> +#define RTNL_LINK_STATS64_READ(stats, name)				\
> +	RTNL_LINK_STATS64_READ_OFFSET(					\
> +		stats, offsetof(struct rtnl_link_stats64, name))
> +#endif

Macros... with multiple casts. Gack

-- 

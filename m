From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Enable 64-bit net device statistics on 32-bit
 architectures
Date: Thu, 03 Jun 2010 20:11:38 +0100
Message-ID: <1275592298.2106.36.camel@achroite.uk.solarflarecom.com>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
	 <1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
	 <20100603114738.41256434@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10830 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab0FCTLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 15:11:42 -0400
In-Reply-To: <20100603114738.41256434@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 11:47 -0700, Stephen Hemminger wrote:
> On Thu, 03 Jun 2010 18:39:04 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > #if BITS_PER_LONG == 64
> > +#define NET_DEVICE_STATS_DEFINE(name)	u64 name
> > +#define RTNL_LINK_STATS64_READ(stats, name)				\
> > +	ACCESS_ONCE((stats)->name)
> > +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> > +	ACCESS_ONCE((const u64 *)((const u8 *)(stats) + (offset)))
> > +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> > +	((u32)ACCESS_ONCE((stats)->name))
> > +#else
> > +#if defined(__LITTLE_ENDIAN)
> > +#define NET_DEVICE_STATS_DEFINE(name)	u32 name, pad_ ## name
> > +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> > +	(ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset))) |	\
> > +	 (u64)(*(const u32 *)((const u8 *)(stats) + (offset) + 4)) << 32)
> > +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> > +	(((const volatile u32 *)&(stats)->name)[0])
> > +#else
> > +#define NET_DEVICE_STATS_DEFINE(name)	u32 pad_ ## name, name
> > +#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
> > +	((u64)(*(const u32 *)((const u8 *)(stats) + (offset))) << 32 |	\
> > +	 ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset) + 4)))
> > +#define RTNL_LINK_STATS64_READ32(stats, name)				\
> > +	(((const volatile u32 *)&(stats)->name)[1])
> > +#endif
> > +#define RTNL_LINK_STATS64_READ(stats, name)				\
> > +	RTNL_LINK_STATS64_READ_OFFSET(					\
> > +		stats, offsetof(struct rtnl_link_stats64, name))
> > +#endif
> 
> Macros... with multiple casts. Gack

RTNL_LINK_STATS64_READ_OFFSET() is only really needed in net-sysfs.c,
and that ugliness could maybe be left there.  So maybe the accessors
could be defined as something like:

#if BITS_PER_LONG == 64

static inline u64 rtnl_link_stats64_read(const u64 *field)
{
	return ACCESS_ONCE(*field);
}
static inline u32 rtnl_link_stats64_read32(const u64 *field)
{
	return ACCESS_ONCE(*field);
}

#else

static inline u64 rtnl_link_stats64_read(const u64 *field)
{
#if defined(__LITTLE_ENDIAN)
	const u32 *low = (const u32 *)field, *high = low + 1;
#else
	const u32 *high = (const u32 *)field, *low = high + 1;
#endif
	return ACCESS_ONCE(*low) | (u64)*high << 32;
}
static inline u32 rtnl_link_stats64_read32(const u64 *field)
{
#if defined(__LITTLE_ENDIAN)
	const u32 *low = (const u32 *)field;
#else
	const u32 *low = (const u32 *)field + 1;
#endif
	return ACCESS_ONCE(*low);
}

#endif

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


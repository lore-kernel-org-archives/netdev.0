From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 14:21:43 +0100
Message-ID: <1226496103.6834.66.camel@localhost.localdomain>
References: <20081112.014923.68124784.davem@davemloft.net>
	 <1226487710.6834.53.camel@localhost.localdomain>
	 <20081112.035240.226243372.davem@davemloft.net>
	 <20081112.041143.11487260.davem@davemloft.net>
	 <1226494493.3016.3.camel@achroite>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:44123 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYKLNVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 08:21:55 -0500
In-Reply-To: <1226494493.3016.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 12:54 +0000, Ben Hutchings wrote:
> On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
> [...]
> > So the following patch should fix this bug.  writeq() should
> > be OK as-is, so doesn't need a similar change.
> > 
> > diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> > index 9acb5d7..d8463b1 100644
> > --- a/drivers/net/niu.c
> > +++ b/drivers/net/niu.c
> > @@ -51,8 +51,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
> >  #ifndef readq
> >  static u64 readq(void __iomem *reg)
> >  {
> > -	return (((u64)readl(reg + 0x4UL) << 32) |
> > -		(u64)readl(reg));
> > +	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
> >  }
> 
> Since there's no sequence point between the reads, there's no guarantee
> that the reads happen in the order written (regardless of barriers
> inside readl()).  This needs to be split into two statements.

The nxge driver does this:

#ifndef readq
static inline uint64_t readq(void *addr)
{
	uint32_t val32 = readl(addr);
	uint64_t val64 = (uint64_t) readl(addr + 4);
	return (val32 | (val64 << 32));
}
#endif

#ifndef writeq
static inline void writeq(uint64_t val64, void *addr)
{
	writel((uint32_t)(val64), addr);
	writel((uint32_t)(val64 >> 32), (addr + 4));
}
#endif

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

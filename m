From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 5/10] Neterion: New driver: Hardware init & configuration
Date: Wed, 25 Mar 2009 04:25:28 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705122509@nekter>
References: <1237968776.1655.267.camel@flash> <20090325.011220.227287174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:59268 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbZCYIZb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:25:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090325.011220.227287174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I missed that one! Yes, it was only tested on 64 bit kernels. The
following macros were removed/deleted by mistake. We'll make these
changes, check and submit.

#ifndef readq
static inline u64 readq(void *addr)
{
        u64 ret = 0;
        ret = readl(addr + 4);
        ret <<= 32;
        ret |= readl(addr);

        return ret;
}
#endif
#ifndef writeq
static inline void writeq(u64 val, void *addr)
{
        writel((u32) (val), addr);
        writel((u32) (val >> 32), (addr + 4));
}
#endif 

Ram
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, March 25, 2009 1:12 AM
> To: Ramkrishna Vepa
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-2.6 PATCH 5/10] Neterion: New driver: Hardware init
&
> configuration
> 
> From: Ramkrishna Vepa <ram.vepa@neterion.com>
> Date: 25 Mar 2009 00:13:12 -0800
> 
> > This patch takes care of Initialization and configuration steps of
> > Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized Server
Adapter.
> 
> This driver won't build on 32-bit platforms, not even x86.
> 
> You didn't build test on i386?
> 
> You have to provide a readq/writeq implementation on 32-bit
> machines so that you can choose in what order it is safe
> to read/write the upper and lower 32-bit halfs of a 64-bit
> register.
> 
> See the following from drivers/net/niu.c:
> 
> #ifndef readq
> static u64 readq(void __iomem *reg)
> {
> 	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
> }
> 
> static void writeq(u64 val, void __iomem *reg)
> {
> 	writel(val & 0xffffffff, reg);
> 	writel(val >> 32, reg + 0x4UL);
> }
> #endif
> 
> And DO NOT JUST COPY THIS!  Think about how your hardware behaves
> if the 64-bit registers are accessed 32-bits at a time, especially
> wrt. state clearing when reading interrupt status registers.

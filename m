From: Roland Dreier <rdreier@cisco.com>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Fri, 10 Oct 2008 10:10:51 -0700
Message-ID: <adaabdcjrz8.fsf@cisco.com>
References: <20081009212755.94fe11f6.akpm@linux-foundation.org>
	<20081009.215452.193703022.davem@davemloft.net>
	<20081009.220513.181546765.davem@davemloft.net>
	<20081009.221426.120533568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, mingo@elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:15505 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757324AbYJJRKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 13:10:54 -0400
In-Reply-To: <20081009.221426.120533568.davem@davemloft.net> (David Miller's
	message of "Thu, 09 Oct 2008 22:14:26 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc'ing Scott so we can make sure that this actually is atomic enough to
work with the enic hardware... (Scott, the context is that enic won't
build on any architecture that doesn't define writeq and readq, such as
32-bit x86; however the definitions below make it possible that multiple
32-bit writes will be interleaved, eg if an interrupt occurs between the
first writel and the second writel)

 > I just pushed the following into net-next-2.6:
 > 
 > enic: Attempt to fix build in 32-bit such as i386.
 > 
 > Such platforms lack readq/writeq but this driver want to call them.
 > 
 > Noticed by Andrew Morton.
 > 
 > Signed-off-by: David S. Miller <davem@davemloft.net>
 > ---
 >  drivers/net/enic/vnic_dev.h |   14 ++++++++++++++
 >  1 files changed, 14 insertions(+), 0 deletions(-)
 > 
 > diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
 > index 2dcffd3..b9dc182 100644
 > --- a/drivers/net/enic/vnic_dev.h
 > +++ b/drivers/net/enic/vnic_dev.h
 > @@ -27,6 +27,20 @@
 >  #define VNIC_PADDR_TARGET	0x0000000000000000ULL
 >  #endif
 >  
 > +#ifndef readq
 > +static inline u64 readq(void __iomem *reg)
 > +{
 > +	return (((u64)readl(reg + 0x4UL) << 32) |
 > +		(u64)readl(reg));
 > +}
 > +
 > +static inline void writeq(u64 val, void __iomem *reg)
 > +{
 > +	writel(val & 0xffffffff, reg);
 > +	writel(val >> 32, reg + 0x4UL);
 > +}
 > +#endif
 > +
 >  enum vnic_dev_intr_mode {
 >  	VNIC_DEV_INTR_MODE_UNKNOWN,
 >  	VNIC_DEV_INTR_MODE_INTX,
 > -- 
 > 1.5.6.5
 > 
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > 

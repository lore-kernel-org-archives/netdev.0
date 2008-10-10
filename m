From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 9 Oct 2008 21:27:55 -0700
Message-ID: <20081009212755.94fe11f6.akpm@linux-foundation.org>
References: <20081009211217.5f4e5f77.akpm@linux-foundation.org>
	<20081009.211552.20994950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38734 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbYJJE2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 00:28:10 -0400
In-Reply-To: <20081009.211552.20994950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Oct 2008 21:15:52 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 9 Oct 2008 21:12:17 -0700
> 
> > 
> > i386 allmodconfig, all trees applied:
> > 
> > drivers/net/enic/vnic_cq.c: In function 'vnic_cq_init':
> > drivers/net/enic/vnic_cq.c:65: error: implicit declaration of function 'writeq'
> > 
> > I can't immediately find an i386 implementation of writeq.
> 
> There isn't, because only a non-atomic implementation (two writew's)
> is possible.
> 
> So what ends up happening is that every driver that wants readq and
> writeq does this ifdef dance:
> 
> #ifndef readq
> static u64 readq(void __iomem *reg)
> {
> 	return (((u64)readl(reg + 0x4UL) << 32) |
> 		(u64)readl(reg));
> }
> 
> static void writeq(u64 val, void __iomem *reg)
> {
> 	writel(val & 0xffffffff, reg);
> 	writel(val >> 32, reg + 0x4UL);
> }
> #endif
> 
> basically stating that they explicitly understand that these are
> non-atomic and that the driver can handle it.
> 
> But this is completely stupid.  Instead of putting this in every driver
> we should put it in the 32-bit asm/io.h files and guard it with
> some ifdef test, on a macro that the driver can define.

Well OK.



We have a driver which has never been compileable on i386 which has
slipped through at least three sets of fingers only to land on the
usual guy's head.

Someone should write a book about this or something.

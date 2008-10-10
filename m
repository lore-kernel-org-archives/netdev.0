From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 09 Oct 2008 21:15:52 -0700 (PDT)
Message-ID: <20081009.211552.20994950.davem@davemloft.net>
References: <20081009211217.5f4e5f77.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751195AbYJJEQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 00:16:17 -0400
In-Reply-To: <20081009211217.5f4e5f77.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 9 Oct 2008 21:12:17 -0700

> 
> i386 allmodconfig, all trees applied:
> 
> drivers/net/enic/vnic_cq.c: In function 'vnic_cq_init':
> drivers/net/enic/vnic_cq.c:65: error: implicit declaration of function 'writeq'
> 
> I can't immediately find an i386 implementation of writeq.

There isn't, because only a non-atomic implementation (two writew's)
is possible.

So what ends up happening is that every driver that wants readq and
writeq does this ifdef dance:

#ifndef readq
static u64 readq(void __iomem *reg)
{
	return (((u64)readl(reg + 0x4UL) << 32) |
		(u64)readl(reg));
}

static void writeq(u64 val, void __iomem *reg)
{
	writel(val & 0xffffffff, reg);
	writel(val >> 32, reg + 0x4UL);
}
#endif

basically stating that they explicitly understand that these are
non-atomic and that the driver can handle it.

But this is completely stupid.  Instead of putting this in every driver
we should put it in the 32-bit asm/io.h files and guard it with
some ifdef test, on a macro that the driver can define.

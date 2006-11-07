From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Tue, 07 Nov 2006 11:17:39 +1100
Message-ID: <1162858659.28571.380.camel@localhost.localdomain>
References: <1162780109.28571.273.camel@localhost.localdomain>
	 <454EE943.6000603@pobox.com>
	 <1162800248.28571.296.camel@localhost.localdomain>
	 <454EF07B.4010503@pobox.com>
	 <1162803178.28571.300.camel@localhost.localdomain>
	 <454F0189.7050008@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47272 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1753876AbWKGAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 19:20:11 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <454F0189.7050008@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Generally the kernel code should write the two 32-bit chunks to the 
> memory-mapped region in order (low dword first), and let things take 
> care of themselves from there.
> 
> That's pretty much the implementation that -every- driver copies, when 
> they need readq/writeq to work on a 32-bit platform.

What do you mean by low dword first ? For example, the implementation
in the s2io driver does:

static inline u64 readq(void __iomem *addr)
{
	u64 ret = 0;
	ret = readl(addr + 4);
	ret <<= 32;
	ret |= readl(addr);

	return ret;
}

static inline void writeq(u64 val, void __iomem *addr)
{
	writel((u32) (val), addr);
	writel((u32) (val >> 32), (addr + 4));
}

As you can see, it reads the -second- dword first (high order dword in
little endian), but writes the first dword first (low order dword in
little endian).

If there is any logic here, it's card specific.

Or is this really what PCI does when doing 64 bits accesses on a 32 bits
PCI bus ? I would have expected the later (what write does) but this
driver does it reverse on reads.

I'm tempted to go to the simple

#define readq readq for now until we clear that up.
 
Ben.



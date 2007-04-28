From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Sun, 29 Apr 2007 02:24:28 +0900 (JST)
Message-ID: <20070429.022428.71103613.anemo@mba.ocn.ne.jp>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
	<463363ED.3050307@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:53000 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031565AbXD1RY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 13:24:27 -0400
In-Reply-To: <463363ED.3050307@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 11:10:37 -0400, Jeff Garzik <jeff@garzik.org> wrote:
> >  static unsigned int netcard_portlist[] __initdata = {
> > -	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
> > +#if defined(CONFIG_ISA) || defined(CONFIG_M32R)
> > +	0x300, 0x280, 0x320, 0x340, 0x360, 0x380,
> > +#endif
> > +	0
> 
> This looks a bit strange, and perhaps more difficult to maintain long term.
> 
> I would suggest creating a NEEDS_PORTLIST cpp macro at the top of ne.c, 
> to be defined or undefined based on CONFIG_xxx symbols.  Then, down in 
> the code itself, conditionally include or exclude all portlist related 
> data tables and code.
> 
> Sound sane?

Sure.  Do you mean something like this?


#if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
#define NEEDS_PORTLIST
#endif
...
#ifdef NEEDS_PORTLIST
static unsigned int netcard_portlist[] __initdata = {
	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
};
#endif
...
#ifdef NEEDS_PORTLIST
	int orig_irq = dev->irq;
#endif
...
#ifdef NEEDS_PORTLIST
	/* Last resort. The semi-risky ISA auto-probe. */
	for (base_addr = 0; netcard_portlist[base_addr] != 0; base_addr++) {
		int ioaddr = netcard_portlist[base_addr];
		dev->irq = orig_irq;
		if (ne_probe1(dev, ioaddr) == 0)
			return 0;
	}
#endif

---
Atsushi Nemoto

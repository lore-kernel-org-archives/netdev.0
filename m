From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] Add NAPI support to sungem.c
Date: Tue, 14 Sep 2004 13:52:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914135234.72465d1a.davem@davemloft.net>
References: <20040914153537.GE8434@sunbeam.de.gnumonks.org>
	<41471498.8010107@pobox.com>
	<20040914195052.GK8434@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040914195052.GK8434@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 21:50:52 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> Hi Jeff, thanks for your comments.
> 
> 
> On Tue, Sep 14, 2004 at 11:56:08AM -0400, Jeff Garzik wrote:
> > >+static inline void
> > >+gem_irq_acknowledge(struct gem *gp, unsigned int mask)
> > >+{
> > >+	writel(mask, gp->regs + GREG_IACK);
> > >+}
> > 
> > PCI posting
> 
> I'm not sure whether I need mb() or wmb() ? 

No, it's something else.

If you do something like, as one example:

	/* Chip resets require 40msec settle delay. */
	writel(FOO_RESET, regs + FOO);
	udelay(40);

It's not going to work properly because the writel() can
be delayed quite a long time, so you have to force the
writel() to completion somehow, the usual way is via:

	writel(FOO_RESET, regs + FOO);
	(void) readl(regs + FOO);
	udelay(40);

or similar.  The read back of the register forces the
write to complete on the PCI bus.

But be very careful and don't do the readl() readbacks too
much, especially in critical code paths, because they are
expensive as they cause a full round-trip to occur on the PCI
bus from the cpu.

Make sure you absolutely do need the read back.

Jeff, can you comment on why it is needed in this specific
case of writing the chip interrupt enabling?  I think it might
not be.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Fri, 22 May 2009 01:08:49 -0700 (PDT)
Message-ID: <20090522.010849.89655675.davem@davemloft.net>
References: <4A14285C.1040705@windriver.com>
	<20090521.151841.160383267.davem@davemloft.net>
	<4A15F466.70708@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: hong.pham@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbZEVIIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 04:08:51 -0400
In-Reply-To: <4A15F466.70708@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hong H. Pham" <hong.pham@windriver.com>
Date: Thu, 21 May 2009 20:40:06 -0400

> Posted below is a log with the fix.

Thank you.

> What's interesting (baffling?) is that interrupts are being received
> with the LD interrupt mask set or cleared.  The mask also changes
> in between interrupts.  The mask always changes from 3 to 0, and never
> from 0 to 3.

The "3 --> 0" transition is made by niu_poll_core() as we are
about to napi_complete() and rearm the LDG.

But yes this log doesn't make any sense.  Neither the masks
nor the ARM bit appear to be working.

I wonder if the spurious interrupts trigger exactly at the

		nw64(LD_IM0(LDN_RXDMA(rp->rx_channel)), 0);

in niu_poll_core().

Can you run one more test?  Supplement the debugging output
with:

	"%pS", get_irq_regs()->tpc

so we can see where the program counter is at the time of
the spurious interrupt?

Meanwhile, even if we go with your patch to fix this, we can't
use it as-is.  Let me explain.

Suppose that we get this spurious interrupt right after we unmask the
interrupt and right before napi_complete().  Your change will make us
re-mask the interrupts, but without scheduling NAPI.

So once the napi_complete() happens, if no further interrupts trigger
in that LDG, we'll never process those interrupt events cleared by
your new code.  See what I mean?

I don't know how to fix this, it's full of races.  I suppose we could
recheck if events are pending in the LDG after we do the
napi_complete() and reschedule NAPI again if so.  But that might be
expensive (several register reads, just to check something that's not
going to happen most of the time).

I'm also wondering why we see this on Niagara-2 and not on PCI-E
cards.  If the interrupts that go into the NCU unit of Niagara-2 are
levelled interrupts, and somehow the ARM bit is not implemented
correctly in the NIU logic when hooked up to NCU instead of PCI-E
logic, that could explain things.

I bet that our Linux driver is the only one that bangs on the LDG
mask registers like this.

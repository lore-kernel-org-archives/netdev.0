From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc2 3/3] tg3: Fix tg3_restart_ints()
Date: Thu, 5 May 2005 16:05:24 -0700
Message-ID: <20050505160524.4946082a.davem@davemloft.net>
References: <1114463061.4917.34.camel@rh4>
	<1114463351.4917.39.camel@rh4>
	<1114464194.4917.52.camel@rh4>
	<20050425151816.1910b2ba.davem@davemloft.net>
	<1114466185.4917.61.camel@rh4>
	<20050425162416.2b4edd43.davem@davemloft.net>
	<1114470490.4917.85.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1114470490.4917.85.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Apr 2005 16:08:10 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> I think removing the read back of intr. mailbox in tg3_interrupt() will
> have the following impact:
> 
> On machines where PIOs are posted by the chipset for a long time, the
> write to the intr. mailbox will not reach the 57xx chip for a long time.
> As a result, the interrupt signal INTA will remain asserted until the
> mailbox write is flushed to the 57xx chip. So this can cause
> tg3_interrupt() to be called multiple times until the INTA signal is de-
> asserted. I think at most it will be called 2 times since on the second
> time, the status block updated bit will not be set and we will read the
> PCI state register, causing the mailbox write to be flushed.
> 
> As you described, the netif_rx_schedule() will be called again the
> second time in tg3_interrupt() but it will do nothing.
> 
> So I think reading the intr. mailbox will help performance by
> eliminating multiple calls to tg3_interrupt() in the scenario I
> described, but is a rather high price to pay on other systems where PIOs
> are not posted for very long.

I think the second interrupt will not happen, here is why.

The platform specific code invokes the interrupt handler roughly
like so:

	local_irq_enable();
	ret = action->handler(irq, dev_id, regs);
	interrupt_controller->ack_irq(irq);

That ACK of the IRQ in the interrupt controller register
set will be STRONGLY ordered wrt. the tg3 mailbox register
write.

Therefore, the mailbox write would reach the tg3 chip, then
the IRQ would be ACK'd in the interrupt controller, in that
exact order.

There may be a tiny window, in the case where the interrupt
controller is processor-near and the PCI bus is far away, where
the IRQ unmask could occur before the tg3 register write reaches
the PCI bus.  But that would be 1) rare and 2) handled properly if
it did occur (as you described).

I therefore see no reason not to remove this register readback.

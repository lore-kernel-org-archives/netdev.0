From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.12-rc2 3/3] tg3: Fix tg3_restart_ints()
Date: Thu, 05 May 2005 15:51:14 -0700
Message-ID: <1115333474.15156.119.camel@rh4>
References: <1114463061.4917.34.camel@rh4>
 <1114463351.4917.39.camel@rh4> <1114464194.4917.52.camel@rh4>
 <20050425151816.1910b2ba.davem@davemloft.net>
 <1114466185.4917.61.camel@rh4>
 <20050425162416.2b4edd43.davem@davemloft.net>
 <1114470490.4917.85.camel@rh4>
 <20050505160524.4946082a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505160524.4946082a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-05-05 at 16:05 -0700, David S. Miller wrote:

> 
> I think the second interrupt will not happen, here is why.
> 
> The platform specific code invokes the interrupt handler roughly
> like so:
> 
> 	local_irq_enable();
> 	ret = action->handler(irq, dev_id, regs);
> 	interrupt_controller->ack_irq(irq);
> 
> That ACK of the IRQ in the interrupt controller register
> set will be STRONGLY ordered wrt. the tg3 mailbox register
> write.
> 

But no PCI cycles will necessarily be generated during the ack_irq()
call. The apic_write() call or the I/O cycles to the 8259 PIC or other
cycles to ack the interrupt controller are not PCI cycles and therefore
may not necessarily flush the tg3 mailbox write PCI cycle. There is no
spec that I'm aware of that requires posted cycles to be flushed when
INTx is asserted or the IRQ is acknowledged.

I am not arguing that the read-back should not be removed. I think most
systems will benefit from its removal. But there may be some systems
with long posted cycles that will be adversely (performance-wise)
affected by its removal.

BTW, when we use MSI, all these problems will disappear. The interrupt
will arrive in order and since MSI is equivalent to an edge interrupt,
it will not remain asserted like INTx and there is no need to flush the
interrupt mailbox.


> Therefore, the mailbox write would reach the tg3 chip, then
> the IRQ would be ACK'd in the interrupt controller, in that
> exact order.
> 
> There may be a tiny window, in the case where the interrupt
> controller is processor-near and the PCI bus is far away, where
> the IRQ unmask could occur before the tg3 register write reaches
> the PCI bus.  But that would be 1) rare and 2) handled properly if
> it did occur (as you described).

Agreed. It will be handled properly.

> 
> I therefore see no reason not to remove this register readback.
> 

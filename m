From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Fri, 29 Apr 2005 09:35:21 -0700
Message-ID: <20050429093521.274adf9a.davem@davemloft.net>
References: <E1DRFqC-00028H-Qi@tigger>
	<E1DRGWv-0003aa-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: markb@wetlettuce.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DRGWv-0003aa-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2005 07:26:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Mark Broadbent <markb@wetlettuce.com> wrote:
> > The interrupt handling code in the tulip network driver appears to use a non 
> > IRQ safe spinlock in an interrupt context.  The following patch should correct 
> > this.
> 
> This is bogus.  Interrupts are already disabled when you're in the
> interrupt handler.

Warning, guru area :-)

Look at most interrupt handlers in the kernel, they use
spin_lock_irqsave() rather consistently.  If an interrupt
is registered with SA_SHIRQ, this is a requirement.
Here is why.

On i386 (or any other platform using the generic IRQ layer),
for example, unless you specify SA_INTERRUPT at
request_irq() time, the handler dispatch is:

	local_irq_enable();

	for each irq registered {
		x->handler();
	}
	local_irq_disable();

(see kernel/irq/handle.c)

At the top level from that handle_IRQ_event() function, the
IRQ source is ACK'd after those calls.

However, if you have multiple devices on that IRQ line, you
run into a problem.  Let's say TUlip interrupts first and
we go into the Tulip driver and grab the lock, next the other
device interrupts and we jump into the Tulip interrupt handler
again, we will deadlock but what we should have done is use
IRQ disabling spin locking like Mark's fix does.

Therefore I think his patch is perfectly fine and this is an
excellent area for an audit of the entire tree.  I even just
noticed recently that some of the Sparc drivers/serial/
drivers were not taking the interrupt handler lock correctly like
this (ie. using irqsave).

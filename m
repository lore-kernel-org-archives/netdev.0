From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Sat, 30 Apr 2005 08:49:31 +1000
Message-ID: <20050429224931.GA18616@gondor.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: markb@wetlettuce.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050429093521.274adf9a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 09:35:21AM -0700, David S. Miller wrote:
> 
> On i386 (or any other platform using the generic IRQ layer),
> for example, unless you specify SA_INTERRUPT at
> request_irq() time, the handler dispatch is:
> 
> 	local_irq_enable();

Yes you're absolutely correct.
 
> However, if you have multiple devices on that IRQ line, you
> run into a problem.  Let's say TUlip interrupts first and
> we go into the Tulip driver and grab the lock, next the other
> device interrupts and we jump into the Tulip interrupt handler
> again, we will deadlock but what we should have done is use
> IRQ disabling spin locking like Mark's fix does.

However, I don't see how this can happen.  __do_IRQ ensures
that the handlers on a single IRQ aren't reentered by desc->lock
and desc->status.  Softirqs are also kept out by irq_enter.  Am
I missing something?

> Therefore I think his patch is perfectly fine and this is an
> excellent area for an audit of the entire tree.  I even just
> noticed recently that some of the Sparc drivers/serial/
> drivers were not taking the interrupt handler lock correctly like
> this (ie. using irqsave).

Unless these drivers are registering two different IRQ lines that
can nest within each other, I still think that a plain spin_lock is
safe and desirable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

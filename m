From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Fri, 29 Apr 2005 21:43:36 +0400
Message-ID: <20050429214336.04b40b3f.vsu@altlinux.ru>
References: <E1DRFqC-00028H-Qi@tigger>
	<E1DRGWv-0003aa-00@gondolin.me.apana.org.au>
	<20050429093521.274adf9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Fri__29_Apr_2005_21_43_36_+0400_bmbCVWLM_IbvmyL="
Cc: Herbert Xu <herbert@gondor.apana.org.au>, markb@wetlettuce.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050429093521.274adf9a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Signature=_Fri__29_Apr_2005_21_43_36_+0400_bmbCVWLM_IbvmyL=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 29 Apr 2005 09:35:21 -0700 David S. Miller wrote:

> Look at most interrupt handlers in the kernel, they use
> spin_lock_irqsave() rather consistently.  If an interrupt
> is registered with SA_SHIRQ, this is a requirement.
> Here is why.
> 
> On i386 (or any other platform using the generic IRQ layer),
> for example, unless you specify SA_INTERRUPT at
> request_irq() time, the handler dispatch is:
> 
> 	local_irq_enable();
> 
> 	for each irq registered {
> 		x->handler();
> 	}
> 	local_irq_disable();
> 
> (see kernel/irq/handle.c)
> 
> At the top level from that handle_IRQ_event() function, the
> IRQ source is ACK'd after those calls.
> 
> However, if you have multiple devices on that IRQ line, you
> run into a problem.  Let's say TUlip interrupts first and
> we go into the Tulip driver and grab the lock, next the other
> device interrupts and we jump into the Tulip interrupt handler
> again, we will deadlock but what we should have done is use
> IRQ disabling spin locking like Mark's fix does.

If what you wrote above is really correct, this means that
Documentation/DocBook/kernel-locking.sgml contains wrong information:

>>> The irq handler does not to use spin_lock_irq(), because the
>>> softirq cannot run while the irq handler is running: it can use
>>> spin_lock(), which is slightly faster. The only exception would
>>> be if a different hardware irq handler uses the same lock:
>>> spin_lock_irq() will stop that from interrupting us.

AFAIK, even if interrupts are enabled, the IRQ line which is currently
handled is disabled in the interrupt controller, therefore the
interrupt handler cannot be reentered (for the same device instance).
Did this really change?

--Signature=_Fri__29_Apr_2005_21_43_36_+0400_bmbCVWLM_IbvmyL=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCcnJKW82GfkQfsqIRAtEoAJ0XtN4RJmR4BYOZ23ZxqKIi1ln0pgCfTT5g
ZiGlc5l+Ti3PYRorPBYq6Xk=
=Ety4
-----END PGP SIGNATURE-----

--Signature=_Fri__29_Apr_2005_21_43_36_+0400_bmbCVWLM_IbvmyL=--

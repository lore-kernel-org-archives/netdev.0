From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Fri, 1 Jun 2007 10:34:10 +1000
Message-ID: <20070601003410.GA10330@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
	<20070531010814.GA30709@gondor.apana.org.au>
	<1180624569.23536.7.camel@athlon>
	<20070531221036.GA9644@gondor.apana.org.au>
	<1180651108.23536.35.camel@athlon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: Doug Chapman <doug.chapman@hp.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1180651108.23536.35.camel@athlon>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 06:38:28PM -0400, Doug Chapman wrote:
> 
> I get a backtrace as it probes each e1000 device and I also still get
> the unexpected interrupt message.
> 
> 
> WARNING: at drivers/net/e1000/e1000_main.c:1331 e1000_sw_init()

Thanks for testing!

Although I still don't know what caused the interrupt in your case,
it is clear that we need to be able to deal with interrupts as soon
as the handler is registered since the cause register is not affected
by e1000_irq_disable and a shared interrupt can easily be mistaken as
our own.

So Auke's solution of doing netif_poll_disable should fix this problem.

In looking at this I've found a couple of other problems:

1) Race between IRQ handler and e1000_open:

A shared/spurious interrupt can cause this:

CPU0				CPU1
e1000_open
	request_irq
				spurious/shared IRQ
				e1000_interrupt
	e1000_irq_enable
		atomic_dec_*
					atomic_inc
					IMC <- ~0
		IMS <- MASK

So we end up with IRQs enabled when they shouldn't be.

2) Race between IRQ handler and e1000_clean (and other mgmt functions):

Again shared/spurious interrupts may cause problems:

CPU0				CPU1
e1000_clean
	do work
				spurious/shared IRQ
				e1000_interrupt
					clear ICR
					netif_rx_schedule_prep fails
					e1000_irq_enable
	netif_rx_complete
	e1000_irq_enable

At this point IRQs are on but we've lost an interrupt.

We can fix this by

1) Ignoring IRQs when irq_sem > 0.
2) Always generate an IRQ after e1000_irq_enable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

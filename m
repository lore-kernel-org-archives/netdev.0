From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Wed, 1 Oct 2003 01:19:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F0B1@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, <akpm@osdl.org>, <netdev@oss.sgi.com>,
        "cramerj" <cramerj@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Why do you even need to use IRQ locking here?
> 
> Your e1000 netdev->hard_start_xmit method doesn't need to do 
> anything special, why does this timer code?  I suppose you 
> need to synchronize with e1000_clean_tx_irq() in the non-NAPI 
> case right?  If so, that's not being accomplished by what 
> your code is doing.  If nobody else takes that xmit_lock in 
> an IRQ disabling manner, the e1000 timer code doing so 
> doesn't make any difference.
> 
> I have an idea for attacking the problem, once you figure out 
> what kind of locking you really need.  Do whatever you need 
> to do to synchronize on the hardware side, but instead of 
> directly freeing the SKB, add each one to a list.  A pointer 
> to the head of this list is stored on the stack of the timer 
> routine, and passed down into the TX purger.
> 
> Then at the top level you can drop all your locks, re-enable 
> hw IRQs and whatever else you need to do, then pass the SKBs 
> in the list off to dev_kfree_skb_irq() (this is the 
> appropriate routine to call to free an SKB from a timer 
> handler, which runs in soft interrupt context).

Chris can jump in here anytime.  :-)

Synchronizing on the hardware side is stumping me.  We have the list of
skbs you describe, but I'm concerned about unmapping the skb buffers if
hardware is right in the middle of some DMA  on one of the buffers.
Some archs really don't like hardware accessing unmapped buffers.

Here's what I'm thinking: when link down is detected in the timer, just
trick hardware into thinking link is still up (ILOS - Invert Loss of
Signal).  No locking, no disabling of interrupts.  Hardware will do the
natural thing by completing the outstanding sends and also provide the
interrupts so we can clean/return skbs as normal (e1000_clean_tx_irq).
Something like:

<timer>
	if lost link
		if outstanding Tx work
			set ILOS		// h/w thinks link is
up, DMA continues
			mdelay(10)
			clear ILOS		// h/w thinks link is
down
			
The mdelay(10) is terrible, but we've already got that in the current
tx_flush routine.

Chris, what am I missing?  I didn't included the ANE business for
clarity.

-scott

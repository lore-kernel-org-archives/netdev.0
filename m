From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [BUG 2.6.0-test11] pcnet32 oops
Date: Tue, 9 Dec 2003 15:15:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209151459.A1345@sygehus.dk>
References: <20031205234510.GA2319@bougret.hpl.hp.com> <20031205165900.2920ea6a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, linux-kernel@vger.kernel.org,
        tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031205165900.2920ea6a.davem@redhat.com>; from davem@redhat.com on Fri, Dec 05, 2003 at 04:59:00PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 04:59:00PM -0800, David S. Miller wrote:
> This is the classic case of doing disabling/enabling of software
> interrupts with hardware interrupts disabled, which is a bug.
> 
> In this case pcnet32_set_multicast_list() is disabling hardware
> interrupts, and the packet freeing of pcnet32_purge_tx_ring()
> is what leads to the software interrupt disable/enable.

I think the root cause of this problem is that pcnet32_set_multicast_list()
dumps the entire TX ring on the floor (as a side effect of calling
pcnet32_restart()). I don't think dev->set_multicast_list() is supposed to
do that.

> However, I'm inclined to believe that we should change dev_kfree_skb_any()
> to fix this class of problems, by making it check for hardware interrupts
> being disabled as well as being in an interrupt.

I've been wondering about this too with the recent netpoll patches. Many
(including pcnet32) implement the poll controller simply as

	disable_irq (dev->irq);
	driver_interrupt_handler (dev->irq, dev, NULL);
	enable_irq (dev->irq);

If the interrupt handler calls dev_kfree_skb_any(), could you then run into
this kind of problem? Or is it just if you call spin_lock_irq*() that you
have a problem?

-- 
Regards,
Rask Ingemann Lambertsen

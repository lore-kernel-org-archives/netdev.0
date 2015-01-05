From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Mon, 5 Jan 2015 15:31:26 +0100
Message-ID: <20150105143126.GA22122@kria>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
 <20141209.214433.7463087833083181.davem@davemloft.net>
 <20141211214537.GA4159@kria>
 <alpine.DEB.2.11.1412122242180.16494@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	peterz@infradead.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:56890 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbbAEObd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 09:31:33 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412122242180.16494@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-12-12, 23:01:28 +0100, Thomas Gleixner wrote:
> On Thu, 11 Dec 2014, Sabrina Dubroca wrote:
> > 2014-12-09, 21:44:33 -0500, David Miller wrote:
> > > 
> > > Adding a new spinlock to every interrupt service routine is
> > > simply a non-starter.
> > > 
> > > You will certainly have to find a way to fix this in a way
> > > that doesn't involve adding any new overhead to the normal
> > > operational paths of these drivers.
> > 
> > Okay. Here is another idea.
> > 
> > Since the issue is with the wait_event() part of synchronize_irq(),
> > and it only takes care of threaded handlers, maybe we could try not
> > waiting for threaded handlers.
> > 
> > Introduce disable_irq_nosleep() that returns true if it successfully
> > synchronized against all handlers (there was no threaded handler
> > running), false if it left some threads running.  And in
> > ->ndo_poll_controller, only call the interrupt handler if
> > synchronization was successful.
> > 
> > Both users of the poll controllers retry their action (alloc/xmit an
> > skb) several times, with calls to the device's poll controller between
> > attempts.  And hopefully, if the first attempt fails, we will still
> > manage to get through?
> 
> Hopefully is not a good starting point. Is the poll controller
> definitely retrying? Otherwise you might end up with the following:
> 
> Interrupt line is shared between your network device and a
> device which requested a threaded interrupt handler.
> 
>   CPU0	       		   	    CPU1
>   interrupt()
>     your_device_handler()
>       return NONE;
>     shared_device_handler()
>       return WAKE_THREAD;
>       --> atomic_inc(threads_active);
> 				    poll()
> 				      disable_irq_nosleep()
> 					sync_hardirq()
> 					return atomic_read(threads_active);
> 
> So if you do not have a reliable retry then you might just go into a
> stale state. And this can happen if the interrupt type is edge because
> we do not disable the interrupt when we wakeup the thread for obvious
> reasons.

We do have loops retrying to run the netpoll controller, and trying to
do the work even if the controller doesn't help.  And by hopefully I
mean: even if we fail, we tried our best and netpoll isn't 100%
reliable.


static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
{
	...
repeat:

	skb = alloc_skb(len, GFP_ATOMIC);
	if (!skb)
		skb = skb_dequeue(&skb_pool);

	if (!skb) {
		if (++count < 10) {
			netpoll_poll_dev(np->dev);
			goto repeat;
		}
		return NULL;
	}

	...
}

void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
			     struct net_device *dev)
{
	...

		/* try until next clock tick */
		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
		     tries > 0; --tries) {
			if (HARD_TX_TRYLOCK(dev, txq)) {
				if (!netif_xmit_stopped(txq))
					status = netpoll_start_xmit(skb, dev, txq);

				HARD_TX_UNLOCK(dev, txq);

				if (status == NETDEV_TX_OK)
					break;

			}

			/* tickle device maybe there is some cleanup */
			netpoll_poll_dev(np->dev);

			udelay(USEC_PER_POLL);
		}

	...
}



> Aside of that I think that something like this is a reasonable
> approach to the problem.
> 
> The only other nitpicks I have are:
> 
>     - The name of the function sucks, though my tired braain can't
>       come up with something reasonable right now

I couldn't think of anything better.  Maybe 'disable_irq_trysync' or
'disable_irq_hardsync'?

Or maybe you prefer something that works like spin_trylock, and
reenables the irq before returning if we can't sync?  Maybe the risk
of abuse would be a bit lower this way?

I made synchronize_irq_nosleep static, but maybe it should be
EXPORT_SYMBOL'ed as well.  I didn't need that for e1000, but that
would be more consistent.


>     - The lack of extensive documentation how this interface is
>       supposed to be used and the pitfals of abusage, both in the
>       function documentation and the changelog.
> 
>       Merlily copying the existing documentation of the other
>       interface is not sufficient.


Yes, my email wasn't really a changelog, just a description and RFC.


Modified documentation:

-----
disable_irq_nosleep - disable an irq and wait for completion of hard IRQ handlers
@irq: Interrupt to disable

Disable the selected interrupt line.  Enables and Disables are
nested.
This function does not sleep, and is safe to call in atomic context.

This function waits for any pending hard IRQ handlers for this
interrupt to complete before returning. If you use this
function while holding a resource the IRQ handler may need you
will deadlock.

This function does not wait for threaded IRQ handlers.
Returns true if synchronized, false if there are threaded
handlers pending.

If false is returned, the caller must assume that synchronization
didn't occur, and that it is NOT safe to proceed.
The caller MUST reenable the interrupt by calling enable_irq in all
cases.

This function may be called - with care - from IRQ context.
-----


Thanks.

--
Sabrina

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Proper suspend/resume flow
Date: Sat, 29 Mar 2014 18:03:47 +0000
Message-ID: <20140329180347.GW7528@n2100.arm.linux.org.uk>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk> <1396111046.2898.88.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:42615 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752257AbaC2SEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 14:04:11 -0400
Content-Disposition: inline
In-Reply-To: <1396111046.2898.88.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2014 at 04:37:26PM +0000, Ben Hutchings wrote:
> My advice here is based on Solarflare's extensive stress-testing of the
> sfc driver control path and the race conditions it uncovered.  It did
> not cover suspend/resume, but it does cover MTU and ring size changes
> which involve the same sort of stop/start while the device is still
> marked as running.

Thanks for your reply.

> - Given the way the watchdog works, I think netif_device_detach() must
> be called first if you are going to stop TX queues in a control
> operation other than ndo_stop (commits e4abce853849, 29c69a488264).
> 
> - The driver must check netif_device_present() before calling
> netif_wake_queue().  Perhaps netif_wake_queue() itself should check
> that, if many drivers need to do it.

I don't think that's sufficient.  Unless I'm missing something, I think
the situation below is possible:

Thread0					Thread1
					netif_device_present()
					- test_bit(__LINK_STATE_PRESENT)
netif_device_detach
- test_and_clear_bit(__LINK_STATE_PRESENT)
- netif_running(dev)
- netif_tx_stop_all_queues
  - netif_tx_stop_queue
    - set_bit(__QUEUE_STATE_DRV_XOFF)
					netif_wake_queue()
					- netif_tx_wake_queue()
					  - test_and_clear_bit(__QUEUE_STATE_DRV_XOFF)
					    - __netif_schedule()
					      - test_and_set_bit(__QDISC_STATE_SCHED)
					        - __netif_reschedule()
					          - sd->output_queue_tailp = &q->next_sched
						    - raise_softirq_irqoff(NET_TX_SOFTIRQ)
					...
					net_tx_action()
					qdisc_run()
					- qdisc_run_begin()
					- __qdisc_run()
					  - qdisc_restart()
					    - sch_direct_xmit()
					      - netif_xmit_frozen_or_stopped()
					        - ops->ndo_start_xmit()

In other words, it's possible for the driver's ndo_start_xmit() method
to be called after netif_device_detach() is called due to a call to
netif_wake_queue() - even if netif_device_present() is first checked.

> - Calls to netif_device_detach() may need to be synchronised with the TX
> scheduler (commits c2f3b8e3a44b, 35205b211c8d).  To support this, the
> function efx_device_detach_sync() maybe should be turned into a general
> netif_device_detach_sync() (and then possibly needs to disable IRQs).

Given the above (I don't see anything that checks to see whether the
device is present in the path from netif_wake_queue() through to calling
the device's ndo_start_xmit() function), I think you're right.  I also
think "if (netif_device_present()) netif_wake_queue();" needs to also be
done under the xmit lock, or the same lock which protects the call to
netif_device_detach() to prevent the above occuring.

However, I have a voice in the back of my mind which sounds like Alan Cox
saying "don't lock code, lock data" :p

I also think you're right about calling netif_stop_queue() or
netif_tx_disable() from contexts other than the xmit function or the
ndo_stop() method.  It's safe in ndo_stop() because netif_running()
will be false at that point, which disables the watchdog.

Calling it at other moments is potentially dangerous as a watchdog poll
(which happens every dev->watchdog_timeo) could occur while the queue
is temporarily disabled, and if it has been more than watchdog_timeo
after the last packet was queued, we'll get an instant watchdog warning.

That said, for the case where a network driver does all it's packet
processing in the NAPI poll function, I think calling napi_disable()
is a good way to ensure that the poll function is not running, and
therefore there are can be no netif_wake_queue() calls - or anything
other than the ndo_start_xmit touching the rings or the device.  This
is needed anyway to stop receive packet processing looking at its
ring.

So, I've now come to this sequence:

suspend()
{
	if (netif_running()) {
		napi_disable();
		netif_tx_lock();
		netif_device_detach();
		netif_tx_unlock();
	}
	... suspend device ...
}

resume()
{
	... resume device ...
	if (netif_running()) {
		netif_device_attach();
		napi_enable();
	}
}

as the way to safely suspend packet processing while suspended.  For
reconfiguration purposes (where hopefully the reconfiguration part
doesn't need to schedule), I think:

	... prepare for reconfiguration (eg, allocate new rings)
	napi_disable();
	netif_tx_lock();

	... reconfigure, swap state, etc ...

	netif_tx_unlock();
	napi_enable();

is sufficient to temporarily suspend packet processing.

I can see another re-work of my Freescale FEC patchset being required.

I'm also debating about rtnl_lock() in some places where netif_running()
is checked - it seems to me that checking netif_running() without holding
the rtnl_lock() is unsafe.  That said, the suspend paths should be single
threaded, so there should be no chance of the device coming up or down.
Even so, I see some drivers do use rtnl_lock() in their suspend/resume
paths.

However, FEC defers the transmit timeout processing to work queue context,
and doesn't take any locks:

        if (fep->delay_work.timeout) {
                fep->delay_work.timeout = false;
                fec_restart(fep->netdev, fep->full_duplex);
                netif_wake_queue(fep->netdev);
	}

Internally fec_restart() has:

	if (netif_running(ndev)) {
		netif_device_detach(ndev);
		napi_disable(&fep->napi);
		netif_stop_queue(ndev);
		netif_tx_lock_bh(ndev);
	}
	... restart processing including a udelay() ...
	if (netif_running(ndev)) {
		netif_tx_unlock_bh(ndev);
		netif_wake_queue(ndev);
		napi_enable(&fep->napi);
		netif_device_attach(ndev);
	}

and it means that netif_running() could change state in the middle of
this sequence.  Putting rtnl_lock() around that stops netif_running()
changing state, but it feels like a very big sledge hammer.  However,
with the rest of my changes to this driver, I may be able to get rid
of that work queue entirely, moving the restart entirely under the
ndo_tx_timeout() call.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

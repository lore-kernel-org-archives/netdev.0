From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 21:25:13 -0700 (PDT)
Message-ID: <20140812.212513.96441522917129709.davem@davemloft.net>
References: <20140812143531.GJ2404@oracle.com>
	<20140812.151352.2235795686370279748.davem@davemloft.net>
	<20140813015817.GA13600@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaHMEZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 00:25:16 -0400
In-Reply-To: <20140813015817.GA13600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 12 Aug 2014 21:58:17 -0400

>> 
>> Please do not usurp vnet_tx_timeout() to handle queue waking.
>> 
>> It is hooked up to netdev_ops->ndo_tx_timeout() which is invoked when
>> the qdisc watchdog triggers after dev->watchdog_timeout time elapses
>> after the queue is stopped without a subsequent wake.
>> 
>> This method is a therefore executed after a hard timeout, meaning that
>> the device should probably be reset, whereas maybe_tx_wakeup() is
>> normal processing meant to drive the engine of TX flow control.
>> 
>> In the context of sunvnet, vnet_tx_timeout() should probably reset the
>> LDC channel(s) of the unresponsive peer(s).
> 
> yes, after a couple of days of reflection on the lingering issues in
> http://www.spinics.net/lists/sparclinux/msg12360.html
> I too was starting to arrive at  similar conclusions about 
> maybe_tx_wakeup vs vnet_tx_timeout.

However, don't get ahead of yourself.  All I'm saying in the context
of reviewing this patch #3 is that you should leave vnet_tx_timeout()
alone and just put what you were putting into vnet_tx_timeout() into
maybe_tx_wakeup().

> First case 2 in the "todo" list (cannot send DRING_STOPPED):
> If we cannot send a vnet_send_ack() we should invoke ldc_disconnect() 
> for this peer.  The ldc_disconnect() will reset hs_state and flags 
> in the ldc_channel, so subsequent attempts to ldc_write() 
> (e.g., from vio_ldc_send()) will return -ENOTCONN. So, for
> that case, a subsequent vnet_start_xmit() would *not* netif_stop_queue(),
> but just drop the packet, reset the dring, and keep driving.
> 
> To recover the disconnected channel, the admin would need to (ldm) 
> unbind/bind the offender, identifiable by their mac address.
> And none of the other channels shold be affected (assuming
> inter-vnet-links is set to on)

This doesn't match my understanding.   My understanding is that when
an LDC connection resets, the peer on the other side should automatically
try to re-bind or whatever is necessary to re-establish the LDC link.

It's supposed to be fault tolerant in as many situations as possible
without the need for explicit adminstrator intervention.

But besides that, an LDC reset is a big hammer.  So I would say that it
should be deferred to the last possible point.

So initially we do the backoff spinning loop synchronously.  If that
doesn't succeed, we schedule a workqueue that can poll the LDC channel
some more trying to do the write, in a sleepable context (so a loop
with delays and preemption points) until a much larger timeout.  Only
at this second timeout do we declare things to be serious enough for
an LDC channel reset.

> So for case 1 we could do something very similar- I haven't tried this yet,
> but here's what I'm thinking: vnet_start_xmit() should not do a
> netif_stop_queue.  Instead it should do a (new function) "vio_stop_queue()"
> which sets some (new) VIO_DR_FLOW_CONTROLLED  state in the vio_driver_state, 
> (or perhaps some flag bit in the ldc_channel?) and also marks a 
> (new) boolean is_flow_controlled state variable in the struct vnet 
> as TRUE.
> 
> The modified maybe_tx_wakeup would check is_flow_controlled on the vnet,
> and call a new vnet_wake_queue() to reset VIO_DR_FLOW_CONTROLLED
> if appropriate.
> 
> vnet_start_xmit should drop packets as long as VIO_DR_FLOW_CONTROLLED
> is set.

Again, as I stated yesterday, you really cannot do this.  Head of line
blocking when one peer gets wedged is absolutely necessary.

If a packet for a blocked peer is pending, you have to make the other
guys wait until either the blocked peer gets unstuck or you reset
the blocked peer's LDC channel on a hard timeout.

> I dont know if there is a way to leverage that path and still avoid
> the head-of-line blocking due to one flow-controlled ldc_channel.

Again, I don't think the semantics resulting from head-of-line
blocking avoidance are acceptable.

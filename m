From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Wed, 13 Aug 2014 07:20:10 -0400
Message-ID: <20140813112010.GC16865@oracle.com>
References: <20140812143531.GJ2404@oracle.com>
 <20140812.151352.2235795686370279748.davem@davemloft.net>
 <20140813015817.GA13600@oracle.com>
 <20140812.212513.96441522917129709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33896 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaHMLUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:20:15 -0400
Content-Disposition: inline
In-Reply-To: <20140812.212513.96441522917129709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (08/12/14 21:25), David Miller wrote:
> 
> However, don't get ahead of yourself.  All I'm saying in the context
> of reviewing this patch #3 is that you should leave vnet_tx_timeout()
> alone and just put what you were putting into vnet_tx_timeout() into
> maybe_tx_wakeup().

And just leave vnet_tx_timeout() as before (i.e, "XXX implement me"?)?

Sure, I can generate that (as a stand-alone unified-diff patch?) 
it would be the minimum fix needed to avoid the deadlock on 
netif_tx_lock() itself.

> This doesn't match my understanding.   My understanding is that when
> an LDC connection resets, the peer on the other side should automatically
> try to re-bind or whatever is necessary to re-establish the LDC link.
> 
> It's supposed to be fault tolerant in as many situations as possible
> without the need for explicit adminstrator intervention.

Ideally, yes. But that's not what I was observing when I tested this.

> But besides that, an LDC reset is a big hammer.  So I would say that it
> should be deferred to the last possible point.

Correct, and that's why it feels ok (to me) to do this when the
DRING_STOPPED fails (so that we also fail subsequent ldc_write's
from vnet_start_xmit()) but not in any other case.

Note that, as I pointed out to Raghuram already, doing ldc_disconnect
does *not* send any reset events. The code may have other missing
functionality. 

> So initially we do the backoff spinning loop synchronously.  If that
> doesn't succeed, we schedule a workqueue that can poll the LDC channel
> some more trying to do the write, in a sleepable context (so a loop
> with delays and preemption points) until a much larger timeout.  Only
> at this second timeout do we declare things to be serious enough for
> an LDC channel reset.
> 
> > So for case 1 we could do something very similar- I haven't tried this yet,
> > but here's what I'm thinking: vnet_start_xmit() should not do a
> > netif_stop_queue.  Instead it should do a (new function) "vio_stop_queue()"
> > which sets some (new) VIO_DR_FLOW_CONTROLLED  state in the vio_driver_state, 
> > (or perhaps some flag bit in the ldc_channel?) and also marks a 
> > (new) boolean is_flow_controlled state variable in the struct vnet 
> > as TRUE.
> > 
> > The modified maybe_tx_wakeup would check is_flow_controlled on the vnet,
> > and call a new vnet_wake_queue() to reset VIO_DR_FLOW_CONTROLLED
> > if appropriate.
> > 
> > vnet_start_xmit should drop packets as long as VIO_DR_FLOW_CONTROLLED
> > is set.
> 
> Again, as I stated yesterday, you really cannot do this.  Head of line
> blocking when one peer gets wedged is absolutely necessary.

In the light of the subsequent discussion about head-of-line blocking
(and it's applicability per ldc_channel, instead of per-net_device),
do we still think the above has issues, or is otherwise not worth
doing?

Further in the thread, David Miller wrote:

> So the question is how to manage this on the driver side, and the most
> natural way I see do this would be to use multiple TX netdev queues
> and a custom netdev_ops->ndo_select_queue() method which selects the
> queue based upon the peer that would be selected.

This might work well for the current sunvnet model (and even
there, it has limitations- if all the traffic is going out 
via the switchport to a gateway, you are again back to the 
head-of-line blocking model).

But how generally useful is this model? For point-to-multipoint links
like ethernet, I dont think you actually track one channel per
peer.  

--Sowmini

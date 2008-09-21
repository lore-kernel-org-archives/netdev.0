From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Sat, 20 Sep 2008 22:35:38 -0700 (PDT)
Message-ID: <20080920.223538.130375517.davem@davemloft.net>
References: <20080914202715.GA2540@ami.dom.local>
	<20080920.002137.108837580.davem@davemloft.net>
	<20080920234843.GA2531@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750886AbYIUFfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 01:35:50 -0400
In-Reply-To: <20080920234843.GA2531@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 21 Sep 2008 01:48:43 +0200

> On Sat, Sep 20, 2008 at 12:21:37AM -0700, David Miller wrote:
> ...
> > Let's look at what actually matters for cpu utilization.  These
> > __qdisc_run() things are invoked in two situations where we might
> > block on the hw queue being stopped:
> > 
> > 1) When feeding packets into the qdisc in dev_queue_xmit().
 ...
> > 2) When waking up a queue.  And here we should schedule the qdisc_run
> >    _unconditionally_.
 ...
> > The cpu utilization savings exist for case #1 only, and we can
> > implement the bypass logic _perfectly_ as described above.
> > 
> > For #2 there is nothing to check, just do it and see what comes
> > out of the qdisc.
> 
> Right, unless __netif_schedule() wasn't done when waking up. I've
> thought about this because of another thread/patch around this
> problem, and got misled by dev_requeue_skb() scheduling. Now, I think
> this could be the main reason for this high load. Anyway, if we want
> to skip this check for #2 I think something like the patch below is
> needed.

Hmmm, looking at your patch....

It's only doing something new when the driver returns NETDEV_TX_BUSY
from ->hard_start_xmit().

That _never_ happens in any sane driver.  That case is for buggy
devices that do not maintain their TX queue state properly.  And
in fact it's a case for which I advocate we just drop the packet
instead of requeueing.  :-)

Oh I see, you're concerned about that cases where qdisc_restart() ends
up using the default initialization of the 'ret' variable.

Really, for the case where the driver actually returns NETDEV_TX_BUSY
we _do_ want to unconditionally __netif_schedule(), since the device
doesn't maintain it's queue state in the normal way.

Therefore it seems logical that what really needs to happen is that
we simply pick some new local special token value for 'ret' so that
we can handle that case.  "-1" would probably work fine.

So I'm dropping your patch.

I also think the qdisc_run() test needs to be there.  When the TX
queue fills up, we will doing tons of completely useless work going:

1) ->dequeue
2) qdisc unlock
3) TXQ lock
4) test state
5) TXQ unlock
6) qdisc lock
7) ->requeue

for EVERY SINGLE packet that is generated towards that device.

That has to be expensive, and I am still very much convinced that
this was the original regression cause that made me put that TXQ
state test back into qdisc_run().

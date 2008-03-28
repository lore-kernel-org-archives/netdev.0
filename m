From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 17:34:18 -0700 (PDT)
Message-ID: <20080327.173418.18777696.davem@davemloft.net>
References: <47EC3182.7080005@sun.com>
	<20080327.170235.53674739.davem@davemloft.net>
	<47EC399E.90804@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	hadi@cyberus.ca
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752984AbYC1AeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:34:19 -0400
In-Reply-To: <47EC399E.90804@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 27 Mar 2008 17:19:42 -0700

> Actually I am running a version of the nxge driver which uses only one 
> TX ring, no LLTX enabled so the driver does single threaded TX.

Ok.

> On the other hand, uperf (or iperf, netperf ) is running multiple TX
> connections in parallel and the connections are bound on multiple
> processors, hence they are running in parallel.

Yes, this is what I was interested in.

I think I know what's wrong.

If one cpu gets into the "qdisc remove, give to device" loop, other
cpus will simply add to the qdisc and that first cpu will do the all
of the TX processing.

This helps performance, but in your case it is clear that if the
device is fast enough and there are enough other cpus generating TX
traffic, it is quite trivial to get a cpu wedged there and never exit.

The code in question is net/sched/sch_generic.c:__qdisc_run(), it just
loops there until the device TX fills up or there are no more packets
in the qdisc queue.

qdisc_run() (in include/linux/pkt_sched.h) sets
__LINK_STATE_QDISC_RUNNING to tell other cpus that there is a cpu
processing the queue inside of __qdisc_run().

net/core/dev.c:dev_queue_xmit() then goes:

	if (q->enqueue) {
		/* Grab device queue */
		spin_lock(&dev->queue_lock);
		q = dev->qdisc;
		if (q->enqueue) {
			/* reset queue_mapping to zero */
			skb_set_queue_mapping(skb, 0);
			rc = q->enqueue(skb, q);
			qdisc_run(dev);
			spin_unlock(&dev->queue_lock);

			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
			goto out;
		}
		spin_unlock(&dev->queue_lock);
	}

The first cpu will get into __qdisc_run(), but the other
ones will just q->enqueue() and exit since the first cpu
has indicated it is processing the qdisc.

I'm not sure how we should fix this at the moment, we want
to keep the behavior but on the other hand we need to
break out of this so we don't get stuck here for too long.

From: David Miller <davem@davemloft.net>
Subject: Re: The proper way of delaying tx in a driver
Date: Wed, 23 Jul 2008 01:11:34 -0700 (PDT)
Message-ID: <20080723.011134.256015233.davem@davemloft.net>
References: <1216795043.11027.311.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750709AbYGWILe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 04:11:34 -0400
In-Reply-To: <1216795043.11027.311.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 23 Jul 2008 16:37:23 +1000

> Drivers like tg3 seem to be at least -somewhat- careful, and only do
> those things when netif_running(). However, unless I missed something,
> this is true from just before the driver open() is called, that is, too
> early for closing the race.
> 
> So the question is, what is the proper approach ?
> 
> I'm happy to help fixing tg3, sungem and emac at least as I'm somewhat
> familiar with those 3 drivers once we decide what is the right sequence
> of operations here.

The other problematic case is netif_device_attach(), which many
drivers use for resume.  It triggers the same WARN_ON() case as
well.

I'm going to attack this as follows:

1) Make running netif_schedule() on the builtin' qdiscs such
   as noop_qdisc and noqueue_qdisc a NOP and not WARN any more.

2) Come up with a "netif_freeze_tx()" or similar to give these
   drivers what they want.

The truth is that neither netif_stop_queue() nor netif_carrier_off()
stop ->hard_start_xmit() execution immediately.

Taking the TX lock(s) and doing netif_stop_queue() comes close, but
it is also not a full solution.

netif_stop_queue() just sets a bit, but a cpu could already be in
the ->hard_start_xmit() handler.

netif_carrier_off() defers the qdisc reset it does into the link_watch
work queue, so it's effect is not immediate either.

To me the most effective queue stopper would be a sequence of three
operations:

1) Set netdev_queue->qdisc to &noop_qdisc

2) Lock the previous qdisc and call ->reset() on it

3) Grab and release TX lock

That guarentees nobody is inside of ->hard_start_xmit() and that
no future packets are pending for the device.

At least for non-LLTX driver.  For LLTX ones, oh well, too bad, they
have to find their own ways to ensure such things.  It's deprecated
for a reason :)


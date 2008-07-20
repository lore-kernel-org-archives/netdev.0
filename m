From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Sun, 20 Jul 2008 16:59:11 -0700 (PDT)
Message-ID: <20080720.165911.86437240.davem@davemloft.net>
References: <1216566963.4847.81.camel@localhost>
	<20080720.102534.246150854.davem@davemloft.net>
	<1216593170.4847.137.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754000AbYGTX7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 19:59:11 -0400
In-Reply-To: <1216593170.4847.137.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 20 Jul 2008 18:32:50 -0400

> pfifo_fast would be a bad choice in that case, but even a pfifo cannot
> guarantee proper RR because it would present packets in a FIFO order
> (and example the first 10 could go to hardware queue1 and the next to
> hardware queue2).

Jamal, I have to wonder why are you so hung up on matching our
software qdiscs with whatever fairness algorithm the hardware happens
to implement internally for the TX queues?

Every time this topic comes up, you insist on them having to match.
And I have no idea why.

It's largely irrelevant and the TX queue can be viewed purely as a
buffer between us and the device, nearly a black hole we stick packets
into.

> > These things are built for parallelization, not prioritization.
> 
> Total parallelization happens in the ideal case. If X cpus classify
> packets going to X different hardware queueus each CPU grabs only locks
> for that hardware queue.

The problem is that the bottleneck is the qdisc itself since all those
cpus synchonize on it's lock.  We can't have a shared qdisc for the
device and get full parallelization.

That's why we're having one qdisc per TX queue, so that they all don't
bunch up on the qdisc lock.

Otherwise, there is zero point in all of these TX multiqueue features
in the hardware if we can't parallelize things fully.


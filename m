From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Sat, 30 Jun 2007 16:33:26 +0200
Message-ID: <468669B6.7000504@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>	<46840AF5.4020209@trash.net> <20070628.212032.108743475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36242 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758252AbXF3Odb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 10:33:31 -0400
In-Reply-To: <20070628.212032.108743475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Now I get to pose a problem for everyone, prove to me how useful
> this new code is by showing me how it can be used to solve a
> reocurring problem in virtualized network drivers of which I've
> had to code one up recently, see my most recent blog entry at:
> 
> 	http://vger.kernel.org/~davem/cgi-bin/blog.cgi/index.html
> 
> Anyways the gist of the issue is (and this happens for Sun LDOMS
> networking, lguest, IBM iSeries, etc.) that we have a single
> virtualized network device.  There is a "port" to the control
> node (which switches packets to the real network for the guest)
> and one "port" to each of the other guests.
> 
> Each guest gets a unique MAC address.  There is a queue per-port
> that can fill up.
> 
> What all the drivers like this do right now is stop the queue if
> any of the per-port queues fill up, and that's why my sunvnet
> driver does right now as well.  We can only thus wakeup the
> queue when all of the ports have some space.
> 
> The ports (and thus the queues) are selected by destination
> MAC address.  Each port has a remote MAC address, if there
> is an exact match with a port's remote MAC we'd use that port
> and thus that port's queue.  If there is no exact match
> (some other node on the real network, broadcast, multicast,
> etc.) we want to use the control node's port and port queue.
> 
> So the problem to solve is to make a way for drivers to do the queue
> selection before the generic queueing layer starts to try and push
> things to the driver.  Perhaps a classifier in the driver or similar.


That sounds like the only reasonable possibility if you really
do want to use queues. Another possibility would be to not use
a queue and make the hole thing unreliable and treat full rx
rings of the guests as "loss on the wire". Not sure if that makes
any sense.

I was thinking about adding a way for (multiqueue) drivers to use
other default qdiscs than pfifo_fast so they can default to a
multiband prio or something else that makes sense for them ..
maybe a dev->qdisc_setup hook that is invoked from dev_activate.
They would need to be able to add a default classifier for this
to have any effect (the grand plan is to get rid of the horrible
wme scheduler). Specialized classifiers like your dst MAC classifier
and maybe even WME should then probably be built into the driver and
don't register with the API, so they don't become globally visible.

> The solution to this problem generalizes to the other facility
> we want now, hashing the transmit queue by smp_processor_id()
> or similar.  With that in place we can look at doing the TX locking
> per-queue too as is hinted at by the comments above the per-queue
> structure in the current net-2.6.23 tree.


It would be great if we could finally get a working e1000 multiqueue
patch so work in this area can actually be tested.


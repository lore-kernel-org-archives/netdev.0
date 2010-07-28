From: Simon Horman <horms@verge.net.au>
Subject: Re: noqueue on bonding devices
Date: Thu, 29 Jul 2010 08:42:36 +0900
Message-ID: <20100728234236.GB4868@verge.net.au>
References: <20100728083217.GB20227@verge.net.au>
 <16360.1280338676@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41525 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab0G1Xmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 19:42:40 -0400
Content-Disposition: inline
In-Reply-To: <16360.1280338676@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 10:37:56AM -0700, Jay Vosburgh wrote:
> Simon Horman <horms@verge.net.au> wrote:
> 
> >Hi Jay, Hi All,
> >
> >I would just to wonder out loud if it is intentional that bonding
> >devices default to noqueue, whereas for instance ethernet devices
> >default to a pfifo_fast with qlen 1000.
> 
> 	Yes, it is.
> 
> >The reason that I ask, is that when setting up some bandwidth
> >control using tc I encountered some strange behaviour which
> >I eventually tracked down to the queue-length of the qdiscs being 1p -
> >inherited from noqueue, as opposed to 1000p which would occur
> >on an ethernet device.
> >
> >Its trivial to work around, by either altering the txqueuelen on
> >the bonding device before adding the qdisc or by manually setting
> >the qlen of the qdisc. But it did take us a while to determine the
> >cause of the problem we were seeing. And as it seems inconsistent
> >I'm interested to know why this is the case.
> 
> 	Software-only virtual devices (loopback, bonding, bridge, vlan,
> etc) typically have no transmit queue because, well, the device does no
> queueing.  Meaning that there is no flow control infrastructure in the
> software device; bonding, et al, won't ever flow control (call
> netif_stop_queue to temporarily suspend transmit) or accumulate packets
> on a transmit queue.
> 
> 	Hardware ethernet devices set a queue length because it is
> meaningful for them to do so.  When their hardware transmit ring fills
> up, they will assert flow control, and stop accepting new packets for
> transmit.  Packets then accumulate in the software transmit queue, and
> when the device unblocks, those packets are ready to go.  When under
> continuous load, hardware network devices typically free up ring entries
> in blocks (not one at a time), so the software transmit queue helps to
> smooth out the chunkiness of the hardware driver's processing, minimize
> dropped packets, etc.
> 
> 	It's certainly possible to add a queue and qdisc to a bonding
> device, and is reasonable to do if you want to do packet scheduling with
> tc and friends.  In this case, the queue is really just for the tc
> actions to connect to; the queue won't accumulate packets on account of
> the driver (but could if the scheduler, e.g., rate limits).

Thanks for the detailed explanation, much appreciated.

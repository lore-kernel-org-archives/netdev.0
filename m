From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: noqueue on bonding devices
Date: Wed, 28 Jul 2010 10:37:56 -0700
Message-ID: <16360.1280338676@death>
References: <20100728083217.GB20227@verge.net.au>
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36155 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab0G1RiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 13:38:00 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6SHWKBj022981
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 13:32:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6SHbwFV1613868
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 13:37:58 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6SHbwZo025228
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 14:37:58 -0300
In-reply-to: <20100728083217.GB20227@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman <horms@verge.net.au> wrote:

>Hi Jay, Hi All,
>
>I would just to wonder out loud if it is intentional that bonding
>devices default to noqueue, whereas for instance ethernet devices
>default to a pfifo_fast with qlen 1000.

	Yes, it is.

>The reason that I ask, is that when setting up some bandwidth
>control using tc I encountered some strange behaviour which
>I eventually tracked down to the queue-length of the qdiscs being 1p -
>inherited from noqueue, as opposed to 1000p which would occur
>on an ethernet device.
>
>Its trivial to work around, by either altering the txqueuelen on
>the bonding device before adding the qdisc or by manually setting
>the qlen of the qdisc. But it did take us a while to determine the
>cause of the problem we were seeing. And as it seems inconsistent
>I'm interested to know why this is the case.

	Software-only virtual devices (loopback, bonding, bridge, vlan,
etc) typically have no transmit queue because, well, the device does no
queueing.  Meaning that there is no flow control infrastructure in the
software device; bonding, et al, won't ever flow control (call
netif_stop_queue to temporarily suspend transmit) or accumulate packets
on a transmit queue.

	Hardware ethernet devices set a queue length because it is
meaningful for them to do so.  When their hardware transmit ring fills
up, they will assert flow control, and stop accepting new packets for
transmit.  Packets then accumulate in the software transmit queue, and
when the device unblocks, those packets are ready to go.  When under
continuous load, hardware network devices typically free up ring entries
in blocks (not one at a time), so the software transmit queue helps to
smooth out the chunkiness of the hardware driver's processing, minimize
dropped packets, etc.

	It's certainly possible to add a queue and qdisc to a bonding
device, and is reasonable to do if you want to do packet scheduling with
tc and friends.  In this case, the queue is really just for the tc
actions to connect to; the queue won't accumulate packets on account of
the driver (but could if the scheduler, e.g., rate limits).

>On an unrelated note, MAINTANERS lists bonding-devel@lists.sourceforge.net
>but the (recent) archives seem to be entirely spam.  Is the MAINTAINERS
>file correct?

	Yah, I should probably change that; the spam is pretty heavy,
and there isn't much I can do to limit it.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

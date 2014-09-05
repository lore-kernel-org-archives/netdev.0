From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Fri, 5 Sep 2014 09:47:58 -0400
Message-ID: <20140905134758.GB1256@oracle.com>
References: <20140902162029.GC31516@oracle.com>
 <5405EFE7.4090302@oracle.com>
 <20140904.223648.559995846094457545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david.stevens@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20977 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757069AbaIENsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:48:03 -0400
Content-Disposition: inline
In-Reply-To: <20140904.223648.559995846094457545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/04/14 22:36), David Miller wrote:
> 
> The memory barrier exists in order to make sure the cookies et al. are
> globally visible before the VIO_DESC_READY.  We don't want stores to
> be reordered such that the VIO_DESC_READY is seen too early.

Ok, though David (dls) was just pointing out that a rmb() might
be missing in vnet_walk_rx_one() before checking for READY descriptor

> I'm having a hard time imagining that putting the wmb() afterwards
> would help, except by adding a new delay in a different place.

correct.

> I say that because the TX trigger is going to make a hypervisor call,
> and I bet that hypervisor trap syncs the store buffer of invoking cpu
> thread.
> 
> Thinking further, another issue to consider is that the wmb() might no
> be necessary considering all of the above, because the remote entity
> should not look at this descriptor until the tx trigger occurs.

So, today the consumer already reads a series of descriptors based on
a single LDC start trigger already in vnet_walk_rx() - it doesnt
actually wait for an LDC "start" per descriptor.

Which is as it should be- the first "start" trigger of a burst 
is just an async signal from producer to consumer that data is ready 
for consumption.

A wmb() (and maybe a missing rmb()) should itself synchronize the critical
state more efficiently than an ldc exchange. The last bit
about VIO_DESC_READY may get flushed at some later point, and
the delay in patch 2/2 slightly helps work around that fudge factor,
but moving the wmb() before/after the VIO_DESC_READY (in my testing)
doesn't really make a difference to correctness - the consumer first
checks for VIO_DESC_READY, and by that time, the rest of the cookie
info should have been correctly sync'ed by the memory barrier.

If we get the memory-barriers right,
the trigger-per-vnet_start_xmit is superfluous, and only 
serves to flood the ldc_channel (and make the env ripe for
!tx_has_space_for()).

(And a side-effect of this is that avoids severl other udelay() loops
that we'd have otherwise undergone as part of __vnet_tx_trigger(),
which is also a healthy thing to avoid)

> Anyways, if the hypervisor trap to signal the tx trigger does not
> flush the local cpu thread's store buffer, then yes moving the memory
> barrier might make sense.

As such, it's expensive and unnecessary to cripple ourselves down to
one LDC exchange per descriptor - the wmb() itself should ensure this
correctly in a cheaper way.

BTW, even if you set the READY state before (not after) the wmb() 
there's still a small iperf-boost to be obtained by lingering
around in vnet_walk_rx() (as in patch 2/2)- that boost is from avoiding
what would otherwise be a ldc stop/start exchange between consumer
and producer. 

But I'm not too attached to this boost (aka patch 2/2)- 
benchmark-special code is always ugly.

--Sowmini

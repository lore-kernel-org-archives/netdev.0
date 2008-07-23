From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC] napi: adding an administrative state & priority
Date: Wed, 23 Jul 2008 15:27:13 -0400
Message-ID: <20080723192548.GA14654@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jgarzik@pobox.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4154 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbYGWT1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 15:27:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at our napi code recently, and two ideas struck me that I thought
would be nice to integrate into the napi infrastructure, but I thought I gather
some opinions on them before I went to the trouble to implement them:

1) An administrative state for napi, specifically administratively disabled
state, on a per-interface basis.  When napi was administratively disabled the
interface would behave as though napi had never been configured on it.  I.E.
netif_rx_schedule would call directly into dev->poll with a budget of 1, so as
to behave like a legacy interrupt handler.   setting of this administrative
state can be handled through sysfs

2) A priority value attached to napi_struct.  Much in the same way that a napi
instances weight constrains how much work will be done by a driver in a given
napi poll, a priority can be assigned to a napi_struct such that its selection
in net_rx_action will be prioritized over other interfaces.  Like above, we can
handle the assignment of priorities on a per napi instance basis through sysfs.

My reasoning for these features is common in that I've had occasion to observe
some workloads where incomming data that is highly sensitive to loss and
latency, gets lost near the hardware.  Most often this happens because the
latency from the time of interrupt to the time of serving in dev->poll is
sufficient to overrun a hardware buffer, or the devices ring buffer.  While ring
buffers can be extended, I'm personally loathe to simply try out run the problem
by adding ring-buffer space.  It would be nice if we had a way to drain the
overrunning queue faster, rather than just making it longer.

I think this is also an adventageous set of ideas, in that it would allow us to
make better use of interrupt coalescing features on the hardware.  Currently
changing interrupt coalescing on the hardware can effectively reduce or increase
the interrupt volume seen from a given NIC in a system.  Its performance impact
is clouded however since the interrupt is deferred until such time as the napi
poll routine is run, which could be some time, dependent on what else is going
on in the system.  While reasons to do this might be suspect in some situations,
I think it would be helpful to have a way to disable napi on an interface so
effects of hardware adjustments can be more clearly seen

So, there are my thoughts, please feel free to pick them to shreds.

Thanks & Regards
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/

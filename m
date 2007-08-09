From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Thu, 09 Aug 2007 09:58:58 -0700
Message-ID: <adamyx0od9p.fsf@cisco.com>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
	<1186587154.5155.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <xma@us.ibm.com>, David Miller <davem@davemloft.net>,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:60444 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965664AbXHIQ7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 12:59:04 -0400
In-Reply-To: <1186587154.5155.43.camel@localhost> (jamal's message of "Wed, 08 Aug 2007 11:32:34 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Dave, could you please hold this portion of the patch for a moment. I
 > > will test this patch ASAP. According to our previous experience, this
 > > changes significant changes some IPoIB driver performance.

 > If you adjust your quantum while doing that testing you may find an
 > optimal value. 

 > Think of a box where you have other network interfaces, the way you
 > are implementing currently implies you are going to be very unfair to 
 > the other interfaces on the box. 

Could you explain why this is unfair?  This is an honest question: I'm
not trying to be difficult, I just don't see how this implementation
leads to unfairness.  If a driver uses *less* than its full budget in
the poll routine, requests that the poll routine be rescheduled and
then returns, it seems to me that the effect on other interfaces would
be to give them more than their fair share of NAPI processing time.

Also, perhaps it would be a good idea to explain exactly what the
ipoib driver is doing in its NAPI poll routine.  The difficultly is
that the IB "interrupt" semantics are not a perfect fit for NAPI -- in
effect, IB just gives us an edge-triggered one-shot interrupt, and so
there is an unadvoidable race between detecting that there is no more
work to do and enabling the interrupt.  It's not worth going into the
details of why things are this way, but IB can return a hint that says
"you may have missed an event" when enabling the interrupt, which can
be used to close the race.  So the two implementations being discussed
are roughly:

	if (may_have_missed_event &&
	    netif_rx_reschedule(napi))
		goto poll_more;

versus

	if (may_have_missed_event) {
		netif_rx_reschedule(napi))
		return done;
	}

The second one seems to perform better because in the missed event
case, it gives a few more packets a chance to arrive so that we can
amortize the polling overhead a little more.  To be honest, I've never
been able to come up with a good story of why the IBM hardware where
this makes a measurable difference hits the missed event case enough
for it to matter.

The other thing that confuses me about why this is a fairness issue is
that if this were a driver where the missed event race didn't happen,
when we detected no more work to do, we would just do:

	netif_rx_complete(napi);
	enable_hw_interrupts();
	return done;

and if a packet arrived between netif_rx_complete and enabling
interrupts, we would still get an interrupt and so the effect would be
to reschedule polling, just via a more inefficient route (going
through the HW interrupt handler).

So clarification on this point would be appreciated -- not because I
want to continue an argument, but just to improve my understanding of NAPI.

 - Roland

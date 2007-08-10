From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Fri, 10 Aug 2007 09:55:07 -0400
Message-ID: <1186754107.5188.32.camel@localhost>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
	 <1186587154.5155.43.camel@localhost>  <adamyx0od9p.fsf@cisco.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <xma@us.ibm.com>, David Miller <davem@davemloft.net>,
	jgarzik@pobox.com, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:55424 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937471AbXHJNzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 09:55:13 -0400
Received: by wr-out-0506.google.com with SMTP id 36so55820wra
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 06:55:12 -0700 (PDT)
In-Reply-To: <adamyx0od9p.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-08 at 09:58 -0700, Roland Dreier wrote:

> Could you explain why this is unfair?  

The simple answer is the core attempts DRR scheduling (search for the
paper by Varghese et al for more details)
If you have multiple users of a resource (network interfaces in this
case), then the quantum defines their weight. If you use more than your
fair quota, then you are being unfair. 

> This is an honest question: I'm
> not trying to be difficult, I just don't see how this implementation
> leads to unfairness.  If a driver uses *less* than its full budget in
> the poll routine, requests that the poll routine be rescheduled and
> then returns, it seems to me that the effect on other interfaces would
> be to give them more than their fair share of NAPI processing time.

Yes, thats what the "deficit" part of DRR does; however, you still will
be unfair by utilizing larger quanta. 

> Also, perhaps it would be a good idea to explain exactly what the
> ipoib driver is doing in its NAPI poll routine.  The difficultly is
> that the IB "interrupt" semantics are not a perfect fit for NAPI -- in
> effect, IB just gives us an edge-triggered one-shot interrupt, and so
> there is an unadvoidable race between detecting that there is no more
> work to do and enabling the interrupt.  It's not worth going into the
> details of why things are this way, 

Talk to your vendor (your hardware guys in your case ;->) next time to
fix their chip.
The best scheme is to allow a Clear-on-write only on the specific
bit/event.

> but IB can return a hint that says
> "you may have missed an event" when enabling the interrupt, which can
> be used to close the race.  

Certainly helps. Is this IB specific or hardware specific?

> So the two implementations being discussed
> are roughly:
> 
> 	if (may_have_missed_event &&
> 	    netif_rx_reschedule(napi))
> 		goto poll_more;
> 
> versus
> 
> 	if (may_have_missed_event) {
> 		netif_rx_reschedule(napi))
> 		return done;
> 	}
> 
> The second one seems to perform better because in the missed event
> case, it gives a few more packets a chance to arrive so that we can
> amortize the polling overhead a little more.

Theory makes sense. Have you validated?

>   To be honest, I've never
> been able to come up with a good story of why the IBM hardware where
> this makes a measurable difference hits the missed event case enough
> for it to matter.

Someone needs to prove one of the schemes is better. Regardless, either
scheme seems to me to be viable as long as you dont violate your
quantum.


cheers,
jamal


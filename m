From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Mon, 13 Aug 2007 14:47:31 -0700
Message-ID: <ada7inz85u4.fsf@cisco.com>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
	<1186587154.5155.43.camel@localhost> <adamyx0od9p.fsf@cisco.com>
	<1186754107.5188.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <xma@us.ibm.com>, David Miller <davem@davemloft.net>,
	jgarzik@pobox.com, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:45517 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758256AbXHMVrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 17:47:37 -0400
In-Reply-To: <1186754107.5188.32.camel@localhost> (jamal's message of "Fri, 10 Aug 2007 09:55:07 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Could you explain why this is unfair?  
 > 
 > The simple answer is the core attempts DRR scheduling (search for the
 > paper by Varghese et al for more details)
 > If you have multiple users of a resource (network interfaces in this
 > case), then the quantum defines their weight. If you use more than your
 > fair quota, then you are being unfair. 

OK, I think we were talking past each other.  As you noted later, the
current behavior *is* fair, since it uses less than the full quota.
What I couldn't understand was why everyone was telling me that using
*less* than a full quota was unfair -- and now I think we all agree
that it is fair.

 > Talk to your vendor (your hardware guys in your case ;->) next time
 > to fix their chip.  The best scheme is to allow a Clear-on-write
 > only on the specific bit/event.

Actually it is more of an IB spec issue than a hardware issue.  IPoIB
is really more of a protocol than a hardware driver in many ways; one
analogy would be PPP, which runs on various serial drivers ranging
from an analog modem to cellular data cards using USB serial to PPPoE.

The primitives for event handling that the IB spec defines are such
that this NAPI event handling gap is unavoidable.  But in fact a lot
of IB adapter hardware has somewhat better event handling so that the
gap never occurs.  We take advantage of this by having the "request
event" operation simply be hard-coded never to return the missed event
hint on hardware where we know the missed event is impossible by
design.  However IPoIB has to run on all IB hardware so we can only
assume the least-common-denominator behavior, which means we have to
have the missed event handling for the hardware where it does apply.

 > > The second one seems to perform better because in the missed event
 > > case, it gives a few more packets a chance to arrive so that we can
 > > amortize the polling overhead a little more.
 > 
 > Theory makes sense. Have you validated?

Yes, IBM (the people with the adapter hardware where this path
triggers) did benchmarking and report that allowing the work to pile
up makes a huge performance difference.  In fact it is kind of
suspicious that the difference is huge -- I wouldn't expect the missed
event path to be common enough to make that much of a difference, but
for some reason it is.

 - R.

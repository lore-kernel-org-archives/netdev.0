From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 11:12:45 -0400
Message-ID: <1181661165.4067.31.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>
	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>
	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>
	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>
	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net>
	 <1181597718.4071.12.camel@localhost>  <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>  <466E9DF2.9010505@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:62876 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529AbXFLPMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 11:12:48 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1820145wxc
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 08:12:48 -0700 (PDT)
In-Reply-To: <466E9DF2.9010505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-12-06 at 15:21 +0200, Patrick McHardy wrote:
> jamal wrote:

> 
> 
> Yes. Using a higher threshold reduces the overhead, but leads to
> lower priority packets getting out even if higher priority packets
> are present in the qdisc. 

As per earlier discussion, the packets already given to hardware should
be fine to go out first. If they get overriden by the chance arrival of
higher prio packets from the stack, then that is fine.

> Note that if we use the threshold with
> multiple queue states (threshold per ring) this doesn't happen.

I think if you do the math, youll find that (n - 1) * m is actually
not that unreasonable given parameters typically used on the drivers;
Lets for example take the parameters from e1000; the tx ring is around
256, the wake threshold is 32 packets (although i have found a better
number is 1/2 the tx size and have that changed in my batching patches).

Assume such a driver with above parameters doing Gige exists and it
implements 4 queus (n = 4); in such a case, (n-1)*m/32 is
3*256/32 = 3*8 = 24 times.

You have to admit your use case is a real corner case but lets be
conservative since we are doing a worst case scenario and from that
perspective consider that gige can be achieved at pkt levels of 86Kpps
to 1.48Mpps and if you are non-work conserving you will be running at
that rate and lets pick the low end of 86Kpps - what that means is there
is a blip (remember again this to be a corner case) for a few microsecs
once in a while with probability of what you described actually
occuring... 
Ok, so then update the threshold to 1/2 the tx ring etc and it is even
less. You get the message.

> If both driver and HW do it, its probably OK for short term, but it
> shouldn't grow too large since short-term fairness is also important.
> But the unnecessary dequeues+requeues can still happen.

In a corner case, yes there is a probability that will happen.
I think its extremely low.

> 
> It does have finite time, but its still undesirable. The average case
> would probably have been more interesting, but its also harder :)
> I also expect to see lots of requeues under "normal" load that doesn't
> ressemble the worst-case, but only tests can confirm that.
> 

And that is what i was asking of Peter. Some testing. Clearly the
subqueueing is more complex; what i am asking for is for the driver
to bear the brunt and not for it to be an impacting architectural
change.

> > I am not sure i understood - but note that i have asked for a middle
> > ground from the begining. 
> 
> 
> I just mean that we could rip the patches out at any point again
> without user visible impact aside from more overhead. So even
> if they turn out to be a mistake its easily correctable.

That is a good compromise i think. The reason i am spending my time
discussing this is i believe this to be a very important subsystem.
You know i have been voiceferous for years on this topic.
What i was worried about is these patches make it and become engrained
with hot lava on stone.

> I've also looked into moving all multiqueue specific handling to
> the top-level qdisc out of sch_generic, unfortunately that leads
> to races unless all subqueue state operations takes dev->qdisc_lock.
> Besides the overhead I think it would lead to ABBA deadlocks.

I  am confident you can handle that.

> So how do we move forward?

What you described above is a good compromise IMO. I dont have much time
to chase this path at the moment but what it does is give me freedom to
revisit later on with data points. More importantly you understand my
view;-> And of course you did throw a lot of rocks but it
a definete alternative ;->

cheers,
jamal



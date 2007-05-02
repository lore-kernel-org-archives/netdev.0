From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Wed, 02 May 2007 08:43:49 -0400
Message-ID: <1178109829.4074.48.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902C3DC46@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:6089 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993093AbXEBMny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 08:43:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so104570wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 05:43:53 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902C3DC46@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-05 at 16:04 -0700, Waskiewicz Jr, Peter P wrote:

I am just gonna delete stuff you had above here because i think you 
repeat those thoughts below. Just add back anything missed.
I will try to make this email shorter, but i am not sure i will
succeed;->

> > 1) You want to change the core code; i dont see a need for that.
> > The packet is received by the driver and netif stop works as 
> > before, with zero changes; the driver shuts down on the first 
> > ring full.
> > The only work is mostly driver specific.
> 
> To me, this doesn't buy you anything to do multiqueue only in the
> driver. 

Lets come up with some terminology; lets call multiqueue what the 
qdiscs do; lets call what the NICs do multi-ring.
Note, i have thus far said you need to have both and they must be
in sync.

> I agree the driver needs work to manage the queues in the
> hardware, but if a single feeder from the kernel is handing it
> packets, you gain nothing in my opinion without granularity of
> stopping/starting each queue in the kernel.
> 
This maybe _the_ main difference we have in opinion.
Like i said earlier, I used to hold the same thoughts you do.
And i think you should challenge my assertion that it doesnt
matter if you have a single entry point; 
[my assumptions are back in what i called #b and #c].

> The changes to PRIO are an initial example of getting my multiqueue
> approach working.  This is the only qdisc I see being a logical change
> for multiqueue; other qdiscs can certainly be added in the future,
> which
> I plan on once multiqueue device support is in the kernel in some
> form.

Fair enough, I looked at:
http://internap.dl.sourceforge.net/sourceforge/e1000/OpenSDM_8257x-10.pdf
and it seems to be implementing WRR (the M and N parameters in the count
field).
WRR doesnt exist in Linux - for no good reason really; theres a gent who
promised to submit some clean code for it but hasnt been heard of since;
you can find some really old code i wrote here:
http://www.cyberus.ca/~hadi/patches/prio-drr.kernel.patch.gz

If you clean that up as a linux qdisc, then other NICs can use it.
In your approach, that would only be usable by NICs with multi-rings
that implement WRR.

> > 3) For me: It is a driver change mostly. A new qdisc may be 
> > needed - but thats about it. 
> 
> I guess this is a fundamental difference in our thinking.  I think of
> multiqueue as the multiple paths out of the kernel, being managed by
> per-queue states.  

Yes, you are right; i think this is where we differ the most.
You feel the need to keep all the rings busy even when one is shutdown;
I claim by having a synced up qdisc of the same scheduler type you dont
need to worry about that. 
Both approaches are correct; what iam proposing is many factors simpler.

> If that is the case, the core code has to be changed at some level,
> specifically in dev_queue_xmit(), so it can check the state of the
> subqueue your skb has been associated with
> (skb->queue_mapping in my patchset).  The qdisc needs to comprehend
> how to classify the skb (using TOS or TC) and assign the queue on the
> NIC to transmit on.
> 
Indeed, something like that would be needed; but it could also be a
simple scheme like netdev->pick_ring(skb->prio) or something along those
lines once the drivers hardware transmit is invoked - and therefore you
move it away from main core. This way you only have the multi-ring
drivers doing the checks.
[Note: there is hardware i have seen which use IEEE semantics of what
priority means (essentialy 802.1p); which happens to be the reverse of
what IETF thinks of it (DSCP/TOS view); so proper mapping is nessary]

> My question to you is this: can you explain the benefit of 
> not allowing the kernel to know of and be able to manage the 
> queues on the NIC?  This seems to be the heart of our disagreement; 

For correctness it is not necessary to use all rings at the same time;
this is not to say if you do that (as you did) is wrong, both schemes
are correct.
To answer your question: For me it is for the sake of a simplicity i.e
being less intrusive and making it transparent to both writers of qdiscs
as well as users of those qdiscs. Simplicity is always better if there
was no trumping difference. Simplicity can never trump correctness. i.e
It would be totaly wrong if i am going to put a packet in coach
class when it paid for business class and vice-versa for the sake of a
simple scheme. But that is not gonna happen with either of those two
approaches.
The added side-benefit is if you followed what i described, you can then
get that WRR working for e1000 and other NICs as well. This in itself is
a big advantage.

> I  view the ability to manage
> these queues from the kernel as being true multiqueue, and view doing
> the queue management solely in the driver as something that doesn't
> give any benefit.

Let me a bit long winded ...
"benefit" should map to correctness; both yours and mine are correct. 
To my approach, managing the hardware rings is cosmetics (doesnt add any
value).
If by "management" you mean a config/control point of view, then you can
tie the qdisc to the multiq driver at config time. i.e when configuring
the qdisc onto a specific driver. I am not against that, i just refered
to it as a peripheral issue.
e.g the qdisc asks the driver "can i setup a WRR of two queues with
weights 3 for queue0 and weight 4 for queue1?" driver looks at its
capability and if there are no capability matches, it rejects.

My problem with your approach is from a datapath view.

It should be easy to demonstrate experimentally that the s/ware qdisc
framework in Linux is so good such that there is no difference in the
achieved qos when using the e1000 between:
 
1) 2 queues at the qdisc level with scheduler WRR + a single hware ring
(which is standard setup in Linux) 
2) no queueing at qdisc level + 2 hware rings implementing scheduler WRR
3) 2 queues at the qdisc level with scheduler WRR + X hware rings
implementing scheduler WRR

We havent talked about wireless - but lets get over the wired world
first.
> 
>  Hopefully we can
> come to an agreement of some sort soon, since this work has been going
> on for some time to be halted after quite a bit of engineering and
> community feedback.
> 
Again, I am sorry for coming in late - I have good reasons.

Note: I am not pulling these ideas out of a hat. I have implemented what
i described and didnt need to make any changes to the core (i never did
the capability check, but talking to you that seems to be a good idea).

cheers,
jamal


From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 01 May 2007 18:11:58 -0400
Message-ID: <1178057518.4078.41.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902C0DB88@orsmsx414.amr.corp.intel.com>
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
Received: from wx-out-0506.google.com ([66.249.82.236]:47556 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946026AbXEAWME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 18:12:04 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1950627wxd
        for <netdev@vger.kernel.org>; Tue, 01 May 2007 15:12:03 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902C0DB88@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-05 at 11:27 -0700, Waskiewicz Jr, Peter P wrote: 

> My patches have been under discussion for
> a few months, and the general approach has been fairly well-accepted.
> The comments that David, Patrick, and Thomas have given were more on
> implementation, which have been fixed and are what you see today.  
> So if you don't like my approach, then please provide an alternative.

I have provided you an alternative - maybe it is unclear and in which
case i will be willing to explain again. 
It really doesnt matter if i look at the patch. 
Unless you are challenging my knowledge of that subsystem,
I am not gonna comment on the semantics of you missing a comma or space 
somewhere because my disagreements are on your conceptual approach; it is 
therefore irrelvant to me that 10 other people have given you comments on 
your code. 
I am not questioning your (probably) great coding skills. I have provided 
you an alternative if you try to listen. An alternative that doesnt
require big changes that you are making or break the assumed layering
we have. 

> Please explain why this is a brute force approach.  Today, netdev gives
> drivers an API to manage the device queue (dev->queue_lock).  I extended
> this to provide a management API to manage each queue on a device.  This
> to me makes complete sense; why hide the fact a device has multiple
> queues from the kernel?  I don't understand your comments here.

What i meant by brute force was you could move all the management into
the driver. For example, you could put additional software queues in
the driver that hold things that dont fit into rings. I said this
was better because nothing is touched in the core code.
An API to me is a function call; the device queue managemnt is the tx
state transition.
If this is still not clear, just ignore it because it is a distraction.
The real core is further below.

> E1000 is not strict prio scheduling, rather, it is round-robin.  This
> question was posed by Patrick McHardy on netdev and I answered it 2
> weeks ago.

RR would fit just fine as well in what i described.
I gave prio qdisc as an example because you were modifying it and
because it covers the majority of the devices i have seen out there that
implement multi-queueing.
As i said further, what i described can be extended to any scheduling
algorithm: strict prio, WRR etc. 
I just want you to understand what i am describing; and if you 
want i can show you how it would work for a scheduler of your choice.

> > I am making the assumptions that: 
> > a) you understand the basics of strict prio scheduling
> > b) You have configured strict prio in the qdisc level and the 
> > hardware levels to be synced i.e if your hardware is capable 
> > of only strict prio, then you better use a matching strict 
> > prio qdisc (and not another qdisc like HTB etc). If your 
> > hardware is capable 2 queues, you better have your qdisc with 
> > only two bands.
> 
> I disagree.  If you read Patrick's comments, using strict PRIO in
> software and in hardware will probably give you results you don't want.

That was based on how your patches work. It is also
why you would need to say "multiqueue" in the tc config.

> Why do 2 layers of QoS? 

Look at it this way:
Linux already has the necessary qdiscs; if there is
one or two missing, writing it will solve your problem.
This way both single-hw-queue and multi-hw-queue hardware benefit
from any new qdisc.
I dont need a speacilized qdisc just because i have multiqueue
hardware.
More importantly, you dont need to make core code changes.
You may need to add a new qdisc if it doesnt exist; but you can do that
without mucking with the core code. It is clean.

> If your hardware has a hardware-based QoS, 
> then you should have a generic round-robin (unassuming) qdisc above 
> it.  

If your hardware has RR scheduling, then you better be fair in feeding
that scheduler packets in a RR fashion otherwise bad things would
happen. Thats the basis of #b. I probably misunderstood
your wording, you seem to be saying the opposite.

> I
> don't understand why you would ever want to do 2 layers of
> prioritization; this is just unnecessary work for the CPU to be doing.
> And if you see how my patches to PRIO are working, you'd see that it
> allows a user to choose as many bands as he/she wants, and they will be
> assigned to the underlying hardware queues.  This is very similar to the
> mapping that the 802.1p spec calls out for how to map many priorities to
> fewer queues.

No big deal:
It is what the prio qdisc has been doing since the dinosaur days;


> > c) If you programmed a TOS, DSCP , IEEE 802.1p to go to qdisc 
> > queue PH via some classifier, then you will make sure that 
> > packets from qdisc PH end up in hardware queue PH.
> > 
> > Not following #b and #c means it is a misconfiguration; i 
> > hope we can agree on that. i.e you need to have both the 
> > exact qdisc that maps to your hardware qdisc as well as 
> > synced configuration between the two layers.
> 
> Please see my comments above.  Restricting any configuration of a
> scheduler like this to a user is undesirable; if a user wants to
> configure something that could shoot themselves in the foot, then that
> should be their problem.
> 

I actually agree with the user being shot in the foot when they
misconfigure. Sometimes that is a better design choice. Configuring
that you are using a strict priority scheduling when in reality
you are using a RR scheduler is shooting yourself in the foot.
The syncing of the upper layer qdisc and the hardware capability could
be resolved easily if the driver can be queuried.
You could stop the user from shooting themselves when they configure
the wrong qdisc on ethx by querying the driver first before accepting
the config. But all that is small details IMO.

> How do packets keep getting transmitted from the qdisc in this 
> example? 
> As soon as the hardware-tx path is shut down in your example
> (netif_stop_queue() is called on the netdev, shutting down the device
> queue), no packets will flow into qdisc_run():
> 
....
... 
> If that queue is stopped, the qdisc will never get called to run and
> ->dequeue(), and hard_start_xmit() will never be called. 

yes, that is true (and the desired intent)

>  So in your
> example, if your PL-ring fills up, you're going to shut down the entry
> point for your PH to the driver.  As soon as you do this, multiqueue is
> still single-queue.  

This goes to my assumption #a - i.e that you understand how strict prio
works:
In strict prio, the qdisc will never give the driver a packet
that is low prio if there was even one that is high prio. So the only
way the PL ring fills up is if there are not any PH packets.

> The effort here is to make the kernel multiqueue-capable, not the devices.

The kernel is already multiqueue capable. Thats what qdiscs do.

> I'm very familiar with the Rideau Canal system, 

fascinating engineering work, no?

> and this is not what I'm
> trying to solve.  What would be analagous to my goal is the lockmaster
> would direct different flows of boats into multiple lock entrypoints,
> based on some criteria. 
>  What you're saying is how to put all packets
> into one bucket, and then select one at a time for dequeueing, which
> still allows those different packets to interfere with each other. 

Multiple boats come into the canal at one entry point;-> I think the
important piece you are missing the feedback control theory involved. In
any case, the canal is a distraction - we can discuss the
(dis)similarities some other time.

> perhaps you're not completely grasping what it is I'm trying to
> implement.

Iam certain i do. And reading most of this email tells me you understand
most of what i am saying.
Let me say that I apologize i came in late into the discussion (and
wouldnt have noticed if it wasnt for your iproute2 change); i am still
catching up. 
I also apologize because this is so radically different from your
approach - so i understand your frustration.
And i hope you understand why i think it is unnecessary that i comment
on your patch.

Perhaps the next best thing to do is to have some descriptions of the
differences in the two approaches. If anything, please respond to whats
below ....

Heres what i see the differences to be:

1) You want to change the core code; i dont see a need for that.
The packet is received by the driver and netif stop works as before,
with zero changes; the driver shuts down on the first ring full.
The only work is mostly driver specific.

2) You want to change qdiscs to make them multi-queue specific.
I only see a need for adding missing schedulers (if they are missing)
and not having some that work with multiqueues and other that dont.
The assumption is that you have mappings between qdisc and hw-rings.

3) For me: It is a driver change mostly. A new qdisc may be needed - but
thats about it. 

4) You counter-argue that theres no need for QoS at the qdisc if the
hardware does it; i am counter-counter-arguing if you need to write
a new scheduler, it will benefit the other single-hwqueue devices.

Anything i missed?

These emails are getting too long - typically people loose interest
sooner. In your response, can you perhaps restrict it to just that
last part and add anything you deem important?

cheers,
jamal


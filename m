From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3-1: WAS(Re: [PATCH 2/4] deferred drop,
	__parent	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 23 Aug 2004 08:31:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093264271.1040.813.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
	 <1093191124.1043.206.camel@jzny.localdomain>
	 <4129BB3A.9000007@crocetta.org>
	 <1093261128.1044.759.camel@jzny.localdomain>
	 <4129DD47.5030807@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4129DD47.5030807@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-23 at 08:04, sandr8 wrote:
> jamal wrote:
> 

> so, maybe we are saying the same thing but in different words :)

Probably ;->

> if we blindly look at layer 3 and unbill when a packet is dropped,
> then the retransmission is already unbilled :)
> it will be billed when it takes place, but the first transmission that
> underwent a drop has been unbilled and hence we are square.
> this without looking at layer 4.

Agreed.

> what i was thinking about was mimicking the conntracking at
> a device level, having per each device a singleton object that
> has the same buckets as the connection tracking. it could
> store a lot of interesting information that would augment queuing
> disciplines to better share the pain of drops and also to perform
> per-connection head drops instead of connection-unaware
> tail-drop.

This connection exists today in the form of marking. Let conmtracking
mark then use fw classifier at the qdisc. If i am not mistaken theres
something more powerful these days called conmarking.
Now if you did it like that then you dont need Haralds code and it will
be much easier to maintain (refer to my earlier email).

> this would improve fairness and shorten the time tcp sources
> need to get the feedback, in a better way than random early
> drop does.

Contracking is a horrible performance pig. I dont even turn it on. Dont
make it a requirement to turn it on.

> having this structure at a device level would be an answer
> for the issue of packets cloned to multiple interfaces, as we
> would be augmented to perform a separate accounting for
> each interface (which seems, afaik, reasonable... in most
> cases we would account on a single interface, and we also
> should likely get less hash collisions... no more than in the
> centralized conntrack).

Heres a thought:
Make it a tc action.
--> netfilter: contrack --> conmark
--> qdisc: classify via fw -> billing action bill
-------->                      attach table index + lock to skb 
-------->   deal with any unfairness on enqueue by using index
-------->   and fine grained lock found in skb

on skb freeing make sure you delete the index and lock.
On cloning, what to do?

Note i do plan to have a contracking action at the qdisc level.
Let me know if that is useful to you then i can prioritize.

> furthermore, the per-bucket lock you suggested, that should
> be a good compromise, would also not "interfere" from one
> interface to the other one. well... maybe as soon as enqueues
> and dequeues on the same device stay serialized (thanks to
> dev->queue_lock) we should not need that further lock
> either.

Possibly yes.

> does it make sense?

I think it does. Make sure you double check the rules i posted earlier.

cheers,
jamal

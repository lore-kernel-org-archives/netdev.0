From: jamal <hadi@cyberus.ca>
Subject: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent workaround,
	reshape_fail , netdev@oss.sgi.com ,
Date: 22 Aug 2004 12:12:04 -0400
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1093191124.1043.206.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,  netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <41220AEA.20409@crocetta.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-17 at 09:40, sandr8 wrote:
> jamal wrote:

> 
> >Yes, this is a hard question. Did you see the suggestion i proposed
> >to Harald?
> >  
> >
> if it is the centralization of the stats with the reason code that,
> for what concerns the ACCT, says wheter to bill or unbill i
> think it is _really_ great :)
> still, for what concerns the multiple interface delivery of the
> same packet i don't see how it would be solved...

Such packets are cloned or copied. I am going to assume the contrack
data remains intact in both cases. LaForge?
BTW, although i mentioned the multiple interfaces as an issue - thinking
a little more i see retransmissions from TCP as well (when enqueue drops
because of full queue) being a problem. 
Haralds patch bills in that case as well for each retransmitted packet
that gets dropped because of full Q.
So best place to really unbill is at the qdisc level.
The only place for now i see that happening is in the case of drops
i.e sch->stats.drops++ 
The dev.c area after enqueue() attempt is a more dangerous place to do
it at (incase the skb doesnt exist because something freed it when
enqueue was called. Also because thats one area open for returning more
intelligent congestion level indicating codes)

> would there be any magic to have some conntrack data per device
> without having to execute the actual tracking twice but without locking
> the whole conntrack either? 

That is the challenge at the moment.
For starters i dont see it as an issue right now to do locking.
Its a cost for the feature since Haralds patch is in. 

In the future we should make accounting a feature that could be turned
on despite contracking and skbs should carry an accounting metadata with
them. 

> what could be the "magic" to let the
> conntrack do the hard work just once and handle the additional traffic
> policing information separately, in an other data structure that is 
> mantained
> on a device basis? that could also be the place where to count how much
> a given flow is backlogged on a given interface... which could help in
> choosing the dropping action... sorry, am i going too much further?

No i think your idea is valuable.
The challenge is say you have a million connections, then do you
have a million locks (one per structure)? I think we could reduce it
by having a pool of stats sharing a lock (maybe by placing them in a 
shared hash table with each bucket having a lock).
You cant have too many locks and you cant have too few ;->


On your qdisc you say:

> >
> it is not ready, but to say it shortly, i'm trying to serve first who 
> has been
> _served_ the less.
> 
> from the first experiments i have made this behaves pretty well and smootly,
> but i've noticed that _not_ unbilling can be pretty unfair towards udp 
> flows,
> since they always keep sending.

If qdisc drops on full Q and unbills i think it should work, no?
If it drops because they abused a bandwidth level, shouldnt you punish
them still? I think you should, but your mileage may vary.
Note you also dont want to unbill more than once. If not maybe you can
introduce something on the skb to indicate unbilling-happened (if done
by policer) so root qdisc doesnt unbill again.

I think the issue starts with defining what resource is being accounted
for. In my view, you are accounting for both CPU and bandwidth.
Lets start by asking  What is the resource being accounted for?


> it simply has a priority dequeue that is manained ordered on the 
> attained service.
> if no drop occours, then accounting before enqueueing simply forecasts 
> the service
> that will have been attained up to the packet currenlty being enqueued 
> when it will
> be dequeued.  [ much easier to code than to say... ]

I think i understand.
A packet that gets enqueued is _guaranteed_ to be transmitted unless
overulled by admin policy. 
Ok, how about the idea of adding skb->unbilled which gets set when
unbilling happens (in the aggregated stats_incr()). skb->unbilled gets
zeroed at the root qdisc after return from enqueueing.

cheers,
jamal

From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: Billing 3-1: WAS(Re: [PATCH 2/4] deferred drop, __parent	workaround,
 reshape_fail , netdev@oss.sgi.com ,
Date: Mon, 23 Aug 2004 14:04:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4129DD47.5030807@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2>	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>	 <1093191124.1043.206.camel@jzny.localdomain>	 <4129BB3A.9000007@crocetta.org> <1093261128.1044.759.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093261128.1044.759.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Mon, 2004-08-23 at 05:39, sandr8 wrote:
>  
>
>>jamal wrote:
>>    
>>
>Ok, in this case, retransmissions have to be unbilled.
>To rewind to what i said a few emails ago:
>The best place to bill is by looking at what comes out of the box;->
>Ok, we dont have that luxury in this case. So the next best place
>is to do it at the qdisc level. Because only at that level do you
>know for sure if packets made it out or not. 
>Since contracking already does the job of marking the flow, then
>thats the second part of your requirement "on behalf of each flow".
>What we are doing now is hacking around to try and reduce the injustice.
>
>Conclusion: The current way of billing is _wrong_. The better way is to
>have contracking just mark and the qdisc decide on billing or unbilling.
>Have a billing table somewhere indexed by flow that increments these
>stats.
>
>For now i think that focussing on just sch.drops++ in case of full 
>queue will help.
>
>Let me cut email here for readability.
>  
>
so, maybe we are saying the same thing but in different words :)

if we blindly look at layer 3 and unbill when a packet is dropped,
then the retransmission is already unbilled :)
it will be billed when it takes place, but the first transmission that
underwent a drop has been unbilled and hence we are square.
this without looking at layer 4.

what i was thinking about was mimicking the conntracking at
a device level, having per each device a singleton object that
has the same buckets as the connection tracking. it could
store a lot of interesting information that would augment queuing
disciplines to better share the pain of drops and also to perform
per-connection head drops instead of connection-unaware
tail-drop.

this would improve fairness and shorten the time tcp sources
need to get the feedback, in a better way than random early
drop does.

having this structure at a device level would be an answer
for the issue of packets cloned to multiple interfaces, as we
would be augmented to perform a separate accounting for
each interface (which seems, afaik, reasonable... in most
cases we would account on a single interface, and we also
should likely get less hash collisions... no more than in the
centralized conntrack).

furthermore, the per-bucket lock you suggested, that should
be a good compromise, would also not "interfere" from one
interface to the other one. well... maybe as soon as enqueues
and dequeues on the same device stay serialized (thanks to
dev->queue_lock) we should not need that further lock
either.

does it make sense?

>cheers,
>jamal
>
ciao ciao!
alessandro

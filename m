From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent workaround,
 reshape_fail , netdev@oss.sgi.com ,
Date: Mon, 23 Aug 2004 11:39:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4129BB3A.9000007@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2>	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org> <1093191124.1043.206.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093191124.1043.206.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Tue, 2004-08-17 at 09:40, sandr8 wrote:
>  
>
>>jamal wrote:
>>    
>>
>
>  
>
>>>Yes, this is a hard question. Did you see the suggestion i proposed
>>>to Harald?
>>>
>>if it is the centralization of the stats with the reason code that,
>>for what concerns the ACCT, says wheter to bill or unbill i
>>think it is _really_ great :)
>>still, for what concerns the multiple interface delivery of the
>>same packet i don't see how it would be solved...
>>    
>>
>
>Such packets are cloned or copied. I am going to assume the contrack
>data remains intact in both cases. LaForge?
>BTW, although i mentioned the multiple interfaces as an issue - thinking
>a little more i see retransmissions from TCP as well (when enqueue drops
>because of full queue) being a problem.
>  
>
imho, the point maybe is that a scheduler should work at layer 3,
am i wrong?
i mean: i made the same question to myself and answered that
the right level should be the third... this would account for tcp
retransmissions as well as forward error corrections packets
added by some application on top of udp, or retrasmissions by
applications on udp... or... whatever...

maybe my reasoning is less foggy if i first answer to an other
question:

>I think the issue starts with defining what resource is being accounted
>for. In my view, you are accounting for both CPU and bandwidth.
>Lets start by asking  What is the resource being accounted for?
>  
>
i would like to account for the number of bytes sent to the wire
on behalf of each flow :)

>Haralds patch bills in that case as well for each retransmitted packet
>that gets dropped because of full Q.
>So best place to really unbill is at the qdisc level.
>The only place for now i see that happening is in the case of drops
>i.e sch->stats.drops++ 
>The dev.c area after enqueue() attempt is a more dangerous place to do
>it at (incase the skb doesnt exist because something freed it when
>enqueue was called. Also because thats one area open for returning more
>intelligent congestion level indicating codes)
>  
>
this seems not to be possible, afaik, with that patch i wrote. the only
skbs that are freed are those that are internally allocated. and the
only kfree_skb() that can happen on skbs that are enqueued in dev.c
should be those in case od a TC_ACT_QUEUED or TC_ACT_STOLEN,
where they should just decrement the user counter. i say "should" since
this is the most reasonable assumption i managed to make, but
this is your field and you definitely know it much better than me :)
in that case, btw, dev.c doesn't get any drop return code...

if a drop return code is given, the packet is not freed internally, but
only "externally".  (for the "where"... the question is open in "billing 1")

where could a skb be freed then?

[ i'm not insisting with that patch, i'm just trying to say that, if i don't
rave, it should not be dangerous to do that after the enqueue()...
then, it's just that for the moment i can't immagine a different
way to do things in that place :) yes, there could be a slight
variation with a skb_get() right before the enqueue and all the
kfree_skb() at their place inside the code, but then somewhere
we should always add a kfree_skb... ouch... and we would need
a by ref skb anyway to get the packet that has been dropped
and if it's not the same as the enqueued one also the enqueued
one should pass through one more kfree_skb()... horrible, more
complex and slower i'd say... ]

>>would there be any magic to have some conntrack data per device
>>without having to execute the actual tracking twice but without locking
>>the whole conntrack either? 
>>    
>>
>
>That is the challenge at the moment.
>For starters i dont see it as an issue right now to do locking.
>Its a cost for the feature since Haralds patch is in. 
>
>In the future we should make accounting a feature that could be turned
>on despite contracking and skbs should carry an accounting metadata with
>them. 
>  
>
i need to think thoroughly on it... depending on where that information is
kept, the complexity of some operations can change a lot... and i should
not only egoistically think to the operations i need but look at it from the
outside to have a less partisan viewpoint on the problem and find the
most generally good solution possible.

>>what could be the "magic" to let the
>>conntrack do the hard work just once and handle the additional traffic
>>policing information separately, in an other data structure that is 
>>mantained
>>on a device basis? that could also be the place where to count how much
>>a given flow is backlogged on a given interface... which could help in
>>choosing the dropping action... sorry, am i going too much further?
>>    
>>
>No i think your idea is valuable.
>The challenge is say you have a million connections, then do you
>have a million locks (one per structure)? I think we could reduce it
>by having a pool of stats sharing a lock (maybe by placing them in a 
>shared hash table with each bucket having a lock).
>  
>
yeah, that could be the right compromise :)

>You cant have too many locks and you cant have too few ;->
>
>
>On your qdisc you say:
>
>>it is not ready, but to say it shortly, i'm trying to serve first who 
>>has been _served_ the less.
>>
>>from the first experiments i have made this behaves pretty well and smootly,
>>but i've noticed that _not_ unbilling can be pretty unfair towards udp 
>>flows,
>>since they always keep sending.
>>    
>>
>
>If qdisc drops on full Q and unbills i think it should work, no?
>  
>
this is the case. i could do it on my own from inside my code, but then 
i would
"pollute" the information seen from other parts of the kernel code and i 
would
introduce a _new_ unfairness between those flows that pass though my qdisc
and those that don't... to sum it up... it would be pretty unclean

>If it drops because they abused a bandwidth level, shouldnt you punish
>them still? I think you should, but your mileage may vary.
>Note you also dont want to unbill more than once. If not maybe you can
>introduce something on the skb to indicate unbilling-happened (if done
>by policer) so root qdisc doesnt unbill again.
>  
>
you are thinking in that perspective because of tcp? as i said above, i 
would stop at layer 3...
btw, if i don't misunderstand what you mean, i guess it's when tcp is 
retransmitting that that
field should somehow be set... is it as feasible when we are not on an 
end-point as when
we are an endpoint? btw, we should then do the same with the other 
protocols and, for
example with udp, it would become application dependent... a suicide?

>>it simply has a priority dequeue that is manained ordered on the 
>>attained service.
>>if no drop occours, then accounting before enqueueing simply forecasts 
>>the service
>>that will have been attained up to the packet currenlty being enqueued 
>>when it will
>>be dequeued.  [ much easier to code than to say... ]
>>    
>>
>
>I think i understand.
>A packet that gets enqueued is _guaranteed_ to be transmitted unless
>overulled by admin policy. 
>Ok, how about the idea of adding skb->unbilled which gets set when
>unbilling happens (in the aggregated stats_incr()). skb->unbilled gets
>zeroed at the root qdisc after return from enqueueing.
>  
>
sorry?? i'm lost... maybe there's something implied i can't get...
do you agree it's not the same skb that will be re-billed
afterwards?

>cheers,
>jamal
>
ciao
Alessandro :)

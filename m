From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Tue, 17 Aug 2004 15:49:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41220CE4.2000308@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2>	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org> <1092743526.1038.47.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1092743526.1038.47.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>It is used all over the stack. Lets defer this part of the 
>discussion - even if we never "fix" this it doesnt matter.
>  
>
sorry, i meant the two new inline functions

>>i was wondering if it would be
>>less nasty to have a device enqueue operation that will
>>interact (wraps it and does something around that) with
>>the outmost qdisc enqueue... this could give a good
>>abstraction to answer to question 2 as well...
>>    
>>
>
>I am not sure i followed.
>  
>
something like enqueue(dev) that will indirectly call dev->qdisc->enqueue
and handle in that single place that stuff that does not fit well in
net/core/dev.c

>Dropping packets at the policer is policy definition. Dropping packets
>at the qdisc due to full queue is an accident. An accident that in
>a good system shouldnt happen.
>
why it should not happen in a good system?
it is an accident that is a sympthom of something. when we
encounter that accident we detect that "sympthom" at the
scheduler. the way the scheduler reacts to that sympthom
is imho part of the policy. i'm somehow advocating that
the policer is something more than the mere filter, but the
filter + that part of the scheduler that decides what to drop...
from that viewpoint there is no big difference between
the filter drop and the "accidental drop" performed
nevertheless in compliance with a given policy.

>For the accident part i agree with
>the unbilling/recompensation feature.
>  
>
why not in the other case? :'''(
well, since later on you ask me what i have
in mind, it would be more clear there why i
personally would need it in any case.

>Yes, this is a hard question. Did you see the suggestion i proposed
>to Harald?
>  
>
if it is the centralization of the stats with the reason code that,
for what concerns the ACCT, says wheter to bill or unbill i
think it is _really_ great :)
still, for what concerns the multiple interface delivery of the
same packet i don't see how it would be solved...

would there be any magic to have some conntrack data per device
without having to execute the actual tracking twice but without locking
the whole conntrack either? what could be the "magic" to let the
conntrack do the hard work just once and handle the additional traffic
policing information separately, in an other data structure that is
mantained
on a device basis? that could also be the place where to count how much
a given flow is backlogged on a given interface... which could help in
choosing the dropping action... sorry, am i going too much further?

>I mean it is grabbed from the qdisc and a DMA of the packet is
>attempted.
>  
>
so, after (maybe better to say while :) qdisc is run and dequeues the
packet.

well, your approach seems to be the most coherent one...

>I believe the cost of using
>stats lock at qdisc is the same as what you have currently with
>unbilling.
>  
>
you mean having a fine grained lock just for the stats?

>>this because it would force me to have more complexity in the enqueue
>>operation, that in the scheduler i'm trying to write does need to have that
>>information to put packets correctly into the queue.
>>    
>>
>
>Ok, now you mention the other piece. What are you trying to do on said
>qdisc?
>  
>
it is not ready, but to say it shortly, i'm trying to serve first who
has been
_served_ the less.

from the first experiments i have made this behaves pretty well and smootly,
but i've noticed that _not_ unbilling can be pretty unfair towards udp
flows,
since they always keep sending.

>>i think that in that case, i'd better duplicate the work and account that
>>information on my own... the speedup i'd get would be definitely worth
>>having twice the same info... even though that would not be elegant at
>>all... :(
>>    
>>
>
>Explain what your qdisc is doing.
>  
>
it simply has a priority dequeue that is manained ordered on the
attained service.
if no drop occours, then accounting before enqueueing simply forecasts
the service
that will have been attained up to the packet currenlty being enqueued
when it will
be dequeued.  [ much easier to code than to say... ]

>cheers,
>jamal
>
ciao ;)

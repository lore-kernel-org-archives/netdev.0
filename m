From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Mon, 16 Aug 2004 17:19:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4120D068.2040608@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2> <1092661235.2874.71.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, sandr8@crocetta.org, devik@cdi.cz,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1092661235.2874.71.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Mon, 2004-08-16 at 03:20, Harald Welte wrote:
>  
>
>>Let's discuss the individual patches seperately.
>>
>>1) Is certainly not a huge issue, no debate here
>>    
>>
>
>Although the patch does look innocent,
>actually it may break a lot of things since that code is particulary
>tricky and the patch changes the environmental rules. It needs study.
>since it doesnt add anything other than cosmetics, holding on it
>might be the wisest thing.
>  
>
the danger should be where it is used incorrectly.
you are right, but for the moment it is not used
spreadly.

if instead you are talking about breaking some
code that relied on the old numerical values
themselves (but the trivial case of 0 that many times
seems to be confused with the only success return
value, which is not true) then i must have definitely
missed that code.

btw, wouldn't it be nice to have something similar for
the tc_calssify results (eg. setting a "terminal" bit in the
defines and adding an inline terminal(result) function
that does mask with that bit so that we avoid switching
and hence some lines of code and branches)?

>>2)... 
>>
>>Having a single packet drop point makes such a change less intrusive.
>>    
>>
>
>Seems to me the interest is more having single point for stats
>collection.
>Let me think about it for a bit and get back to you guys.
>
>  
>
well i didn't dare doing that too because
all those * or & insertion themselves made
up a 50k patch... but in fact that would be
nice and would lighten the code inside the
many enqueue()...

needless to say, the more (common) code
is pulled outside of the per-discipline
code, the smallest the kernel is and the
easiest is to mantain/debug/introduce
further changes.

>>4) This is the part you are complaining about, right?  I agree, I don't
>>like conntrack specific stuff in dev.c and packet scheduler areas.
>>    
>>
>
>Let me think about it and get back to you. Solution to #2 should apply
>here.
>  
>
as i said from the beginning, i don't like that too.
yes, it is working fine for me, but that is not the
logical place where to do that...

please correct me if i am wrong: the two big questions are:

1) moving that code away from net/core/dev.c

and

2) what to do in case of packets sent over multiple interfaces?

for what concerns (1), i was wondering if it would be
less nasty to have a device enqueue operation that will
interact (wraps it and does something around that) with
the outmost qdisc enqueue... this could give a good
abstraction to answer to question 2 as well...

for what concerns (2), i see that jamal takes literally
the meaning of 'billing' a connection... well i was
thinking just at traffic policing and not at money
accounting and billing servers...

in any case... regarding what to do if a packet sent over
multiple interfaces is dropped only in some of them and
not on all of them... this could also happen for a broadcast
or multicast packet... and thinking about it, the most coerent
thing to do from my viewpoint (traffic policing, not getting
money for the service given) would be to have a separate view
of the same packet flow at every different interface... this
would get more complex, but the separate device-level enqueue
could be the place to do that. there would also have place the
single point for drops.

in an other message, jamal wrote:

>Let me think about it.
>Clearly the best place to account for things is on the wire once the
>packet has left the box ;-> So the closest you are to the wire, the
>better. How open are you to move accounting further down? My thoughts
>are along the lines of incrementing the contrack counters at the qdisc
>level. Since you transport after the structure has been deleted, it
>should work out fine and fair billing will be taken care of.
>  
>
accounting when the packet goes to the wire would mean at the
dequeue level?

besides, as harald sais, grabbing a lock every time a packet is sent and
not only when a packet is dropped... this would also imply from my
particular viewpoint, that when enqueing a packet we will not yet know how
much its flow/connection has been billed till know. we'll know that, only
once the previous packet will have been dequeued. and for me it would
be _much_ more cpu-intensive to behave consequently to that information if
i get it that late :''''(

this because it would force me to have more complexity in the enqueue
operation, that in the scheduler i'm trying to write does need to have that
information to put packets correctly into the queue.

i think that in that case, i'd better duplicate the work and account that
information on my own... the speedup i'd get would be definitely worth
having twice the same info... even though that would not be elegant at
all... :(

i should stop, take an other long breath, and think a little bit about 
this ;)

cheers
alessandro

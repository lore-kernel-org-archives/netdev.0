From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent	workaround,
 reshape_fail , netdev@oss.sgi.com ,
Date: Mon, 23 Aug 2004 14:27:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4129E2A2.2050500@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2>	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>	 <1093191124.1043.206.camel@jzny.localdomain>	 <4129BB3A.9000007@crocetta.org> <1093262296.1040.778.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093262296.1040.778.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>Let me layout a few things:
>
>    ..-->classification --> tcaction
>return code1 --> enqueue
>return code2 ...(packet may be freed here)--> dev.c
>
>The rules are:
>1) A qdisc receiving a STOLEN/QUEUED/SHOT signal from the classification
>result (return code 1) MUST free the packet and immediately stop
>processing that packet.
>The infrastructure code will clone packets if they want to steal or
>queue it. Infact the skbs flow may even change during this path (eg
>packet rewritten)
>Billing issues: In such a case multiple packets may be later reinjected
>(after replicating the one that was stolen) which totaly bypass
>contracking code. Multiple packets may make it out to the wire.
>You need to find a way to bill them ;-> (opposite of what you are trying
>to do).
>  
>
i don't know the code that does that, since afaik it
was not yet there in 2.6.8... if it is, please tell me
because i'm eager to have a full viewpoint of the
forthcoming packet action framework :)

>2)Return code (return code 2) of qdisc from enqueue function need to be
>dealt with care if the packet is localy generated so it doesnt confuse
>TCP (SCTP and DCCP sound like two other protocols that could be added)
>
>Here we have two paths:
>i) policy dropped packets.
>Billing issues: You want to unbill dropped but not stolen packets.
>
>ii) packets that are dropped because of a full Q should continue to
>return a XMIT_DROP.
>Billing: MUST unbill.
>
>Again as  above shows, billing would work better at the qdisc level.
>  
>
yes, sure...
but for the moment i personally don't know which path
STOLEN and QUEUED packets will follow... it's not
a reproach :) it's just that i simply can't know for the
moment, but i don't want to make you hurry, i perfectly
understand that you've got plenty of things to do :)

>>[ i'm not insisting with that patch, i'm just trying to say that, if i don't
>>rave, it should not be dangerous to do that after the enqueue()...
>>then, it's just that for the moment i can't immagine a different
>>way to do things in that place :) yes, there could be a slight
>>variation with a skb_get() right before the enqueue and all the
>>kfree_skb() at their place inside the code, but then somewhere
>>we should always add a kfree_skb... ouch... and we would need
>>a by ref skb anyway to get the packet that has been dropped
>>and if it's not the same as the enqueued one also the enqueued
>>one should pass through one more kfree_skb()... horrible, more
>>complex and slower i'd say... ]
>>    
>>
>
>Linux is being efficient by sharing skbs. One of the most expensive
>things in a stack is copying packets around (which is avoided).
>If this was a simple system where allocating and freeing can be mapped
>to exactly a flow then what you suggest can be done. In Linux you cant.
>
>  
>
in that patch i was not copying them... just passing them by reference 
through a
"struct sk_buff ** const skb" parameter.

what is the difference from before...?

calling:
before) when calling we passed a pointer on the stack.
now) when calling we pass a pointer on the stack

returning:
before) when returning we didn't tell the caller which
packet was dropped
now) when returning we tell the sender which packet
is not queued or is thrown away from our queue to
make place for the packet enqueued.

what happens on the stack now?

for the calling: more or less the same as before :)
for the returning...

1) the external pointer is const, cannot be changed. this
is good to avoid stupid bugs.
2) being the external pointer const, the internal one always
lays in the stack frame of the outmost caller of an enqueue
operation. hust the external one is passed to callees. when
a requeue operation is called, that pointer nevertheless stays
in the stack frame of the outmost caller of an enqueue
operation. that's to say: it never moves from the stack of the
caller of dev->qdisc->enqueue()... [in that case it was dev.c,
but maybe it would be nicer to have it in a sort of
dev->enqueue() that would have to do with device level
conntracking].

additional cost for the function calling? z-e-r-o !!! :)
performance issues? maybe some improvement due
to the elimination of many internal jumps and conditions.

furthermore, telling the caller the packet that we chose to
drop allows it to reshape it without the need for every
qdisc to recur too any callback function.

>>>That is the challenge at the moment.
>>>For starters i dont see it as an issue right now to do locking.
>>>Its a cost for the feature since Haralds patch is in. 
>>>
>>>In the future we should make accounting a feature that could be turned
>>>on despite contracking and skbs should carry an accounting metadata with
>>>them. 
>>> 
>>>
>>>      
>>>
>>i need to think thoroughly on it... depending on where that information is
>>kept, the complexity of some operations can change a lot... and i should
>>not only egoistically think to the operations i need but look at it from the
>>outside to have a less partisan viewpoint on the problem and find the
>>most generally good solution possible.
>>    
>>
>
>I am begining to think that all contrack should do is mark the packets
>then let the qdisc take care of things.
>
>Cutting email here, since another topic below and this email is too
>long.
>
>cheers,
>jamal
>  
>
ciao :)

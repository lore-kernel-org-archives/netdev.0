From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent
	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 23 Aug 2004 07:58:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093262296.1040.778.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
	 <1093191124.1043.206.camel@jzny.localdomain>
	 <4129BB3A.9000007@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4129BB3A.9000007@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-23 at 05:39, sandr8 wrote:
> jamal wrote:

> >Haralds patch bills in that case as well for each retransmitted packet
> >that gets dropped because of full Q.
> >So best place to really unbill is at the qdisc level.
> >The only place for now i see that happening is in the case of drops
> >i.e sch->stats.drops++ 
> >The dev.c area after enqueue() attempt is a more dangerous place to do
> >it at (incase the skb doesnt exist because something freed it when
> >enqueue was called. Also because thats one area open for returning more
> >intelligent congestion level indicating codes)
> >  
> >
> this seems not to be possible, afaik, with that patch i wrote. the only
> skbs that are freed are those that are internally allocated. and the
> only kfree_skb() that can happen on skbs that are enqueued in dev.c
> should be those in case od a TC_ACT_QUEUED or TC_ACT_STOLEN,
> where they should just decrement the user counter. i say "should" since
> this is the most reasonable assumption i managed to make, but
> this is your field and you definitely know it much better than me :)
> in that case, btw, dev.c doesn't get any drop return code...
> 
> if a drop return code is given, the packet is not freed internally, but
> only "externally".  (for the "where"... the question is open in "billing 1")
> 
> where could a skb be freed then?

Let me layout a few things:

    ..-->classification --> tcaction
return code1 --> enqueue
return code2 ...(packet may be freed here)--> dev.c

The rules are:
1) A qdisc receiving a STOLEN/QUEUED/SHOT signal from the classification
result (return code 1) MUST free the packet and immediately stop
processing that packet.
The infrastructure code will clone packets if they want to steal or
queue it. Infact the skbs flow may even change during this path (eg
packet rewritten)
Billing issues: In such a case multiple packets may be later reinjected
(after replicating the one that was stolen) which totaly bypass
contracking code. Multiple packets may make it out to the wire.
You need to find a way to bill them ;-> (opposite of what you are trying
to do).

2)Return code (return code 2) of qdisc from enqueue function need to be
dealt with care if the packet is localy generated so it doesnt confuse
TCP (SCTP and DCCP sound like two other protocols that could be added)

Here we have two paths:
i) policy dropped packets.
Billing issues: You want to unbill dropped but not stolen packets.

ii) packets that are dropped because of a full Q should continue to
return a XMIT_DROP.
Billing: MUST unbill.

Again as  above shows, billing would work better at the qdisc level.

> [ i'm not insisting with that patch, i'm just trying to say that, if i don't
> rave, it should not be dangerous to do that after the enqueue()...
> then, it's just that for the moment i can't immagine a different
> way to do things in that place :) yes, there could be a slight
> variation with a skb_get() right before the enqueue and all the
> kfree_skb() at their place inside the code, but then somewhere
> we should always add a kfree_skb... ouch... and we would need
> a by ref skb anyway to get the packet that has been dropped
> and if it's not the same as the enqueued one also the enqueued
> one should pass through one more kfree_skb()... horrible, more
> complex and slower i'd say... ]

Linux is being efficient by sharing skbs. One of the most expensive
things in a stack is copying packets around (which is avoided).
If this was a simple system where allocating and freeing can be mapped
to exactly a flow then what you suggest can be done. In Linux you cant.

> >>
> >That is the challenge at the moment.
> >For starters i dont see it as an issue right now to do locking.
> >Its a cost for the feature since Haralds patch is in. 
> >
> >In the future we should make accounting a feature that could be turned
> >on despite contracking and skbs should carry an accounting metadata with
> >them. 
> >  
> >
> i need to think thoroughly on it... depending on where that information is
> kept, the complexity of some operations can change a lot... and i should
> not only egoistically think to the operations i need but look at it from the
> outside to have a less partisan viewpoint on the problem and find the
> most generally good solution possible.

I am begining to think that all contrack should do is mark the packets
then let the qdisc take care of things.

Cutting email here, since another topic below and this email is too
long.

cheers,
jamal

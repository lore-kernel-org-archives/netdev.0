From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 17 Aug 2004 07:52:07 -0400
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1092743526.1038.47.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, sandr8@crocetta.org, devik@cdi.cz,  netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4120D068.2040608@crocetta.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-16 at 11:19, sandr8 wrote:
> jamal wrote:
> 
[..]
> the danger should be where it is used incorrectly.
> you are right, but for the moment it is not used
> spreadly.

It is used all over the stack. Lets defer this part of the 
discussion - even if we never "fix" this it doesnt matter.

> please correct me if i am wrong: the two big questions are:
> 
> 1) moving that code away from net/core/dev.c
> 
> and
> 
> 2) what to do in case of packets sent over multiple interfaces?
>
> for what concerns (1), i was wondering if it would be
> less nasty to have a device enqueue operation that will
> interact (wraps it and does something around that) with
> the outmost qdisc enqueue... this could give a good
> abstraction to answer to question 2 as well...

I am not sure i followed.

> for what concerns (2), i see that jamal takes literally
> the meaning of 'billing' a connection... well i was
> thinking just at traffic policing and not at money
> accounting and billing servers...

The policer (or any other action) accounts for what passes through it. 
Dropping packets at the policer is policy definition. Dropping packets
at the qdisc due to full queue is an accident. An accident that in
a good system shouldnt happen. For the accident part i agree with
the unbilling/recompensation feature.
I do agree with you - I think we have some bad accounting practises at
the qdisc level. Look at the requeu accounting for another example.
I also have issues with some of the other stats, example
stats.packets should really be incremented on enqueue to account for 
all the packets enqueue has seen (instead it is an accounting for
how many success have happened)

> in any case... regarding what to do if a packet sent over
> multiple interfaces is dropped only in some of them and
> not on all of them... this could also happen for a broadcast
> or multicast packet... and thinking about it, the most coerent
> thing to do from my viewpoint (traffic policing, not getting
> money for the service given) would be to have a separate view
> of the same packet flow at every different interface... this
> would get more complex, but the separate device-level enqueue
> could be the place to do that. there would also have place the
> single point for drops.

Yes, this is a hard question. Did you see the suggestion i proposed
to Harald?

> in an other message, jamal wrote:
> 
> >Let me think about it.
> >Clearly the best place to account for things is on the wire once the
> >packet has left the box ;-> So the closest you are to the wire, the
> >better. How open are you to move accounting further down? My thoughts
> >are along the lines of incrementing the contrack counters at the qdisc
> >level. Since you transport after the structure has been deleted, it
> >should work out fine and fair billing will be taken care of.
> >  
> >
> accounting when the packet goes to the wire would mean at the
> dequeue level?

I mean it is grabbed from the qdisc and a DMA of the packet is
attempted.

> besides, as harald sais, grabbing a lock every time a packet is sent and
> not only when a packet is dropped... this would also imply from my
> particular viewpoint, that when enqueing a packet we will not yet know how
> much its flow/connection has been billed till know. we'll know that, only
> once the previous packet will have been dequeued. and for me it would
> be _much_ more cpu-intensive to behave consequently to that information if
> i get it that late :''''(

I have been thinking about the lock cost. I believe the cost of using
stats lock at qdisc is the same as what you have currently with
unbilling.

> this because it would force me to have more complexity in the enqueue
> operation, that in the scheduler i'm trying to write does need to have that
> information to put packets correctly into the queue.

Ok, now you mention the other piece. What are you trying to do on said
qdisc?

> i think that in that case, i'd better duplicate the work and account that
> information on my own... the speedup i'd get would be definitely worth
> having twice the same info... even though that would not be elegant at
> all... :(

Explain what your qdisc is doing.

cheers,
jamal

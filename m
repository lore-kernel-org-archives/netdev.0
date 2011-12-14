From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Wed, 14 Dec 2011 00:16:38 -0500
Message-ID: <1323839798.8451.172.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
	 <1323531352.3159.106.camel@denise.theartistscloset.com>
	 <4EE39D88.9010002@ziu.info>
	 <1323542103.3159.148.camel@denise.theartistscloset.com>
	 <4EE7E3E4.6070409@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:51105 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab1LNFQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 00:16:55 -0500
In-Reply-To: <4EE7E3E4.6070409@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks again, Michal.  I'll respond in the text - John

On Wed, 2011-12-14 at 00:46 +0100, Michal Soltys wrote:
> On 10.12.2011 19:35, John A. Sullivan III wrote:
> > On Sat, 2011-12-10 at 18:57 +0100, Michal Soltys wrote: <snip> So,
> > again, trying to wear the eminently practical hat of a sys admin, for
> > periodic traffic, i.e., protocols like VoiP and video that are sending
> > packets are regular intervals and thus likely to reset the curve after
> > each packet, m1 helps reduce latency while m2 is a way of reducing the
> > chance of overrunning the circuit under heavy load, i.e., where the
> > concave queue is backlogged.
> >
> 
> Well, updated, - not "reset". The latter [kind of] implies the return to
> original form, and just so we're on the same page - the curve would have
> to be completely under the old one for that to happen. There's also no
> chance of overloading anything - except if a machine is shaping on
> behalf of something upstream with smaller uplink, and doing so without
> UL keeping LS in check.
> 
> > When we start multiplexing streams of periodic traffic, we are still
> > fine as long as we are not backlogged.  Once we are backlogged, we
> > drop down to the m2 curve which prevents us from overrunning the
> > circuit (assuming the sum of our rt m2 curves<= circuit size) and
> > hopefully still provides adequate latency.  If we are badly
> > backlogged, we have a problem with which HFSC can't help us :) (and I
> > suppose where short queues are helpful).
> >
> 
> Keep in mind that not backlogged classes are not hurt by backlogged
> ones. And you can't overrun - be it m1 or m2, or at which point any
> class activates (providing curves make sense). If everything is
> backlogged, you still get nicely multiplexed traffic as defined by
> your hierarchy.
I think I understand the technology (although I confess I did not take
the time to fully digest how the curves are updated) but I'm grappling
more with the practical application and I may be making a false
assumption here.

Once again, with my practical, "how do I use this" hat on, my
instinctive thought is that I would ensure that the sum of the rt m2
curves do not exceed ul, well, not ul literally as rt disregards ul but,
more accurately, circuit capacity so that my circuit is not
oversubscribed and my guarantees are sustainable.  But, since m1 on a
concave curve is a momentary "super charge", I don't need to worry about
oversubscribing since the rate is not sustained.  Thus, if all the
traffic were to be backlogged at m1 rates, we would overrun the circuit.
That's what I meant by m2 working as a circuit breaker.

As I think it through further, I realize that is not true in theory and
may be the source of the error I reference later in this email.  I
suppose it may also be problematic in practice so let me walk through it
a bit further with you if I may.

Let's imagine we have five classes of service.  We don't need to
identify them for this exercise but what we do know is that the sum of
their m2 curves <= circuit capacity and the sum of their m1 curves >
circuit capacity because, operating under my false assumption, this is
only for that temporary boost.  If all five classes receive their first
packet at the identical moment, we will fail to meet the guarantees.

More practically, let's assume the first four are continuously
backlogged and the fifth is receiving a heavy but not backlogged stream
of periodic (as in at regular intervals) traffic such that the curve is
recalculated so that each packet is sent on the m1 curve, I think it is
possible that we once again exceed the capacity of the link.  Ah, no.  I
see it.  Now that I've interrupted writing this email to take the time
to digest how the curve is updated, I see it more clearly.

Since the curves always take the minimum of what the data would have
been if we had kept transmitting the data at the old curve rate or what
the data would be if we reset the curve and started over again at m1 (my
practical translation of the algorithm), the sustained rate even if the
queue constantly goes idle and, as soon as it goes idle receives a new
packet will never exceed the volume of traffic that would have been
transmitted by the rt curve if it was under continuous backlog (not
taking into account any linksharing bandwidth).

I realize I am babbling in my own context so let me state in another way
in case I'm not being clear.  My concern was that, if the four classes
are continuously backlogged and the fifth class with a concave rt
service curve constantly goes idle and then immediately receives a
packet, it will always be transmitting at the m1 rate and thus exceed
the capacity of the circuit (since the sum of the five m2 curves =
capacity and the m1 of the fifth class is greater than the m2 of the
fifth class).  However, the curves do not recalculate to m1
automatically.  They calculate to whichever would be less - the total
data transmitted as if we had continued to transmit on the rt curve as
if it was continually backlogged or the amount of data transmitted if we
were starting the curve over again.  Thus the total bits dequeued if the
circuit cycles between active and passive (backlogged and not
backlogged) will never exceed the total number of bits dequeued if the
queue was continuously backlogged even for concave curves.

Here is ascii art from http://www.sonycsl.co.jp/~kjc/software/TIPS.txt
depicting what I am trying to say:
                                                     ________
                                     ________--------
                                    /                  ______
                                   /   ________--------
                       ________---+----        
                      /          /             
                     /          /              
    total    ->     /          + new coordinate                
                   /                           
                  /                            
           service curve       |
                 of            +
          previous period   current
                             time

			Update Operation

                                                       ______
                                       ________--------
                                  +----        
                                 /             
                                /              
    total    ->                + new coordinate                
                                               
                                               
                               |
                               +
                             current
                             time

			New Service Curve

So now I'll put my practical hat back on where practice will violate
theory but with no practical deleterious effect except in the most
extreme cases.  I propose that, from a practical, system administrator
perspective, it is feasible and probably ideal to define rt service
curves so that the sum of all m2 curves <= circuit capacity and m1
curves should be specified to meet latency requirements REGARDLESS OF
EXCEEDING CIRCUIT CAPACITY.

In theory, we can exceed circuit capacity and violate our guarantees as
in the example I gave where all five queues go active at exactly the
same time.  In practicality, the backlog will never exceed the sum of
the m1 curves times their duration minus the circuit capacity over that
same time period.  In other words, let's say we have a 1.5 Mbps link and
we have five rt curves all with m1 of 1 Mbps for 10 ms.  In 10 ms, we
will have queued 5 * 1 * .01 = 50kbits of traffic and dequeued 1.5 * .01
= 15 kbits of traffic thus, our backlog will never exceed 35kbits.  This
is likely to be quickly drained at the first idle time unless we truly
have all five queues continuously backlogged.

So, my approach of ensuring the sum of m2 curves <= capacity but m1
curves are specified based solely on latency requirements even if they
overload the circuit works in practice except under the most extreme
conditions (where ALL queues are continuously backlogged and even then
the damage is limited) even though it violates the theory.

Am I accurate here?

> 
> If anything briefly stops being backlogged, it will get bonus on next
> backlog period
I am assuming this assumes a concave curve and has to do with the
recalculation of the curve and that this would not be true if m1=m2?

>  - while making sure, it wouldn't go with new curve above
> previous backlog period's one (and assuming its actual rate is not above
> the defined RT curve, as in such case it will get bonus from excess
> bandwidth available as specified by LS (or will get none, if LS is not
> defined)).
When I first read this, I had no clue what you meant :) Now that I've
taken time to digest the curve recalculation, I think you are saying the
exact same thing I said above only in far fewer words ;)
> 
> > If you have a chance, could you look at the email I sent entitled "An
> > error in my HFSC sysadmin documentation".  That's the last piece I
> > need to fall in place before I can share my documentation of this
> > week's research.  Thanks - John
> 
> Yes, will do.
I'm guessing I slightly violated the rt guarantee precisely because of
what I described above.
> 
> Btw, have you check the manpages of recent iproute2 w.r.t. hfsc ?
> Lots of this should be explained, or at least mentioned there.
Yes, you were so kind as to give me links to them. I found them very
helpful - much more mathematical and theoretical than I am used to in a
man page but I'm not sure it would be possible to explain HFSC any other
way.  Thanks again - John

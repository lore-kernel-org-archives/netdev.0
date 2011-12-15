From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Thu, 15 Dec 2011 02:38:36 -0500
Message-ID: <1323934716.8451.272.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
	 <1323531352.3159.106.camel@denise.theartistscloset.com>
	 <4EE39D88.9010002@ziu.info>
	 <1323542103.3159.148.camel@denise.theartistscloset.com>
	 <4EE7E3E4.6070409@ziu.info>
	 <1323839798.8451.172.camel@denise.theartistscloset.com>
	 <4EE951E6.4020708@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:51315 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab1LOHi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 02:38:56 -0500
In-Reply-To: <4EE951E6.4020708@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-15 at 02:48 +0100, Michal Soltys wrote:
> On 11-12-14 06:16, John A. Sullivan III wrote:
> > I think I understand the technology (although I confess I did not take
> > the time to fully digest how the curves are updated) <snip>
> 
> Hmm, imho you can't really skip that part - or part about "why split RT
> into eligible/deadline" to see the mechanics behind RT curves.
<grin> I did eventually realize that which is why I stopped the email in
mid-stream and took several hours to work through it and then deleted
half of what I wrote :)
> 
> >
> > <snip>
> 
> > Thus, if all the traffic were to be backlogged at m1 rates, we would
> > overrun the circuit.
> 
> Curves don't really change that in any way.
Yes, I suppose that was my point just phrased a different way - in other
words, if we are careless or ignorant about curves, we can get ourselves
in trouble!
> 
> If you did the above for m1 (or m2) for RT curves, the eligiblity would
> lose the point (leafs would always be eligible), and the whole thing
> would kind-of degenerate into more complex version of LS. There's a
> reason why BSDs won't even let you define RT curves that sum at any
> point to more than 80% (aside keeping LS useful, perhaps also related to
> thier timer resolution [years ago]). Unless they changed it in recent
> versions - I didn't really have any modern BSD under my hands for a
> while.
> 
> > and the sum of their m1 curves > circuit capacity because, operating
> > under my false assumption, this is only for that temporary boost. If
> > all five classes receive their first packet at the identical moment,
> > we will fail to meet the guarantees.
> 
> I'd say more aggressive eliglibility and earlier deadline - than any
> boost. 
Yes, granted.  What I'm trying to do in the documentation is translate
the model's mathematical concepts into concepts more germane to system
administrators.  A sys admin is not very likely to think in terms of
deadline times but will think, "I've got a momentary boost in bandwidth
to allow me to ensure proper latency for time sensitive traffic."  Of
course, that could be where I'm getting in trouble :)

> Which will briefly (if enough leafs are backlogged) turn whole
> carefully designed RT mechanics into dimensionless LS-like thingy. So -
> while that is possible - why do it ? Setup RT that fits the achievable
> speed, and leave the excess bandwidth to LS.
Because doing so would recouple bandwidth and latency, I think - that's
what I'm trying to sort through and will address more fully toward the
end of this reply.
> 
> Whole RT design - with eligible/deadline split - is to allow convex
> curves to send "earlier", pushing the deadlines to the "right" - which
> in turn allows newly backlogged class to have brief priority. But it all
> remains under interface limit and over-time fulfills guarantees (even if
> locally they are violated).
To the right? I would have thought to the left on the x axis, i.e., the
deadline time becomes sooner? Ah, unless you are referring to the other
queue's deadline times and mean not literally changing the deadline time
but jumping in front of the ones on the right of the new queue's
deadline time.
> 
> > I realize I am babbling in my own context so let me state in another
> > way in case I'm not being clear.  My concern was that, if the four
> > classes are continuously backlogged and the fifth class with a concave
> > rt service curve constantly goes idle and then immediately receives a
> > packet, it will always be transmitting at the m1 rate and thus exceed
> > the capacity of the circuit (since the sum of the five m2 curves =
> > capacity and the m1 of the fifth class is greater than the m2 of the
> > fifth class).
> 
> Actually it won't. See what I wrote about the eligible/deadline above.
> The 4 classes (suppose they are under convex RT) will be eligible
> earlier than they would normally be (and send more). When the 5th class
> becomes active with its steeper m1, it literally "has a green light" to
> send whenever it's eligible, as the deadlines of the 4 classes are
> further to the right. If all classes remain backlogged from now on, it
> all evens out properly. If the 5th goes idle, other classes will
> "buffer up" again (from a lack of better term).
Right - that was why I put my concern in the past tense.  Once I
realized how the curves updated, I realized my concern was not valid.  I
left it there to give context to the rest of the email.
> 
> > So now I'll put my practical hat back on where practice will violate
> > theory but with no practical deleterious effect except in the most
> > extreme cases.  I propose that, from a practical, system administrator
> > perspective, it is feasible and probably ideal to define rt service
> > curves so that the sum of all m2 curves<= circuit
> 
> Going above would really make LS pointless, and turn RT into LS-like
> thing (see above).
> 
> > curves should be specified to meet latency requirements REGARDLESS OF
> > EXCEEDING CIRCUIT CAPACITY.
> 
> Again (see above) - that will not get you anywhere. m1 or m2 (look at
> the curve as a whole, not just its parts) - it just makes RT lose its
> properties and actual meaning behind numbers. Briefly, but still.
Perhaps but here is my thinking (which may be quite wrong) and why I
said earlier, doing what you propose seems to recouple bandwidth and
latency (although I do realize they are ultimately linked and the m1/m2
split is really manipulating early bandwidth to achieve independent
latency guarantees).

Where I am focused (and perhaps stuck) is the idea of decoupling latency
and bandwidth guarantees.  ls curves, like the m2 portion of the rt
curves seem to have more to do with sustained bandwidth when excess
available bandwidth is available.  I'm assuming in contrast that the m1
portion of the rt curve is for momentarily increasing bandwidth to help
move time sensitive traffic to the head of the queues when the class
first becomes active.  On the other hand, I do see that, in almost all
my examples, when I have allocated ls ratios differently from the m2
portion of the rt curve, it has been to allocate bandwidth more
aggressively to the time sensitive applications.  Perhaps this is what
you are telling me when you say use ls instead of oversubscribing m1 -
just using different words :)

The thought behind oversubscribing m1 . . . well . . . not intentionally
oversubscribing - just not being very careful about setting m1 to make
sure it is not oversubscribed (perhaps I wasn't clear that the
oversubscription is not intentional) - is that it is not likely that all
queues are continually backlogged thus I can get away with an accidental
over-allocation in most cases as it will quickly sort itself out as soon
as a queue goes idle.  As a result, I can calculate m1 solely based upon
the latency requirements of the traffic not accounting for the impact of
the bandwidth momentarily required to do that, i.e., not being too
concerned if I have accidentally oversubscribed m1.

The advantages of doing it via the m1 portion of the rt curve rather
than the ls curve are:

1) It is guaranteed whereas the ls will only work when there is
available bandwidth.  Granted, my assumption that it is rare for all
classes to be continually backlogged implies there is always some extra
bandwidth available.  And granted that it is not guaranteed if too many
oversubscribed m1's kick in at the same time.

2) It seems less complicated than trying to figure out what my possibly
available ls ratios should be to meet my latency requirements (which
then also recouples bandwidth and latency).  m1 is much more direct and
reliable.

This is where you and I seem to differ (and I gladly defer to the fact
that you know 10,000 times more about this than I do!).  Is that because
we are prioritizing differently ("how can I do this simply with clear
divisions between latency and bandwidth even if it momentarily violates
the model" versus "how do we preserve the model from momentarily
degrading") or because I have missed the point somewhere and focusing so
obsessively on separating latency and bandwidth guarantees is obscuring
my ability to see how doing this via ls ratios is more advantageous?
> 
<snip>
> 
> ps.
> Going through other mails will take me far more time I think.
> 
No problem; I greatly appreciate all the time you've taken to help me
understand this and hope I am coming across as exploring rather than
being argumentative.  I hope the resulting documentation will, in a
small way, help return the favor.

The most important other email by far and away is the "An error in my
HFSC sysadmin documentation" which is fairly short.  The long ones are
just the resultant documentation which I should eventually submit to you
in a graphics supporting format anyway.

Thank you very much as always - John

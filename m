From: Michal Soltys <soltys@ziu.info>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Thu, 15 Dec 2011 02:48:22 +0100
Message-ID: <4EE951E6.4020708@ziu.info>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>  <4EE358A4.7060302@ziu.info>  <1323531352.3159.106.camel@denise.theartistscloset.com>  <4EE39D88.9010002@ziu.info>  <1323542103.3159.148.camel@denise.theartistscloset.com>  <4EE7E3E4.6070409@ziu.info> <1323839798.8451.172.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3267 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755804Ab1LOBs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 20:48:29 -0500
In-Reply-To: <1323839798.8451.172.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-14 06:16, John A. Sullivan III wrote:
> I think I understand the technology (although I confess I did not take
> the time to fully digest how the curves are updated) but I'm grappling
> more with the practical application and I may be making a false
> assumption here.

Hmm, imho you can't really skip that part - or part about "why split RT
into eligible/deadline" to see the mechanics behind RT curves.

>
> Once again, with my practical, "how do I use this" hat on, my
> instinctive thought is that I would ensure that the sum of the rt m2
> curves do not exceed ul, well, not ul literally as rt disregards ul
> but, more accurately, circuit capacity so that my circuit is not
> oversubscribed and my guarantees are sustainable.

> But, since m1 on a concave curve is a momentary "super charge", I
> don't need to worry about oversubscribing since the rate is not
> sustained.

It's just a slope, from which you derive the time(s) used in deciding
"what to send next":

> Thus, if all the traffic were to be backlogged at m1 rates, we would
> overrun the circuit.

Curves don't really change that in any way.

If you did the above for m1 (or m2) for RT curves, the eligiblity would
lose the point (leafs would always be eligible), and the whole thing
would kind-of degenerate into more complex version of LS. There's a
reason why BSDs won't even let you define RT curves that sum at any
point to more than 80% (aside keeping LS useful, perhaps also related to
thier timer resolution [years ago]). Unless they changed it in recent
versions - I didn't really have any modern BSD under my hands for a
while.

> and the sum of their m1 curves > circuit capacity because, operating
> under my false assumption, this is only for that temporary boost. If
> all five classes receive their first packet at the identical moment,
> we will fail to meet the guarantees.

I'd say more aggressive eliglibility and earlier deadline - than any
boost. Which will briefly (if enough leafs are backlogged) turn whole
carefully designed RT mechanics into dimensionless LS-like thingy. So -
while that is possible - why do it ? Setup RT that fits the achievable
speed, and leave the excess bandwidth to LS.

Whole RT design - with eligible/deadline split - is to allow convex
curves to send "earlier", pushing the deadlines to the "right" - which
in turn allows newly backlogged class to have brief priority. But it all
remains under interface limit and over-time fulfills guarantees (even if
locally they are violated).

> I realize I am babbling in my own context so let me state in another
> way in case I'm not being clear.  My concern was that, if the four
> classes are continuously backlogged and the fifth class with a concave
> rt service curve constantly goes idle and then immediately receives a
> packet, it will always be transmitting at the m1 rate and thus exceed
> the capacity of the circuit (since the sum of the five m2 curves =
> capacity and the m1 of the fifth class is greater than the m2 of the
> fifth class).

Actually it won't. See what I wrote about the eligible/deadline above.
The 4 classes (suppose they are under convex RT) will be eligible
earlier than they would normally be (and send more). When the 5th class
becomes active with its steeper m1, it literally "has a green light" to
send whenever it's eligible, as the deadlines of the 4 classes are
further to the right. If all classes remain backlogged from now on, it
all evens out properly. If the 5th goes idle, other classes will
"buffer up" again (from a lack of better term).

> So now I'll put my practical hat back on where practice will violate
> theory but with no practical deleterious effect except in the most
> extreme cases.  I propose that, from a practical, system administrator
> perspective, it is feasible and probably ideal to define rt service
> curves so that the sum of all m2 curves<= circuit

Going above would really make LS pointless, and turn RT into LS-like
thing (see above).

> curves should be specified to meet latency requirements REGARDLESS OF
> EXCEEDING CIRCUIT CAPACITY.

Again (see above) - that will not get you anywhere. m1 or m2 (look at
the curve as a whole, not just its parts) - it just makes RT lose its
properties and actual meaning behind numbers. Briefly, but still.

I can think of scenarios where such setups would work fine (aside if it
would be really needed), but let's leave that for different occasion :)

>>
>>  If anything briefly stops being backlogged, it will get bonus on next
>>  backlog period
> I am assuming this assumes a concave curve and has to do with the
> recalculation of the curve and that this would not be true if m1=m2?

yes


ps.
Going through other mails will take me far more time I think.

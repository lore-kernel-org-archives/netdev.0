From: Michal Soltys <soltys@ziu.info>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 17 Dec 2011 19:40:36 +0100
Message-ID: <4EECE224.90800@ziu.info>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>  <4EE358A4.7060302@ziu.info>  <1323531352.3159.106.camel@denise.theartistscloset.com>  <4EE39D88.9010002@ziu.info>  <1323542103.3159.148.camel@denise.theartistscloset.com>  <4EE7E3E4.6070409@ziu.info>  <1323839798.8451.172.camel@denise.theartistscloset.com>  <4EE951E6.4020708@ziu.info> <1323934716.8451.272.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3962 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab1LQSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Dec 2011 13:40:35 -0500
In-Reply-To: <1323934716.8451.272.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for late reply.

On 15.12.2011 08:38, John A. Sullivan III wrote:

> Yes, granted.  What I'm trying to do in the documentation is translate
> the model's mathematical concepts into concepts more germane to
> system > administrators.  A sys admin is not very likely to think in
> terms of > deadline times but will think, "I've got a momentary
> boost in > bandwidth to allow me to ensure proper latency for time
> sensitive > traffic."  Of course, that could be where I'm getting in
> trouble :)

Tough to say. I'd say you can't completely avoid math here (I'm not
saying not to trim it a bit though). In the same way one can't really go
through TBF without understanding what token bucket is. Well, the
complexity of both is on different level, but you see my point.

>> Whole RT design - with eligible/deadline split - is to allow convex
>> curves to send "earlier", pushing the deadlines to the "right" -
>> which in turn allows newly backlogged class to have brief priority.
>> But it all remains under interface limit and over-time fulfills
>> guarantees (even if locally they are violated).
> To the right? I would have thought to the left on the x axis, i.e.,
> the deadline time becomes sooner? Ah, unless you are referring to the
> other queue's deadline times and mean not literally changing the
> deadline time but jumping in front of the ones on the right of the new
> queue's deadline time.

I mean - for convex curves - deadlines are further to the right, as such
class is eligible earlier (for convex curves, eligible is just linear m2
without m1 part), thus => receive more service => deadline projection is
shifted to the right. When some other concave curve becomes active, its
deadlines will be naturally preferred if both curves are eligible.

> The thought behind oversubscribing m1 . . . well . . . not
> intentionally oversubscribing - just not being very careful about
> setting m1 to make sure it is not oversubscribed (perhaps I wasn't
> clear that the oversubscription is not intentional) - is that it is
> not likely that all queues are continually backlogged thus I can get
> away with an accidental over-allocation in most cases as it will
> quickly sort itself out as soon as a queue goes idle.  As a result, I
> can calculate m1 solely based upon the latency requirements of the
> traffic not accounting for the impact of the bandwidth momentarily
> required to do that, i.e., not being too concerned if I have
> accidentally oversubscribed m1.

Well, that's one way to do it. If your aim is that say certain n% of
leaves are used at the same time (with rare exceptions), you could set
RT curves (m1 parts) as if you had less leaves. If you leave m2 alone
and don't care about mentioned exceptions, it should work.

But IMHO that's more like a corner case (with alternative solutions
available), than a "cookbook" recommendation.

> The advantages of doing it via the m1 portion of the rt curve rather
> than the ls curve are:
>
> 1) It is guaranteed whereas the ls will only work when there is
> available bandwidth.  Granted, my assumption that it is rare for all
> classes to be continually backlogged implies there is always some
> extra bandwidth available.  And granted that it is not guaranteed if
> too many oversubscribed m1's kick in at the same time.
>
> 2) It seems less complicated than trying to figure out what my
> possibly available ls ratios should be to meet my latency requirements
> (which then also recouples bandwidth and latency).  m1 is much more
> direct and reliable.

Like mentioned above - it's one way to do things and you're right.  But
I think you might be underestimating LS a bit. By its nature, it
schedules at speed normalized to the interface's capacity after all (or
UL limits, if applicable) - so the less of the classes are acutally
active, the more they get from LS. You mentioned earlier that you saw LS
being more aggressive in allocating bandwidth - maybe that was the
effect you were seeing ?

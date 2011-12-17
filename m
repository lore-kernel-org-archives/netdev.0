From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 17 Dec 2011 15:41:28 -0500
Message-ID: <1324154488.8451.420.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
	 <1323531352.3159.106.camel@denise.theartistscloset.com>
	 <4EE39D88.9010002@ziu.info>
	 <1323542103.3159.148.camel@denise.theartistscloset.com>
	 <4EE7E3E4.6070409@ziu.info>
	 <1323839798.8451.172.camel@denise.theartistscloset.com>
	 <4EE951E6.4020708@ziu.info>
	 <1323934716.8451.272.camel@denise.theartistscloset.com>
	 <4EECE224.90800@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:50842 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982Ab1LQUld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Dec 2011 15:41:33 -0500
In-Reply-To: <4EECE224.90800@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-17 at 19:40 +0100, Michal Soltys wrote:
> Sorry for late reply.
No problem - you're my lifeline on this so any response is greatly
appreciated!
> 
> On 15.12.2011 08:38, John A. Sullivan III wrote:
> 
<snip>
> > The advantages of doing it via the m1 portion of the rt curve rather
> > than the ls curve are:
> >
> > 1) It is guaranteed whereas the ls will only work when there is
> > available bandwidth.  Granted, my assumption that it is rare for all
> > classes to be continually backlogged implies there is always some
> > extra bandwidth available.  And granted that it is not guaranteed if
> > too many oversubscribed m1's kick in at the same time.
> >
> > 2) It seems less complicated than trying to figure out what my
> > possibly available ls ratios should be to meet my latency requirements
> > (which then also recouples bandwidth and latency).  m1 is much more
> > direct and reliable.
> 
> Like mentioned above - it's one way to do things and you're right.  But
> I think you might be underestimating LS a bit. By its nature, it
> schedules at speed normalized to the interface's capacity after all (or
> UL limits, if applicable) - so the less of the classes are acutally
> active, the more they get from LS. You mentioned earlier that you saw LS
> being more aggressive in allocating bandwidth - maybe that was the
> effect you were seeing ?
I think this is the crux right here.  As I think it through, I'm
probably just raising a tempest in a tea pot by my ignorance so I think
I'll stop here and just implement what you have advised.  I'll outline
the way I was thinking below just in case it does have merit and should
not be discarded.

I think LS can be used to do it but here is how I instinctively (and
perhaps erroneously) viewed rt m1, rt m2 and ls.  I thought, rt m2 are
my sustained guarantees so, what I'll do is divide all my available
bandwidth across all my various traffic flows via rt m2.  This reflects
that I was planning to use ls in a different way.  My thinking was that
rt m2 reflects how I want the bandwidth allocated if all queues are
backlogged and hence why I matched the sum of the rt m2 curves to the
total available bandwidth.

However, constant backlog is not likely to be the case most of the time.
When it is not, that's where I used ls curves.  So, when they are all
backlogged, I have tight control over how I have allocated all the
bandwidth. When they are not, I have a separate control (the ls curves)
which can be used to allocate that extra bandwidth in ratios completely
different from the rt m2 ratios if that is appropriate (as it is likely
to be).

Notice at this point, I have only considered bandwidth and have used the
rt m2 curves and the ls curves solely as bandwidth control mechanisms.
This is where I decided I might want to bend the rules and, if m2 does
not provide sufficiently low latency, I would add an m1 curve to
guarantee that latency.  Since the m2 curves add up to the total
available bandwidth, by definition my higher m1 curves are going to
exceed it but that's OK because the queues are not all backlogged most
of the time.

Thus rt m1 and ls are doing the same thing in the sense that they are
allocated with the assumption that not all queues are backlogged
(because, in my scenario, if all queues are backlogged, we will
eventually be using exclusively rt m2 curves), but they are tuned
differently.  rt m1 is tuned for latency and takes precedence whereas ls
is tuned for bandwidth as long as I don't need the extra bandwidth to
meet the rt m1 guarantees.

So, that was my newbie thinking.  It sounds like what I should really do
is target my rt m2 curves for truly minimum needed bandwidth, tune my rt
m1 curves for latency, ensure the sum of the greater of the m1 or m2 rt
curves does not exceed total bandwidth, and then use ls to allocate
anything left over.

So, sorry for all the gyrations.  Unless anyone tells me differently,
I'll use that last paragraph as my summary guidelines.  Thanks - John

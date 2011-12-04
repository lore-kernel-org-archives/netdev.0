From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: More understanding HFSC
Date: Sun, 04 Dec 2011 01:12:19 -0500
Message-ID: <1322979139.3347.147.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:58386 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123Ab1LDGMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 01:12:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To try to understand more about HFSC, I've tried to map out a real world
scenario and how we'd handle it.  My apologies in advance for a
consequently long email :(

As others have pointed out, we immediately noticed that
http://trash.net/~kaber/hfsc/SIGCOM97.pdf seems to speak of sc and ul
whereas the Linux implementation adds rt and ls.  Is it correct to
assume that this is because the Linux implementation foresaw instances
where one might not want the sharing ratio of available bandwidth to be
the same as the ratio of guaranteed bandwidth?

I'm guessing a practical illustration would be a bulk class where I have
low rt just to keep the class from being starved but want it to obtain
available bandwidth more aggressively.  Is that correct?

So trying to put the four possible parameters together, it sounds like
ul is normally used to specify the maximum link speed and can be
specified at the root, no, next child from root class and then flow down
to all descendants without being explicitly specified? But one can also
give a class an explicit ul if one wants to limit the amount of
bandwidth a leaf or branch can consume when sharing available bandwidth?

sc would be used where rt=ls?

ls is used solely to determine ratios of sharing available bandwidth
between peers, does not need to aggregate to <= ul but normally does by
convention? Thus, it has nothing to do with the actual amount of
bandwidth available, just ratios?

rt only applies to leaves and is the guaranteed bandwidth and must
aggregate to <= ul if all guarantees are to be honored?

Very important for my understanding, specifying rt and ls in the same
class is NOT the mechanism used for decoupling latency guarantees from
bandwidth allocations.  That is simply specifying that available
bandwidth will be obtained in a different proportion than the guaranteed
bandwidth.  The decoupling of latency from bandwidth happens by having a
dilinear service curve, i.e., specifying either m1, d, and m2 or
specifying umax, dmax, and rate where umax/dmax != rate.  Is that
correct? If I have that wrong, I think I really missed the point (which
is quite possible!).

So, it then seems like:
virtual time is dependent upon ls
eligible time is dependent upon available bandwidth as determined by ul
and ls
deadline time is dependent on the curve which is why a dilinear curve
can be used to "jump the queue" so to speak or to drop back in the
queue.

This raises an interesting question about dilinear curves and ul.  If m1
is being used to "jump the queue" and not to determine guaranteed
bandwidth, do we need to take into account the resultant bandwidth
calculation of m1 when ensuring rt <= ul? To illustrate, let's say we
have a 100kbits link.  We give interactive traffic 40kbits, VoIP
20kbits, and bulk 40kbits so rt = ul.  However, we specify interactive
as rt 1534b 10ms 40kbits and VoiP as rt 254b 10ms 20kbits.  The m1 rate
puts us way over ul (~= 400kbits + 200kbits + 40kbits).  Is this OK
since it is not actually the guaranteed bandwidth but just the data used
to calculate deadline? I am guessing that if we are in the situation
where packets simply cannot be transmitted fast enough to meet the
requested deadline that this implies we do not have sufficient eligible
time and so deadline becomes moot.


If I've got that right, does the following illustration hold:
Let's assume we have a T1 at 1.544 Mbps (if I've remembered that
correctly).  So we create the highest level child class with a ul of 1.5
Mbps to keep it slightly under the link speed to ensure we do not trip
QoS on the upstream router.  Hmm . . . I suppose that principle would
not hold true in a shared environment like cable or DSL.  In any event,
I think that means 1536kbits in tc-speak.

We then create five child classes named Interactive, VoIP, Video, Web,
and Bulk with the following characteristics and settings:

Bulk is basically everything that has no latency sensitivity and can
tolerate dropped packets.  We assign it rt=100kbits just to keep it from
being starved when other classes are highly active but we'd like it to
access excess bandwidth a little more aggressively so we set
ls=300kbits.  Does this seem reasonable?

Interactive must nowadays include VDI so it is no longer small ssh or
telnet packets.  It needs to accommodate full sized Ethernet packets in
order to transfer screens with a minimum of latency.  It is moderately
latency sensitive and cannot tolerate dropped packets.  I'll assume umax
needs to account for Ethernet header, CRC, preamble, and IFG.  We want
this router to add no more than 30ms to any interactive session.  Thus
we define it with:
rt umax 1534b dmax 30ms rate 300kbits ls rate 500kbits
We defined ls because we want this type of traffic to aggressively
acquire excess bandwidth if we need more than we have guaranteed.
1534b/30ms~=409kbits so we have a concave service curve.

VoIP is very latency sensitive and cannot tolerate drops.  We want to
add no more than 10ms latency to the traffic flow.  We are figuring that
ulaw/alaw will produce the largest packets at 254b including IFG et al.
So we define it as:
rt umax 254b dmax 10ms rate 200kbits ls rate 500kbits
254b/10ms~=203kbits so we have a slightly concave service curve.  This
raises an interesting question.  What if we had set dmax to 20 ms? This
would have given us a convex service curve where m1 != 0.  Is that
illegal? I thought the specification said any convex curves must have m1
= 0.  If it is illegal and we did this by accident, what would happen?

Video is always a problem :) We need to guarantee a large amount of
bandwidth but we also do not want to be eaten alive by video.  We
characterize it as very latency sensitive but we would rather tolerate
drops than queueing and unwanted latency.  Hmm . . . is queue depth
induced latency even an issue with HFSC?
In any event, we want to introduce no more than 10ms latency.  The
typical frame size is 16Kb and there is no difference between the rt and
ls rate so we define the class with:
sc umax 16kbits dmax 10ms rate 400kbits
Interestingly, m1 (1.6Mbps) exceeds ul.  As asked previously, is this a
problem?

Web follows the example cited in my previous email.  We want the text
and css of the served web pages to load quickly.  Larger, non-text data
can take a back seat.  We will guess that the average text is 10KB and
we want to introduce no more than 200ms to start loading the page text.
We thus define it as:
rt umax 80kbits dmax 200ms rate 200kbits ls 400 kbits

Is this setup reasonable, practical, and reflecting a proper
understanding of HFSC or have I missed the boat entirely and need to go
to the back of the class? Thanks to anyone who has taken the time to
read this novel :) - John

From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: [WARNING - VERY LONG] A sysadmin's understanding of HFSC and
 IFB
Date: Wed, 14 Dec 2011 05:32:52 -0500
Message-ID: <1323858772.8451.203.camel@denise.theartistscloset.com>
References: <1323415051.3159.25.camel@denise.theartistscloset.com>
	 <1323417599.2529.18.camel@edumazet-laptop>
	 <1323817279.8451.7.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:57633 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755283Ab1LNKc6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 05:32:58 -0500
In-Reply-To: <1323817279.8451.7.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-13 at 18:01 -0500, John A. Sullivan III wrote:
> On Fri, 2011-12-09 at 08:59 +0100, Eric Dumazet wrote:
> > Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 02:17 -0500, John A. Sulli=
van III a
> > =C3=A9crit :
> > > Hello, all.  I've been trying to summarize my last week's worth o=
f
> > > research into HFSC and IFB.  Being neither a developer nor a
> > > mathematician, I found most of the existing documentation dauntin=
g and
> > > am truly grateful for the help I received on this list to underst=
and the
> > > technologies.
> > >=20
> > > I do not currently have a blog to post this research and so was t=
hinking
> > > of posting it to this list so that it could be archived and searc=
hable
> > > for other poor sysadmin types like me to save them the days of
> > > struggling to get their practical heads around the concepts.
> > >=20
> > > However, since this is probably a 15 page or so document, I reali=
zed
> > > this could be quite rude to those on dial up or metered connectio=
ns.
> > > Would it be appropriate to post my summary here? Thanks - John
> > >=20
> >=20
> > Please post here, thats definitely a good idea.
> >=20
> > I am pretty sure your contribution could serve to add a page to=20
> >=20
> > http://www.linuxfoundation.org/collaborate/workgroups/networking/gr=
oup
> >=20
> > I believe we lack documentation. A lot.
> <snip>
> OK - it's almost ready.  The only problem I know if is that, when I d=
o
> the math based upon my explanation, I sometimes violate an rt curve w=
hen
> I should not.  I posed that in an email to the list entitled "An erro=
r
> in my HFSC sysadmin documentation".  If anyone can figure out where m=
y
> error is, I will gladly change the documentation.  Here's what I have=
=2E
> The graphics except the ASCII art are obviously missing.  All
> corrections and suggestions very gratefully accepted - John
>=20
<snip>
Thanks to Michal's help, I took the time to understand how service
curves are updated and the practical implications for system
administration.  I thus added two sections to the very end of the
document - one on service curve update details and the other on general
guidelines.  I'll paste in those additions here. They bring the entire
document to somewhere around 22 pages.  Unfortunately, the non-ascii
graphics will be lost in the email.

PLEASE PROTECT OTHERS FROM ME :) This document is based upon my very ne=
w
and raw knowledge.  I have not yet run this through our lab and do not
have practical experience.  I would hate for this email to become an
authoritative document simply by its presence.  If there is something
wrong, please point it out.  Thanks.  Here goes:


Service curve updates in detail
This section is probably beyond what most system administrators need to
know to configure their systems but is included for completeness or for
those who may need more information to troubleshoot a configuration
which may not be behaving as expected.  If you do not need this much
detail, skip to the summary guidelines section.
As mentioned above, it is the complicated subject of updating service
curves which transforms HFSC's ability to guarantee latency separately
from bandwidth from an interesting theory with little practical
application into a fabulously powerful and practical traffic shaping
tool.  So how do these updates work?
Service curves are usually represented as a two dimensional graph - a
line with either one or two slopes with an x and y axis.  The x axis is
elapsed time and the y axis is service or work rendered.  Translated ou=
t
of mathematical formula terms and into system administrator terms, the
work or service rendered is the number of bits sent out of the queue.
That's why the slope of the line equals the bandwidth.  If we choose a
dot on the line (curve) where the y coordinate is 100kbits dequeued and
the x coordinate is 100ms elapsed, then the slope is 100kbits/0.1s =3D =
1
Mbps.
When a queue first becomes backlogged, i.e., when it first has packets
to send, it starts to track the service curve, i.e., how many bits have
been delivered over how much time.  While it is backlogged, i.e., has
packets to send, the queue is active.  Once the packets are all dequeue=
d
and there are no more to send, the queue becomes passive.  Now more
packets arrive and the queue becomes active, backlogged.  At this point=
,
the service curve needs to be updated.  We'll walk through this process
in several stages of increasing complexity.
The bottom line is that HFSC will dequeue the packets at the lesser of
the work which would have been rendered if we had been continually usin=
g
the previous service curve (the curve we were using when the queue was
last backlogged) or the work that would be rendered if we started the
queue over again.  What in the world does that mean?! Once we understan=
d
it, it is actually a very practical way of making sure we can always
meet our guarantees and not overrun our circuit as long as the sum of
the rt m2 curves does not exceed the total bandwidth, i.e., as long as
we sys admins have done our job properly.  Let's take it apart piece by
piece to understand it.
Let's start with a very simple, monolinear rt service curve (i.e., the
m1 slope =3D the m2 slope) with no link sharing (no extra bandwidth
allocated).  Let's say the guaranteed bandwidth is 100 kbps.  Let's say
the queue initially goes active for one second so we have transmitted
100 kbits:
        |
200kbits|
        |
        |
100kbits|  x/
        |  /
        | /
  0kbits|/_________
        0s 1s 2s
Now let's say the queue goes passive, i.e., nothing to transmit, for on=
e
second taking us to a total elapsed time of 2 seconds and the goes
active again.  HFSC will extrapolate what the total number of bits
dequeued (in HFSC terms, work performed) would have been if there had
been no passive period.  It then compares this to the total number of
bits transmitted so far (work already performed) plus how many new bits
we would transmit if we started the rt curve over again (this will make
more sense when we demonstrate this with dilinear curves).  It chooses
whichever would result is the least amount of work performed, i.e., the
fewest bits dequeued.  I'll represent this in the graph below by
extrapolating the first curve, sliding the amount of data already
transmitted (the x) over to the new elapsed time (the time the queue
became backlogged again), and then starting the original line from that
point:
300kbits|        z/
        |        /
        |       /
200kbits|      / z/=20
        |     /  /
        |    /  /
100kbits|  x/.x/
        |  /
        | /
  0kbits|/_________
        0s 1  2  3
Using the rt curve starting over again results in less work than if we
had been continually transmitting using the previous service curve (z)
so that is the rate at which we will dequeue.  In the case of monolinea=
r
curves, that will always be the case.  It may not be the case in
dilinear curves.  Look at this illustration taken once more from
http://www.sonycsl.co.jp/~kjc/software/TIPS.txt :
                                                     ________
                                     ________--------
                                    /                  ______
                                   /   ________--------
                       ________---+----       =20
                      /          /            =20
                     /          /             =20
    total    ->     /          + new coordinate               =20
                   /                          =20
                  /                           =20
           service curve       |
                 of            +
          previous period   current
                             time

                        Update Operation

                                                       ______
                                       ________--------
                                  +----       =20
                                 /            =20
                                /             =20
    total    ->                + new coordinate               =20
                                              =20
                                              =20
                               |
                               +
                             current
                             time

                        New Service Curve

That can be a bit confusing. Let's go back and take it one step at a
time.  Unfortunately for those viewing this in text only, the next
several illustrations are difficult to render in ASCII art so we will
use graphics.
Let's consider the same monolinear rt service curve but this time there
will be some additional bandwidth added due to link sharing.
The solid black line is the first backlog period m2 curve, i.e., the
guaranteed bandwidth (100 kbits/s).  It is backlogged for 1s.  However,
more data is transmitted than 100 kbits because link sharing has
allocated another 50 kbps so the total data transmitted is 150 kbps.
This is represented by the green line.  The link goes passive for 1s an=
d
then goes active again for another 1s.  The dashed black line shows the
data trajectory of the previous service curve, i.e., it shows how much
work would have been done (how many bits would have been dequeued) if i=
t
had remained backlogged.  That is one point of comparison. The second
point of comparison is to take the total actual work done (the total
bits transmitted so far) and use that as the y starting point for a new
curve beginning with x at the current time.  This is the blue line.  Th=
e
only difference from the first illustration is that the second point
started  at a higher point on the y axis, i.e., with more bits already
dequeued, than the last time because of the link sharing bandwidth.  Th=
e
end result is the same - the new curve is chosen as the dequeuing rate.
What happens if link sharing gave us a lot of extra bandwidth, say 200
kbs?
In this case, so much extra data was transmitted that the amount of wor=
k
done by starting the curve over again exceeds the amount of work that
would have been done if the previous service curve had remained
backlogged so HFSC will choose to dequeue at the rate of the previous
service curve.  However, once again, the end result is the same because
the slope of the curves are the same, i.e., the bandwidth.




Now let's make the leap to see what happens with dilinear service
curves, i.e., where we are specifying latency separately from bandwidth=
=2E
In this case, lets say that m1 (the latency determining, temporary
bandwidth) is 200 kbps for a period of 1s and m2 (the guaranteed,
sustained bandwidth) is still 100 kbps and we have no additional
bandwidth from link sharing.  Let's say the first backlogged period
lasts two seconds, then there are two seconds of idle time followed by
one second of backlog.  HFSC will compare these two curves:

Notice the change in rate at 1s.  Once again, the black line is the
first service curve - the solid part being the actual transmission and
the dotted portion being the extrapolation as if it was continually
backlogged.  The blue line is the second service curve.  Notice that it
starts at the faster m1 rate.  Since the total work done, i.e., bits
dequeued is less when using the second curve, that is the one HFSC uses
to dequeue.  The effect is that the new packets are sent at the
accelerated rate and receive the full benefit of HFSC's ability to
separately guarantee latency and bandwidth.
Now, let's change the scenario.  Let's say the idle time between
backlogs is only 0.5s instead of 2s.  The curve comparison looks like
this:

Notice how the two service curves cross.  For the first half a second,
the number of bits which would be dequeued using the fully reset servic=
e
curve would be less than if the previous service curve had been
continually backlogged but, for the next half a second, the number of
bits which would be dequeued using the previous service curve is less.
In this case, HFSC will dequeue bits at the faster m1 rate for the firs=
t
half a second and then slow down to the m2 rate of the previous service
curve for the next half a second.  The service curve is "partially
reset" and the packets receive a partial "acceleration."
Let's consider one last scenario.  It is the same as the previous
scenario except that link sharing has added 50 kbps to the first two
seconds of dequeuing.  Because more work has been done, i.e., more bits
have been dequeued, the second curve will start its trajectory higher i=
n
the graph because it always starts with how much work has already been
done, i.e., how many bits have already been dequeued.  Thus, the graph
looks like this:

Now note that, for the entire second period of backlog, the
extrapolation of the previous service curve would produce less work,
fewer bits, than starting a fresh curve.  In this case, the service
curve is not "reset" at all, the m2 rate of the previous service curve
is used for the entire dequeuing process and the packets receive no
acceleration however they will all be delivered on time because our m2
rate is guaranteed.
Piecing it all together and bringing the theory back to practical
application, we see that the total number of bits dequeued can never be
more than if the first service curve had remained permanently
backlogged.  This is how we can be sure we will never overrun the
circuit bandwidth assuming we have done our job of ensuring the sum of
the bandwidth guarantees do not exceed the circuit capacity.
However, in practicality, we can cheat a little bit.  In most cases, we
can simply be sure that the sum of the rt m2 service curves do not
exceed the circuit bandwidth.  If we need to set higher m1 curves to
guarantee latency, the sum of the rt m1 service curves could exceed
circuit capacity.  However, any idle time would quickly remedy the
situation (unless our m1 rates are excessively over capacity).
The only situations in which we could not practically cheat are the
extreme scenarios when, under no circumstances whatsoever can we
possibly not meet our guarantees (perhaps life critical systems) or
where the circuits are incredibly saturated and all queues are
constantly backlogged (in which case we probably have a bigger, non-HFS=
C
problem!).
Summary guidelines
Recall that HFSC classes call for defining any of ul, ls, sc, or rt
service curves.  We can use the following guidelines for the values of
these curves.  Remember these are guidelines.  Your needs may dictate a
different configuration.
ul
Set the ul service curve to just under the circuit capacity in a
dedicated circuit (to avoid tripping the carrier's traffic shaping) or
equal to the circuit capacity in a shared circuit (like DSL or Cable
where other users outside our control are adding traffic to ours so we
cannot avoid the carrier's traffic shaping).
Use a monolinear curve, i.e., only specify rate and not umax and dmax.
Set it at the highest level class and nowhere else (since it, in effect=
,
flows down through the hierarchy) unless you need to specifically limit
link sharing at a lower level in the hierarchy. Recall that ul does not
limit bandwidth guaranteed by rt.  Thus, one way of limiting bandwidth
at a leaf node is to simply specify the rt curve at the maximum amount
and do not specify an ls curve; this means it will nor borrow additiona=
l
bandwidth.  One would only need to specify ul in this case if one wante=
d
the leaf to be able to borrow above the rt guarantees but only up to a
set amount.  Finally, one might use a lower level ul if one wanted to
limit the bandwidth allocated to a non-leaf node (a branch).  Remember,
branches do not have rt curves and so one cannot limit bandwidth that
way. Thus, the only way to hard limit a branch is to set ul.  To
reiterate, ul is usually set only at the top level class.
When specifying a ul service curve, one must also specify an ls service
curve.  One cannot specify a ul curve  without an ls curve.
ls
The ls service curve is used ONLY to calculate link sharing, i.e., how
to allocate extra available bandwidth.  It does not specify directly ho=
w
much bandwidth a queue receives.
If a class does specify an ls service curve either directly or
indirectly (by specifying an sc service curve), it will not receive any
extra bandwidth over its rt service curve.
Only the ratios of ls service curves are important, not the values.
Nonetheless, for sanity's sake, it makes sense to use ls service curve
values which have some relevance to the circuit size.
Use monolinear ls service curves.
ls service curves and ul service curves are the only types of service
curves which can be applied to branches. This is how traffic is divided
between the branches of a hierarchy.  Remember that extra bandwidth is
only divided between peers at the same level in the hierarchy.
Use ls service curves on leaf nodes if you want the leaf node to use
extra bandwidth if it is available.
If the ratio in which extra bandwidth should be allocated is the same
ratio in which it is guaranteed, i.e., the ls service curve is the same
as the rt service curve, both can be specified in a single definition
using the sc service curve, i.e., no need for separate ls and rt
entries.  Use separate ls and rt definitions in a leaf node if the rati=
o
at which extra bandwidth is allocated is different than the ratio in
which it is guaranteed.  For example, we may have a small amount of
guaranteed bandwidth for our web server and a larger amount of
guaranteed traffic for all the rest of our bulk traffic but, if the web
site needs more bandwidth and there is contention for extra bandwidth
between web and bulk traffic, we want the web server to have top
priority.  Thus, the ratio of the web to bulk rt curves might be 1:5 bu=
t
the ratio of the ls curves 5:1.  This is one of the big advantages of
HFSC.
sc
Use sc service curves on leaf nodes when the rt service curve and the l=
s
service curves are identical.
Use monolinear sc service curves.  By implication, do not use sc servic=
e
curves if you want a dilinear rt curve, i.e., to guarantee latency
separately from bandwidth.
rt
The rt service curves are used for guaranteeing bandwidth and have
nothing to do with allocating extra available bandwidth.
If the minimum required latency is greater than the latency provided by
the guaranteed bandwidth, use a monolinear rt service curve.  For
example, let's say we have allocated 2 Mbps to VoIP traffic with a
maximum packet size of 222 bytes and we need latency of no more than 10
ms.  (222 * 8)/2,000,000(b/s) =3D 0.9ms per packet.  The latency provid=
ed
by the guaranteed bandwidth (the m2 curve) is already less than the
minimum latency we need so we do not need to specify a separate m1
curve.
If the minimum required latency is less than the latency provided by th=
e
guaranteed bandwidth, use a dilinear rt service curve.  For example,
let's say we have allocated 2 Mbps to video with a frame size of 8KB an=
d
the minimum latency for those frames should be 10ms.  (8000 *
8)bits/0.010s =3D 6.4 Mbps.  To meet our minimum latency, we need more
bandwidth than 2 Mbps so we need to specify an m1 curve which is steepe=
r
(more bandwidth) than the m2 curve so rt umax 64kbit dmax 10ms rate
2000kbit.
The rt service curves are NOT limited by the ul service curves.
Ensure that the sum of all the m2 rt curves, i.e., the sum of all the
guaranteed bandwidths, are less than or equal to the top level ul which
should be less than or equal to the circuit capacity.
Unless carried to excess, specify m1 rt curves where needed according t=
o
the queue latency requirements even if the sum of the m1 curves, i.e.,
the sum of all the temporary bandwidths necessary to meet the latency
guarantees, is greater than the top level ul.  Strictly speaking, this
violates the theory that HFSC should be able to meet all bandwidth
guarantees but, practically speaking, one can do this with no
deleterious effects except in the most extreme situations where all
queues are continually backlogged or there can be absolutely no
violation of guarantee whatsoever under any circumstances (perhaps life
critical systems).

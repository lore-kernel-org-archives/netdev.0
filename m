From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: RE: [RFC] TCP burst control
Date: Fri, 9 Jul 2004 11:36:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407091538.i69FcLQs028671@uni01mr.unity.ncsu.edu>
References: <Pine.LNX.4.60.0407071007420.2510@zippy.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>, <netdev@oss.sgi.com>,
        <rhee@ncsu.edu>, <lxu2@ncsu.edu>, "'John Heffner'" <jheffner@psc.edu>,
        "'Jamshid Mahdavi'" <jmahdavi@earthlink.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Matt Mathis'" <mathis@psc.edu>
In-Reply-To: <Pine.LNX.4.60.0407071007420.2510@zippy.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David and Matt,

The main cause of the problem is that the current linux implementation of
TCP does not follow RFC, especially by incorporating its own burst control
mechanisms. Rate halving is a form of burst control -- but this is not part
of the problems. *The cause is the use of packet-in-flight to moderate
cwnd*. This is not part of the standard and it interferes with a lot of
congestion control functions including rate halving. Let me give you some
more information below.

When fast recovery kicks in, packet-in-flight (flightSize) can be very small
because of lost packets. This is even more so with high speed connections
having large cwnd values (i.e., you lose more packets with these
connections). Because flightSize is small, but cwnd is still very large
compared to flightSize (even after cwnd reduction due to fast recovery),
there could be a lot of burst. This burst happens because the connection can
send as many as (cwnd - flightSize) at a time. Here the current
implementation makes mistake by reducing cwnd to flightSize + C -- this is a
violation of RFC 2851. This surely helps burst -- because it does not send
any new packets for a long time :-)

Since cwnd becomes very close to flightSize, rate halving obviously does not
work here. Note that rate halving gradually reduces cwnd to the half of cwnd
as duplicate acks are arriving. But this burst control of Linux makes rate
halving ineffective because cwnd is anyway reduced far below the half of
cwnd because flightSize is far less than the half. 

This feature not only creates a lot of oscillation in transmission (so
making the flow very unstable), but also reduces the throughput very
significantly. Look at the link below: the experimental results with the
current linux burst control with a scalable TCP flow. You can see that a
back-to-back loss leaves big gaps in transmission. We chose Scalable TCP for
demo because STCP may show a bigger difference as it has more fast recovery
per second. There are three of them.

http://www4.ncsu.edu/~lxu2/stcp_burst/

In the link, you can also find the experiment with our new burst control. It
makes the flow quite smooth. 

This is a real problem (I would say a bug) with the current implementation
that it does not follow RFC. In contrast, our implementation does not
violate RFC since we are not modifying cwnd at all because of flightSize. We
leave cwnd to congestion control. The burst control is just to regulate the
transmission so that it would not create the burst; cwnd is only the
guidance on how many packets you can send at a time and the burst control is
simply to adjust the transmission to match cwnd, but without creating too
much burst. In this regard, our control is pretty good. It may not be the
best one and requires more work to find the optimal control, but you cannot
go wrong with our technique since it does not violate RFC and it only makes
improvement. 

Along with burst control, I would like to add one additional mechanism in
ack processing. This does not cause any behavior change with TCP stack - it
is going to make it run faster. Just implementation suggestion. When
processing selective acks, the current linux implementation does too much
redundant work; since some sack blocks are duplicates, duplicate sack blocks
do not need a processing again. We need to remove this redundancy to speed
up sack processing. Also every time that a new sack arrives, the current
implementation performs a linear search on a list. This causes a lot of
overhead especially with high speed -- because you are receiving many ACKs.
This search processing can be greatly enhanced with a simple caching scheme.
All these changes require only a few lines of code. Again, no behavior
changes and just improves the speed. Also it is general enough to be used
with any TCP variants. Our test indicates this simple mechanism is good
enough (no need for any fancier implementation as HTCP suggests), and is
originally implemented by Tom Kelly. 

Ok. enuf arguing and rest my case here.
Injong and Lisong.

> -----Original Message-----
> From: Matt Mathis [mailto:mathis@psc.edu]
> To: Injong Rhee
> Cc: 'David S. Miller'; Stephen Hemminger; netdev@oss.sgi.com;
> rhee@ncsu.edu; lxu2@ncsu.edu; John Heffner; Jamshid Mahdavi
> Subject: RE: [RFC] TCP burst control
> 
> Yes, Injong is correct about the problem with Rate Having.  I haven't
> looked at
> his fix to see if I agree with it, but let me summarize the problem that
> we
> never finished (and prevented us from formally publishing it).
> 
> Basicly if the sender is under fluctuating resource stress such that awnd
> (the
> actual window) is frequently less than cwnd (remember this was written
> BEFORE
> cwnd validation.) then a loss that is detected when awnd is at a minimum
> sets
> cwnd to an unreasonably small value that has nothing to do with the actual
> state of the network.  Since we also set ssthresh down to cwnd, this takes
> "forever" to recover.
> 
> The real killer is if the application is periodicly bursty, such as
> copying
> >from older unbuffered disks or timesharing systems running other compute
> bound
> applications (normal for supercomputers).  Under these conditions TCP
> suffers
> >from frequent idle intervals, each restarting with a full window burst
> (pre-cwnd validation!).  If the burst was just slightly larger than the
> network
> pipe size, then the packets at the end of the burst are most at risk of
> being
> dropped.  When the ACKs for subsequent packets arrive and the loss is
> detected,
> awnd will be nearly zero, resulting in nearly zero cwnd and ssthresh......
> 
> We were in the heat of investigating solutions to this and other related
> problems (there are multiple potential solutions), when we realized that
> autotuning is orders of magnitude more important (at least to our users).
> 
> As the code points out there are other corner cases that we missed, such
> as
> reordering and such.  In principle I would like to come back to congestion
> control work, revisit FACK-RH and fold in all of the new stuff such as
> cwnd
> validation and window moderation.  (BTW I would not be surprised if these
> algorithms don't play nicely with rate halving - each was designed and
> tested
> without considering the effects of the others).
> 
> Thanks,
> --MM--
> -------------------------------------------
> Matt Mathis      http://www.psc.edu/~mathis
> Work:412.268.3319    Home/Cell:412.654.7529
> -------------------------------------------
> Evil is defined by mortals who think they know
> "The Truth" and forcibly apply it to others.
> 
> On Wed, 7 Jul 2004, Injong Rhee wrote:
> 
> >
> > Hi David,
> >
> > Let me clarify the issue a little. In my earlier message, I might have
> > sounded like accusing rate halving of the burst problem and window
> > oscillation. I might have misrepresented it a little in the heat of
> writing
> > the email too fast :-). In fact, rate halving helps ease burst during
> fast
> > recovery as written in the Internet draft.
> >
> > The main problem lies in the variable that rate halving is closely
> > interacting with in TCP SACK implementation: packet_in_flight (or
pipe_).
> In
> > the current implementation of Linux TCP SACK, cwnd is set to
> > packet_in_flight + C for every ack for CWR, recovery, and timeout-- Here
> C
> > is 1 to 3. But many times, packet_in_flight drops *far* below cwnd
> during
> > fast recovery. In high speed networks, a lot of packets can be lost in
> one
> > RTT (even acks as well because of slow CPUs). If that happens,
> > packet_in_flight becomes very small. At this time, Linux cwnd moderation
> (or
> > burst control) kicks in by setting cwnd to packet_in_flight + C so that
> the
> > sender does not burst all those packets between packet_in_flight and
> cwnd at
> > a single time. However, there is a problem with this approach. Since
> cwnd is
> > kept to very small, the transmission rate drops to almost zero during
> fast
> > recovery -- it should drop only to half of the current transmission rate
> (or
> > in high-speed protocols like BIC, it is only 87% of the current rate).
> Since
> > fast recovery lasts more than several RTTs, the network capacity is
> highly
> > underutilized during fast recovery. Furthermore, right after fast
> recovery,
> > cwnd goes into slow start since cwnd is typically far smaller than
> ssthrsh
> > after fast recovery. This also creates a lot of burst -- likely causing
> back
> > to back losses or even timeouts.
> >
> > You can see this behavior in the following link:
> >
> >
> http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments
> /B
> > IC-600-75-7500-1-0-0-noburst/index.htm
> >
> > We run in a dummynet without any change in the burst control. You can
> see
> > that whenever there is fast recovery, the rate almost drop to zero. The
> pink
> > line is the throughput observed from the dummynet at every second, and
> red
> > one is from Iperf. In the second figure, you can see cwnd. It drops to
> the
> > bottom during fast recovery -- this is not part of congestion control.
> It is
> > the burst control of Linux SACK doing it.
> >
> > But with our new burst control:
> >
> >
> http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments
> /B
> > IC-600-75-7500-1-0-0/index.htm
> >
> > You can see that cwnd is quite stabilized and the throughput does not
> have
> > as much dip as in the original case.
> >
> > Here is what we do: instead of reducing cwnd to packet_in_flight (which
> is,
> > in fact, meddling with congestion control), we reduce the gap between
> these
> > two numbers by allowing transmitting more packets per ack (we set this
> to
> > three more packets per ack) until packet_in_flight becomes close to
cwnd.
> > Also right after fast recovery, we increase packet_in_flight by 1% of
> > packet_in_flight up to cwnd. This reduces the huge burst after fast
> > recovery. Our implementation is trying to leave cwnd only to congestion
> > control and separates burst control from congestion control. This makes
> the
> > behavior of congestion control more predictable.  We will report more on
> > this tomorrow when we get back to the Lab to test some other
> environments,
> > especially when we have smaller buffers. This scheme may not be the cure
> for
> > all and needs more testing. So far, it has been working very well.
> >
> > Stay tuned.
> > Injong.
> > ---
> > Injong Rhee, Associate Professor
> > North Carolina State University
> > Raleigh, NC 27699
> > rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee
> >
> >
> >
> > -----Original Message-----
> > From: David S. Miller [mailto:davem@redhat.com]
> > Sent: Tuesday, July 06, 2004 8:29 PM
> > To: Injong Rhee
> > Cc: shemminger@osdl.org; netdev@oss.sgi.com; rhee@ncsu.edu;
> lxu2@ncsu.edu;
> > mathis@psc.edu
> > Subject: Re: [RFC] TCP burst control
> >
> > On Tue, 6 Jul 2004 20:09:41 -0400
> > "Injong Rhee" <rhee@eos.ncsu.edu> wrote:
> >
> >> Currently with rate having, current Linux tcp stack is full of hacks
> that
> > in
> >> fact, hurt the performance of linux tcp (sorry to say this).
> >
> > If rate-halving is broken, have you taken this up with it's creator,
> > Mr. Mathis?  What was his response?
> >
> > I've added him to the CC: list so this can be properly discussed.
> >

From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: An error in my HFSC sysadmin documentation
Date: Fri, 09 Dec 2011 14:35:25 -0500
Message-ID: <1323459325.3159.73.camel@denise.theartistscloset.com>
References: <1323455084.3159.63.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:56264 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab1LITf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 14:35:28 -0500
In-Reply-To: <1323455084.3159.63.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-09 at 13:24 -0500, John A. Sullivan III wrote:
> Hello, all.  As I mentioned, I'm trying to compile documentation on IFB
> and HFSC from a sysadmin's perspective but I think I have an error in
> the way I'm explaining how HFSC determines when to send which packet to
> meet bandwidth and latency guarantees of the rt service curve.  I'll
> show where my math is breaking down in the hope someone can see and
> correct my error.
Argh!! After walking through it again, correcting my original error and
using much closer rounding, I still hit a problem.  I'll paste in the
documentation I've written on deadline time and the walk through of how
it works but, at the very end, Queue B's rt service curve is violated
when it should not be:

<snip>
Deadline time is closely related to eligible time and is likewise
measured against clock time.  However, deadline time is measured against
the end or tail of the packet, i.e., by when must we have finished
sending this packet at the specified bandwidth in order to meet our
packet delivery guarantees for bandwidth and latency.  Once again,
http://www.sonycsl.co.jp/~kjc/software/TIPS.txt has an excellent ASCII
graphic for illustrating the relationship between eligible time measured
at the beginning of the packet and deadline time measured from the end:
                    bytes         
                         |                   /
                         |                  /service curve
                         |                 /
           next   -->+   +----------------+
           packet    |   |               /|
           length    |   |              / |
                     |   |             /  |
      cumulative --> +   +------------+   |
           bytes         |           /|   |
           already       |          / |   |
           sent          |         /  |   |
                                  /   |   |
                                      |   |
                                      |   |
                              --------+---+--------------> time
                                eligible  deadline
                                time

This time, the slope is the rt service curve.  The way in which HFSC
chooses from among several different queues all with packets whose
eligible time is greater than current clock time is almost identical to
the way it chooses among backlogged queues with virtual time, viz., it
chooses the packet with the lowest deadline time.  Remember that the
steeper the curve, the greater the bandwidth and the shorter the
distance between eligible time and deadline time for the same sized
packet.
Let's walk through a real example.  We have Queue A with VoIP traffic -
small, 222 byte packets and an rt service curve bandwidth such that it
takes 0.2ms to send its packets; that equates to roughly 8.88 Mbps ((222
* 8)bits/0.0002s).  Let's also assume that we have so much VoIP traffic
that the queue is filled so we always have a VoIP packet asking to be
dequeued.  Queue B is sending FTP with large packets and an rt service
curve rate such that each packet takes 2ms to send; this equates to
6.056 Mbps ((1514 * 8)bits/0.002s).  Queue B is also completely full.
Let's assume that the maximum bandwidth available is the sum of the
guaranteed bandwidths, viz., 14.936 Mbps.  This will allow us to
calculated the progress of clock time, i.e., how long it actually takes
to send each packet.  Also remember that each packet has a 4 byte CRC,
and 8 byte preamble, and a 12 byte interframe gap time at least in
traditional Ethernet.  Thus to transmit a packet in Queue A, we really
need to transmit 246 bytes and, to transmit one in Queue B, we need to
transmit 1538 bytes.  Thus, the elapsed time to send a Queue A packet is
(246 * 8)bits / 14,936,000(b/s) = 0.132ms and the time to transmit a
Queue B packet is (1538 * 8)bits / 14,936,000(b/s) = 0.824ms.  Sorry for
all the math but this is what is inside the black box (and a very
simplified version!).
Let's assume that clock time (CT - the actual time) is 1000ms (not
realistic but it makes the explanation easier!).  The next packet queued
in Queue A has an ET (eligible time) of 1000ms and the next packet in
Queue B has an ET of 999ms, i.e., both are eligible to be sent.  A less
sophisticated traffic shaping algorithm would send the FTP packet first.
However, HFSC calculates the deadline time (DT) for the packet in Queue
A at 1000.2 (1000 + 0.2) and the deadline time for the packet in Queue B
at 1001ms (999 + 2) so it sends A instead since it has the smaller DT.
0.132ms has elapsed in real time so CT is now 1000.132.  The
eligible/deadline times (ET/DT) for A and B respectively are
1000.2/1000.4 and 999/1001.  Notice that A is no longer eligible to send
because its ET > CT so B is serviced.  0.824ms has elapsed to send B's
packet so CT is now 1000.956.  ET/DT for A is still 1000.2/1000.4 but B
has changed to 1001/1003.  B just misses being eligible to send but A is
eligible so A is sent.  Elapsed time is 0.132, CT is now 1001.088, ET/DT
for A is 1000.4/1000.6.  Both A and B are eligible at the same time
again as both their ETs <= CT.  A's DT is less than B's DT so A is
serviced.  
In fact, A will send 11 packets.  Let's see the result after A sends 11
packets.  Elapsed time is 11* 0.132 = 1.452ms so clock time is 1002.54.
A's ET/DT have incremented by 11 * 0.2 so they are 1002.6/1002.8.  B's
ET/DT have remained at 1001/1003.  A is no longer eligible so the fact
that its DT is less than B's DT is irrelevant.  B is serviced.

Here's the problem.  B is serviced when clock time is 1002.54.  It takes
0.824 to send B's packet so it has finished dequeueing at 1002.54 +
0.824 = 1003.364 which violates B's deadline time of 1003.  That seems
too big for a rounding error.  Where am I wrong? Thanks - John

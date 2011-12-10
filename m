From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 10 Dec 2011 13:35:03 -0500
Message-ID: <1323542103.3159.148.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
	 <1323531352.3159.106.camel@denise.theartistscloset.com>
	 <4EE39D88.9010002@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:59481 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab1LJSfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 13:35:10 -0500
In-Reply-To: <4EE39D88.9010002@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-10 at 18:57 +0100, Michal Soltys wrote:
> On 11-12-10 16:35, John A. Sullivan III wrote:
> > Makes perfect sense but seems to confirm what I was thinking.  There
> > seems to be little practical use for the m1 curve.  Assuming the
> > queues are often backlogged (or we would not be using traffic
> > shaping), m1 only applies for a typically very short period of time,
> > perhaps one packet, after that, the latency is determined exclusively
> > by m2.  So, unless I've missed something (which is not unlikely), m1
> > is very interesting in theory but not very useful in the real world.
> > Am I missing something?
> 
> You forgot about how curves get updated on fresh backlog periods.

I was wondering if that was the key!
> 
> If your important traffic designated to some leaf is not permanently
> backlogged, it will be constantly switching between active/inactive
> states. Any switch to active state will update its curves (minimum of
> previous one vs. fresh one anchored at current (time,service)), during
> which it will regain some/all of the m1 time.
> 
> For simplicity, say you have uplink 10mbit, divided into two chunks
> chunks (A and B) with convex/concave curves. On A there's 24/7 torrent
> daemon, on B there's some low bandwidth latency sensitive voip/game/etc.
> The B will send 1 packet, maybe a few and go inactive - possibly for
> tens/hundreds of miliseconds. Next time the class becomes backlogged,
> the curves will be updated, and almost for sure the whole new one will
> be chosen as the minimum one - and m1 will be used. In a sort of way -
> m1 will be (for the most part) responsible for "activation"
> latency-sensitive bandwidth, and m2 will be more responsbile for the
> bursts. Difference between m1 and m2 and 'd' duration of m1 will skew
> the role.
> 
> Perhaps easier example: setup as above, but put a ping on B with 100ms
> delay between sends. Every single one of those will go at m1 speed
> (crazy curve setups aside).
> 
> Similary, if you consider A's RT set to say 5mbit, and B to 4mbit/2mbit
> (and LS fifty/fifty). And some video in B now, that doesn't push itself
> more than 2mbit. Each packet of B will use m1.
<snip>
So, again, trying to wear the eminently practical hat of a sys admin,
for periodic traffic, i.e., protocols like VoiP and video that are
sending packets are regular intervals and thus likely to reset the curve
after each packet, m1 helps reduce latency while m2 is a way of reducing
the chance of overrunning the circuit under heavy load, i.e., where the
concave queue is backlogged.

When we start multiplexing streams of periodic traffic, we are still
fine as long as we are not backlogged.  Once we are backlogged, we drop
down to the m2 curve which prevents us from overrunning the circuit
(assuming the sum of our rt m2 curves <= circuit size) and hopefully
still provides adequate latency.  If we are badly backlogged, we have a
problem with which HFSC can't help us :) (and I suppose where short
queues are helpful).

Thus concave curves seem very helpful for periodic traffic (probably the
type of traffic in mind when it was created) but less so for bursting
traffic.  Specifically, I'm thinking of the use case someone proposed to
accelerate text delivery from web sites.  As long as each web site
connection is isolated, it will work fine but, for a web server with any
kind of continuous load, they will be living on the m2 curve.  Then
again, maybe the queues empty more often than I expect :)

Thanks again.  A week ago, I didn't even know HFSC existed until I was
working on integrating Endian products (http://www.endian.com) with
Firepipes (http://iscs.sf.net) and noticed they were using hfsc.

If you have a chance, could you look at the email I sent entitled "An
error in my HFSC sysadmin documentation".  That's the last piece I need
to fall in place before I can share my documentation of this week's
research.  Thanks - John

From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: delack_timer expiration changes for every frame
Date: Wed, 02 Jun 2010 04:11:57 -0700 (PDT)
Message-ID: <20100602.041157.24595101.davem@davemloft.net>
References: <1274388439.2508.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751457Ab0FBLLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 07:11:47 -0400
In-Reply-To: <1274388439.2508.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 May 2010 22:47:19 +0200

> So we change the delack_timer by a positive delta (~ HZ/10) and a
>  negative delta (~HZ/10), on the typical netperf TCP_RR workload.

Yes, this is silly.

> Here, the incoming frame is handled by netperf, doing a recvmsg().
> tcp_send_delayed_ack() sets the delack_timer to jiffies + HZ/25
> 
> [  392.207721] timer->expires=23045, new expires=23019(10) diff=26 timer=e5ecb754
 ...
> [  392.209221]  [<c1279ce7>] ? tcp_send_delayed_ack+0xb5/0xc1
> [  392.209282]  [<c1276d26>] ? tcp_rcv_established+0x39f/0x4f7

HZ/25 is TCP_DELACK_MIN and TCP_ATO_MIN, but the actual value we use
here involves incorporation of various measurements made on the
connection (RTO, etc.)

 ...
> tcp_v4_rcv() sets the delack timer to 37 ticks, so mod_timer() optimizations is not
> working at all.
> 
> [  392.217454] timer->expires=23019, new expires=23049(37) diff=-30 timer=e5ecb754
 ...
> [  392.218765]  [<c127cf56>] ? tcp_v4_rcv+0x41c/0x6b7
> [  392.218826]  [<c1265832>] ? ip_local_deliver_finish+0xe9/0x178

There must be a tail-call here at tcp_v4_rcv() or something missed in
the backtrace stack scanning logic, because tcp_v4_rcv() and it's main
inline tcp_v4_do_rcv() do not modify established state socket timers,
and in particular do not modify the delack timer, that I can see.

It must be in via tcp_rcv_established() or similar.
...

Nevermind, it's the inlined prequeue stuff.

It uses a seperate calculation of the delack timer offset, independant
of the one made by tcp_send_delayed_ack(), it's timer offset formula is:

	(3 * tcp_rto_min(sk)) / 4

with a MAX of:

	TCP_RTO_MAX

So every time we go in and out of recvmsg() we'll hop between these
two different delayed ACK settings.

The prequeue logic is trying to stretch the delayed ACK to 3/4 of a
window of data.  It's set a bit high, intentionally, in the hopes that
we'll get the process into recvmsg() and have it emit it's response
packet from a subsequent sendmsg() (that the ACK can ride on) before
this timer fires.

But when we drop the socket lock to sleep or return to userspace, one
of the next packets is just going to reset this timer differently.

While the intentions of the prequeue code look legit, the use of two
different delayed ACK timeout schemes has bad implications elsewhere.

For example, if the delack timer does actually fire, there is this
ATO fixup code here:

		if (!icsk->icsk_ack.pingpong) {
			/* Delayed ACK missed: inflate ATO. */
			icsk->icsk_ack.ato = min(icsk->icsk_ack.ato << 1, icsk->icsk_rto);
		} else {
			/* Delayed ACK missed: leave pingpong mode and
			 * deflate ATO.
			 */
			icsk->icsk_ack.pingpong = 0;
			icsk->icsk_ack.ato      = TCP_ATO_MIN;
		}

which is totally wrong if the delack timer offset is the one
calculated by the prequeue code.  Doubling the ATO in that case
is completely the wrong thing to do.

So yes we have all kinds of inconsistencies here and we should
probably unify things so that the timer gets kicked less often.

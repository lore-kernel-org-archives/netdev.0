From: Michal Soltys <soltys@ziu.info>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 10 Dec 2011 18:57:28 +0100
Message-ID: <4EE39D88.9010002@ziu.info>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>  <4EE358A4.7060302@ziu.info> <1323531352.3159.106.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3970 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941Ab1LJR51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 12:57:27 -0500
In-Reply-To: <1323531352.3159.106.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-10 16:35, John A. Sullivan III wrote:
> Makes perfect sense but seems to confirm what I was thinking.  There
> seems to be little practical use for the m1 curve.  Assuming the
> queues are often backlogged (or we would not be using traffic
> shaping), m1 only applies for a typically very short period of time,
> perhaps one packet, after that, the latency is determined exclusively
> by m2.  So, unless I've missed something (which is not unlikely), m1
> is very interesting in theory but not very useful in the real world.
> Am I missing something?

You forgot about how curves get updated on fresh backlog periods.

If your important traffic designated to some leaf is not permanently
backlogged, it will be constantly switching between active/inactive
states. Any switch to active state will update its curves (minimum of
previous one vs. fresh one anchored at current (time,service)), during
which it will regain some/all of the m1 time.

For simplicity, say you have uplink 10mbit, divided into two chunks
chunks (A and B) with convex/concave curves. On A there's 24/7 torrent
daemon, on B there's some low bandwidth latency sensitive voip/game/etc.
The B will send 1 packet, maybe a few and go inactive - possibly for
tens/hundreds of miliseconds. Next time the class becomes backlogged,
the curves will be updated, and almost for sure the whole new one will
be chosen as the minimum one - and m1 will be used. In a sort of way -
m1 will be (for the most part) responsible for "activation"
latency-sensitive bandwidth, and m2 will be more responsbile for the
bursts. Difference between m1 and m2 and 'd' duration of m1 will skew
the role.

Perhaps easier example: setup as above, but put a ping on B with 100ms
delay between sends. Every single one of those will go at m1 speed
(crazy curve setups aside).

Similary, if you consider A's RT set to say 5mbit, and B to 4mbit/2mbit
(and LS fifty/fifty). And some video in B now, that doesn't push itself
more than 2mbit. Each packet of B will use m1.

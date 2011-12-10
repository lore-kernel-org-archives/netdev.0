From: Michal Soltys <soltys@ziu.info>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 10 Dec 2011 14:03:32 +0100
Message-ID: <4EE358A4.7060302@ziu.info>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:4172 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab1LJNDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 08:03:31 -0500
In-Reply-To: <1323467512.3159.93.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-09 22:51, John A. Sullivan III wrote:
> 
> Let's work through the math to make that more understandable. HFSC is
> committed to deliver 2 Mbps to video and each packet is 8KB long.
> Thus, HFSC's commitment to deliver that packet is within (8000 *
> 8)bits / 2,000,000(b/s) = 32ms.  I'm not quite sure why I come up with
> 32 and they say 33 but we'll use 33.  In other words, to meet the
> deadline based solely upon the rate, the bandwidth part of the rt
> service curve, the packet needs to be finished dequeueing at 33ms.
> Since it only takes 6.5ms to send the packet, HFSC can sit on the
> packet it received for 33 - 6.5 = 26.5ms.  This adds unnecessary
> latency to the video stream.

For the record, HFSC will only sit on anything if respective classes
(subtrees) are limited by UL. And RT curves ignore those. If you have
one leaf active, then it will just dequeue asap (modulo UL). If you
have more, then RT and afterwards LS will arbitrate the packets
w.r.t. to the curves you set (and if applicable - UL will stall LS
to match specified speeds).

> That's our documentation so I think I get it but here's my problem.
> Practically speaking, as long as it's not extreme, latency at the
> beginning of a video stream (I'm using video because that is the
> example given) is not an issue. 

> The problem is if I introduce latency in the video stream once it has
> started.  So what is the advantage of starting the stream in 3.5ms
> versus 26.5ms?

> The subsequent packets where latency really matters are all governed
> by the m2 curve at 2 Mbps in this example.

That 2mbit is worst-case scenario (congested link). Remember
about LS which will govern the remaining bandwidth as soon as all RT
requirements are fulfilled.

If you do need a bigger /guarantee/ no matter what, you need steeper m2.
Or different approach. HFSC won't give more that it's asked to do for -
if the RT curve's m2 is set to 2mbit, then packets enqueued in the leaf
with such curve will get 2mbit (modulo cpu/network/uplink
capability/etc.).

> Moreover, let's say I have three video streams which start
> simultaneously.  Only the first packet of the first stream receives
> the 6.6Mbps bandwidth guarantee of the first 10ms so the other videos
> receive no practical benefit whatsoever from this m1 curve.

If you want guarantees per flow, you have to setup for that (same
applies to other classful qdiscs). Rough simplistic scheme would be:

For N flows, you need N classes (+ appropriate filter setup to direct
them to respective leafs) - or - more elaborate qdisc at the leaf that
will go over packets (by quantity or their length) in e.g. round robin
fashion from different flows it can distinguish (and longer period of m1
that will be sufficient to cover more packets). Or something in between.

You have lots of tools to choose from (not all listed of course) -
fliters such as fw, u32, flow; qdiscs (meant to attach to leaf classes)
such as choke, red, sfq, drr; iptables targets (mark, classify). And
more.

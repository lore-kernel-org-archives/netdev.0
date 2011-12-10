From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Sat, 10 Dec 2011 10:35:52 -0500
Message-ID: <1323531352.3159.106.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:63157 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673Ab1LJPgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 10:36:11 -0500
In-Reply-To: <4EE358A4.7060302@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks again for your help, Michal.  I'll answer in line - John

On Sat, 2011-12-10 at 14:03 +0100, Michal Soltys wrote:
> On 11-12-09 22:51, John A. Sullivan III wrote:
> > 
> > Let's work through the math to make that more understandable. HFSC is
> > committed to deliver 2 Mbps to video and each packet is 8KB long.
> > Thus, HFSC's commitment to deliver that packet is within (8000 *
> > 8)bits / 2,000,000(b/s) = 32ms.  I'm not quite sure why I come up with
> > 32 and they say 33 but we'll use 33.  In other words, to meet the
> > deadline based solely upon the rate, the bandwidth part of the rt
> > service curve, the packet needs to be finished dequeueing at 33ms.
> > Since it only takes 6.5ms to send the packet, HFSC can sit on the
> > packet it received for 33 - 6.5 = 26.5ms.  This adds unnecessary
> > latency to the video stream.
> 
> For the record, HFSC will only sit on anything if respective classes
> (subtrees) are limited by UL. And RT curves ignore those. If you have
> one leaf active, then it will just dequeue asap (modulo UL). If you
> have more, then RT and afterwards LS will arbitrate the packets
> w.r.t. to the curves you set (and if applicable - UL will stall LS
> to match specified speeds).
Yes, that's what I thought.  I think the example given is that the FTP
queue is constantly backlogged at which point, as you point out, rt will
arbitrate.
> 
> > That's our documentation so I think I get it but here's my problem.
> > Practically speaking, as long as it's not extreme, latency at the
> > beginning of a video stream (I'm using video because that is the
> > example given) is not an issue. 
> 
> > The problem is if I introduce latency in the video stream once it has
> > started.  So what is the advantage of starting the stream in 3.5ms
> > versus 26.5ms?
> 
> > The subsequent packets where latency really matters are all governed
> > by the m2 curve at 2 Mbps in this example.
> 
> That 2mbit is worst-case scenario (congested link). Remember
> about LS which will govern the remaining bandwidth as soon as all RT
> requirements are fulfilled.
Yes, with your help I think I've got that.
> 
> If you do need a bigger /guarantee/ no matter what, you need steeper m2.
> Or different approach. HFSC won't give more that it's asked to do for -
> if the RT curve's m2 is set to 2mbit, then packets enqueued in the leaf
> with such curve will get 2mbit (modulo cpu/network/uplink
> capability/etc.).
Yes, makes perfect sense.  But I suppose I'm focusing on m1 and its
practical purpose.
> 
> > Moreover, let's say I have three video streams which start
> > simultaneously.  Only the first packet of the first stream receives
> > the 6.6Mbps bandwidth guarantee of the first 10ms so the other videos
> > receive no practical benefit whatsoever from this m1 curve.
> 
> If you want guarantees per flow, you have to setup for that (same
> applies to other classful qdiscs). Rough simplistic scheme would be:
> 
> For N flows, you need N classes (+ appropriate filter setup to direct
> them to respective leafs) - or - more elaborate qdisc at the leaf that
> will go over packets (by quantity or their length) in e.g. round robin
> fashion from different flows it can distinguish (and longer period of m1
> that will be sufficient to cover more packets). Or something in between.
<snip>
Makes perfect sense but seems to confirm what I was thinking.  There
seems to be little practical use for the m1 curve.  Assuming the queues
are often backlogged (or we would not be using traffic shaping), m1 only
applies for a typically very short period of time, perhaps one packet,
after that, the latency is determined exclusively by m2.  So, unless
I've missed something (which is not unlikely), m1 is very interesting in
theory but not very useful in the real world.  Am I missing something?

Thus, the biggest advantage of HFSC over something like HTB is that we
have separate controls for the bandwidth guarantees and the ratio for
sharing available excess bandwidth.  The decoupling of latency and
bandwidth guarantees, which is a remarkable accomplishment, seems to
fall into the category of technical fact but not practically useful.
I'd very much like to be wrong :) Thanks - John

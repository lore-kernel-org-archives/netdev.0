From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Latency guarantees in HFSC rt service curves
Date: Fri, 09 Dec 2011 16:51:52 -0500
Message-ID: <1323467512.3159.93.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:57386 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079Ab1LIVv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 16:51:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  Sorry to be SPAMming the list but I think I must have a
fundamental conceptual misunderstanding of HFSC's decoupling of latency
and bandwidth guarantees.  I understand how it is done.  I understand in
theory why it is critically important.  Where I'm failing is seeing how
the current implementation makes any real world difference.  I'm sure it
does, I just don't see it.

Here's how I've explained it at the end of the 14 pages of documentation
I've created to try to explain IFB and HFSC from a system
administrator's perspective.  As you can see, I'm relying upon the
excellent illustration of this part of HFSC in the SIGCOM97 paper on
page 4:

"To illustrate the advantage of decoupling delay and bandwidth
allocation with non-linear service curves, consider the example in
Figure 2, where a video and a FTP session share a 10 Mbps link . . . .
Let the video source sends 30 8KB frames per second, which corresponds
to a required bandwidth of 2 Mbps. The remaining 8 Mbps is reserved by a
continuously backlogged FTP session. For simplicity, let all packets be
of size 8 KB. Thus, it takes roughly 6.5 ms to transmit a packet."

"As can be seen, the deadlines of the video packets occur every 33 ms,
while the deadlines of the FTP packets occur every 8.2 ms. This results
in a delay of approximately 26 ms for a video packet."

Let's work through the math to make that more understandable.  HFSC is
committed to deliver 2 Mbps to video and each packet is 8KB long.  Thus,
HFSC's commitment to deliver that packet is within (8000 * 8)bits /
2,000,000(b/s) = 32ms.  I'm not quite sure why I come up with 32 and
they say 33 but we'll use 33.  In other words, to meet the deadline
based solely upon the rate, the bandwidth part of the rt service curve,
the packet needs to be finished dequeueing at 33ms.  Since it only takes
6.5ms to send the packet, HFSC can sit on the packet it received for 33
- 6.5 = 26.5ms.  This adds unnecessary latency to the video stream.

In the second scenario, we introduce an initial, elevated bandwidth
guarantee for the first 10ms.  The bandwidth for the first 10ms is now
6.6 Mbps instead of 2 Mbps.  We do the math again and HFSC's commitment
to video to maintain 6.6 Mbps is to finish dequeueing the packet within
(8000 * 8)bits / 6,600,000(b/s) = 10ms.  Since it takes 6.5 ms to send
the packet, HFSC can sit on the packet for no more than 10 - 6.5 = 3.5
ms.  Quite a difference!

That's our documentation so I think I get it but here's my problem.
Practically speaking, as long as it's not extreme, latency at the
beginning of a video stream (I'm using video because that is the example
given) is not an issue.  The problem is if I introduce latency in the
video stream once it has started.  So what is the advantage of starting
the stream in 3.5ms versus 26.5ms? The subsequent packets where latency
really matters are all governed by the m2 curve at 2 Mbps in this
example.

Moreover, let's say I have three video streams which start
simultaneously.  Only the first packet of the first stream receives the
6.6Mbps bandwidth guarantee of the first 10ms so the other videos
receive no practical benefit whatsoever from this m1 curve.

I'm sure that's not the case but what am I missing? Thanks - John

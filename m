From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: An error in my HFSC sysadmin documentation
Date: Fri, 09 Dec 2011 13:24:44 -0500
Message-ID: <1323455084.3159.63.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:55314 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859Ab1LISYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 13:24:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  As I mentioned, I'm trying to compile documentation on IFB
and HFSC from a sysadmin's perspective but I think I have an error in
the way I'm explaining how HFSC determines when to send which packet to
meet bandwidth and latency guarantees of the rt service curve.  I'll
show where my math is breaking down in the hope someone can see and
correct my error.

As I was writing this, I saw my error but I will post it in case someone
else steps into the same hole.

Let's say we have a 15 Mbps circuit.  We have two rt service curves.
One is for VoIP and has a rate of 8.9 Mbps (we'll refer to it as V)
while the other is for FTP with a rate of 6.1 Mbps (we'll refer to it as
F).  Let's say that both are being used to the maximum.  V is filled
with 222 byte packets for its ulaw streams and F is filled with 1514
byte packets.

Let's now pick it up where the eligible time for the head of the packet
in each queue is 1000ms just to pick a convenient time.  At the given
rate and packet sizes, the deadline differential (for lack of a better
term) is 2ms for F ((1514 * 8)bits/6,100,000(b/s)) and 0.2ms for V ((222
* 8)bits/8,900,000(b/s)).  The actual transmission time for a packet in
F is 0.8ms ((1514 * 8)bits/15,000,000(b/s)) and 0.1ms for V excluding
CRC, preamble, and IFG.

Thus deadline time measured at the end of the packet is 1000.2 for V and
1002 for F thus V is serviced, correct? Ah, I see my error but I'll
continue in case someone else steps into the same error. The new
deadline time for V is 1000.4 and for F is still 1002 so V is serviced
again and so it goes until eligible time for V is 1001.8.  Then,
perhaps, F is selected to transmit but, it has only 0.2ms left to meet
deadline time and it takes 0.8ms to send the packet thus violating our
guarantees.

Here is the mistake.  Let's assume that clock time equaled eligible time
at 1000ms when we began.  DT (deadline time) for V is 1000.2 and 1002
for F so V is serviced.  It took 0.1ms to send the packet so clock time
is now 1000.1.  ET (Eligible time) for V is 1000.2 while it is still
1000 for F thus DT doesn't enter into the mix since V is not eligible to
dequeue.  F is sent, CT (clock time) becomes 1000.9, V ET is 1000.2 and
DT is 1000.4 while F ET is 1002 and DT is 1004.  V's ET <= CT and its DT
< F's DT so V is serviced while F cannot dequeue because its ET > CT.
CT becomes 1001, V's ET becomes 1000.4 and its DT 1000.6. In fact, it
will send 6 more packets advancing CT to 1001.6 and its ET to 1001.6
making its DT 1001.8.  This means, it can send yet one more packet
advancing CT to 1001.7, its ET to 1001.8.  At this point, neither is
eligible to send which should not be the case since we have guaranteed
to the full rate of the line.  I'm assuming this does not reflect
reality but reflects the fact that I have rounded my calculations (e.g.,
the time to transmit the V packet is not 0.1ms but rather 0.1184ms) and
have not included CRC, preamble, and IFG (which would make V
transmission time 0.1312ms).

By the way, how does HFSC decide which packet to send if multiple
packets happen to have the exact same deadline time? Thanks - John

From: Patrick Ohly <patrick.ohly@intel.com>
Subject: TX time stamping
Date: Tue, 03 Mar 2009 10:31:21 -0800
Message-ID: <1236105081.4653.68.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38822 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbZCCSbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 13:31:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Based on previous discussions, there are some areas of time stamping
which could be improved or needing a fix.

The first being, using skb->sk to send back TX information. The goal is
to notify the sender, and just the sender of the packet about the time
when the packet got transmitted.

I cannot think of how this can be done without skb->sk, but I am open to
suggestions. Without it, one would have to fall back to some kind of
broadcasting scheme were all TX stamped packets are received by all processes
potentially interested in them. This has security issues (packet data
needs to be included to identify packets -> data sent by one user would
be visible to other users; TX stamping feature would have to be
restricted to root, which is not the case now), and potentially impacts
performance (every process has to analyze every packet) and might not be
reliable (depending on the packet payload, processes might not be able
to identify their own packets when they get mixed with those of other
processes).

When an early call to skb_orphan() gets implemented, would it be
acceptable to only do that if no TX time stamping is requested for the
packet? This can be tested relatively fast (check one field in shinfo)?

Second, loopback. I cannot see any issues with loopback, but please let
me know if I have missed something. If I remember (and understand)
correctly, loopback is implemented as writing to a special network
device. Once the TX software fallback is implemented again (see third
point below), then this case can be tested with the timestamping test
program by selecting "lo" as device and asking for TX software time
stamps.

Third, TX software time stamping. I believe a clean solution could work
like this:
      * if TX time stamping is requested, then clone the skb and get a
        reference to the socket
      * ask driver to send packet
      * check status of cloned skb: if TX software fallback is
        necessary, do it using the socket reference
      * drop the references to the cloned skb and the socket

In this scenario the extra work is only done for those packets which
need it. It will work for drivers which call skb_orphan().

As an extra refinement one can later add a driver flag which tells the
kernel that the driver will do the software TX fallback itself. In that
case no extra work needs to be done before calling the driver.

Of course, this all depends on still having the socket before calling
the driver - see above  :-/

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.



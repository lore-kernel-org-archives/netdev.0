From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: inter-packet gap in pktgen
Date: Tue, 7 Dec 2004 23:25:22 +0100
Message-ID: <20041207222522.GA30266@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Robert,

For TX/RX tests, I've been trying to convince pktgen to spit out exactly
N packets per second (for various values of N) by tweaking the inter-packet
gap parameter, and I've noticed the following.

The 'ipg' parameter to pktgen seems to be neither (i) the actual
on-the-wire inter-packet gap (which is the time between the FCS of one
packet and the preamble of the next), nor (ii) the time between the first
data bit of one packet and that of the next.

>From observing that the pps rate for a given 'ipg' does not depend on the
packet size, it would seem that 'ipg' attempts to be (ii).  But it doesn't
quite succeed in that -- it appears to be always ~496ns off on my box.
For example, if I send 500B packets with param 'ipg' equal to 10000ns, I
would expect to end up either with 71kpps(i) or with 100kpps(ii).  But what
I get is 95kpps, 1e9/(10000+496).  At 5000ns ipg, I get neither 109kpps(i)
nor 200kpps(ii) but 182kpps, 1e9/(5000+496).

Presumably this 496ns is the CPU cost of shoving one packet towards the
NIC, and pktgen only after sending a packet starts waiting for 'ipg' ns
before transmitting the next packet.

Can we not compensate for this cost so that we either always get (i) or
(ii)?  Possibly by first getting the current time X, then transmitting
the packet, and then waiting until X+ipg, which would then give us (ii).
(We'd have to rename it to 'inter-packet-start gap' though, or something
like that.)

By tweaking the 'ipg' parameter I can generate pretty much any packet rate
I want, as long as I set ipg=(1e9/rate)-496 instead of something possibly
more straightforward.


thanks,
Lennert

From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Simultanious transmits seems to cause hang on pcnet32
Date: Tue, 18 Jul 2006 11:20:17 -0400
Message-ID: <20060718152016.GA13642@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:38345 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S932240AbWGRPUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 11:20:24 -0400
Received: from lsorense by caffeine.csclub.uwaterloo.ca with local (Exim 4.50)
	id 1G2rMv-0005d0-0n
	for netdev@vger.kernel.org; Tue, 18 Jul 2006 11:20:17 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am currently doing some testing on my system and managing to totally
hang the system (so that the watchdog has to come along and reboot it).

The setup is this:
I have a PLX PCI-PCI bridge with 4 79C972 chips behind it, each running
100baseTX.  I am transmitting traffic from a smartbits test system from
port 1 to port 3 and back, and from port 2 to port 4 and back.  I am
running 500 packets/second with 60 byte packets each way.

If I start the traffic on all 4 ports at the same time, I get less than
100 packets received back at the smartbits on each port, and then the
linux kernel is hung.  No response to anything I have tried.  The
watchdog then reboots the system.

If I start traffic on less than 4 ports, and then add the remaining
ports a second or so later, then it runs just fine and keeps up with the
traffic.

I tried making the traffic all flow out eth0 (an rtl8139 port) instead
of out the pcnet32 ports, and then there is no problem, so I think there
is some problem when multiple ports try to start transmitting at the
same time.

So far it has failed with 2.6.8 and 2.6.16 and with 2.6.17's pcnet32
with the napi patches applied.

I noticed that sometime between 2.6.4 and 2.6.8, the TxDone interrupts
were removed entirely, where as they used to be sent every once in a
while.  I am not sure if this is making a difference yet.

I tried increasing the ring sizes to their maximum setting of 9/9 rather
than the current default of 4/5, and that didn't make any difference
either.

Does anyone have a suggestion for how to go about debuging this issue?
So far I am very confused.

I tried turning on lots of debuging in pcnet32, but that seems to slow
the system down enough (printing debug messages on the serial console)
that it only manages to transmit 10 packets per port per second, at
which point it doesn't lock up.  Reducing the test setting from 500
60byte packets/second to 100 makes the problem disappear as well.

So I am open for suggestions to try.  I really don't know where to go
about debuging this when it makes the kernel lock up.  It makes me think
it is getting stuck somewhere with interrupts disabled, but I can't see
anything in the transmit code that looks like that could happen.

--
Len Sorensen

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: flow control off
Date: Mon, 5 Feb 2007 09:22:53 -0800
Message-ID: <20070205092253.4d8a8f74@freekitty>
References: <20070202153425.2d979fd4@freekitty>
	<20070203223231.GG24090@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50452 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbXBER0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 12:26:35 -0500
In-Reply-To: <20070203223231.GG24090@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is what I saw.

The transmitter on the Marvell Yukon II (88e8053) hangs when doing transmit flow
control under load.  There appears to be a bug or race condition that 
causes the MAC to stop transmitting data.

There are two drivers for the Yukon II device on Linux. SysKonnect/Marvell
has one called sk98lin it is downloadable from syskonnect.def, and I wrote
one called sky2 that is part of the standard Linux kernel. This problem
is reproducible with the sky2 driver only; the sk98lin driver has a watchdog
routine that resets the hardware perodically, so it masks the problem.

When the failure mode occurs only after several minutes of sustained activity
and a situation where PAUSE frames would be received. In my testing I used

  server == 1000mbit  ===> switch --- 100mbit ---> client

Server was Mac Mini (88E8053) running Linux 2.6.20-rc7 and client was a 
Sony Vaio (88e8036) laptop.  The server was running NFS in kernel
and client was doing a large copy. The server was using UDP to cause
large amounts of 802 pause frames. The problem is not as reproducible with
TCP tests because TCP congestion control avoids over running the switch.

When failure occurs:
     * packets continue to be received and passed up the stack

     * GMAC status register is the pause state
     * transmit packets continue transferred by the DMA into the RAM buffer
     * when the the RAM buffer fills no more packets are DMA'd
     * when transmit queue in driver fills, it gets a watch dog timeout

     * switch appears to get confused and other ports hang as well.

During development of the sky2 driver a similar problem was observed on
receive if the receive DMA buffer was not 8 byte aligned.  For performance
reasons, Linux drivers usually offset the Rx buffer by 2 bytes so that
the TCP/IP headers are aligned for faster CPU access.  If the sky2 Rx
buffer was offset, then the receiver DMA would occasionally hung. The
workaround for receive was to align the receive buffer on a quad word
boundary.

This problem appears to be flow control related because after disabling
flow control, no errors occurred in a 48 hour test run.

There probably are other races and hangs that are related. I don't
consider all the hangs eliminated yet.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

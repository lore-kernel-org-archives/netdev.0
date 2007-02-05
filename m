From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] sky2: flow control off
Date: Mon, 5 Feb 2007 19:42:15 +0100
Message-ID: <20070205184215.GA31926@1wt.eu>
References: <20070202153425.2d979fd4@freekitty> <20070203223231.GG24090@1wt.eu> <20070205092253.4d8a8f74@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2264 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932588AbXBESmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 13:42:24 -0500
Content-Disposition: inline
In-Reply-To: <20070205092253.4d8a8f74@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

First, thanks for this detailed explanation.

On Mon, Feb 05, 2007 at 09:22:53AM -0800, Stephen Hemminger wrote:
> Here is what I saw.
> 
> The transmitter on the Marvell Yukon II (88e8053) hangs when doing transmit flow
> control under load.  There appears to be a bug or race condition that 
> causes the MAC to stop transmitting data.
> 
> There are two drivers for the Yukon II device on Linux. SysKonnect/Marvell
> has one called sk98lin it is downloadable from syskonnect.def, and I wrote
> one called sky2 that is part of the standard Linux kernel. This problem
> is reproducible with the sky2 driver only; the sk98lin driver has a watchdog
> routine that resets the hardware perodically, so it masks the problem.
> 
> When the failure mode occurs only after several minutes of sustained activity
> and a situation where PAUSE frames would be received. In my testing I used
> 
>   server == 1000mbit  ===> switch --- 100mbit ---> client
> 
> Server was Mac Mini (88E8053) running Linux 2.6.20-rc7 and client was a 
> Sony Vaio (88e8036) laptop.  The server was running NFS in kernel
> and client was doing a large copy. The server was using UDP to cause
> large amounts of 802 pause frames. The problem is not as reproducible with
> TCP tests because TCP congestion control avoids over running the switch.

I encountered *exactly* this problem with a one-leg firewall equipped with a
88E8053 attached to a 1000 Mbps switch, itself hosting 100 Mbps stations,
but with sk98lin (2.4). Running tcpdump on the firewall, I noticed duplicated
and corrupted frames. I could only reproduce the duplicated and corrupted
frames on a lab setup, not the Tx hangs, by sending high UDP traffic on the
port to a 100 Mbps host. Sending to 1000 Mbps hosts never triggered the
problem, hence my conclusions about flow control too. What I found interesting
is that using a very old version of the sky2 driver which I had with me
(sky2 v0.5), I could not trigger the problem anymore. But right now, I realize
that this version of the driver did not support flow control yet, which might
converge with your observations :

# ethtool -i eth0
driver: sky2
version: 0.5
firmware-version: N/A
bus-info: 01:00.0

# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             off
TX:             off

> When failure occurs:
>      * packets continue to be received and passed up the stack
> 
>      * GMAC status register is the pause state
>      * transmit packets continue transferred by the DMA into the RAM buffer
>      * when the the RAM buffer fills no more packets are DMA'd
>      * when transmit queue in driver fills, it gets a watch dog timeout
> 
>      * switch appears to get confused and other ports hang as well.
> 
> During development of the sky2 driver a similar problem was observed on
> receive if the receive DMA buffer was not 8 byte aligned.  For performance
> reasons, Linux drivers usually offset the Rx buffer by 2 bytes so that
> the TCP/IP headers are aligned for faster CPU access.  If the sky2 Rx
> buffer was offset, then the receiver DMA would occasionally hung. The
> workaround for receive was to align the receive buffer on a quad word
> boundary.
> 
> This problem appears to be flow control related because after disabling
> flow control, no errors occurred in a 48 hour test run.

No problem here with the old driver without flow control either. I can try
to disable it right here on my setup with sk98lin, and test again. I did not
know that the sk98lin had a watchdog, it could explain why sometimes the
system entered a strange state (packets taking *seconds* to be forwarded).

Anyway, I'm more and more convinced that there are hardware bugs. It is
not normal at all that both the original syskonnect driver and your fresh
new code show such similar problems !

> There probably are other races and hangs that are related. I don't
> consider all the hangs eliminated yet.

Well, at least you have a more maintainable driver than what was the
previous one, so you will eventually manage to fix all problems ;-)

Best regards,
Willy


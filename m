From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 14:25:41 +0200
Message-ID: <20080731122541.GA29176@xi.wantstofly.org>
References: <20080731023652.GA23814@xi.wantstofly.org> <20080731030339.GA4327@gondor.apana.org.au> <20080731101425.GE23814@xi.wantstofly.org> <20080731.031654.44296685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org, dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:51398 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbYGaMZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 08:25:44 -0400
Content-Disposition: inline
In-Reply-To: <20080731.031654.44296685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 03:16:54AM -0700, David Miller wrote:

> > As to the congestion window, I had the idea that it's not increasing
> > beyond ~2-3 because the RTT is so low so it doesn't need much data
> > to fill the pipe, but I'm not a TCP expert.
> 
> Local network 10GB needs a pretty decent congestion window.
> 
> Well, it needs to be at least as big as the largest amount of
> non-retransmitted data in-flight, and you've stated here that
> the receive has grown it's window to 700K.

As Herbert Xu suspected, these tests were bw limited by the receiver
(a 2.4 GHz Core 2 Quad, but with a non-PCIe NIC), at ~70 MiB/s.  D'oh.

If I put a (x1) PCIe NIC in the receiver and do not change the sender
(which is still the same 1.2 GHz ARM box with the puny 16 bit memory
bus), I get ~95 MiB/s.

At this point things seem to be CPU limited at the sender again.  E.g.
by simply dropping IRQF_SAMPLE_RANDOM from mv643xx_eth.c (the driver
used on the sender), throughput jumps to ~108 MiB/s, and I get:

	real    0m9.531s	sys     0m9.350s
	real    0m9.603s	sys     0m9.460s
	real    0m9.566s	sys     0m9.380s
	real    0m9.587s	sys     0m9.370s
	real    0m9.552s	sys     0m9.350s
	real    0m9.525s	sys     0m9.330s

Putting the 5 * mss_now nagle hack back in doesn't seem to change
the gso_size distribution anymore at this point, and it doesn't
change the numbers much:

	real    0m9.565s	sys     0m9.340s
	real    0m9.555s	sys     0m9.400s
	real    0m9.594s	sys     0m9.430s
	real    0m9.503s	sys     0m9.320s
	real    0m9.563s	sys     0m9.420s
	real    0m9.539s	sys     0m9.310s

The throughput with software GSO off again seems to be about ~93 MiB/s:

	real    0m11.327s	sys     0m11.020s
	real    0m11.160s	sys     0m11.000s
	real    0m11.517s	sys     0m11.400s
	real    0m11.116s	sys     0m10.970s
	real    0m11.513s	sys     0m11.400s
	real    0m11.151s	sys     0m11.050s

From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Thu, 5 Feb 2009 03:32:41 -0500
Message-ID: <20090205033241.a99121fe.billfink@mindspring.com>
References: <20090204081201.GB10445@ioremap.net>
	<20090204085432.GA21638@1wt.eu>
	<20090204085907.GA19388@gondor.apana.org.au>
	<20090204.010146.18100191.davem@davemloft.net>
	<20090204091217.GA21385@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, jarkao2@gmail.com, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:47216 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756612AbZBEId3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 03:33:29 -0500
In-Reply-To: <20090204091217.GA21385@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Feb 2009, Willy Tarreau wrote:

> On Wed, Feb 04, 2009 at 01:01:46AM -0800, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 4 Feb 2009 19:59:07 +1100
> > 
> > > On Wed, Feb 04, 2009 at 09:54:32AM +0100, Willy Tarreau wrote:
> > > >
> > > > My server is running 2.4 :-), but I observed the same issues with older
> > > > 2.6 as well. I can certainly imagine that things have changed a lot since,
> > > > but the initial point remains : jumbo frames are expensive to deal with,
> > > > and with recent NICs and drivers, we might get close performance for
> > > > little additional cost. After all, initial justification for jumbo frames
> > > > was the devastating interrupt rate and all NICs coalesce interrupts now.
> > > 
> > > This is total crap! Jumbo frames are way better than any of the
> > > hacks (such as GSO) that people have come up with to get around it.
> > > The only reason we are not using it as much is because of this
> > > nasty thing called the Internet.
> > 
> > Completely agreed.
> > 
> > If Jumbo frames are slower, it is NOT some fundamental issue.  It is
> > rather due to some misdesign of the hardware or it's driver.
> 
> Agreed we can't use them *because* of the internet, but this
> limitation has forced hardware designers to find valid alternatives.
> For instance, having the ability to reach 10 Gbps with 1500 bytes
> frames on myri10ge with a low CPU usage is a real achievement. This
> is "only" 800 kpps after all.
> 
> And the arbitrary choice of 9k for jumbo frames was total crap too.
> It's clear that no hardware designer was involved in the process.
> They have to stuff 16kB of RAM on a NIC to use only 9. And we need
> to allocate 3 pages for slightly more than 2. 7.5 kB would have been
> better in this regard.
> 
> I still find it nice to lower CPU usage with frames larger than 1500,
> but given the fact that this is rarely used (even in datacenters), I
> think our efforts should concentrate on where the real users are, ie
> <1500.

Those in the HPC realm use 9000 byte jumbo frames because it makes
a major performance difference, especially across large RTT paths,
and the Internet2 backbone fully supports 9000 byte jumbo frames
(with some wishing we could support much larger frame sizes).

Local environment:

9000 byte jumbo frames:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.1875 MB /  10.01 sec = 9905.9707 Mbps 100 %TX 76 %RX 0 retrans 0.15 msRTT

4080 byte MTU:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
 9171.6875 MB /  10.02 sec = 7680.7663 Mbps 100 %TX 99 %RX 0 retrans 0.19 msRTT

The performance impact is even more pronounced on a large RTT path
such as the following netem emulated 80 ms RTT path:

9000 byte jumbo frames:

[root@lang2 ~]# nuttcp -T30 -w80m 192.168.89.15
25904.2500 MB /  30.16 sec = 7205.8755 Mbps 96 %TX 55 %RX 0 retrans 82.73 msRTT

4080 byte MTU:

[root@lang2 ~]# nuttcp -T30 -w80m 192.168.89.15
 8650.0129 MB /  30.25 sec = 2398.8862 Mbps 33 %TX 19 %RX 2371 retrans 81.98 msRTT

And if there's any loss in the path, the performance difference is also
dramatic, such as here across a real MAN environment with about a 1 ms RTT:

9000 byte jumbo frames:

[root@chance9 ~]# nuttcp -w20m 192.168.88.8
 7711.8750 MB /  10.05 sec = 6436.2406 Mbps 82 %TX 96 %RX 261 retrans 0.92 msRTT

4080 byte MTU:

[root@chance9 ~]# nuttcp -w20m 192.168.88.8
 4551.0625 MB /  10.08 sec = 3786.2108 Mbps 50 %TX 95 %RX 42 retrans 0.95 msRTT

All testing was with myri10ge on the transmitter side (2.6.20.7 kernel).

So my experience has definitely been that 9000 byte jumbo frames are a
major performance win for high throughput applications.

						-Bill

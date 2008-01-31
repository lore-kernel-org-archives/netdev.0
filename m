From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 06:45:33 -0500
Message-ID: <20080131064533.ef0ae932.billfink@mindspring.com>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
	<20080130.055333.192844925.davem@davemloft.net>
	<Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
	<20080130082136.1017631d@deepthought>
	<Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
	<649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Bruce Allen" <ballen@gravity.phys.uwm.edu>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "SANGTAE HA" <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:38766 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753984AbYAaLps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 06:45:48 -0500
In-Reply-To: <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jan 2008, SANGTAE HA wrote:

> On Jan 30, 2008 5:25 PM, Bruce Allen <ballen@gravity.phys.uwm.edu> wrote:
> >
> > In our application (cluster computing) we use a very tightly coupled
> > high-speed low-latency network.  There is no 'wide area traffic'.  So it's
> > hard for me to understand why any networking components or software layers
> > should take more than milliseconds to ramp up or back off in speed.
> > Perhaps we should be asking for a TCP congestion avoidance algorithm which
> > is designed for a data center environment where there are very few hops
> > and typical packet delivery times are tens or hundreds of microseconds.
> > It's very different than delivering data thousands of km across a WAN.
> >
> 
> If your network latency is low, regardless of type of protocols should
> give you more than 900Mbps. I can guess the RTT of two machines is
> less than 4ms in your case and I remember the throughputs of all
> high-speed protocols (including tcp-reno) were more than 900Mbps with
> 4ms RTT. So, my question which kernel version did you use with your
> broadcomm NIC and got more than 900Mbps?
> 
> I have two machines connected by a gig switch and I can see what
> happens in my environment. Could you post what parameters did you use
> for netperf testing?
> and also if you set any parameters for your testing, please post them
> here so that I can see that happens to me as well.

I see similar results on my test systems, using Tyan Thunder K8WE (S2895)
motherboard with dual Intel Xeon 3.06 GHZ CPUs and 1 GB memory, running
a 2.6.15.4 kernel.  The GigE NICs are Intel PRO/1000 82546EB_QUAD_COPPER,
on a 64-bit/133-MHz PCI-X bus, using version 6.1.16-k2 of the e1000
driver, and running with 9000-byte jumbo frames.  The TCP congestion
control is BIC.

Unidirectional TCP test:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79
tx:  1186.5649 MB /  10.05 sec =  990.2741 Mbps 11 %TX 9 %RX 0 retrans

and:

[bill@chance4 ~]$ nuttcp -f-beta -Irx -r -w2m 192.168.6.79
rx:  1186.8281 MB /  10.05 sec =  990.5634 Mbps 14 %TX 9 %RX 0 retrans

Each direction gets full GigE line rate.

Bidirectional TCP test:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.6.79
tx:   898.9934 MB /  10.05 sec =  750.1634 Mbps 10 %TX 8 %RX 0 retrans
rx:  1167.3750 MB /  10.06 sec =  973.8617 Mbps 14 %TX 11 %RX 0 retrans

While one direction gets close to line rate, the other only got 750 Mbps.
Note there were no TCP retransmitted segments for either data stream, so
that doesn't appear to be the cause of the slower transfer rate in one
direction.

If the receive direction uses a different GigE NIC that's part of the
same quad-GigE, all is fine:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.5.79
tx:  1186.5051 MB /  10.05 sec =  990.2250 Mbps 12 %TX 13 %RX 0 retrans
rx:  1186.7656 MB /  10.05 sec =  990.5204 Mbps 15 %TX 14 %RX 0 retrans

Here's a test using the same GigE NIC for both directions with 1-second
interval reports:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -i1 -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -i1 -w2m 192.168.6.79
tx:    92.3750 MB /   1.01 sec =  767.2277 Mbps     0 retrans
rx:   104.5625 MB /   1.01 sec =  872.4757 Mbps     0 retrans
tx:    83.3125 MB /   1.00 sec =  700.1845 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5541 Mbps     0 retrans
tx:    83.8125 MB /   1.00 sec =  703.0322 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5502 Mbps     0 retrans
tx:    83.0000 MB /   1.00 sec =  696.1779 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5522 Mbps     0 retrans
tx:    83.7500 MB /   1.00 sec =  702.4989 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5512 Mbps     0 retrans
tx:    83.1250 MB /   1.00 sec =  697.2270 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5512 Mbps     0 retrans
tx:    84.1875 MB /   1.00 sec =  706.1665 Mbps     0 retrans
rx:   117.5625 MB /   1.00 sec =  985.5510 Mbps     0 retrans
tx:    83.0625 MB /   1.00 sec =  696.7167 Mbps     0 retrans
rx:   117.6875 MB /   1.00 sec =  987.5543 Mbps     0 retrans
tx:    84.1875 MB /   1.00 sec =  706.1545 Mbps     0 retrans
rx:   117.6250 MB /   1.00 sec =  986.5472 Mbps     0 retrans
rx:   117.6875 MB /   1.00 sec =  987.0724 Mbps     0 retrans
tx:    83.3125 MB /   1.00 sec =  698.8137 Mbps     0 retrans

tx:   844.9375 MB /  10.07 sec =  703.7699 Mbps 11 %TX 6 %RX 0 retrans
rx:  1167.4414 MB /  10.05 sec =  973.9980 Mbps 14 %TX 11 %RX 0 retrans

In this test case, the receiver ramped up to nearly full GigE line rate,
while the transmitter was stuck at about 700 Mbps.  I ran one longer
60-second test and didn't see the oscillating behavior between receiver
and transmitter, but maybe that's because I have the GigE NIC interrupts
and nuttcp client/server applications both locked to CPU 0.

So in my tests, once one direction gets the upper hand, it seems to
stay that way.  Could this be because the slower side is so busy
processing the transmits of the faster side, that it just doesn't
get to do its fair share of transmits (although it doesn't seem to
be a bus or CPU issue).  Hopefully those more knowledgeable about
the Linux TCP/IP stack and network drivers might have some more
concrete ideas.

						-Bill

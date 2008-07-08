From: Bill Fink <billfink@mindspring.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 18:05:00 -0400
Message-ID: <20080708180500.e8a61231.billfink@mindspring.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com>
	<20080708134845.2372a483@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:52912 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbYGHWFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:05:12 -0400
In-Reply-To: <20080708134845.2372a483@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jul 2008, Stephen Hemminger wrote:

> On Mon, 07 Jul 2008 23:29:31 -0700
> Roland Dreier <rdreier@cisco.com> wrote:
> 
> > Interesting... I'd not tried nuttcp before, and on my testbed, which is
> > a very high-bandwidth, low-RTT network (IP-over-InfiniBand with DDR IB,
> > so the network is capable of 16 Gbps, and the RTT is ~25 microseconds),
> > the difference between autotuning and not for nuttcp is huge (testing
> > with 2.6.26-rc8 plus some pending 2.6.27 patches that add checksum
> > offload, LSO and LRO to the IP-over-IB driver):
> > 
> > nuttcp -T30 -i1 ends up with:
> > 
> > 14465.0625 MB /  30.01 sec = 4043.6073 Mbps 82 %TX 2 %RX
> > 
> > while setting the window even to 128 KB with
> > nuttcp -w128k -T30 -i1 ends up with:
> > 
> > 36416.8125 MB /  30.00 sec = 10182.8137 Mbps 90 %TX 96 %RX
> > 
> > so it's a factor of 2.5 with nuttcp.  I've never seen other apps behave
> > like that -- for example NPtcp (netpipe) only gets slower when
> > explicitly setting the window size.
> > 
> > Strange...
> 
> I suspect that the link is so fast that the window growth isn't happening
> fast enough. With only a 30 second test, you probably barely made it
> out of TCP slow start.

Nah.  30 seconds is plenty of time.  I got up to nearly 8 Gbps
in 4 seconds (see my test report in earlier message in this thread),
and that was on an ~72 ms RTT network path.  Roland's IB network
only has a ~25 usec RTT.

BTW I believe there is one other important difference between the way
the tcp_rmem/tcp_wmem autotuning parameters are handled versus the way
the rmem_max/wmem_max parameters are used when explicitly setting the
socket buffer sizes.  I believe the tcp_rmem/tcp_wmem autotuning maximum
parameters are hard limits, with the default maximum tcp_rmem setting
being ~170 KB and the default maximum tcp_wmem setting being 128 KB.
On the other hand, I believe the rmem_max/wmem_max determines the maximum
value allowed to be set via the SO_RCVBUF/SO_SNDBUF setsockopt() call.
But then Linux doubles the requested value, so when Roland specified
a "-w128" nuttcp parameter, he actually got a socket buffer size
of 256 KB, which would thus be double that available in the autotuning
case assuming the tcp_rmem/tcp_wmem settings are using their default
values.  This could then account for a factor of 2 X between the two
test cases.  The "-v" verbose option to nuttcp might shed some light
on this hypothesis.

						-Bill

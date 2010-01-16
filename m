From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Sat, 16 Jan 2010 12:08:36 +0530
Message-ID: <OFA56A461E.61811628-ON652576AD.0022D2A5-652576AD.002350AE@in.ibm.com>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com> <4B50B032.2060609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:51450 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab0APG04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 01:26:56 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0G6QnJK006938
	for <netdev@vger.kernel.org>; Sat, 16 Jan 2010 11:56:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0G6QmCH983214
	for <netdev@vger.kernel.org>; Sat, 16 Jan 2010 11:56:48 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0G6QmXY011884
	for <netdev@vger.kernel.org>; Sat, 16 Jan 2010 11:56:48 +0530
In-Reply-To: <4B50B032.2060609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> wrote on 01/15/2010 11:43:06 PM:
>
> > Remove inline skb data in tcp_sendmsg(). For the few devices that
> > don't support NETIF_F_SG, dev_queue_xmit will call skb_linearize,
> > and pass the penalty to those slow devices (the following drivers
> > do not support NETIF_F_SG: 8139cp.c, amd8111e.c, dl2k.c, dm9000.c,
> > dnet.c, ethoc.c, ibmveth.c, ioc3-eth.c, macb.c, ps3_gelic_net.c,
> > r8169.c, rionet.c, spider_net.c, tsi108_eth.c, veth.c,
> > via-velocity.c, atlx/atl2.c, bonding/bond_main.c, can/dev.c,
> > cris/eth_v10.c).
> >
> > This patch does not affect devices that support SG but turn off
> > via ethtool after register_netdev.
> >
> > I ran the following test cases with iperf - #threads: 1 4 8 16 32
> > 64 128 192 256, I/O sizes: 256 4K 16K 64K, each test case runs for
> > 1 minute, repeat 5 iterations. Total test run time is 6 hours.
> > System is 4-proc Opteron, with a Chelsio 10gbps NIC. Results (BW
> > figures are the aggregate across 5 iterations in mbps):
> >
> > -------------------------------------------------------
> > #Process   I/O Size    Org-BW     New-BW   %-change
> > -------------------------------------------------------
> > 1           256        2098       2147      2.33
> > 1           4K         14057      14269     1.50
> > 1           16K        25984      27317     5.13
> > 1           64K        25920      27539     6.24
> > ...
> > 256         256        1947       1955      0.41
> > 256         4K         9828       12265     24.79
> > 256         16K        25087      24977     -0.43
> > 256         64K        26715      27997     4.79
> > -------------------------------------------------------
> > Total:      -          600071     634906    5.80
> > -------------------------------------------------------
>
> Does bandwidth alone convey the magnitude of the change?  I would think
that
> would only be the case if the CPU(s) were 100% utilized, and perhapsnot
even
> completely then.  At the risk of a shameless plug, it's not for nothing
that
> netperf reports service demand :)
>
> I would think that change in service demand (CPU per unit of work) would
be
> something one wants to see.
>
> Also, the world does not run on bandwidth alone, so small packet
> performance and
> any delta there would be good to have.
>
> Multiple process tests may not be as easy in netperf as it is in
> iperf, but under:
>
> ftp://ftp.netperf.org/netperf/misc
>
> I have a single-stream test script I use called runemomni.sh and an
> example of
> its output, as well as an aggregate script I use called
> runemomniagg2.sh - I'll
> post an example of its output there as soon as I finish some runs.

I usually run netperf for smaller number of threads and aggregate
the output using some scripts. I will try what you suggested above,
and see if I can get consistent results for higher number of
processes. Thanks for the links.

- KK

> The script
> presumes one has ./configure'd netperf:
>
> ./configure --enable-burst --enable-omni ...
>
> The netperf omni tests still ass-u-me that the CPU util each
> measures is all his
> own, which means the service demands from aggrgate tests require some
> post-processing fixup.
>
> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Using-
> Netperf-to-Measure-Aggregate-Performance
>
> happy benchmarking,
>
> rick jones
>
> FWIW, service demand and pps performance may be even more important
> for non-SG
> devices because they may be slow 1 Gig devices and still hit link-
> rate on a bulk
> throughput test even with a non-trivial increase in CPU util.  However, a

> non-trivial hit in CPU util may rather change the pps performance.
>
> PPS - there is a *lot* of output in those omni test results - best
> viewed with a
> spreadsheet program.


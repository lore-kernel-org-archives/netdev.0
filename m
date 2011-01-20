From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 20 Jan 2011 17:38:33 +0900
Message-ID: <20110120083727.GA1807@verge.net.au>
References: <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43636 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab1AUCKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 21:10:12 -0500
Content-Disposition: inline
In-Reply-To: <4D35ECE2.4040901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Trimmed Eric from CC list as vger was complaining that it is too long ]

On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> >So it won't be all that simple to implement well, and before we try,
> >I'd like to know whether there are applications that are helped
> >by it. For example, we could try to measure latency at various
> >pps and see whether the backpressure helps. netperf has -b, -w
> >flags which might help these measurements.
> 
> Those options are enabled when one adds --enable-burst to the
> pre-compilation ./configure  of netperf (one doesn't have to
> recompile netserver).  However, if one is also looking at latency
> statistics via the -j option in the top-of-trunk, or simply at the
> histogram with --enable-histogram on the ./configure and a verbosity
> level of 2 (global -v 2) then one wants the very top of trunk
> netperf from:

Hi,

I have constructed a test where I run an un-paced  UDP_STREAM test in
one guest and a paced omni rr test in another guest at the same time.
Breifly I get the following results from the omni test..

1. Omni test only:		MEAN_LATENCY=272.00
2. Omni and stream test:	MEAN_LATENCY=3423.00
3. cpu and net_cls group:	MEAN_LATENCY=493.00
   As per 2 plus cgoups are created for each guest
   and guest tasks added to the groups
4. 100Mbit/s class:		MEAN_LATENCY=273.00
   As per 3 plus the net_cls groups each have a 100MBit/s HTB class
5. cpu.shares=128:		MEAN_LATENCY=652.00
   As per 4 plus the cpu groups have cpu.shares set to 128
6. Busy CPUS:			MEAN_LATENCY=15126.00
   As per 5 but the CPUs are made busy using a simple shell while loop

There is a bit of noise in the results as the two netperf invocations
aren't started at exactly the same moment

For reference, my netperf invocations are:
netperf -c -C -t UDP_STREAM -H 172.17.60.216 -l 12
netperf.omni -p 12866 -D -c -C -H 172.17.60.216 -t omni -j -v 2 -- -r 1 -d rr -k foo -b 1 -w 200 -m 200

foo contains
PROTOCOL
THROUGHPUT,THROUGHPUT_UNITS
LOCAL_SEND_THROUGHPUT
LOCAL_RECV_THROUGHPUT
REMOTE_SEND_THROUGHPUT
REMOTE_RECV_THROUGHPUT
RT_LATENCY,MIN_LATENCY,MEAN_LATENCY,MAX_LATENCY
P50_LATENCY,P90_LATENCY,P99_LATENCY,STDDEV_LATENCY
LOCAL_CPU_UTIL,REMOTE_CPU_UTIL


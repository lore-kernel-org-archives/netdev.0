From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 21:43:01 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Carsten Aulbert" <carsten.aulbert@aei.mpg.de>,
	"Henning Fehrmann" <henning.fehrmann@aei.mpg.de>,
	"Bruce Allen" <bruce.allen@aei.mpg.de>
To: "Bruce Allen" <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49364 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbYAaFoS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 00:44:18 -0500
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen wrote:
> Hi Jesse,
> 
> It's good to be talking directly to one of the e1000 developers and
> maintainers.  Although at this point I am starting to think that the
> issue may be TCP stack related and nothing to do with the NIC.  Am I
> correct that these are quite distinct parts of the kernel?

Yes, quite.
 
> Important note: we ARE able to get full duplex wire speed (over 900
> Mb/s simulaneously in both directions) using UDP.  The problems occur
> only with TCP connections.

That eliminates bus bandwidth issues, probably, but small packets take
up a lot of extra descriptors, bus bandwidth, CPU, and cache resources.
 
>>> The test was done with various mtu sizes ranging from 1500 to 9000,
>>> with ethernet flow control switched on and off, and using reno and
>>> cubic as a TCP congestion control.
>> 
>> As asked in LKML thread, please post the exact netperf command used
>> to start the client/server, whether or not you're using irqbalanced
>> (aka irqbalance) and what cat /proc/interrupts looks like (you ARE
>> using MSI, right?)
> 
> I have to wait until Carsten or Henning wake up tomorrow (now 23:38 in
> Germany).  So we'll provide this info in ~10 hours.

I would suggest you try TCP_RR with a command line something like this:
netperf -t TCP_RR -H <hostname> -C -c -- -b 4 -r 64K

I think you'll have to compile netperf with burst mode support enabled.

> I assume that the interrupt load is distributed among all four cores
> -- the default affinity is 0xff, and I also assume that there is some
> type of interrupt aggregation taking place in the driver.  If the
> CPUs were not able to service the interrupts fast enough, I assume
> that we would also see loss of performance with UDP testing.
> 
>> One other thing you can try with e1000 is disabling the dynamic
>> interrupt moderation by loading the driver with
>> InterruptThrottleRate=8000,8000,... (the number of commas depends on
>> your number of ports) which might help in your particular benchmark.
> 
> OK.  Is 'dynamic interrupt moderation' another name for 'interrupt
> aggregation'?  Meaning that if more than one interrupt is generated
> in a given time interval, then they are replaced by a single
> interrupt? 

Yes, InterruptThrottleRate=8000 means there will be no more than 8000
ints/second from that adapter, and if interrupts are generated faster
than that they are "aggregated."

Interestingly since you are interested in ultra low latency, and may be
willing to give up some cpu for it during bulk transfers you should try
InterruptThrottleRate=1 (can generate up to 70000 ints/s)

>> just for completeness can you post the dump of ethtool -e eth0 and
>> lspci -vvv?
> 
> Yup, we'll give that info also.
> 
> Thanks again!

Welcome, its an interesting discussion.  Hope we can come to a good
conclusion.

Jesse

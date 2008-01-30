From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 17:07:28 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:33551 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763606AbYA3XHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 18:07:47 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

It's good to be talking directly to one of the e1000 developers and 
maintainers.  Although at this point I am starting to think that the 
issue may be TCP stack related and nothing to do with the NIC.  Am I 
correct that these are quite distinct parts of the kernel?

> The 82573L (a client NIC, regardless of the class of machine it is in)
> only has a x1 connection which does introduce some latency since the
> slot is only capable of about 2Gb/s data total, which includes overhead
> of descriptors and other transactions.  As you approach the maximum of
> the slot it gets more and more difficult to get wire speed in a
> bidirectional test.

According to the Intel datasheet, the PCI-e x1 connection is 2Gb/s in each 
direction.  So we only need to get up to 50% of peak to saturate a 
full-duplex wire-speed link.  I hope that the overhead is not a factor of 
two.

Important note: we ARE able to get full duplex wire speed (over 900 Mb/s 
simulaneously in both directions) using UDP.  The problems occur only with 
TCP connections.

>> The test was done with various mtu sizes ranging from 1500 to 9000,
>> with ethernet flow control switched on and off, and using reno and
>> cubic as a TCP congestion control.
>
> As asked in LKML thread, please post the exact netperf command used to
> start the client/server, whether or not you're using irqbalanced (aka
> irqbalance) and what cat /proc/interrupts looks like (you ARE using MSI,
> right?)

I have to wait until Carsten or Henning wake up tomorrow (now 23:38 in 
Germany).  So we'll provide this info in ~10 hours.

I assume that the interrupt load is distributed among all four cores -- 
the default affinity is 0xff, and I also assume that there is some type of 
interrupt aggregation taking place in the driver.  If the CPUs were not 
able to service the interrupts fast enough, I assume that we would also 
see loss of performance with UDP testing.

> I've recently discovered that particularly with the most recent kernels
> if you specify any socket options (-- -SX -sY) to netperf it does worse
> than if it just lets the kernel auto-tune.

I am pretty sure that no socket options were specified, but again need to 
wait until Carsten or Henning come back on-line.

>> The behavior depends on the setup. In one test we used cubic
>> congestion control, flow control off. The transfer rate in one
>> direction was above 0.9Gb/s while in the other direction it was 0.6
>> to 0.8 Gb/s. After 15-20s the rates flipped. Perhaps the two steams
>> are fighting for resources. (The performance of a full duplex stream
>> should be close to 1Gb/s in both directions.)  A graph of the
>> transfer speed as a function of time is here:
>> https://n0.aei.uni-hannover.de/networktest/node19-new20-noflow.jpg
>> Red shows transmit and green shows receive (please ignore other
>> plots):

> One other thing you can try with e1000 is disabling the dynamic
> interrupt moderation by loading the driver with
> InterruptThrottleRate=8000,8000,... (the number of commas depends on
> your number of ports) which might help in your particular benchmark.

OK.  Is 'dynamic interrupt moderation' another name for 'interrupt 
aggregation'?  Meaning that if more than one interrupt is generated in a 
given time interval, then they are replaced by a single interrupt?

> just for completeness can you post the dump of ethtool -e eth0 and lspci
> -vvv?

Yup, we'll give that info also.

Thanks again!

Cheers,
 	Bruce

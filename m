From: Mandeep Singh Baines <mandeep.baines@gmail.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Sat, 8 Sep 2007 09:42:22 -0700
Message-ID: <20070908164222.GB3765@ludhiana>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <20070907035528.GA3755@ludhiana> <46E11C07.50307@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:61802 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390AbXIHQoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 12:44:06 -0400
Received: by wa-out-1112.google.com with SMTP id v27so934696wah
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2007 09:43:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <46E11C07.50307@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman (jchapman@katalix.com) wrote:
> Hi Mandeep,
>
> Mandeep Singh Baines wrote:
>> Hi James,
>> I like the idea of staying in poll longer.
>> My comments are similar to what Jamal and Stephen have already 
>> said.
>> A tunable (via sysfs) would be nice.
>> A timer might be preferred to jiffy polling. Jiffy polling will not 
>> increase latency the way a timer would. However, jiffy polling will 
>> consume a lot more
>> CPU than a timer would. Hence more power. For jiffy polling, you 
>> could have thousands of calls to poll for a single packet received. 
>> While in a timer approach the numbers of polls per packet is upper 
>> bound to 2. 
>
> Why would using a timer to hold off the napi_complete() rather than 
> jiffy count limit the polls per packet to 2?
>

I was thinking a timer could be used in the way suggested in Jamal's
paper. The driver would do nothing (park) until the timer expires. So
there would be no calls to poll for the duration of the timer. Hence,
this approach would add extra latency not present in a jiffy polling
approach.

>> I think it may difficult to make poll efficient for the no packet 
>> case because,
>> at a minimum, you have to poll the device state via the has_work 
>> method.
>
> Why wouldn't it be efficient? It would usually be done by reading an 
> "interrupt pending" register.
>

Reading the "interrupt pending" register would require an MMIO read.
MMIO reads are very expensive. In some systems the latency of an MMIO
read can be 1000x that of an L1 cache access.

You can use mmio_test to measure MMIO read latency on your system:

http://svn.gnumonks.org/trunk/mmio_test/

However, work_done() doesn't have to be inefficient. For newer
devices you can implement work_done() without an MMIO read by polling
the next ring entry status in memory or some other mechanism. Since
PCI is coherent, acceses to this memory location could be cached
after the first miss. For architectures where PCI is not coherent you'd 
have to go to memory for every poll. So for these architectures has_work()
will be moderately expensive (memory access) even when has_work() does
not require an MMIO read. This might affect home routers: not sure if MIPS or
ARM have coherent PCI.

>> If you go to a timer implementation then having a tunable will be 
>> important.
>> Different appications will have different requirements on delay and 
>> jitter.
>> Some applications may want to trade delay/jitter for less CPU/power 
>> consumption and some may not.
>
> I agree. I'm leaning towards a new ethtool parameter to control this 
> to be consistent with other per-device tunables.
>
>> imho, the work should definately be pursued further:)
>
> Thanks Mandeep. I'll try. :)
>
> -- 
> James Chapman
> Katalix Systems Ltd
> http://www.katalix.com
> Catalysts for your Embedded Linux software development
>

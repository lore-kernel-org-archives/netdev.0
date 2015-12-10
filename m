From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Thu, 10 Dec 2015 09:49:36 -0800
Message-ID: <5669BB30.3080000@hpe.com>
References: <20151203162627.GA8989@redhat.com> <5661D7D7.4020401@hpe.com>
 <20151210141825.GA27930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>
To: Otto Sabart <osabart@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:37388 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbbLJRth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 12:49:37 -0500
In-Reply-To: <20151210141825.GA27930@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2015 06:18 AM, Otto Sabart wrote:
>> *) Is irqbalance disabled and the IRQs set the same each time, or might
>> there be variability possible there?  Each of the five netperf runs will be
>> a different four-tuple which means each may (or may not) get RSS hashed/etc
>> differently.
>
> The irqbalance is disabled on all systems.
>
> Can you suggest, if there is a need to assign irqs manually? Which irqs
> we should pin to which CPU?

Likely as not it will depend on your goals.  When I want single-stream 
results, I will tend to disable irqbalance and set all the IRQs to one 
CPU in the system (often as not CPU0 but that is as much habit as 
anything else).  The idea is to clamp-down on any source of run-to-run 
variation.  I will also sometimes alter where I bind netperf/netserver 
to show the effects (especially on service demand) when 
netperf/netserver run on the same CPU as the IRQ, a thread in the same 
core as the IRQ, a core in the same processor as the IRQ and/or a core 
in another processor.  Unless all the IRQs are pointed at the same CPU 
(or I always specify the same, full four-tuple for addressing and wait 
for TIME_WAIT) that can be a challenge to keep straight.

When I want to measure aggregate, I either let irqbalance do its thing 
and run a bunch of warm-up tests, or simply peanut-butter the IRQs 
across the CPUs with variations on the theme of:

grep eth[23] /proc/interrupts | awk -F ":" -v cpus=12 '{mask = 1 * 
2^(count++ % cpus);printf("echo %x > 
/proc/irq/%d/smp_affinity\n",mask,$1)}' | sh

How one might structure/alter that pipeline will depend on the CPU 
enumeration.  That one was from a 2x6 core system where I didn't want to 
hit the second thread of each core, and the enumeration was the first 
twelve CPUs were on thread 0 of each core of both processors.

>> *) It is perhaps adding duct tape to already-present belt and suspenders,
>> but is power-management set to a fixed state on the systems involved? (Since
>> this seems to be ProLiant G7s going by the legends on the charts, either
>> static high perf or static low power I would imagine)
>
> Power management is set to OS-Control in bios, which effectively means,
> that _bios_ does not do any power management at all.

Probably just as well :)

>> *) What is the difference before/after for the service demands?  The netperf
>> tests being run are asking for CPU utilization but I don't see the service
>> demand change being summarized.
>
> Unfortunatelly we does not have any summary chart for service demands,
> we will add some shortly.
>
>> *) Does a specific CPU on one side or the other saturate?
>> (LOCAL_CPU_PEAK_UTIL, LOCAL_CPU_PEAK_ID, REMOTE_CPU_PEAK_UTIL,
>> REMOTE_CPU_PEAK_ID output selectors)
>
> We are sort of stuck in a stone age. We still use old fashion tcp/udp
> migrated tests, but we plan to switch to omni.

Well, you don't have to invoke with -t omni to make use of the output 
selectors - just add the -O (or -o or -k) test-specific option.

>
>> *) What are the processors involved?  Presumably the "other system" is
>> fixed?
>
> In this case:
>
> hp-dl380g7 - $ lscpu:
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                24
> On-line CPU(s) list:   0-23
> Thread(s) per core:    2
> Core(s) per socket:    6
> Socket(s):             2
> NUMA node(s):          2
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 44
> Model name:            Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz
> Stepping:              2
> CPU MHz:               2660.000
> BogoMIPS:              5331.27
> Virtualization:        VT-x
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              12288K
> NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22
> NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23
>
>
> hp-dl385g7 - $ lscpu:
> tecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                24
> On-line CPU(s) list:   0-23
> Thread(s) per core:    1
> Core(s) per socket:    12
> Socket(s):             2
> NUMA node(s):          4
> Vendor ID:             AuthenticAMD
> CPU family:            16
> Model:                 9
> Model name:            AMD Opteron(tm) Processor 6172
> Stepping:              1
> CPU MHz:               2100.000
> BogoMIPS:              4200.39
> Virtualization:        AMD-V
> L1d cache:             64K
> L1i cache:             64K
> L2 cache:              512K
> L3 cache:              5118K
> NUMA node0 CPU(s):     0,2,4,6,8,10
> NUMA node1 CPU(s):     12,14,16,18,20,22
> NUMA node2 CPU(s):     13,15,17,19,21,23
> NUMA node3 CPU(s):     1,3,5,7,9,11

I guess that helps explain why there were such large differences in the 
deltas between TCP_STREAM and TCP_MAERTS since it wasn't the same 
per-core "horsepower" on either side and so why LRO on/off could have 
also affected the TCP_STREAM results. (When LRO was off it was off on 
both sides, and when on was on on both yes?)

happy benchmarking,

rick jones

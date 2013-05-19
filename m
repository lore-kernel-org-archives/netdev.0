From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next 0/4] net: low latency Ethernet device polling
Date: Sun, 19 May 2013 13:25:25 +0300
Message-ID: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donanld.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Dave Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, 

Please consider applying to net-next.

Thanks,
Eliezer

This is an updated version of the code we posted on February.

Patch 1 adds ndo_ll_poll and the IP code to use it.
Patch 2 is an example of how TCP can use ndo_ll_poll.
Patch 3 shows how this method would be implemented for the ixgbe driver.
Patch 4 adds statistics to the ixgbe driver for ndo_ll_poll events.

Changes from previous version:
1. The sysctl knob is now in microseconds, we don't adjust it for cpu
clock changes. The default value is now 0 (off).
Recommended value is around 50.

2. For now the code depends at configure time on CONFIG_I86_TSC to
satisfy both the need for a high precision get_cycles() and a 64 bit
cycles_t. I looked into using sched_clock(). It looks like it does not
have the required precision on all architectures. Using config it would
be easy to add other architectures once some testing has been done on them.

3. The napi reference in struct skb is now a union with the dma cookie
since the former is only used on RX and the latter on TX, as suggested
by Eric Dumazet.

4. We do a better job at honoring non-blocking operations.

5. Removed busy-polling support for tcp_read_sock().
Doing a release_sock() followed by a lock_sock() to get the backlog 
processed is unsafe there.
If there is interest in tcp_read_sock() support we would need another
way to get backlog processing done.
BTW I was not able to find a microbenchamrk that uses tcp_read_sock(),
any suggestions?

6. To avoid the overhead of reference counting napi structs by skbs
and sockets in the fastpath, and increasing the size of the skb struct,
we no longer allow unloading the module once this feature has been used.

It seems that for most of the people interested in busy-polling, giving
up the ability to blindly remove the module for a slight but measurable
performance gain is a good tradeoff.
(There is a module parameter to override this behavior and if you know
what you are doing and are careful to stop the processes you can safely
unload, but we don't enforce this.)

7. We no longer try to dynamically turn GRO off when someone is busy-
polling, since this sometimes caused reordering with packets left on
the napi->gro_list by napi. For most workloads you should probably start
by globally disabling GRO with ethtool. In some cases the performance
gain of GRO greatly outweighs the cost of reordering.
Your mileage may vary.

8. Many small changes suggested by people here. I would like to thank
all of the people that took the time to review our code.

The performance is about the same as the last time.
I promised Rick Jones CPU utilization numbers so here are some examples
with these numbers added.

Performance numbers:
        setup                    TCP_RR              UDP_RR
kernel  Config     C3/6 rx-usecs tps cpu% S.dem   tps cpu% S.dem
patched optimized* on   100      87k 3.13 11.4   94K 3.17 10.7
patched optimized* on   0        71k 3.12 14.0   84k 3.19 12.0
patched optimized* on   adaptive 80k 3.13 12.5   90k 3.46 12.2
patched typical    on   100      72  3.13 14.0   79k 3.17 12.8
patched typical    on   0        60k 2.13 16.5   71k 3.18 14.0
patched typical    on   adaptive 67k 3.51 16.7   75k 3.36 14.5
3.9     optimized* on   adaptive 25k 1.0  12.7   28k 0.98 11.2
3.9     typical    off  0        48k 1.09  7.3   52k 1.11 4.18
3.9     typical    0ff  adaptive 35k 1.12 4.08   38k 0.65 5.49
3.9     optimized* off  adaptive 40k 0.82 4.83   43k 0.70 5.23
3.9     optimized* off  0        57k 1.17 4.08   62k 1.04 3.95
*not the same config as the one used in v1.

Test setup details:
Machines: each with two Intel Xeon 2680 CPUs and X520 (82599) optical NICs
Tests: Netperf tcp_rr and udp_rr, 1 byte (round trips per second)
Kernel: unmodified 3.9 and patched 3.9
Config: typical is derived from RH6.2, optimized is a stripped down config.
Interrupt coalescing (ethtool rx-usecs) settings: 0=off, 1=adaptive, 100 us
When C3/6 states were turned on (via BIOS) the performance governor was used.

This is not the same exact optimized config that I used last time.
When trying it on kernel 3.9 my machines would not boot.
So I re-did it and I removed a slightly different set of options.
As a result it is a bit faster on the patched kernel.
This is also probably the explanation for a slight regression in 
the performance of the unpatched 3.9 kernel with the optimized config
compared to the 3.8 results.

how to test:
(changes from v1 are highlighted with ***)

1. The patchset should apply cleanly to net-next.
If someone wants a set for 3.9 I can give it to them.
(don't forget to configure INET_LL_RX_POLL and INET_LL_TCP_POLL).

2. The ethtool -c setting for rx-usecs should be on the order of 100.

3. *** Use ethtool -K to disable GRO and LRO
(You are encouraged to try it both ways. If you find that your workload
does better with GRO on do tell us.)

4. *** Sysctl value net.ipv4.ip_low_latency_poll controls how long
(in us) to busy-wait for more data, You are encouraged to play
with this and see what works for you. The default is now 0 so you need to
set it to turn the feature on. I recommend a value around 50.

4. benchmark thread and IRQ should be bound to separate cores.
Both cores should be on the same CPU NUMA node as the NIC.
When the app and the IRQ run on the same CPU  you get a ~5% penalty.
If interrupt coalescing is set to a low value this penalty
can be very large.

5. If you suspect that your machine is not configured properly,
use numademo to make sure that the CPU to memory BW is OK.
numademo 128m memcpy local copy numbers should be more than
8GB/s on a properly configured machine.

Credit:
Jesse Brandeburg, Arun Chekhov Ilango, Julie Cummings,
Alexander Duyck, Eric Geisler, Jason Neighbors, Yadong Li,
Mike Polehn, Anil Vasudevan, Don Wood
Special thanks for finding bugs in earlier versions:
Willem de Bruijn and Andi Kleen

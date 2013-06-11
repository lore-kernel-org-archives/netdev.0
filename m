From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v10 net-next 0/6] net: low latency Ethernet device polling
Date: Tue, 11 Jun 2013 05:25:42 +0300
Message-ID: <51B68AA6.1050105@linux.intel.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com> <20130610.134116.1913599114372510768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130610.134116.1913599114372510768.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2013 23:41, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Mon, 10 Jun 2013 11:39:30 +0300
>
>> I removed the select/poll patch (was 5/7 in v9) from the set.
>> The rest are the same patches that were in v9.
>
> Reply to this email with some text to put in the merge commit,
> including basic benchmark results, so that I can apply this series.
>
sorry,

Here is the text from the RFC and v2 cover letters, updated and merged.
If this is too long, please tell me what you think should be removed.

Thanks,
Eliezer

---

This patch set adds the ability for the socket layer code to
poll directly on an Ethernet device's RX queue.
This eliminates the cost of the interrupt and context switch
and with proper tuning allows us to get very close to the HW latency.

This is a follow up to Jesse Brandeburg's Kernel Plumbers talk from last 
year
http://www.linuxplumbersconf.org/2012/wp-content/uploads/2012/09/2012-lpc-Low-Latency-Sockets-slides-brandeburg.pdf

Patch 1 adds a napi_id and a hashing mechanism to lookup a napi by id.
Patch 2 adds an ndo_ll_poll method and the code that supports it.
Patch 3 adds support for busy-polling on UDP sockets.
Patch 4 adds support for TCP.
Patch 5 adds the ixgbe driver code implementing ndo_ll_poll.
Patch 6 adds additional statistics to the ixgbe driver for ndo_ll_poll.


Performance numbers:
      setup                         TCP_RR           UDP_RR
kernel  Config     C3/6 rx-usecs tps cpu% S.dem  tps cpu% S.dem
patched optimized  on   100      87k 3.13 11.4   94K 3.17 10.7
patched optimized  on   0        71k 3.12 14.0   84k 3.19 12.0
patched optimized  on   adaptive 80k 3.13 12.5   90k 3.46 12.2
patched typical    on   100      72  3.13 14.0   79k 3.17 12.8
patched typical    on   0        60k 2.13 16.5   71k 3.18 14.0
patched typical    on   adaptive 67k 3.51 16.7   75k 3.36 14.5
3.9     optimized  on   adaptive 25k 1.0  12.7   28k 0.98 11.2
3.9     typical    off  0        48k 1.09  7.3   52k 1.11 4.18
3.9     typical    0ff  adaptive 35k 1.12 4.08   38k 0.65 5.49
3.9     optimized  off  adaptive 40k 0.82 4.83   43k 0.70 5.23
3.9     optimized  off  0        57k 1.17 4.08   62k 1.04 3.95

Test setup details:
Machines: each with two Intel Xeon 2680 CPUs and X520 (82599) optical NICs
Tests: Netperf tcp_rr and udp_rr, 1 byte (round trips per second)
Kernel: unmodified 3.9 and patched 3.9
Config: typical is derived from RH6.2, optimized is a stripped down config.
Interrupt coalescing (ethtool rx-usecs) settings: 0=off, 1=adaptive, 100 us
When C3/6 states were turned on (via BIOS) the performance governor was 
used.

These performance numbers were measured with v2 of the patch set.
Performance of the optimized config with an rx-usecs setting of 100
(the first line in the table above) was tracked during the evolution
of the patches and has never varied by more than 1%.


Design:
A global hash table that allows us to look up a struct napi by a unique 
id was added.

A napi_id field was added both to struct sk_buff and struct sk.
This is used to track which NAPI we need to poll for a specific socket.

The device driver marks every incoming skb with this id.
This is propagated to the sk when the socket is looked up in the 
protocol handler.

When the socket code does not find any more data on the socket queue,
it now may call ndo_ll_poll which will crank the device's rx queue and
feed incoming packets to the stack directly from the context of the
socket.

A sysctl value (net.core4.low_latency_poll) controls how many
microseconds we busy-wait before giving up. (setting to 0 globally 
disables busy-polling)


Locking:

1. Locking between napi poll and ndo_ll_poll:
Since what needs to be locked between a device's NAPI poll and
ndo_ll_poll, is highly device / configuration dependent, we do this
inside the Ethernet driver.
For example, when packets for high priority connections are sent to
separate rx queues, you might not need locking between napi poll and
ndo_ll_poll at all.

For ixgbe we only lock the RX queue.
ndo_ll_poll does not touch the interrupt state or the TX queues.
(earlier versions of this patchset did touch them,
but this design is simpler and works better.)

If a queue is actively polled by a socket (on another CPU) napi poll
will not service it, but will wait until the queue can be locked
and cleaned before doing a napi_complete().
If a socket can't lock the queue because another CPU has it,
either from napi or from another socket polling on the queue,
the socket code can busy wait on the socket's skb queue.

Ndo_ll_poll does not have preferential treatment for the data from the
calling socket vs. data from others, so if another CPU is polling,
you will see your data on this socket's queue when it arrives.

Ndo_ll_poll is called with local BHs disabled, so it won't race on
the same CPU with net_rx_action, which calls the napi poll method.

2. Napi_hash
The napi hash mechanism uses RCU.
napi_by_id() must be called under rcu_read_lock().
After a call to napi_hash_del(), caller must take care to wait an rcu
grace period before freeing the memory containing the napi struct.
(Ixgbe already had this because the queue vector structure uses rcu to
protect the statistics counters in it.)


how to test:

1. The patchset should apply cleanly to net-next.
(don't forget to configure INET_LL_RX_POLL).

2. The ethtool -c setting for rx-usecs should be on the order of 100.

3. Use ethtool -K to disable GRO and LRO
(You are encouraged to try it both ways. If you find that your workload
does better with GRO on do tell us.)

4. Sysctl value net.core.low_latency_poll controls how long
(in us) to busy-wait for more data, You are encouraged to play
with this and see what works for you. The default is now 0 so you need to
set it to turn the feature on. I recommend a value around 50.

4. benchmark thread and IRQ should be bound to separate cores.
Both cores should be on the same CPU NUMA node as the NIC.
When the app and the IRQ run on the same CPU  you get a small penalty.
If interrupt coalescing is set to a low value this penalty can be very
large.

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
---

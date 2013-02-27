From: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Subject: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 09:55:49 -0800
Message-ID: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds the ability for the socket layer code to poll directly 
on an Ethernet device's RX queue. This eliminates the cost of the interrupt
and context switch and with proper tuning allows us to get very close
to the HW latency.

This is a follow up to Jesse Brandeburg's Kernel Plumbers talk from last year
http://www.linuxplumbersconf.org/2012/wp-content/uploads/2012/09/2012-lpc-Low-Latency-Sockets-slides-brandeburg.pdf

Patch 1 adds ndo_ll_poll and the IP code to use it.
Patch 2 is an example of how TCP can use ndo_ll_poll.
Patch 3 shows how this method would be implemented for the ixgbe driver.
Patch 4 adds statistics to the ixgbe driver for ndo_ll_poll events.
(Optional) Patch 5 is a handy kprobes module to measure detailed latency 
numbers.

this patchset is also available in the following git branch
git://github.com/jbrandeb/lls.git rfc

Performance numbers:
Kernel   Config     C3/6  rx-usecs  TCP  UDP
3.8rc6   typical    off   adaptive  37k  40k
3.8rc6   typical    off   0*        50k  56k
3.8rc6   optimized  off   0*        61k  67k
3.8rc6   optimized  on    adaptive  26k  29k
patched  typical    off   adaptive  70k  78k
patched  optimized  off   adaptive  79k  88k
patched  optimized  off   100       84k  92k
patched  optimized  on    adaptive  83k  91k
*rx-usecs=0 is usually not useful in a production environment.

Notice that the patched kernel gives good results even with no tweaking.
Performance for the default configuration is up by almost 100%,
tuning will get you another 14%. Comparing best-case performance
patched vs. unpatched, we are up 36%.

Test setup details:
Machines: each with two Intel Xeon 2680 CPUs and X520 (82599) optical NICs
Tests: Netperf tcp_rr and udp_rr, 1 byte (round trips per second)
Kernel: unmodified 3.8rc6 and patched 3.8rc6
Config: typical is derived from RH6.2, optimized is a stripped down config
Interrupt coalescing (ethtool rx-usecs) settings: 0=off, 1=adaptive, 100 us
C3/6 states were turned on and off through BIOS.
When C states were on the performance governor was used.

Design:
Pointers to a napi_struct were added both to struct sk_buff and struct sk.
These are used to track which NAPI we need to poll for a specific socket.
(more about this in the open issues section)
The device driver marks every incoming skb.
This info is propagated to the sk when an skb is added to the socket queue.
When the socket code does not find any more data on the socket queue,
it now may call ndo_ll_poll which will crank the device's rx queue and feed
incoming packets to the stack directly from the context of the socket.
A sysctl value (net.ipv4.ip_low_latency_poll) controls how many cycles we 
busy-wait before giving up. (setting to 0 globally disables busy-polling)

Locking: 
Since what needs to be locked between a device's NAPI poll and ndo_ll_poll,
is highly device / configuration dependent, we do this inside the
Ethernet driver. For example, when packets for high priority connections
are sent to separate rx queues, you might not need locking at all.
For ixgbe we only lock the RX queue.
ndo_ll_poll does not touch the interrupt state or the TX queues.
(earlier versions of this patchset did touch them,
but this design is simpler and works better.)
Ndo_ll_poll is called with local BHs disabled. 

If a queue is actively polled by a socket (on another CPU) napi poll
will not service it, but will wait until the queue can be locked 
and cleaned before doing a napi_complete().
If a socket can't lock the queue because another CPU has it,
either from NAPI or from another socket polling on it,
the socket code can busy wait on the socket's skb queue.
Ndo_ll_poll does not have preferential treatment for the data from the
calling socket vs. data from others, so if another CPU is polling,
you will see your data on this socket's queue when it arrives.

Open issues:
1. Find a way to avoid the need to change the sk and skb structs.
One big disadvantage of how we do this right now is that when a device is
removed, it's hard to prevent it from getting polled by a socket
which holds a stale reference. 

2. How do we decide which sockets are eligible to do busy polling?
Do we add a socket option to control this?
How do we provide sane defaults while allowing flexibility and performance?

3. Andi Kleen and HPA pointed out that using get_cycles() is not portable.

4. How and where do we call ndo_ll_poll from the socket code?
One good place seems to be wherever the kernel puts the process to sleep,
waiting for more data, but this makes doing something intelligent about
poll (the system call) hard. From the perspective of how ndo_ll_poll
itself is implemented this does not seem to matter.

5. I would like to hear suggestions on naming conventions and where
to put the code that for now I have put in include/net/ll_poll.h 

How to test:
1. The patchset should apply cleanly to either net  or Linux 3.8 
(don't forget to configure INET_LL_RX_POLL and INET_LL_TCP_POLL).

2. The ethtool -c setting for rx-usecs should be on the order of 100.

3. Sysctl value net.ipv4.ip_low_latency_poll controls how long
(in cycles) to busy-wait for more data, You are encouraged to play
with this and see what works for you. (setting it to 0 would
globally disable the new mechanism altogether.)

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
Jesse Brandeburg, Arun Chekhov Ilango, Alexander Duyck, Eric Geisler,
Jason Neighbors, Yadong Li, Mike Polehn, Anil Vasudevan, Don Wood
Special thanks for finding bugs in earlier versions:
Willem de Bruijn and Andi Kleen

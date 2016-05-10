From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 16:11:52 +0200
Message-ID: <cover.1462886866.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the softirq loop can be scheduled both inside the ksofirqd kernel
thread and inside any running process. This makes nearly impossible for the
process scheduler to balance in a fair way the amount of time that
a given core spends performing the softirq loop.

Under high network load, the softirq loop can take nearly 100% of a given CPU,
leaving very little time for use space processing. On single core hosts, this
means that the user space can nearly starve; for example super_netperf
UDP_STREAM tests towards a remote single core vCPU guest[1] can measure an
aggregated throughput of a few thousands pps, and the same behavior can be
reproduced even on bare-metal, eventually simulating a single core with taskset
and/or sysfs configuration.

This patch series allows the administrator to let the napi poll loop run inside
its own kernel thread, a thread for each napi instance, while retaining the
default, softirq-based behavior. The RPS mechanism is currently not affected.

When the napi poll loop is run inside a proper kernel thread, the process
scheduler can fairly balance the rx job between the user space application and
the kernel and give the administrator the ability to manage the network workload
with scheduler tools and configuration.

With the default scheduling policy, the starvation issue observed on single vCPU
guest under UDP flood is solved and the throughput measured under heavy
overload is quite stable around the peak performance.

In the remote host to VM scenario, running even the hypervisor napi poll loop
in threaded mode gives additional benefit, since the process scheduler can
more easily avoid cpu conflict between the VM process and the kernel thread
processing the rx packets.

The raw numbers, obtained with the super_neterf UDP_STREAM test, in a remote
host to VM scenario, using a tun device with a noqueue qdisc in the hypervisor
and using 'sdfn' for the rx flow hash on the ingress device, are as follow:

		vanilla		guest threaded		both hypevisor and
							guest threaded
size/flow	kpps		kpps/delta		kpps/delta
1/1		746		901/+20%		1024/+37%
1/25		185		585/+215%		789/+325%
1/50		330		642/+94%		843/+155%
1/100		180		662/+267%		872/+383%
1/200		177		672/+279%		812/+358%
64/1		707		1042/+47%		1062/+50%
64/25		320		586/+83%		746/+132%
64/50		195		648/+232%		761/+290%
64/100		221		666/+200%		787/+255%
64/200		186		688/+268%		793/+325%
256/1		475		777/+63%		809/+70%
256/25		303		589/+83%		860/+183%
256/50		308		584/+89%		825/+168%
256/100		268		698/+159%		785/+191%
256/200		186		656/+398%		795/+503%
1438/1		619		664/+7%			640/+3%
1438/25		519		766/+47%		829/+59%
1438/50		451		712/+57%		820/+81%
1438/100	294		759/+158%		797/+170%
1438/200	262		728/+177%		769/+193%
4096/1		176		207/+17%		200/+13%
4096/25		225		275/+22%		286/+27%
4096/50		212		272/+28%		283/+33%
4096/100	168		264/+57%		283/+68%
4096/200	134		240/+78%		273/+102%
64000/1		16		18/+13%			18/+13%
64000/25	18		18/0			18/0
64000/50	18		18/0			18/0
64000/100	18		18/0			18/0
64000/200	15		15/0			15/0

This patchset is a first RFC but in the long run we would like to move
more and more NAPI instances into kthreads. The kthread approach should
give a lot of new advantages over the softirq based approach:

* moving into a more dpdk-alike busy poll packet processing direction:
we can even use busy polling without the need of a connected UDP or TCP
socket and can leverage busy polling for forwarding setups. This could
very well increase latency and packet throughput without hurting other
processes if the networking stack gets more and more preemptive in the
future.

* possibility to acquire mutexes in the networking processing path: e.g.
we would need that to configure hw_breakpoints if we want to add
watchpoints in the memory based on some rules in the kernel

* more and better tooling to adjust the weight of the networking
kthreads, preferring certain networking cards or setting cpus affinity
on packet processing threads. Maybe also using deadline scheduling or
other scheduler features might be worthwhile.

* scheduler statistics can be used to observe network packet processing

At this point we are not really sure if we should go with this simpler
approach by putting NAPI itself into kthreads or leverage the threadirqs
function by putting the whole interrupt into a thread and signaling NAPI
that it does not reschedule itself in a softirq but to simply run at
this particular context of the interrupt handler.

While the threaded irq way seems to better integrate into the kernel and
also other devices could move their interrupts into the threads easily
on a common policy, we don't know how to really express the necessary
knobs with the current device driver model (module parameters, sysfs
attributes, etc.). This is where we would like to hear some opinions.
NAPI would e.g. have to query the kernel if the particular IRQ/MSI if it
should be scheduled in a softirq or in a thread, so we don't have to
rewrite all device drivers. This might even be needed on a per rx-queue
granularity.

[1] when the flows are processed by the hypervisor on different rx queues, i.e.
the flows use different source/destination IPs or the hypervisor uses the L4
header to compute the rx hash.

Paolo Abeni (2):
  net: implement threaded-able napi poll loop support
  net: add sysfs attribute to control napi threaded mode

 include/linux/netdevice.h |   4 ++
 net/core/dev.c            | 113 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-sysfs.c      | 102 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 219 insertions(+)

-- 
1.8.3.1

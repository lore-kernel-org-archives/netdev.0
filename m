From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 0/5] genirq: threadable IRQ support
Date: Wed, 15 Jun 2016 15:42:01 +0200
Message-ID: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130AbcFONmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 09:42:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a new genirq interface to allows the user space to change
the IRQ mode at runtime, switching to and from the threaded mode.

The configuration is performing on a per irqaction basis, writing into the
newly added procfs entry /proc/irq/<nr>/<irq action name>/threaded. Such entry
is created at IRQ request time, only if CONFIG_IRQ_FORCED_THREADING
is defined.

Upon IRQ creation, the device handling such IRQ may optionally provide, via
the newly added API irq_set_mode_notifier(), an additional callback to be
notified about IRQ mode change.
The device can use such callback to configure its internal state to behave
differently in threaded mode and in normal mode if required.

Additional IRQ flags are added to let the device specifies some default
aspects of the IRQ thread. The device can request a SCHED_NORMAL scheduling
policy and avoid the affinity setting for the IRQ thread. Both of such
options are beneficial for the first threadable IRQ user.

The initial user for this feature is the networking subsystem; some
infrastructure is added to the network core for such goal. A new napi field
storing an IRQ thread reference is used to mark a NAPI instance as threaded
and __napi_schedule is modified to invoke a poll loop directly instead of
raising a softirq when the related NAPI instance is in threaded mode, plus 
a IRQ_mode_set callback is provided to notify the NAPI instance of the IRQ
mode change.

Each network device driver must be migrated explicitly to leverage the new
infrastructure. In this patch series, the Intel ixgbe is updated to invoke
irq_set_mode_notifier(), only when using msix IRQs. 
This avoids other IRQ events to be delayed indefinitely when the rx IRQ is
processed in thread mode. The default behavior after the driver migration is
unchanged.

Running the rx packets processing inside a conventional kthread is beneficial
for different workload since it allows the process scheduler to nicely use
the available resources. With multiqueue NICs, the ksoftirq design does not allow
any running process to use 100% of a single CPU, under relevant network load,
because the softirq poll loop will be scheduled on each CPU.

The above can be experienced in a hypervisor/VMs scenario, when the guest is
under UDP flood. If the hypervisor's NIC has enough rx queues the guest will
compete with ksoftirqd on each CPU. Moreover, since the ksoftirqd CPU
utilization change with the ingress traffic, the scheduler try to migrate the
guest processes towards the CPUs with the highest capacity, further impacting
the guest ability to process rx packets.

Running the hypervisor rx packet processing inside a migrable kthread allows
the process scheduler to let the guest process[es] to fully use a single a
core each, migrating some rx threads as required.

The raw numbers, obtained with the netperf UDP_STREAM test, using a tun
device with a noqueue qdisc in the hypervisor, and using random IP addresses
as source in case of multiple flows, are as follow:

		vanilla		threaded
size/flow	kpps		kpps/delta
1/1		824		843/+2%
1/25		736		906/+23%
1/50		752		906/+20%
1/100		772		906/+17%
1/200		741		976/+31%
64/1		829		840/+1%
64/25		711		932/+31%
64/50		780		894/+14%
64/100		754		946/+25%
64/200		714		945/+32%
256/1		702		510/-27%
256/25		724		894/+23%
256/50		739		889/+20%
256/100		798		873/+9%
256/200		812		907/+11%
1400/1		720		727/+1%
1400/25		826		826/0
1400/50		827		833/0
1400/100	820		820/0
1400/200	796		799/0

The guest runs 2vCPU, so it's not prone to the userspace livelock issue
recently exposed here: http://thread.gmane.org/gmane.linux.kernel/2218719

There are relevant improvement in all cpu bounded scenarios with multiple flows
and significant regression with medium size packet, single flow. The latter
is due to the increased 'burstiness' of packet processing which cause the
single socket in the guest of overflow more easily, if the receiver application
is scheduled on the same cpu processing the incoming packets.

The kthread approach should give a lot of new advantages over the softirq
based approach:

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



Paolo Abeni (5):
  genirq: implement support for runtime switch to threaded irqs
  genirq: add flags for controlling the default threaded irq behavior
  sched/preempt: cond_resched_softirq() must check for softirq
  netdev: implement infrastructure for threadable napi irq
  ixgbe: add support for threadable rx irq

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  14 +-
 include/linux/interrupt.h                     |  21 +++
 include/linux/netdevice.h                     |   4 +
 kernel/irq/internals.h                        |   3 +
 kernel/irq/manage.c                           | 212 ++++++++++++++++++++++++--
 kernel/irq/proc.c                             |  51 +++++++
 kernel/sched/core.c                           |   3 +-
 net/core/dev.c                                |  59 +++++++
 8 files changed, 355 insertions(+), 12 deletions(-)

-- 
1.8.3.1

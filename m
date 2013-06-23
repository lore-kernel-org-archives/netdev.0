From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 00/45] CPU hotplug: stop_machine()-free CPU hotplug, part 1
Date: Sun, 23 Jun 2013 19:07:44 +0530
Message-ID: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-arch-owner@vger.kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset is a first step towards removing stop_machine() from the
CPU hotplug offline path. It introduces a set of APIs (as a replacement to
preempt_disable()/preempt_enable()) to synchronize with CPU hotplug from
atomic contexts.

The motivation behind getting rid of stop_machine() is to avoid its
ill-effects, such as performance penalties[1] and the real-time latencies it
inflicts on the system (and also things involving stop_machine() have often
been notoriously hard to debug). And in general, getting rid of stop_machine()
from CPU hotplug also greatly enhances the elegance of the CPU hotplug design
itself.

Getting rid of stop_machine() involves building the corresponding
infrastructure in the core CPU hotplug code and converting all places which
used to depend on the semantics of stop_machine() to synchronize with CPU
hotplug.

This patchset builds a first-level base infrastructure on which tree-wide
conversions can be built upon, and also includes the conversions themselves.
We certainly need a few more careful tree-sweeps to complete the conversion,
but the goal of this patchset is to introduce the core pieces and to get the
first batch of conversions in, while covering a reasonable bulk among them.

This patchset also has a debug infrastructure to help with the conversions -
with the newly introduced CONFIG_DEBUG_HOTPLUG_CPU option turned on, it
prints warnings whenever the need for a conversion is detected. Patches 4-7
build this framework. Needless to say, I'd really appreciate if people could
test kernels with this option turned on and report omissions or better yet,
send patches to contribute to this effort.

[It is to be noted that this patchset doesn't replace stop_machine() yet,
so the immediate risk in having an unconverted (or converted) call-site
is nil, since there is no major functional change involved.]

Once the conversion gets completed, we can finalize on the design of the
stop_machine() replacement and use that in the core CPU hotplug code. We have
had some discussions in the past where we debated several different
designs[2]. We'll revisit that with more ideas once this conversion gets over.


This patchset applies on current tip:master. It is also available in the
following git branch:

git://github.com/srivatsabhat/linux.git  stop-mch-free-cpuhp-part1-v1


Thank you very much!


References:
----------

1. Performance difference between CPU Hotplug with and without
   stop_machine():
   http://article.gmane.org/gmane.linux.kernel/1435249

2. Links to discussions around alternative synchronization schemes to
   replace stop_machine() in the CPU Hotplug code:

   v6: http://lwn.net/Articles/538819/
   v5: http://lwn.net/Articles/533553/
   v4: https://lkml.org/lkml/2012/12/11/209
   v3: https://lkml.org/lkml/2012/12/7/287
   v2: https://lkml.org/lkml/2012/12/5/322
   v1: https://lkml.org/lkml/2012/12/4/88

--
 Srivatsa S. Bhat (45):
      CPU hotplug: Provide APIs to prevent CPU offline from atomic context
      CPU hotplug: Clarify the usage of different synchronization APIs
      Documentation, CPU hotplug: Recommend usage of get/put_online_cpus_atomic()
      CPU hotplug: Add infrastructure to check lacking hotplug synchronization
      CPU hotplug: Protect set_cpu_online() to avoid false-positives
      CPU hotplug: Sprinkle debugging checks to catch locking bugs
      CPU hotplug: Expose the new debug config option
      CPU hotplug: Convert preprocessor macros to static inline functions
      smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      sched/core: Use get/put_online_cpus_atomic() to prevent CPU offline
      migration: Use raw_spin_lock/unlock since interrupts are already disabled
      sched/fair: Use get/put_online_cpus_atomic() to prevent CPU offline
      timer: Use get/put_online_cpus_atomic() to prevent CPU offline
      sched/rt: Use get/put_online_cpus_atomic() to prevent CPU offline
      rcu: Use get/put_online_cpus_atomic() to prevent CPU offline
      tick-broadcast: Use get/put_online_cpus_atomic() to prevent CPU offline
      time/clocksource: Use get/put_online_cpus_atomic() to prevent CPU offline
      softirq: Use get/put_online_cpus_atomic() to prevent CPU offline
      irq: Use get/put_online_cpus_atomic() to prevent CPU offline
      net: Use get/put_online_cpus_atomic() to prevent CPU offline
      block: Use get/put_online_cpus_atomic() to prevent CPU offline
      percpu_counter: Use get/put_online_cpus_atomic() to prevent CPU offline
      infiniband: ehca: Use get/put_online_cpus_atomic() to prevent CPU offline
      [SCSI] fcoe: Use get/put_online_cpus_atomic() to prevent CPU offline
      staging/octeon: Use get/put_online_cpus_atomic() to prevent CPU offline
      x86: Use get/put_online_cpus_atomic() to prevent CPU offline
      perf/x86: Use get/put_online_cpus_atomic() to prevent CPU offline
      KVM: Use get/put_online_cpus_atomic() to prevent CPU offline
      kvm/vmx: Use get/put_online_cpus_atomic() to prevent CPU offline
      x86/xen: Use get/put_online_cpus_atomic() to prevent CPU offline
      alpha/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      blackfin/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      cris/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      hexagon/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      ia64: irq, perfmon: Use get/put_online_cpus_atomic() to prevent CPU offline
      ia64: smp, tlb: Use get/put_online_cpus_atomic() to prevent CPU offline
      m32r: Use get/put_online_cpus_atomic() to prevent CPU offline
      MIPS: Use get/put_online_cpus_atomic() to prevent CPU offline
      mn10300: Use get/put_online_cpus_atomic() to prevent CPU offline
      powerpc, irq: Use GFP_ATOMIC allocations in atomic context
      powerpc: Use get/put_online_cpus_atomic() to prevent CPU offline
      powerpc: Use get/put_online_cpus_atomic() to avoid false-positive warning
      sh: Use get/put_online_cpus_atomic() to prevent CPU offline
      sparc: Use get/put_online_cpus_atomic() to prevent CPU offline
      tile: Use get/put_online_cpus_atomic() to prevent CPU offline

 Documentation/cpu-hotplug.txt                 |   20 +++-
 arch/alpha/kernel/smp.c                       |   19 ++--
 arch/blackfin/mach-common/smp.c               |    4 -
 arch/cris/arch-v32/kernel/smp.c               |    5 +
 arch/hexagon/kernel/smp.c                     |    3 +
 arch/ia64/kernel/irq_ia64.c                   |   15 +++
 arch/ia64/kernel/perfmon.c                    |    8 +-
 arch/ia64/kernel/smp.c                        |   12 +-
 arch/ia64/mm/tlb.c                            |    4 -
 arch/m32r/kernel/smp.c                        |   16 ++-
 arch/mips/kernel/cevt-smtc.c                  |    7 +
 arch/mips/kernel/smp.c                        |   16 ++-
 arch/mips/kernel/smtc.c                       |   12 ++
 arch/mips/mm/c-octeon.c                       |    4 -
 arch/mn10300/mm/cache-smp.c                   |    3 +
 arch/mn10300/mm/tlb-smp.c                     |   17 ++-
 arch/powerpc/kernel/irq.c                     |    9 +-
 arch/powerpc/kernel/machine_kexec_64.c        |    4 -
 arch/powerpc/kernel/smp.c                     |    4 +
 arch/powerpc/kvm/book3s_hv.c                  |    5 +
 arch/powerpc/mm/mmu_context_nohash.c          |    3 +
 arch/powerpc/oprofile/cell/spu_profiler.c     |    3 +
 arch/powerpc/oprofile/cell/spu_task_sync.c    |    4 +
 arch/powerpc/oprofile/op_model_cell.c         |    6 +
 arch/sh/kernel/smp.c                          |   12 +-
 arch/sparc/kernel/smp_64.c                    |   12 ++
 arch/tile/kernel/module.c                     |    3 +
 arch/tile/kernel/tlb.c                        |   15 +++
 arch/tile/mm/homecache.c                      |    3 +
 arch/x86/kernel/apic/io_apic.c                |   21 ++++
 arch/x86/kernel/cpu/mcheck/therm_throt.c      |    4 -
 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    6 +
 arch/x86/kvm/vmx.c                            |   13 +--
 arch/x86/mm/tlb.c                             |   14 +--
 arch/x86/xen/mmu.c                            |    9 +-
 block/blk-softirq.c                           |    3 +
 drivers/infiniband/hw/ehca/ehca_irq.c         |    5 +
 drivers/scsi/fcoe/fcoe.c                      |    7 +
 drivers/staging/octeon/ethernet-rx.c          |    3 +
 include/linux/cpu.h                           |   27 +++++
 include/linux/cpumask.h                       |   59 +++++++++++-
 kernel/cpu.c                                  |  124 +++++++++++++++++++++++++
 kernel/irq/manage.c                           |    7 +
 kernel/irq/proc.c                             |    3 +
 kernel/rcutree.c                              |    4 +
 kernel/sched/core.c                           |   27 +++++
 kernel/sched/fair.c                           |   14 +++
 kernel/sched/rt.c                             |   14 +++
 kernel/smp.c                                  |   52 ++++++----
 kernel/softirq.c                              |    3 +
 kernel/time/clocksource.c                     |    5 +
 kernel/time/tick-broadcast.c                  |    8 ++
 kernel/timer.c                                |    4 +
 lib/Kconfig.debug                             |    9 ++
 lib/cpumask.c                                 |    8 ++
 lib/percpu_counter.c                          |    2 
 net/core/dev.c                                |    9 +-
 virt/kvm/kvm_main.c                           |    8 +-
 58 files changed, 591 insertions(+), 129 deletions(-)


Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

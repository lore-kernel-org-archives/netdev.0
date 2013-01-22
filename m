From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Tue, 22 Jan 2013 13:03:09 +0530
Message-ID: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset removes CPU hotplug's dependence on stop_machine() from the CPU
offline path and provides an alternative (set of APIs) to preempt_disable() to
prevent CPUs from going offline, which can be invoked from atomic context.
The motivation behind the removal of stop_machine() is to avoid its ill-effects
and thus improve the design of CPU hotplug. (More description regarding this
is available in the patches).

All the users of preempt_disable()/local_irq_disable() who used to use it to
prevent CPU offline, have been converted to the new primitives introduced in the
patchset. Also, the CPU_DYING notifiers have been audited to check whether
they can cope up with the removal of stop_machine() or whether they need to
use new locks for synchronization (all CPU_DYING notifiers looked OK, without
the need for any new locks).

Applies on v3.8-rc4. It currently has some locking issues with cpu idle (on
which even lockdep didn't provide any insight unfortunately). So for now, it
works with CONFIG_CPU_IDLE=n.

Overview of the patches:
-----------------------

Patches 1 to 6 introduce a generic, flexible Per-CPU Reader-Writer Locking
scheme.

Patch 7 uses this synchronization mechanism to build the
get/put_online_cpus_atomic() APIs which can be used from atomic context, to
prevent CPUs from going offline.

Patch 8 is a cleanup; it converts preprocessor macros to static inline
functions.

Patches 9 to 42 convert various call-sites to use the new APIs.

Patch 43 is the one which actually removes stop_machine() from the CPU
offline path.

Patch 44 decouples stop_machine() and CPU hotplug from Kconfig.

Patch 45 updates the documentation to reflect the new APIs.


Changes in v5:
--------------
  Exposed a new generic locking scheme: Flexible Per-CPU Reader-Writer locks,
  based on the synchronization schemes already discussed in the previous
  versions, and used it in CPU hotplug, to implement the new APIs.

  Audited the CPU_DYING notifiers in the kernel source tree and replaced
  usages of preempt_disable() with the new get/put_online_cpus_atomic() APIs
  where necessary.


Changes in v4:
--------------
  The synchronization scheme has been simplified quite a bit, which makes it
  look a lot less complex than before. Some highlights:

* Implicit ACKs:

  The earlier design required the readers to explicitly ACK the writer's
  signal. The new design uses implicit ACKs instead. The reader switching
  over to rwlock implicitly tells the writer to stop waiting for that reader.

* No atomic operations:

  Since we got rid of explicit ACKs, we no longer have the need for a reader
  and a writer to update the same counter. So we can get rid of atomic ops
  too.

Changes in v3:
--------------
* Dropped the _light() and _full() variants of the APIs. Provided a single
  interface: get/put_online_cpus_atomic().

* Completely redesigned the synchronization mechanism again, to make it
  fast and scalable at the reader-side in the fast-path (when no hotplug
  writers are active). This new scheme also ensures that there is no
  possibility of deadlocks due to circular locking dependency.
  In summary, this provides the scalability and speed of per-cpu rwlocks
  (without actually using them), while avoiding the downside (deadlock
  possibilities) which is inherent in any per-cpu locking scheme that is
  meant to compete with preempt_disable()/enable() in terms of flexibility.

  The problem with using per-cpu locking to replace preempt_disable()/enable
  was explained here:
  https://lkml.org/lkml/2012/12/6/290

  Basically we use per-cpu counters (for scalability) when no writers are
  active, and then switch to global rwlocks (for lock-safety) when a writer
  becomes active. It is a slightly complex scheme, but it is based on
  standard principles of distributed algorithms.

Changes in v2:
-------------
* Completely redesigned the synchronization scheme to avoid using any extra
  cpumasks.

* Provided APIs for 2 types of atomic hotplug readers: "light" (for
  light-weight) and "full". We wish to have more "light" readers than
  the "full" ones, to avoid indirectly inducing the "stop_machine effect"
  without even actually using stop_machine().

  And the patches show that it _is_ generally true: 5 patches deal with
  "light" readers, whereas only 1 patch deals with a "full" reader.

  Also, the "light" readers happen to be in very hot paths. So it makes a
  lot of sense to have such a distinction and a corresponding light-weight
  API.

Links to previous versions:
v4: https://lkml.org/lkml/2012/12/11/209
v3: https://lkml.org/lkml/2012/12/7/287
v2: https://lkml.org/lkml/2012/12/5/322
v1: https://lkml.org/lkml/2012/12/4/88

--

Paul E. McKenney (1):
      cpu: No more __stop_machine() in _cpu_down()

Srivatsa S. Bhat (44):
      percpu_rwlock: Introduce the global reader-writer lock backend
      percpu_rwlock: Introduce per-CPU variables for the reader and the writer
      percpu_rwlock: Provide a way to define and init percpu-rwlocks at compile time
      percpu_rwlock: Implement the core design of Per-CPU Reader-Writer Locks
      percpu_rwlock: Make percpu-rwlocks IRQ-safe, optimally
      percpu_rwlock: Allow writers to be readers, and add lockdep annotations
      CPU hotplug: Provide APIs to prevent CPU offline from atomic context
      CPU hotplug: Convert preprocessor macros to static inline functions
      smp, cpu hotplug: Fix smp_call_function_*() to prevent CPU offline properly
      smp, cpu hotplug: Fix on_each_cpu_*() to prevent CPU offline properly
      sched/timer: Use get/put_online_cpus_atomic() to prevent CPU offline
      sched/migration: Use raw_spin_lock/unlock since interrupts are already disabled
      sched/rt: Use get/put_online_cpus_atomic() to prevent CPU offline
      rcu, CPU hotplug: Fix comment referring to stop_machine()
      tick: Use get/put_online_cpus_atomic() to prevent CPU offline
      time/clocksource: Use get/put_online_cpus_atomic() to prevent CPU offline
      softirq: Use get/put_online_cpus_atomic() to prevent CPU offline
      irq: Use get/put_online_cpus_atomic() to prevent CPU offline
      net: Use get/put_online_cpus_atomic() to prevent CPU offline
      block: Use get/put_online_cpus_atomic() to prevent CPU offline
      crypto: pcrypt - Protect access to cpu_online_mask with get/put_online_cpus()
      infiniband: ehca: Use get/put_online_cpus_atomic() to prevent CPU offline
      [SCSI] fcoe: Use get/put_online_cpus_atomic() to prevent CPU offline
      staging: octeon: Use get/put_online_cpus_atomic() to prevent CPU offline
      x86: Use get/put_online_cpus_atomic() to prevent CPU offline
      perf/x86: Use get/put_online_cpus_atomic() to prevent CPU offline
      KVM: Use get/put_online_cpus_atomic() to prevent CPU offline from atomic context
      kvm/vmx: Use get/put_online_cpus_atomic() to prevent CPU offline
      x86/xen: Use get/put_online_cpus_atomic() to prevent CPU offline
      alpha/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      blackfin/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      cris/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      hexagon/smp: Use get/put_online_cpus_atomic() to prevent CPU offline
      ia64: Use get/put_online_cpus_atomic() to prevent CPU offline
      m32r: Use get/put_online_cpus_atomic() to prevent CPU offline
      MIPS: Use get/put_online_cpus_atomic() to prevent CPU offline
      mn10300: Use get/put_online_cpus_atomic() to prevent CPU offline
      parisc: Use get/put_online_cpus_atomic() to prevent CPU offline
      powerpc: Use get/put_online_cpus_atomic() to prevent CPU offline
      sh: Use get/put_online_cpus_atomic() to prevent CPU offline
      sparc: Use get/put_online_cpus_atomic() to prevent CPU offline
      tile: Use get/put_online_cpus_atomic() to prevent CPU offline
      CPU hotplug, stop_machine: Decouple CPU hotplug from stop_machine() in Kconfig
      Documentation/cpu-hotplug: Remove references to stop_machine()


  Documentation/cpu-hotplug.txt                 |   17 +-
 arch/alpha/kernel/smp.c                       |   19 +-
 arch/arm/Kconfig                              |    1 
 arch/blackfin/Kconfig                         |    1 
 arch/blackfin/mach-common/smp.c               |    6 -
 arch/cris/arch-v32/kernel/smp.c               |    8 +
 arch/hexagon/kernel/smp.c                     |    5 +
 arch/ia64/Kconfig                             |    1 
 arch/ia64/kernel/irq_ia64.c                   |   13 +
 arch/ia64/kernel/perfmon.c                    |    6 +
 arch/ia64/kernel/smp.c                        |   23 ++
 arch/ia64/mm/tlb.c                            |    6 -
 arch/m32r/kernel/smp.c                        |   12 +
 arch/mips/Kconfig                             |    1 
 arch/mips/kernel/cevt-smtc.c                  |    8 +
 arch/mips/kernel/smp.c                        |   16 +-
 arch/mips/kernel/smtc.c                       |    3 
 arch/mips/mm/c-octeon.c                       |    4 
 arch/mn10300/Kconfig                          |    1 
 arch/mn10300/kernel/smp.c                     |    2 
 arch/mn10300/mm/cache-smp.c                   |    5 +
 arch/mn10300/mm/tlb-smp.c                     |   15 +-
 arch/parisc/Kconfig                           |    1 
 arch/parisc/kernel/smp.c                      |    4 
 arch/powerpc/Kconfig                          |    1 
 arch/powerpc/mm/mmu_context_nohash.c          |    2 
 arch/s390/Kconfig                             |    1 
 arch/sh/Kconfig                               |    1 
 arch/sh/kernel/smp.c                          |   12 +
 arch/sparc/Kconfig                            |    1 
 arch/sparc/kernel/leon_smp.c                  |    2 
 arch/sparc/kernel/smp_64.c                    |    9 +
 arch/sparc/kernel/sun4d_smp.c                 |    2 
 arch/sparc/kernel/sun4m_smp.c                 |    3 
 arch/tile/kernel/smp.c                        |    4 
 arch/x86/Kconfig                              |    1 
 arch/x86/include/asm/ipi.h                    |    5 +
 arch/x86/kernel/apic/apic_flat_64.c           |   10 +
 arch/x86/kernel/apic/apic_numachip.c          |    5 +
 arch/x86/kernel/apic/es7000_32.c              |    5 +
 arch/x86/kernel/apic/io_apic.c                |    7 +
 arch/x86/kernel/apic/ipi.c                    |   10 +
 arch/x86/kernel/apic/x2apic_cluster.c         |    4 
 arch/x86/kernel/apic/x2apic_uv_x.c            |    4 
 arch/x86/kernel/cpu/mcheck/therm_throt.c      |    4 
 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    5 +
 arch/x86/kvm/vmx.c                            |    8 +
 arch/x86/mm/tlb.c                             |   14 +
 arch/x86/xen/mmu.c                            |   11 +
 arch/x86/xen/smp.c                            |    9 +
 block/blk-softirq.c                           |    4 
 crypto/pcrypt.c                               |    4 
 drivers/infiniband/hw/ehca/ehca_irq.c         |    8 +
 drivers/scsi/fcoe/fcoe.c                      |    7 +
 drivers/staging/octeon/ethernet-rx.c          |    3 
 include/linux/cpu.h                           |    8 +
 include/linux/percpu-rwlock.h                 |   86 +++++++++
 include/linux/stop_machine.h                  |    2 
 init/Kconfig                                  |    2 
 kernel/cpu.c                                  |   61 ++++++
 kernel/irq/manage.c                           |    7 +
 kernel/rcutree.c                              |    9 -
 kernel/sched/core.c                           |   36 +++-
 kernel/sched/fair.c                           |    5 -
 kernel/sched/rt.c                             |    3 
 kernel/smp.c                                  |   65 ++++---
 kernel/softirq.c                              |    3 
 kernel/time/clocksource.c                     |    5 +
 kernel/time/tick-broadcast.c                  |    2 
 kernel/timer.c                                |    2 
 lib/Kconfig                                   |    3 
 lib/Makefile                                  |    1 
 lib/percpu-rwlock.c                           |  242 +++++++++++++++++++++++++
 net/core/dev.c                                |    9 +
 virt/kvm/kvm_main.c                           |   10 +
 75 files changed, 776 insertions(+), 129 deletions(-)
 create mode 100644 include/linux/percpu-rwlock.h
 create mode 100644 lib/percpu-rwlock.c



Thanks,
Srivatsa S. Bhat
IBM Linux Technology Center

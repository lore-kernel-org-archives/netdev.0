From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 28/45] perf/x86: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Fri, 28 Jun 2013 01:27:18 +0530
Message-ID: <20130627195718.29830.42774.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPU_DYING notifier modifies the per-cpu pointer pmu->box, and this can
race with functions such as uncore_pmu_to_box() and uncore_pci_remove() when
we remove stop_machine() from the CPU offline path. So protect them using
get/put_online_cpus_atomic().

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/kernel/cpu/perf_event_intel_uncore.c b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
index 9dd9975..7c2a064 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_uncore.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
@@ -1,3 +1,4 @@
+#include <linux/cpu.h>
 #include "perf_event_intel_uncore.h"
 
 static struct intel_uncore_type *empty_uncore[] = { NULL, };
@@ -2630,6 +2631,7 @@ uncore_pmu_to_box(struct intel_uncore_pmu *pmu, int cpu)
 	if (box)
 		return box;
 
+	get_online_cpus_atomic();
 	raw_spin_lock(&uncore_box_lock);
 	list_for_each_entry(box, &pmu->box_list, list) {
 		if (box->phys_id == topology_physical_package_id(cpu)) {
@@ -2639,6 +2641,7 @@ uncore_pmu_to_box(struct intel_uncore_pmu *pmu, int cpu)
 		}
 	}
 	raw_spin_unlock(&uncore_box_lock);
+	put_online_cpus_atomic();
 
 	return *per_cpu_ptr(pmu->box, cpu);
 }
@@ -3229,6 +3232,7 @@ static void uncore_pci_remove(struct pci_dev *pdev)
 	list_del(&box->list);
 	raw_spin_unlock(&uncore_box_lock);
 
+	get_online_cpus_atomic();
 	for_each_possible_cpu(cpu) {
 		if (*per_cpu_ptr(pmu->box, cpu) == box) {
 			*per_cpu_ptr(pmu->box, cpu) = NULL;
@@ -3237,6 +3241,8 @@ static void uncore_pci_remove(struct pci_dev *pdev)
 	}
 
 	WARN_ON_ONCE(atomic_read(&box->refcnt) != 1);
+	put_online_cpus_atomic();
+
 	kfree(box);
 }
 

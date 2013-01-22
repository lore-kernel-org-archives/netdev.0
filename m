From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 26/45] perf/x86: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Tue, 22 Jan 2013 13:09:52 +0530
Message-ID: <20130122073948.13822.43399.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPU_DYING notifier modifies the per-cpu pointer pmu->box, and this can
race with functions such as uncore_pmu_to_box() and uncore_pci_remove() when
we remove stop_machine() from the CPU offline path. So protect them using
get/put_online_cpus_atomic().

Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/cpu/perf_event_intel_uncore.c b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
index b43200d..6faae53 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_uncore.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
@@ -1,3 +1,4 @@
+#include <linux/cpu.h>
 #include "perf_event_intel_uncore.h"
 
 static struct intel_uncore_type *empty_uncore[] = { NULL, };
@@ -1965,6 +1966,7 @@ uncore_pmu_to_box(struct intel_uncore_pmu *pmu, int cpu)
 	if (box)
 		return box;
 
+	get_online_cpus_atomic();
 	raw_spin_lock(&uncore_box_lock);
 	list_for_each_entry(box, &pmu->box_list, list) {
 		if (box->phys_id == topology_physical_package_id(cpu)) {
@@ -1974,6 +1976,7 @@ uncore_pmu_to_box(struct intel_uncore_pmu *pmu, int cpu)
 		}
 	}
 	raw_spin_unlock(&uncore_box_lock);
+	put_online_cpus_atomic();
 
 	return *per_cpu_ptr(pmu->box, cpu);
 }
@@ -2556,6 +2559,7 @@ static void uncore_pci_remove(struct pci_dev *pdev)
 	if (WARN_ON_ONCE(phys_id != box->phys_id))
 		return;
 
+	get_online_cpus_atomic();
 	raw_spin_lock(&uncore_box_lock);
 	list_del(&box->list);
 	raw_spin_unlock(&uncore_box_lock);
@@ -2569,6 +2573,7 @@ static void uncore_pci_remove(struct pci_dev *pdev)
 
 	WARN_ON_ONCE(atomic_read(&box->refcnt) != 1);
 	kfree(box);
+	put_online_cpus_atomic();
 }
 
 static int uncore_pci_probe(struct pci_dev *pdev,


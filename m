From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 44/45] sparc: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Wed, 26 Jun 2013 02:03:53 +0530
Message-ID: <20130625203353.16593.20506.stgit@srivatsabhat.in.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sam Ravnborg <sam@ravnborg.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Kleikamp <dave.kleikamp@oracle.com>,
	sparclinux@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/sparc/kernel/smp_64.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 77539ed..4f71a95 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -792,7 +792,9 @@ static void smp_cross_call_masked(unsigned long *func, u32 ctx, u64 data1, u64 d
 /* Send cross call to all processors except self. */
 static void smp_cross_call(unsigned long *func, u32 ctx, u64 data1, u64 data2)
 {
+	get_online_cpus_atomic();
 	smp_cross_call_masked(func, ctx, data1, data2, cpu_online_mask);
+	put_online_cpus_atomic();
 }
 
 extern unsigned long xcall_sync_tick;
@@ -896,7 +898,7 @@ void smp_flush_dcache_page_impl(struct page *page, int cpu)
 	atomic_inc(&dcpage_flushes);
 #endif
 
-	this_cpu = get_cpu();
+	this_cpu = get_online_cpus_atomic();
 
 	if (cpu == this_cpu) {
 		__local_flush_dcache_page(page);
@@ -922,7 +924,7 @@ void smp_flush_dcache_page_impl(struct page *page, int cpu)
 		}
 	}
 
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
@@ -933,7 +935,7 @@ void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
 	if (tlb_type == hypervisor)
 		return;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 
 #ifdef CONFIG_DEBUG_DCFLUSH
 	atomic_inc(&dcpage_flushes);
@@ -958,7 +960,7 @@ void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
 	}
 	__local_flush_dcache_page(page);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void __irq_entry smp_new_mmu_context_version_client(int irq, struct pt_regs *regs)
@@ -1150,6 +1152,7 @@ void smp_capture(void)
 {
 	int result = atomic_add_ret(1, &smp_capture_depth);
 
+	get_online_cpus_atomic();
 	if (result == 1) {
 		int ncpus = num_online_cpus();
 
@@ -1166,6 +1169,7 @@ void smp_capture(void)
 		printk("done\n");
 #endif
 	}
+	put_online_cpus_atomic();
 }
 
 void smp_release(void)

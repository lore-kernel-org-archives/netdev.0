From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 42/46] sparc: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Mon, 18 Feb 2013 18:14:08 +0530
Message-ID: <20130218124408.26245.83105.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/sparc/kernel/leon_smp.c  |    2 ++
 arch/sparc/kernel/smp_64.c    |    9 +++++----
 arch/sparc/kernel/sun4d_smp.c |    2 ++
 arch/sparc/kernel/sun4m_smp.c |    3 +++
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/kernel/leon_smp.c b/arch/sparc/kernel/leon_smp.c
index 0f3fb6d..441d3ac 100644
--- a/arch/sparc/kernel/leon_smp.c
+++ b/arch/sparc/kernel/leon_smp.c
@@ -420,6 +420,7 @@ static void leon_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 		unsigned long flags;
 
 		spin_lock_irqsave(&cross_call_lock, flags);
+		get_online_cpus_atomic();
 
 		{
 			/* If you make changes here, make sure gcc generates proper code... */
@@ -476,6 +477,7 @@ static void leon_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 			} while (++i <= high);
 		}
 
+		put_online_cpus_atomic();
 		spin_unlock_irqrestore(&cross_call_lock, flags);
 	}
 }
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 537eb66..e1d7300 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -894,7 +894,8 @@ void smp_flush_dcache_page_impl(struct page *page, int cpu)
 	atomic_inc(&dcpage_flushes);
 #endif
 
-	this_cpu = get_cpu();
+	get_online_cpus_atomic();
+	this_cpu = smp_processor_id();
 
 	if (cpu == this_cpu) {
 		__local_flush_dcache_page(page);
@@ -920,7 +921,7 @@ void smp_flush_dcache_page_impl(struct page *page, int cpu)
 		}
 	}
 
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
@@ -931,7 +932,7 @@ void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
 	if (tlb_type == hypervisor)
 		return;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 
 #ifdef CONFIG_DEBUG_DCFLUSH
 	atomic_inc(&dcpage_flushes);
@@ -956,7 +957,7 @@ void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
 	}
 	__local_flush_dcache_page(page);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void __irq_entry smp_new_mmu_context_version_client(int irq, struct pt_regs *regs)
diff --git a/arch/sparc/kernel/sun4d_smp.c b/arch/sparc/kernel/sun4d_smp.c
index ddaea31..1fa7ff2 100644
--- a/arch/sparc/kernel/sun4d_smp.c
+++ b/arch/sparc/kernel/sun4d_smp.c
@@ -300,6 +300,7 @@ static void sun4d_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 		unsigned long flags;
 
 		spin_lock_irqsave(&cross_call_lock, flags);
+		get_online_cpus_atomic();
 
 		{
 			/*
@@ -356,6 +357,7 @@ static void sun4d_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 			} while (++i <= high);
 		}
 
+		put_online_cpus_atomic();
 		spin_unlock_irqrestore(&cross_call_lock, flags);
 	}
 }
diff --git a/arch/sparc/kernel/sun4m_smp.c b/arch/sparc/kernel/sun4m_smp.c
index 128af73..5599548 100644
--- a/arch/sparc/kernel/sun4m_smp.c
+++ b/arch/sparc/kernel/sun4m_smp.c
@@ -192,6 +192,7 @@ static void sun4m_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 		unsigned long flags;
 
 		spin_lock_irqsave(&cross_call_lock, flags);
+		get_online_cpus_atomic();
 
 		/* Init function glue. */
 		ccall_info.func = func;
@@ -238,6 +239,8 @@ static void sun4m_cross_call(smpfunc_t func, cpumask_t mask, unsigned long arg1,
 					barrier();
 			} while (++i < ncpus);
 		}
+
+		put_online_cpus_atomic();
 		spin_unlock_irqrestore(&cross_call_lock, flags);
 }
 

From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 24/45] staging: octeon: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Tue, 22 Jan 2013 13:09:31 +0530
Message-ID: <20130122073928.13822.79334.stgit@srivatsabhat.in.ibm.com>
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

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David Daney <david.daney@cavium.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 drivers/staging/octeon/ethernet-rx.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index 34afc16..8588b4d 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -36,6 +36,7 @@
 #include <linux/prefetch.h>
 #include <linux/ratelimit.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/interrupt.h>
 #include <net/dst.h>
 #ifdef CONFIG_XFRM
@@ -97,6 +98,7 @@ static void cvm_oct_enable_one_cpu(void)
 		return;
 
 	/* ... if a CPU is available, Turn on NAPI polling for that CPU.  */
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (!cpu_test_and_set(cpu, core_state.cpu_state)) {
 			v = smp_call_function_single(cpu, cvm_oct_enable_napi,
@@ -106,6 +108,7 @@ static void cvm_oct_enable_one_cpu(void)
 			break;
 		}
 	}
+	put_online_cpus_atomic();
 }
 
 static void cvm_oct_no_more_work(void)


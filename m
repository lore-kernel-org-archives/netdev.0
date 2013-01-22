From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 17/45] softirq: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 22 Jan 2013 13:07:43 +0530
Message-ID: <20130122073739.13822.99740.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/softirq.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index ed567ba..98c3e27 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -631,6 +631,7 @@ static void remote_softirq_receive(void *data)
 
 static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
 {
+	get_online_cpus_atomic();
 	if (cpu_online(cpu)) {
 		cp->func = remote_softirq_receive;
 		cp->info = cp;
@@ -638,8 +639,10 @@ static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softir
 		cp->priv = softirq;
 
 		__smp_call_function_single(cpu, cp, 0);
+		put_online_cpus_atomic();
 		return 0;
 	}
+	put_online_cpus_atomic();
 	return 1;
 }
 #else /* CONFIG_USE_GENERIC_SMP_HELPERS */

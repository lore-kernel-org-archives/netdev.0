From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 42/45] powerpc: Use get/put_online_cpus_atomic() to avoid
 false-positive warning
Date: Wed, 26 Jun 2013 02:03:39 +0530
Message-ID: <20130625203339.16593.60632.stgit@srivatsabhat.in.ibm.com>
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
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	Zhao Chenhui <chenhui.zhao@freescale.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linuxppc-dev@lists.ozlabs.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bringing a secondary CPU online is a special case in which, accessing
the cpu_online_mask is safe, even though that task (which running on the
CPU coming online) is not the hotplug writer.

It is a little hard to teach this to the debugging checks under
CONFIG_DEBUG_HOTPLUG_CPU. But luckily powerpc is one of the few places
where the CPU coming online traverses the cpu_online_mask before fully
coming online. So wrap that part under get/put_online_cpus_atomic(), to
avoid false-positive warnings from the CPU hotplug debug code.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: Zhao Chenhui <chenhui.zhao@freescale.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/smp.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index 2123bec..59c9a09 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -657,6 +657,7 @@ __cpuinit void start_secondary(void *unused)
 		cpumask_set_cpu(base + i, cpu_core_mask(cpu));
 	}
 	l2_cache = cpu_to_l2cache(cpu);
+	get_online_cpus_atomic();
 	for_each_online_cpu(i) {
 		struct device_node *np = cpu_to_l2cache(i);
 		if (!np)
@@ -667,6 +668,7 @@ __cpuinit void start_secondary(void *unused)
 		}
 		of_node_put(np);
 	}
+	put_online_cpus_atomic();
 	of_node_put(l2_cache);
 
 	local_irq_enable();

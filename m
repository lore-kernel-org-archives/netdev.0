From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 22/45] percpu_counter: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 01:59:43 +0530
Message-ID: <20130625202943.16593.52711.stgit@srivatsabhat.in.ibm.com>
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
	Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>,
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

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 lib/percpu_counter.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index ba6085d..f5e718d 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -98,6 +98,15 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 	s64 ret;
 	int cpu;
 
+	/*
+	 * The calls to get/put_online_cpus_atomic() is strictly not
+	 * necessary, since CPU hotplug is explicitly handled via the
+	 * hotplug callback which synchronizes through fbc->lock.
+	 * But we add them here anyway to make it easier for the debug
+	 * code under CONFIG_DEBUG_HOTPLUG_CPU to validate the correctness
+	 * of hotplug synchronization.
+	 */
+	get_online_cpus_atomic();
 	raw_spin_lock(&fbc->lock);
 	ret = fbc->count;
 	for_each_online_cpu(cpu) {
@@ -105,6 +114,7 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 		ret += *pcount;
 	}
 	raw_spin_unlock(&fbc->lock);
+	put_online_cpus_atomic();
 	return ret;
 }
 EXPORT_SYMBOL(__percpu_counter_sum);

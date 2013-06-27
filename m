From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 23/45] percpu_counter: Use _nocheck version of
 for_each_online_cpu()
Date: Fri, 28 Jun 2013 01:26:41 +0530
Message-ID: <20130627195641.29830.18825.stgit@srivatsabhat.in.ibm.com>
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
	Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The percpu-counter-sum code does a for_each_online_cpu() protected
by a spinlock, which makes it look like it needs to use
get/put_online_cpus_atomic(), going forward. However, the code has
adequate synchronization with CPU hotplug, via a hotplug callback
and the fbc->lock.

So use for_each_online_cpu_nocheck() to avoid false-positive warnings
from the hotplug locking validator. And add a comment justifying the
same.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 lib/percpu_counter.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index ba6085d..2d80e8a 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -98,9 +98,16 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 	s64 ret;
 	int cpu;
 
+	/*
+	 * CPU hotplug synchronization is explicitly handled via the
+	 * hotplug callback, which synchronizes through fbc->lock.
+	 * So it is safe to use the _nocheck() version of
+	 * for_each_online_cpu() here (to avoid false-positive warnings
+	 * from the CPU hotplug debug code).
+	 */
 	raw_spin_lock(&fbc->lock);
 	ret = fbc->count;
-	for_each_online_cpu(cpu) {
+	for_each_online_cpu_nocheck(cpu) {
 		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
 		ret += *pcount;
 	}

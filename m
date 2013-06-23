From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 22/45] percpu_counter: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Sun, 23 Jun 2013 19:12:59 +0530
Message-ID: <20130623134256.19094.99231.stgit@srivatsabhat.in.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 lib/percpu_counter.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index ba6085d..9cf9086 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -98,6 +98,7 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 	s64 ret;
 	int cpu;
 
+	get_online_cpus_atomic();
 	raw_spin_lock(&fbc->lock);
 	ret = fbc->count;
 	for_each_online_cpu(cpu) {
@@ -105,6 +106,7 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 		ret += *pcount;
 	}
 	raw_spin_unlock(&fbc->lock);
+	put_online_cpus_atomic();
 	return ret;
 }
 EXPORT_SYMBOL(__percpu_counter_sum);

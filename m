From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 03/45] Documentation,
 CPU hotplug: Recommend usage of get/put_online_cpus_atomic()
Date: Sun, 23 Jun 2013 19:08:29 +0530
Message-ID: <20130623133824.19094.76756.stgit@srivatsabhat.in.ibm.com>
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
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org
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

So add documentation to recommend using the new get/put_online_cpus_atomic()
APIs to prevent CPUs from going offline, while invoking from atomic context.

Cc: Rob Landley <rob@landley.net>
Cc: linux-doc@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 Documentation/cpu-hotplug.txt |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/Documentation/cpu-hotplug.txt b/Documentation/cpu-hotplug.txt
index 9f40135..7b3ca60 100644
--- a/Documentation/cpu-hotplug.txt
+++ b/Documentation/cpu-hotplug.txt
@@ -113,13 +113,18 @@ Never use anything other than cpumask_t to represent bitmap of CPUs.
 	#include <linux/cpu.h>
 	get_online_cpus() and put_online_cpus():
 
-The above calls are used to inhibit cpu hotplug operations. While the
+The above calls are used to inhibit cpu hotplug operations, when invoked from
+non-atomic contexts (because the above functions can sleep). While the
 cpu_hotplug.refcount is non zero, the cpu_online_mask will not change.
-If you merely need to avoid cpus going away, you could also use
-preempt_disable() and preempt_enable() for those sections.
-Just remember the critical section cannot call any
-function that can sleep or schedule this process away. The preempt_disable()
-will work as long as stop_machine_run() is used to take a cpu down.
+
+However, if you are executing in atomic context (ie., you can't afford to
+sleep), and you merely need to avoid cpus going offline, you can use
+get_online_cpus_atomic() and put_online_cpus_atomic() for those sections.
+Just remember the critical section cannot call any function that can sleep or
+schedule this process away. Using preempt_disable() will also work, as long
+as stop_machine() is used to take a CPU down. But we are going to get rid of
+stop_machine() in the CPU offline path soon, so it is strongly recommended
+to use the APIs mentioned above.
 
 CPU Hotplug - Frequently Asked Questions.
 
@@ -360,6 +365,9 @@ A: There are two ways.  If your code can be run in interrupt context, use
 		return err;
 	}
 
+   If my_func_on_cpu() itself cannot block, use get/put_online_cpus_atomic()
+   instead of get/put_online_cpus(), to prevent CPUs from going offline.
+
 Q: How do we determine how many CPUs are available for hotplug.
 A: There is no clear spec defined way from ACPI that can give us that
    information today. Based on some input from Natalie of Unisys,

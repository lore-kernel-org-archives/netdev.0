From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 1/5] cpu: move cpu notifiers into cpu.h
Date: Wed, 22 Jun 2011 14:35:18 +0800
Message-ID: <1308724522-32461-2-git-send-email-amwang@redhat.com>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Amerigo Wang <amwang@redhat.com>,
	Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Brandon Philips <brandon@ifup.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>, rds-devel@oss.oracle.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not necessary to share the same notifier.h.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 include/linux/cpu.h      |   33 +++++++++++++++++++++++++++++++++
 include/linux/notifier.h |   34 ++--------------------------------
 net/rds/page.c           |    1 +
 3 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 5f09323..b1a635a 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -70,6 +70,39 @@ enum {
 	CPU_PRI_WORKQUEUE	= 5,
 };
 
+#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
+#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
+#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
+#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
+#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
+#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
+#define CPU_DYING		0x0008 /* CPU (unsigned)v not running any task,
+					* not handling interrupts, soon dead.
+					* Called on the dying cpu, interrupts
+					* are already disabled. Must not
+					* sleep, must not fail */
+#define CPU_POST_DEAD		0x0009 /* CPU (unsigned)v dead, cpu_hotplug
+					* lock is dropped */
+#define CPU_STARTING		0x000A /* CPU (unsigned)v soon running.
+					* Called on the new cpu, just before
+					* enabling interrupts. Must not sleep,
+					* must not fail */
+
+/* Used for CPU hotplug events occurring while tasks are frozen due to a suspend
+ * operation in progress
+ */
+#define CPU_TASKS_FROZEN	0x0010
+
+#define CPU_ONLINE_FROZEN	(CPU_ONLINE | CPU_TASKS_FROZEN)
+#define CPU_UP_PREPARE_FROZEN	(CPU_UP_PREPARE | CPU_TASKS_FROZEN)
+#define CPU_UP_CANCELED_FROZEN	(CPU_UP_CANCELED | CPU_TASKS_FROZEN)
+#define CPU_DOWN_PREPARE_FROZEN	(CPU_DOWN_PREPARE | CPU_TASKS_FROZEN)
+#define CPU_DOWN_FAILED_FROZEN	(CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
+#define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
+#define CPU_DYING_FROZEN	(CPU_DYING | CPU_TASKS_FROZEN)
+#define CPU_STARTING_FROZEN	(CPU_STARTING | CPU_TASKS_FROZEN)
+
+
 #ifdef CONFIG_SMP
 /* Need to know about CPUs going up/down? */
 #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE)
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index c0688b0..9eb25fc 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -185,6 +185,8 @@ static inline int notifier_to_errno(int ret)
  *	VC switch chains (for loadable kernel svgalib VC switch helpers) etc...
  */
  
+/* CPU notfiers are defined in include/linux/cpu.h. */
+
 /* netdevice notifier chain. Please remember to update the rtnetlink
  * notification exclusion list in rtnetlink_event() when adding new
  * types.
@@ -220,38 +222,6 @@ static inline int notifier_to_errno(int ret)
 
 #define NETLINK_URELEASE	0x0001	/* Unicast netlink socket released */
 
-#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
-#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
-#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
-#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
-#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
-#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
-#define CPU_DYING		0x0008 /* CPU (unsigned)v not running any task,
-					* not handling interrupts, soon dead.
-					* Called on the dying cpu, interrupts
-					* are already disabled. Must not
-					* sleep, must not fail */
-#define CPU_POST_DEAD		0x0009 /* CPU (unsigned)v dead, cpu_hotplug
-					* lock is dropped */
-#define CPU_STARTING		0x000A /* CPU (unsigned)v soon running.
-					* Called on the new cpu, just before
-					* enabling interrupts. Must not sleep,
-					* must not fail */
-
-/* Used for CPU hotplug events occurring while tasks are frozen due to a suspend
- * operation in progress
- */
-#define CPU_TASKS_FROZEN	0x0010
-
-#define CPU_ONLINE_FROZEN	(CPU_ONLINE | CPU_TASKS_FROZEN)
-#define CPU_UP_PREPARE_FROZEN	(CPU_UP_PREPARE | CPU_TASKS_FROZEN)
-#define CPU_UP_CANCELED_FROZEN	(CPU_UP_CANCELED | CPU_TASKS_FROZEN)
-#define CPU_DOWN_PREPARE_FROZEN	(CPU_DOWN_PREPARE | CPU_TASKS_FROZEN)
-#define CPU_DOWN_FAILED_FROZEN	(CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
-#define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
-#define CPU_DYING_FROZEN	(CPU_DYING | CPU_TASKS_FROZEN)
-#define CPU_STARTING_FROZEN	(CPU_STARTING | CPU_TASKS_FROZEN)
-
 /* Hibernation and suspend events */
 #define PM_HIBERNATION_PREPARE	0x0001 /* Going to hibernate */
 #define PM_POST_HIBERNATION	0x0002 /* Hibernation finished */
diff --git a/net/rds/page.c b/net/rds/page.c
index d8acdeb..b82d63e 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -32,6 +32,7 @@
  */
 #include <linux/highmem.h>
 #include <linux/gfp.h>
+#include <linux/cpu.h>
 
 #include "rds.h"
 
-- 
1.7.4.4

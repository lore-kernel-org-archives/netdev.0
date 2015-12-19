From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v2] RDS: don't pretend to use cpu notifiers
Date: Sat, 19 Dec 2015 12:55:43 -0800
Message-ID: <1450558543-3650-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

It looks like an attempt to use CPU notifier here which was never
completed. Nobody tried to wire it up completely since 2k9. So I unwind
this code and get rid of everything not required. Oh look! 19 lines were
removed while code still does the same thing.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Tested-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---

v2:
Test and Ack tag added.

 net/rds/page.c | 31 ++++++-------------------------
 1 file changed, 6 insertions(+), 25 deletions(-)

diff --git a/net/rds/page.c b/net/rds/page.c
index 9005a2c..5a14e6d 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -179,37 +179,18 @@ out:
 }
 EXPORT_SYMBOL_GPL(rds_page_remainder_alloc);
 
-static int rds_page_remainder_cpu_notify(struct notifier_block *self,
-					 unsigned long action, void *hcpu)
+void rds_page_exit(void)
 {
-	struct rds_page_remainder *rem;
-	long cpu = (long)hcpu;
+	unsigned int cpu;
 
-	rem = &per_cpu(rds_page_remainders, cpu);
+	for_each_possible_cpu(cpu) {
+		struct rds_page_remainder *rem;
 
-	rdsdebug("cpu %ld action 0x%lx\n", cpu, action);
+		rem = &per_cpu(rds_page_remainders, cpu);
+		rdsdebug("cpu %u\n", cpu);
 
-	switch (action) {
-	case CPU_DEAD:
 		if (rem->r_page)
 			__free_page(rem->r_page);
 		rem->r_page = NULL;
-		break;
 	}
-
-	return 0;
-}
-
-static struct notifier_block rds_page_remainder_nb = {
-	.notifier_call = rds_page_remainder_cpu_notify,
-};
-
-void rds_page_exit(void)
-{
-	int i;
-
-	for_each_possible_cpu(i)
-		rds_page_remainder_cpu_notify(&rds_page_remainder_nb,
-					      (unsigned long)CPU_DEAD,
-					      (void *)(long)i);
 }
-- 
1.9.1

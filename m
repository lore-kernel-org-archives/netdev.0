From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: rds: don't pretend to use cpu notifiers
Date: Fri, 27 Nov 2015 17:00:26 +0100
Message-ID: <1448640026-31438-1-git-send-email-bigeasy@linutronix.de>
Cc: Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44612 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763AbbK0QA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 11:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like an attempt to use CPU notifier here which was never
completed. Nobody tried to wire it up completely since 2k9. So I unwind
this code and get rid of everything not required. Oh look! 19 lines were
removed while code still does the same thing.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/rds/page.c | 31 ++++++-------------------------
 1 file changed, 6 insertions(+), 25 deletions(-)

diff --git a/net/rds/page.c b/net/rds/page.c
index 9005a2c920ee..5a14e6d6a926 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -179,37 +179,18 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
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
2.6.2

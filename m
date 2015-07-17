From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Allow other tasks to be scheduled in large lookup loops
Date: Fri, 17 Jul 2015 10:07:46 +0200
Message-ID: <2dcec22264c46d248e4f56ac5dfd6a8d321b162f.1437120351.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, mroos@linux.ee, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47817 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbbGQIHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on system speed, the large lookup loop can take a considerable
amount of time to complete causing watchdog warnings to appear. Allow
other tasks to be scheduled after every batch of 1000 lookups.

Reported-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index c90777e..5ed6211 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -20,8 +20,10 @@
 #include <linux/rcupdate.h>
 #include <linux/rhashtable.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 
 #define MAX_ENTRIES	1000000
+#define RELAX_CPU_AFTER	1000
 #define TEST_INSERT_FAIL INT_MAX
 
 static int entries = 50000;
@@ -61,7 +63,7 @@ static struct rhashtable_params test_rht_params = {
 
 static int __init test_rht_lookup(struct rhashtable *ht)
 {
-	unsigned int i;
+	unsigned int i, relax_cnt = RELAX_CPU_AFTER;
 
 	for (i = 0; i < entries * 2; i++) {
 		struct test_obj *obj;
@@ -87,6 +89,11 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 				return -EINVAL;
 			}
 		}
+
+		if (!relax_cnt--) {
+			schedule();
+			relax_cnt = RELAX_CPU_AFTER;
+		}
 	}
 
 	return 0;
-- 
2.4.3

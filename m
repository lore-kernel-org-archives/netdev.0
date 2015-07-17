From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] rhashtable: Allow other tasks to be scheduled in large lookup loops
Date: Fri, 17 Jul 2015 10:52:48 +0200
Message-ID: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, mroos@linux.ee,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48008 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946187AbbGQIwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:52:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on system speed, the large lookup/insert/delete loops of the testsuite can
take a considerable amount of time to complete causing watchdog warnings to appear.
Allow other tasks to be scheduled throughout the loops.

Reported-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: Use cond_resched() instead schedule()

 lib/test_rhashtable.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index c90777e..9af7cef 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -20,6 +20,7 @@
 #include <linux/rcupdate.h>
 #include <linux/rhashtable.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 
 #define MAX_ENTRIES	1000000
 #define TEST_INSERT_FAIL INT_MAX
@@ -87,6 +88,8 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 				return -EINVAL;
 			}
 		}
+
+		cond_resched_rcu();
 	}
 
 	return 0;
@@ -160,6 +163,8 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 		} else if (err) {
 			return err;
 		}
+
+		cond_resched();
 	}
 
 	if (insert_fails)
@@ -183,6 +188,8 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 
 			rhashtable_remove_fast(ht, &obj->node, test_rht_params);
 		}
+
+		cond_resched();
 	}
 
 	end = ktime_get_ns();
-- 
2.4.3

From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 4/4] rhashtable-test: allow to retry even if -ENOMEM was returned
Date: Fri, 20 Nov 2015 18:17:20 +0100
Message-ID: <1448039840-11367-5-git-send-email-phil@nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53540 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760457AbbKTRRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 12:17:23 -0500
In-Reply-To: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is rather a hack to expose the current issue with rhashtable to
under high pressure sometimes return -ENOMEM even though system memory
is not exhausted and a consecutive insert may succeed.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 6fa77b3..270bf72 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -52,6 +52,10 @@ static int tcount = 10;
 module_param(tcount, int, 0);
 MODULE_PARM_DESC(tcount, "Number of threads to spawn (default: 10)");
 
+static bool enomem_retry = false;
+module_param(enomem_retry, bool, 0);
+MODULE_PARM_DESC(enomem_retry, "Retry insert even if -ENOMEM was returned (default: off)");
+
 struct test_obj {
 	int			value;
 	struct rhash_head	node;
@@ -79,14 +83,22 @@ static struct semaphore startup_sem = __SEMAPHORE_INITIALIZER(startup_sem, 0);
 static int insert_retry(struct rhashtable *ht, struct rhash_head *obj,
                         const struct rhashtable_params params)
 {
-	int err, retries = -1;
+	int err, retries = -1, enomem_retries = 0;
 
 	do {
 		retries++;
 		cond_resched();
 		err = rhashtable_insert_fast(ht, obj, params);
+		if (err == -ENOMEM && enomem_retry) {
+			enomem_retries++;
+			err = -EBUSY;
+		}
 	} while (err == -EBUSY);
 
+	if (enomem_retries)
+		pr_info(" %u insertions retried after -ENOMEM\n",
+			enomem_retries);
+
 	return err ? : retries;
 }
 
-- 
2.1.2

From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Fri, 28 Aug 2015 12:28:04 +0200
Message-ID: <1440757685-14241-2-git-send-email-phil@nwl.cc>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After adding cond_resched() calls to threadfunc(), a surprisingly high
rate of insert failures occurred probably due to table resizes getting a
better chance to run in background. To not soften up the remaining
tests, retry inserts until they either succeed or fail permanently.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 63654e3..093cf84 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -244,7 +244,7 @@ static int thread_lookup_test(struct thread_data *tdata)
 
 static int threadfunc(void *data)
 {
-	int i, step, err = 0, insert_fails = 0;
+	int i, step, err = 0, retries = 0;
 	struct thread_data *tdata = data;
 
 	up(&prestart_sem);
@@ -253,21 +253,22 @@ static int threadfunc(void *data)
 
 	for (i = 0; i < entries; i++) {
 		tdata->objs[i].value = (tdata->id << 16) | i;
+insert_retry:
 		cond_resched();
 		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
 		                             test_rht_params);
 		if (err == -ENOMEM || err == -EBUSY) {
-			tdata->objs[i].value = TEST_INSERT_FAIL;
-			insert_fails++;
+			retries++;
+			goto insert_retry;
 		} else if (err) {
 			pr_err("  thread[%d]: rhashtable_insert_fast failed\n",
 			       tdata->id);
 			goto out;
 		}
 	}
-	if (insert_fails)
-		pr_info("  thread[%d]: %d insert failures\n",
-		        tdata->id, insert_fails);
+	if (retries)
+		pr_info("  thread[%d]: retried insert operation %d times\n",
+		        tdata->id, retries);
 
 	err = thread_lookup_test(tdata);
 	if (err) {
-- 
2.1.2

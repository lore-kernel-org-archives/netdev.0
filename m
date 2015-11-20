From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 3/4] rhashtable-test: calculate max_entries value by default
Date: Fri, 20 Nov 2015 18:17:19 +0100
Message-ID: <1448039840-11367-4-git-send-email-phil@nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A maximum table size of 64k entries is insufficient for the multiple
threads test even in default configuration (10 threads * 50000 objects =
500000 objects in total). Since we know how many objects will be
inserted, calculate the max size unless overridden by parameter.

Note that specifying the exact number of objects upon table init won't
suffice as that value is being rounded down to the next power of two -
anticipate this by rounding up to the next power of two in beforehand.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index cfc3440..6fa77b3 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -36,9 +36,9 @@ static int runs = 4;
 module_param(runs, int, 0);
 MODULE_PARM_DESC(runs, "Number of test runs per variant (default: 4)");
 
-static int max_size = 65536;
+static int max_size = 0;
 module_param(max_size, int, 0);
-MODULE_PARM_DESC(runs, "Maximum table size (default: 65536)");
+MODULE_PARM_DESC(runs, "Maximum table size (default: calculated)");
 
 static bool shrinking = false;
 module_param(shrinking, bool, 0);
@@ -321,7 +321,7 @@ static int __init test_rht_init(void)
 	entries = min(entries, MAX_ENTRIES);
 
 	test_rht_params.automatic_shrinking = shrinking;
-	test_rht_params.max_size = max_size;
+	test_rht_params.max_size = max_size ? : roundup_pow_of_two(entries);
 	test_rht_params.nelem_hint = size;
 
 	pr_info("Running rhashtable test nelem=%d, max_size=%d, shrinking=%d\n",
@@ -367,6 +367,8 @@ static int __init test_rht_init(void)
 		return -ENOMEM;
 	}
 
+	test_rht_params.max_size = max_size ? :
+	                           roundup_pow_of_two(tcount * entries);
 	err = rhashtable_init(&ht, &test_rht_params);
 	if (err < 0) {
 		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
-- 
2.1.2

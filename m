From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 3/3] rhashtable-test: calculate max_entries value by default
Date: Fri, 28 Aug 2015 12:28:05 +0200
Message-ID: <1440757685-14241-3-git-send-email-phil@nwl.cc>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57689 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbbH1K2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 06:28:08 -0400
In-Reply-To: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 093cf84..73fcb8e 100644
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
@@ -317,7 +317,7 @@ static int __init test_rht_init(void)
 	entries = min(entries, MAX_ENTRIES);
 
 	test_rht_params.automatic_shrinking = shrinking;
-	test_rht_params.max_size = max_size;
+	test_rht_params.max_size = max_size ? : roundup_pow_of_two(entries);
 	test_rht_params.nelem_hint = size;
 
 	pr_info("Running rhashtable test nelem=%d, max_size=%d, shrinking=%d\n",
@@ -363,6 +363,8 @@ static int __init test_rht_init(void)
 		return -ENOMEM;
 	}
 
+	test_rht_params.max_size = max_size ? :
+	                           roundup_pow_of_two(tcount * entries);
 	err = rhashtable_init(&ht, &test_rht_params);
 	if (err < 0) {
 		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
-- 
2.1.2

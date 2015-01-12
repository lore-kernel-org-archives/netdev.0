From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Lower/upper bucket may map to same lock
 while shrinking
Date: Mon, 12 Jan 2015 23:58:21 +0000
Message-ID: <20150112235821.GB16617@casper.infradead.org>
References: <20150112232217.GA5277@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: davem@davemloft.net, Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48394 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbbALX6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:58:24 -0500
Content-Disposition: inline
In-Reply-To: <20150112232217.GA5277@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each per bucket lock covers a configurable number of buckets. While
shrinking, two buckets in the old table contain entries for a single
bucket in the new table. We need to lock down both while linking.
Check if they are protected by different locks to avoid a recursive
lock.

Fixes: 97defe1e ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 8023b55..45477f7 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -443,8 +443,16 @@ int rhashtable_shrink(struct rhashtable *ht)
 		new_bucket_lock = bucket_lock(new_tbl, new_hash);
 
 		spin_lock_bh(old_bucket_lock1);
-		spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
-		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
+
+		/* Depending on the lock per buckets mapping, the bucket in
+		 * the lower and upper region may map to the same lock.
+		 */
+		if (old_bucket_lock1 != old_bucket_lock2) {
+			spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
+			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
+		} else {
+			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+		}
 
 		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
 				   tbl->buckets[new_hash]);
@@ -452,7 +460,8 @@ int rhashtable_shrink(struct rhashtable *ht)
 				   tbl->buckets[new_hash + new_tbl->size]);
 
 		spin_unlock_bh(new_bucket_lock);
-		spin_unlock_bh(old_bucket_lock2);
+		if (old_bucket_lock1 != old_bucket_lock2)
+			spin_unlock_bh(old_bucket_lock2);
 		spin_unlock_bh(old_bucket_lock1);
 	}
 
-- 
1.9.3

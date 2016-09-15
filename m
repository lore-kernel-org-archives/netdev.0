From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/7] rhashtable: Call library function alloc_bucket_locks
Date: Thu, 15 Sep 2016 14:19:17 -0700
Message-ID: <1473974361-2275254-4-git-send-email-tom@herbertland.com>
References: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <roopa@cumulusnetworks.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34080 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755491AbcIOVTi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 17:19:38 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FLJXdD008085
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g2yag75p-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:36 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 19435ca47b8a11e69ce024be0593f280-f75f9a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 14:19:34 -0700
In-Reply-To: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allocate the array of bucket locks for the hash table we now
call library function alloc_bucket_spinlocks. This function is
based on the old alloc_bucket_locks in rhashtable and should
produce the same effect.

Acked-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 lib/rhashtable.c | 46 ++++------------------------------------------
 1 file changed, 4 insertions(+), 42 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 06c2872..5b53304 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -59,50 +59,10 @@ EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #define ASSERT_RHT_MUTEX(HT)
 #endif
 
-
-static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
-			      gfp_t gfp)
-{
-	unsigned int i, size;
-#if defined(CONFIG_PROVE_LOCKING)
-	unsigned int nr_pcpus = 2;
-#else
-	unsigned int nr_pcpus = num_possible_cpus();
-#endif
-
-	nr_pcpus = min_t(unsigned int, nr_pcpus, 64UL);
-	size = roundup_pow_of_two(nr_pcpus * ht->p.locks_mul);
-
-	/* Never allocate more than 0.5 locks per bucket */
-	size = min_t(unsigned int, size, tbl->size >> 1);
-
-	if (sizeof(spinlock_t) != 0) {
-		tbl->locks = NULL;
-#ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
-		    gfp == GFP_KERNEL)
-			tbl->locks = vmalloc(size * sizeof(spinlock_t));
-#endif
-		if (gfp != GFP_KERNEL)
-			gfp |= __GFP_NOWARN | __GFP_NORETRY;
-
-		if (!tbl->locks)
-			tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
-						   gfp);
-		if (!tbl->locks)
-			return -ENOMEM;
-		for (i = 0; i < size; i++)
-			spin_lock_init(&tbl->locks[i]);
-	}
-	tbl->locks_mask = size - 1;
-
-	return 0;
-}
-
 static void bucket_table_free(const struct bucket_table *tbl)
 {
 	if (tbl)
-		kvfree(tbl->locks);
+		free_bucket_spinlocks(tbl->locks);
 
 	kvfree(tbl);
 }
@@ -131,7 +91,9 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 
 	tbl->size = nbuckets;
 
-	if (alloc_bucket_locks(ht, tbl, gfp) < 0) {
+	/* Never allocate more than 0.5 locks per bucket */
+	if (alloc_bucket_spinlocks(&tbl->locks, &tbl->locks_mask,
+				   tbl->size >> 1, ht->p.locks_mul, gfp)) {
 		bucket_table_free(tbl);
 		return NULL;
 	}
-- 
2.8.0.rc2

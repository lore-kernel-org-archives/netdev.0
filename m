From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix/cleanup inet_ehash_locks_alloc()
Date: Tue, 26 May 2015 07:55:34 -0700
Message-ID: <1432652134.4060.244.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36820 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536AbbEZOzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:55:36 -0400
Received: by paza2 with SMTP id a2so85433991paz.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 07:55:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If tcp ehash table is constrained to a very small number of buckets
(eg boot parameter thash_entries=128), then we can crash if spinlock
array has more entries.

While we are at it, un-inline inet_ehash_locks_alloc() and make
following changes :

- Budget 2 cache lines per cpu worth of 'spinlocks'
- Try to kmalloc() the array to avoid extra TLB pressure.
  (Most servers at Google allocate 8192 bytes for this hash table)
- Get rid of various #ifdef

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h |   47 ++------------------------------
 net/ipv4/inet_hashtables.c    |   31 +++++++++++++++++++++
 2 files changed, 34 insertions(+), 44 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 774d24151d4a..b73c88a19dd4 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -24,7 +24,6 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/wait.h>
-#include <linux/vmalloc.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_sock.h>
@@ -164,52 +163,12 @@ static inline spinlock_t *inet_ehash_lockp(
 	return &hashinfo->ehash_locks[hash & hashinfo->ehash_locks_mask];
 }
 
-static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
-{
-	unsigned int i, size = 256;
-#if defined(CONFIG_PROVE_LOCKING)
-	unsigned int nr_pcpus = 2;
-#else
-	unsigned int nr_pcpus = num_possible_cpus();
-#endif
-	if (nr_pcpus >= 4)
-		size = 512;
-	if (nr_pcpus >= 8)
-		size = 1024;
-	if (nr_pcpus >= 16)
-		size = 2048;
-	if (nr_pcpus >= 32)
-		size = 4096;
-	if (sizeof(spinlock_t) != 0) {
-#ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE)
-			hashinfo->ehash_locks = vmalloc(size * sizeof(spinlock_t));
-		else
-#endif
-		hashinfo->ehash_locks =	kmalloc(size * sizeof(spinlock_t),
-						GFP_KERNEL);
-		if (!hashinfo->ehash_locks)
-			return ENOMEM;
-		for (i = 0; i < size; i++)
-			spin_lock_init(&hashinfo->ehash_locks[i]);
-	}
-	hashinfo->ehash_locks_mask = size - 1;
-	return 0;
-}
+int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo);
 
 static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 {
-	if (hashinfo->ehash_locks) {
-#ifdef CONFIG_NUMA
-		unsigned int size = (hashinfo->ehash_locks_mask + 1) *
-							sizeof(spinlock_t);
-		if (size > PAGE_SIZE)
-			vfree(hashinfo->ehash_locks);
-		else
-#endif
-		kfree(hashinfo->ehash_locks);
-		hashinfo->ehash_locks = NULL;
-	}
+	kvfree(hashinfo->ehash_locks);
+	hashinfo->ehash_locks = NULL;
 }
 
 struct inet_bind_bucket *
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 3766bddb3e8a..185efef0f125 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/wait.h>
+#include <linux/vmalloc.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
@@ -609,3 +610,33 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
 		}
 }
 EXPORT_SYMBOL_GPL(inet_hashinfo_init);
+
+int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
+{
+	unsigned int i, nblocks = 1;
+
+	if (sizeof(spinlock_t) != 0) {
+		/* allocate 2 cache lines or at least one spinlock per cpu */
+		nblocks = max_t(unsigned int,
+				2 * L1_CACHE_BYTES / sizeof(spinlock_t),
+				1);
+		nblocks = roundup_pow_of_two(nblocks * num_possible_cpus());
+
+		/* no more locks than number of hash buckets */
+		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
+
+		hashinfo->ehash_locks =	kmalloc_array(nblocks, sizeof(spinlock_t),
+						      GFP_KERNEL | __GFP_NOWARN);
+		if (!hashinfo->ehash_locks)
+			hashinfo->ehash_locks = vmalloc(nblocks * sizeof(spinlock_t));
+
+		if (!hashinfo->ehash_locks)
+			return -ENOMEM;
+
+		for (i = 0; i < nblocks; i++)
+			spin_lock_init(&hashinfo->ehash_locks[i]);
+	}
+	hashinfo->ehash_locks_mask = nblocks - 1;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet_ehash_locks_alloc);

From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] rhashtable: avoid large lock-array allocations
Date: Fri, 12 Aug 2016 12:03:52 +0200
Message-ID: <1470996232-16558-1-git-send-email-fw@strlen.de>
Cc: tgraf@suug.ch, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58268 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504AbcHLKDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 06:03:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sander reports following splat after netfilter nat bysrc table got
converted to rhashtable:

swapper/0: page allocation failure: order:3, mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
 CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.8.0-rc1 [..]
 [<ffffffff811633ed>] warn_alloc_failed+0xdd/0x140
 [<ffffffff811638b1>] __alloc_pages_nodemask+0x3e1/0xcf0
 [<ffffffff811a72ed>] alloc_pages_current+0x8d/0x110
 [<ffffffff8117cb7f>] kmalloc_order+0x1f/0x70
 [<ffffffff811aec19>] __kmalloc+0x129/0x140
 [<ffffffff8146d561>] bucket_table_alloc+0xc1/0x1d0
 [<ffffffff8146da1d>] rhashtable_insert_rehash+0x5d/0xe0
 [<ffffffff819fcfff>] nf_nat_setup_info+0x2ef/0x400

The failure happens when allocating the spinlock array.
Even with GFP_KERNEL its unlikely for such a large allocation
to succeed.

Thomas Graf pointed me at inet_ehash_locks_alloc(), so in addition
to adding NOWARN for atomic allocations this also makes the bucket-array
sizing more conservative.

In commit 095dc8e0c3686 ("tcp: fix/cleanup inet_ehash_locks_alloc()"),
Eric Dumazet says: "Budget 2 cache lines per cpu worth of 'spinlocks'".
IOW, consider size needed by a single spinlock when determining
number of locks per cpu.  So with 64 byte per cacheline and 4 byte per
spinlock this gives 32 locks per cpu.

Resulting size of the lock-array (sizeof(spinlock) == 4):

cpus:    1   2   4   8   16   32   64
old:    1k  1k  4k  8k  16k  16k  16k
new:   128 256 512  1k   2k   4k   8k

8k allocation should have decent chance of success even
with GFP_ATOMIC, and should not fail with GFP_KERNEL.

With 72-byte spinlock (LOCKDEP):
cpus :   1   2
old:    9k 18k
new:   ~2k ~4k

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Suggested-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 lib/rhashtable.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5d845ff..42acd81 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -30,7 +30,7 @@
 
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4U
-#define BUCKET_LOCKS_PER_CPU   128UL
+#define BUCKET_LOCKS_PER_CPU	32UL
 
 static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
@@ -70,7 +70,7 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	unsigned int nr_pcpus = num_possible_cpus();
 #endif
 
-	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
+	nr_pcpus = min_t(unsigned int, nr_pcpus, 64UL);
 	size = roundup_pow_of_two(nr_pcpus * ht->p.locks_mul);
 
 	/* Never allocate more than 0.5 locks per bucket */
@@ -83,6 +83,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 			tbl->locks = vmalloc(size * sizeof(spinlock_t));
 		else
 #endif
+		if (gfp != GFP_KERNEL)
+			gfp |= __GFP_NOWARN | __GFP_NORETRY;
+
 		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
 					   gfp);
 		if (!tbl->locks)
-- 
2.7.3

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: suppress a division by zero warning
Date: Wed, 22 Jul 2015 07:02:00 +0200
Message-ID: <1437541320.16824.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38549 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbGVFCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:02:03 -0400
Received: by wibxm9 with SMTP id xm9so83739322wib.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 22:02:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrew Morton reported following warning on one ARM build
with gcc-4.4 :

net/ipv4/inet_hashtables.c: In function 'inet_ehash_locks_alloc':
net/ipv4/inet_hashtables.c:617: warning: division by zero

Even guarded with a test on sizeof(spinlock_t), compiler does not
like current construct on a !CONFIG_SMP build.

Remove the warning by using a temporary variable.

Fixes: 095dc8e0c368 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_hashtables.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 5f9b063bbe8a..0cb9165421d4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -624,22 +624,21 @@ EXPORT_SYMBOL_GPL(inet_hashinfo_init);
 
 int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 {
+	unsigned int locksz = sizeof(spinlock_t);
 	unsigned int i, nblocks = 1;
 
-	if (sizeof(spinlock_t) != 0) {
+	if (locksz != 0) {
 		/* allocate 2 cache lines or at least one spinlock per cpu */
-		nblocks = max_t(unsigned int,
-				2 * L1_CACHE_BYTES / sizeof(spinlock_t),
-				1);
+		nblocks = max(2U * L1_CACHE_BYTES / locksz, 1U);
 		nblocks = roundup_pow_of_two(nblocks * num_possible_cpus());
 
 		/* no more locks than number of hash buckets */
 		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
 
-		hashinfo->ehash_locks =	kmalloc_array(nblocks, sizeof(spinlock_t),
+		hashinfo->ehash_locks =	kmalloc_array(nblocks, locksz,
 						      GFP_KERNEL | __GFP_NOWARN);
 		if (!hashinfo->ehash_locks)
-			hashinfo->ehash_locks = vmalloc(nblocks * sizeof(spinlock_t));
+			hashinfo->ehash_locks = vmalloc(nblocks * locksz);
 
 		if (!hashinfo->ehash_locks)
 			return -ENOMEM;

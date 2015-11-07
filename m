From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sun,  8 Nov 2015 00:50:39 +0900
Message-ID: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Cc: netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:35639 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbKGPvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 10:51:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 095dc8e0c3686d58 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
silently changed from kmalloc() to kmalloc_array(). The latter has
overflow check whereas the former doesn't have.

If nblocks * locksz might overflow, we need to do like

  -  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
  +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
       hashinfo->ehash_locks = vmalloc(nblocks * locksz);

because kmalloc_array() detects overflow and returns NULL.
But if nblocks * locksz is guaranteed not to overflow, there is
no need to use kmalloc_array().

Since I assume it won't overflow, use kmalloc() than kmalloc_array().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/ipv4/inet_hashtables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980..8f4ab27 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -648,8 +648,8 @@ int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 		/* no more locks than number of hash buckets */
 		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
 
-		hashinfo->ehash_locks =	kmalloc_array(nblocks, locksz,
-						      GFP_KERNEL | __GFP_NOWARN);
+		hashinfo->ehash_locks =	kmalloc(nblocks * locksz,
+						GFP_KERNEL | __GFP_NOWARN);
 		if (!hashinfo->ehash_locks)
 			hashinfo->ehash_locks = vmalloc(nblocks * locksz);
 
-- 
1.8.3.1

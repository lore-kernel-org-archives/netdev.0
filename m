From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] rhashtable: fix for resize events during table walk
Date: Mon,  6 Jul 2015 14:01:42 +0200
Message-ID: <1436184102-19175-1-git-send-email-phil@nwl.cc>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, daniel@iogearbox.net,
	geert@linux-m68k.org, mroos@linux.ee
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51023 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715AbbGFMBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 08:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If rhashtable_walk_next detects a resize operation in progress, it jumps
to the new table and continues walking that one. But it misses to drop
the reference to it's current item, leading it to continue traversing
the new table's bucket in which the current item is sorted into, and
after reaching that bucket's end continues traversing the new table's
second bucket instead of the first one, thereby potentially missing
items.

This fixes the rhashtable runtime test for me. Bug probably introduced
by Herbert Xu's patch eddee5ba ("rhashtable: Fix walker behaviour during
rehash") although not explicitly tested.

Fixes: eddee5ba ("rhashtable: Fix walker behaviour during rehash")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/rhashtable.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a60a6d3..e36b94b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -585,6 +585,7 @@ void *rhashtable_walk_next(struct rhashtable_iter *iter)
 	struct bucket_table *tbl = iter->walker->tbl;
 	struct rhashtable *ht = iter->ht;
 	struct rhash_head *p = iter->p;
+	void *rc = NULL;
 
 	if (p) {
 		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
@@ -617,12 +618,12 @@ next:
 	if (iter->walker->tbl) {
 		iter->slot = 0;
 		iter->skip = 0;
-		return ERR_PTR(-EAGAIN);
+		rc = ERR_PTR(-EAGAIN);
 	}
 
 	iter->p = NULL;
 
-	return NULL;
+	return rc;
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_next);
 
-- 
2.1.2

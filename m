From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net 2/2] rhashtable: Do not schedule more than one rehash if we can't grow further
Date: Wed, 22 Apr 2015 09:41:46 +0200
Message-ID: <51bb8e331b30d9a418a577008996bc0c61c9e69d.1429688383.git.tgraf@suug.ch>
References: <cover.1429688383.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51885 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934199AbbDVHlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:41:50 -0400
In-Reply-To: <cover.1429688383.git.tgraf@suug.ch>
In-Reply-To: <cover.1429688383.git.tgraf@suug.ch>
References: <cover.1429688383.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code currently only stops inserting rehashes into the
chain when no resizes are currently scheduled. As long as resizes
are scheduled and while inserting above the utilization watermark,
more and more rehashes will be scheduled.

This lead to a perfect DoS storm with thousands of rehashes
scheduled which lead to thousands of spinlocks to be taken
sequentially.

Instead, only allow either a series of resizes or a single rehash.
Drop any further rehashes and return -EBUSY.

Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
---
 lib/rhashtable.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f648cfd..b28df40 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -405,8 +405,8 @@ int rhashtable_insert_rehash(struct rhashtable *ht)
 
 	if (rht_grow_above_75(ht, tbl))
 		size *= 2;
-	/* More than two rehashes (not resizes) detected. */
-	else if (WARN_ON(old_tbl != tbl && old_tbl->size == size))
+	/* Do not schedule more than one rehash */
+	else if (old_tbl != tbl)
 		return -EBUSY;
 
 	new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC);
-- 
2.3.5

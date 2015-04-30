From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Thu, 30 Apr 2015 22:46:45 +0000
Message-ID: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
References: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35630 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbbD3WrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:47:05 -0400
Received: by pdbqd1 with SMTP id qd1so74462166pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:47:04 -0700 (PDT)
In-Reply-To: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grow the table quicker than 2x in the beginning to avoid long chains
of rehashes. The effect is observable in the self-test where table
jumps are reduced to a minimum after a lot of entries have been added
in a short period of time. The iterator is able to get a consistent
view most of the time.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4936fc4..23e7f18 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -271,6 +271,38 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
 	return rht_dereference(new_tbl->future_tbl, ht) ? -EAGAIN : 0;
 }
 
+static int table_growth_log(unsigned int size)
+{
+	/*
+	 * Table growth:
+	 *     2 ->   64
+	 *     4 ->  128
+	 *     8 ->  128
+	 *    16 ->  256
+	 *    32 ->  512
+	 *    64 ->  512
+	 *   128 -> 1024
+	 *   256 -> 2048
+	 *   512 -> 2048
+	 *  1024 -> 4096
+	 *  2048 -> 8192
+	 *  4096 -> 8192
+	 */
+	int log = 5 - (ilog2(size) / 3);
+
+	return log > 1 ? log : 1;
+}
+
+static unsigned int grow_table(struct rhashtable *ht, unsigned int old_size)
+{
+	unsigned int new_size;
+
+	new_size = old_size << table_growth_log(old_size);
+	new_size = min(new_size, ht->p.max_size);
+
+	return new_size;
+}
+
 /**
  * rhashtable_expand - Expand hash table while allowing concurrent lookups
  * @ht:		the hash table to expand
@@ -295,7 +327,8 @@ static int rhashtable_expand(struct rhashtable *ht)
 
 	old_tbl = rhashtable_last_table(ht, old_tbl);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, GFP_KERNEL);
+	new_tbl = bucket_table_alloc(ht, grow_table(ht, old_tbl->size),
+				     GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -404,7 +437,7 @@ int rhashtable_insert_rehash(struct rhashtable *ht)
 	size = tbl->size;
 
 	if (rht_grow_above_75(ht, tbl))
-		size *= 2;
+		size = grow_table(ht, size);
 	/* Do not schedule more than one rehash */
 	else if (old_tbl != tbl)
 		return -EBUSY;
-- 
1.9.3

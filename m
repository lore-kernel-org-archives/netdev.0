From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Fix race between rehashing and readers
Date: Thu, 12 Mar 2015 16:33:48 +0000
Message-ID: <20150312163348.GD5378@casper.infradead.org>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51122 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128AbbCLQdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:33:49 -0400
Content-Disposition: inline
In-Reply-To: <20150312133749.GB21620@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rehashing can occur in parallel to readers. Readers are aware of this
situation so new readers are allowed while the rehashing is in
process. Existing readers may have already fetched the tbl and
future_tbl and may thus assume no rehashing is in progress. The
rehashing must thus wait for all existing readers to complete after
publihsing the future_tbl to make sure all parallel readers see the
table before we start moving entries.

Fixes: aa34a6cb0478 ("rhashtable: Add arbitrary rehash function")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
Herbert: This is what I think is needed to fix this properly.

 lib/rhashtable.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d7f3db5..624cf59 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -275,10 +275,12 @@ static void rhashtable_rehash(struct rhashtable *ht,
 
 	/* Make insertions go into the new, empty table right away. Deletions
 	 * and lookups will be attempted in both tables until we synchronize.
-	 * The synchronize_rcu() guarantees for the new table to be picked up
-	 * so no new additions go into the old table while we relink.
+	 * The synchronize_rcu() guarantees that readers have either completed
+	 * or are aware of both the new and old table before we start moving
+	 * entries to the new table.
 	 */
 	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	synchronize_rcu();
 
 	for (old_hash = 0; old_hash < old_tbl->size; old_hash++)
 		rhashtable_rehash_chain(ht, old_hash);
-- 
1.9.3

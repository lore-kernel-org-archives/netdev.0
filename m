From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net 1/2] rhashtable: Schedule async resize when sync realloc fails
Date: Wed, 22 Apr 2015 09:41:45 +0200
Message-ID: <b5b3fa09e48a245bcbe9d9b38d271619f4c2fd80.1429688383.git.tgraf@suug.ch>
References: <cover.1429688383.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51881 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbDVHlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:41:49 -0400
In-Reply-To: <cover.1429688383.git.tgraf@suug.ch>
In-Reply-To: <cover.1429688383.git.tgraf@suug.ch>
References: <cover.1429688383.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rhashtable_insert_rehash() fails with ENOMEM, this indicates that
we can't allocate the necessary memory in the current context but the
limits as set by the user would still allow to grow.

Thus attempt an async resize in the background where we can allocate
using GFP_KERNEL which is more likely to succeed. The insertion itself
will still fail to indicate pressure.

This fixes a bug where the table would never continue growing once the
utilization is above 100%.

Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4898442..f648cfd 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -410,8 +410,13 @@ int rhashtable_insert_rehash(struct rhashtable *ht)
 		return -EBUSY;
 
 	new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC);
-	if (new_tbl == NULL)
+	if (new_tbl == NULL) {
+		/* Schedule async resize/rehash to try allocation
+		 * non-atomic context.
+		 */
+		schedule_work(&ht->run_work);
 		return -ENOMEM;
+	}
 
 	err = rhashtable_rehash_attach(ht, tbl, new_tbl);
 	if (err) {
-- 
2.3.5

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Fix reader/rehash race
Date: Thu, 12 Mar 2015 22:07:49 +1100
Message-ID: <20150312110749.GA19285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43481 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbCLLHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 07:07:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a potential race condition between readers and the rehasher.
In particular, the rehasher could have started a rehash while the
reader finishes a scan of the old table but fails to see the new
table pointer.

This patch closes this window by adding smp_wmb/smp_rmb.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 6ffc793..68210cc 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -271,6 +271,9 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	 */
 	rcu_assign_pointer(ht->future_tbl, new_tbl);
 
+	/* Ensure the new table is visible to readers. */
+	smp_wmb();
+
 	for (old_hash = 0; old_hash < old_tbl->size; old_hash++)
 		rhashtable_rehash_chain(ht, old_hash);
 
@@ -618,6 +621,9 @@ restart:
 		return rht_obj(ht, he);
 	}
 
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
 	old_tbl = tbl;
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	if (unlikely(tbl != old_tbl))
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

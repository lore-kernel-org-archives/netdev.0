From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Remove unnecessary wmb for future_tbl
Date: Tue, 8 Dec 2015 17:09:04 +0800
Message-ID: <20151208090904.GA17605@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45802 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098AbbLHJJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 04:09:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 9497df88ab5567daa001829051c5f87161a81ff0 ("rhashtable:
Fix reader/rehash race") added a pair of barriers.  In fact the
wmb is superfluous because every subsequent write to the old or
new hash table uses rcu_assign_pointer, which itself carriers a
full barrier prior to the assignment.

Therefore we may remove the explicit wmb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 1c624db..d1f94b4 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -232,9 +232,6 @@ static int rhashtable_rehash_attach(struct rhashtable *ht,
 	 */
 	rcu_assign_pointer(old_tbl->future_tbl, new_tbl);
 
-	/* Ensure the new table is visible to readers. */
-	smp_wmb();
-
 	spin_unlock_bh(old_tbl->locks);
 
 	return 0;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

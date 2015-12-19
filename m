From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH v2] rhashtable: Kill harmless RCU warning in
 rhashtable_walk_init
Date: Sat, 19 Dec 2015 10:45:28 +0800
Message-ID: <20151219024528.GA27814@gondor.apana.org.au>
References: <20151218062450.GA19749@gondor.apana.org.au>
 <1450443254.8474.120.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151218131408.GA21756@gondor.apana.org.au>
 <20151218.162731.305092674804556753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, ying.huang@linux.intel.com, lkp@01.org,
	linux-kernel@vger.kernel.org, colin.king@canonical.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:55452 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbLSCpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 21:45:44 -0500
Content-Disposition: inline
In-Reply-To: <20151218.162731.305092674804556753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 04:27:31PM -0500, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 18 Dec 2015 21:14:08 +0800
> 
> > On Fri, Dec 18, 2015 at 04:54:14AM -0800, Eric Dumazet wrote:
> >>
> >> You can avoid the comment by using the self documented and lockdep
> >> enabled primitive
> >> 
> >> iter->walker->tbl = rcu_dereference_protected(ht->tbl,
> >> 					      lockdep_is_held(&ht->lock));
> > 
> > That is just gross.  I think a comment is much better in this case.
> 
> Herbert, this macro was created exactly to handle this situation,
> and this is what we do everywhere else in the tree.

OK.

---8<---
The commit f9f51b8070be3e829100614a7372b219723b864f ("rhashtable:
Fix walker list corruption") causes a suspicious RCU usage warning
because we no longer hold ht->mutex when we dereference ht->tbl.

However, this is a false positive because we now hold ht->lock
which also guarantees that ht->tbl won't disppear from under us.

This patch kills the warning by using rcu_dereference_protected.

Reported-by: kernel test robot <ying.huang@linux.intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index eb9240c..51282f5 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -519,7 +519,8 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
 		return -ENOMEM;
 
 	spin_lock(&ht->lock);
-	iter->walker->tbl = rht_dereference(ht->tbl, ht);
+	iter->walker->tbl =
+		rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
 	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
 	spin_unlock(&ht->lock);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

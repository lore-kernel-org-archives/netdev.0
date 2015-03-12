From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [rhashtable] [ INFO: possible recursive locking detected ]
Date: Thu, 12 Mar 2015 14:47:13 +1100
Message-ID: <20150312034713.GA14026@gondor.apana.org.au>
References: <20150312032924.GA12390@wfg-t540p.sh.intel.com>
 <20150312033744.GA13869@gondor.apana.org.au>
 <20150311.234156.247575265894541661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, lkp@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40244 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbbCLDrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:47:20 -0400
Content-Disposition: inline
In-Reply-To: <20150311.234156.247575265894541661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 11:41:56PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 12 Mar 2015 14:37:45 +1100
> 
> > rhashtable: Add annotation to nested lock
> >     
> > Commit aa34a6cb0478842452bac58edb50d3ef9e178c92 ("rhashtable:
> > Add arbitrary rehash function") killed the annotation on the
> > nested lock which leads to bitching from lockdep.
> >     
> > Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> This doesn't apply to net-next, the second hunk gives a reject.

Sorry, I based on this on top of the cleanup patches sent earlier.
Here is a rebase on net-next.  I will resend the cleanups later.

--8<--
rhashtable: Add annotation to nested lock
    
Commit aa34a6cb0478842452bac58edb50d3ef9e178c92 ("rhashtable:
Add arbitrary rehash function") killed the annotation on the
nested lock which leads to bitching from lockdep.
    
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b1c19c5..d7f3db5 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -234,7 +234,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 
 	new_bucket_lock = bucket_lock(new_tbl, new_hash);
 
-	spin_lock(new_bucket_lock);
+	spin_lock_nested(new_bucket_lock, RHT_LOCK_NESTED);
 	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
 				      new_tbl, new_hash);
 
@@ -415,7 +415,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	if (tbl != old_tbl) {
 		hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
-		spin_lock(bucket_lock(tbl, hash));
+		spin_lock_nested(bucket_lock(tbl, hash), RHT_LOCK_NESTED);
 	}
 
 	if (compare &&

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

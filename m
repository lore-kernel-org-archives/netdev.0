From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable - Cap total number of entries to 2^31
Date: Thu, 27 Apr 2017 13:44:51 +0800
Message-ID: <20170427054451.GA529@gondor.apana.org.au>
References: <20170425112356.GB11322@breakpoint.cc>
 <20170425132837.GA25657@gondor.apana.org.au>
 <20170425141749.GD11322@breakpoint.cc>
 <20170425.104822.1395000926293799711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:50176 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753403AbdD0Fug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 01:50:36 -0400
Content-Disposition: inline
In-Reply-To: <20170425.104822.1395000926293799711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 10:48:22AM -0400, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 25 Apr 2017 16:17:49 +0200
> 
> > I'd have less of an issue with this if we'd be talking about
> > something computationally expensive, but this is about storing
> > an extra value inside a struct just to avoid one "shr" in insert path...
> 
> Agreed, this shift is probably filling an available cpu cycle :-)

OK, but we need to have an extra field for another reason anyway.
The problem is that we're not capping the total number of elements
in the hashtable when max_size is not set, this means that nelems
can overflow which will cause havoc with the automatic shrinking
when it tries to fit 2^32 entries into a minimum-sized table.

So I'm taking that hole back for now :)

---8<---
When max_size is not set or if it set to a sufficiently large
value, the nelems counter can overflow.  This would cause havoc
with the automatic shrinking as it would then attempt to fit a
huge number of entries into a tiny hash table.

This patch fixes this by adding max_elems to struct rhashtable
to cap the number of elements.  This is set to 2^31 as nelems is
not a precise count.  This is sufficiently smaller than UINT_MAX
that it should be safe.

When max_size is set max_elems will be lowered to at most twice
max_size as is the status quo.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index ae93b65..45f8936 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -155,6 +155,7 @@ struct rhashtable_params {
  * @nelems: Number of elements in table
  * @key_len: Key length for hashfn
  * @p: Configuration parameters
+ * @max_elems: Maximum number of elements in table
  * @rhlist: True if this is an rhltable
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
@@ -165,6 +166,7 @@ struct rhashtable {
 	atomic_t			nelems;
 	unsigned int			key_len;
 	struct rhashtable_params	p;
+	unsigned int			max_elems;
 	bool				rhlist;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
@@ -327,8 +329,7 @@ static inline bool rht_grow_above_100(const struct rhashtable *ht,
 static inline bool rht_grow_above_max(const struct rhashtable *ht,
 				      const struct bucket_table *tbl)
 {
-	return ht->p.max_size &&
-	       (atomic_read(&ht->nelems) / 2u) >= ht->p.max_size;
+	return atomic_read(&ht->nelems) >= ht->max_elems;
 }
 
 /* The bucket lock is selected based on the hash and protects mutations
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f3b82e0..751630b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -961,6 +961,11 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->max_size)
 		ht->p.max_size = rounddown_pow_of_two(params->max_size);
 
+	/* Cap total entries at 2^31 to avoid nelems overflow. */
+	ht->max_elems = 1u << 31;
+	if (ht->p.max_size < ht->max_elems / 2)
+		ht->max_elems = ht->p.max_size * 2;
+
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

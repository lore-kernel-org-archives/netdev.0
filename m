From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Enforce minimum size on initial hash table
Date: Wed, 16 Dec 2015 18:13:14 +0800
Message-ID: <20151216101314.GA24928@gondor.apana.org.au>
References: <567113CA.8030108@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: William Hua <william.hua@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45830 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932751AbbLPKNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 05:13:21 -0500
Content-Disposition: inline
In-Reply-To: <567113CA.8030108@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Hua <william.hua@canonical.com> wrote:
>
> I wasn't aware there was an enforced minimum size. I simply set the 
> nelem_hint in the rhastable_params struct to 1, expecting it to grow as
> needed. This caused a segfault afterwards when trying to insert an
> element.

OK we're doing the size computation before we enforce the limit
on min_size.

---8<---
We need to do the initial hash table size computation after we
have obtained the correct min_size/max_size parameters.  Otherwise
we may end up with a hash table whose size is outside the allowed
envelope.

Fixes: a998f712f77e ("rhashtable: Round up/down min/max_size to...")
Reported-by: William Hua <william.hua@canonical.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 1c624db..9a40963 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -739,9 +737,6 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
 		return -EINVAL;
 
-	if (params->nelem_hint)
-		size = rounded_hashtable_size(params);
-
 	memset(ht, 0, sizeof(*ht));
 	mutex_init(&ht->mutex);
 	spin_lock_init(&ht->lock);
@@ -761,6 +756,9 @@ int rhashtable_init(struct rhashtable *ht,
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
+	if (params->nelem_hint)
+		size = rounded_hashtable_size(&ht->p);
+
 	/* The maximum (not average) chain length grows with the
 	 * size of the hash table, at a rate of (log N)/(log log N).
 	 * The value of 16 is selected so that even if the hash
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH net-next] rhashtable: Do not lower max_elems when max_size is
 zero
Date: Fri, 28 Apr 2017 14:10:48 +0800
Message-ID: <20170428061048.GA6817@gondor.apana.org.au>
References: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
 <20170427223024.32657-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de,
        tgraf@suug.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:50360 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1161851AbdD1GLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 02:11:45 -0400
Content-Disposition: inline
In-Reply-To: <20170427223024.32657-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 03:30:24PM -0700, Florian Fainelli wrote:
> After commit 6d684e54690c ("rhashtable: Cap total number of
> entries to 2^31"), we would be hitting a panic() in net/core/rtnetlink.c
> during initialization. The call stack would look like this:

Thanks for the patch.  I think we could just fold it into the
previous if clause, like this:

---8<---
The commit 6d684e54690c ("rhashtable: Cap total number of entries
to 2^31") breaks rhashtable users that do not set max_size.  This
is because when max_size is zero max_elems is also incorrectly set
to zero instead of 2^31.

This patch fixes it by only lowering max_elems when max_size is not
zero.

Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
Reported-by: Florian Fainelli <f.fainelli@gmail.com>
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 751630b..3895486 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -958,13 +958,14 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->min_size)
 		ht->p.min_size = roundup_pow_of_two(params->min_size);
 
-	if (params->max_size)
-		ht->p.max_size = rounddown_pow_of_two(params->max_size);
-
 	/* Cap total entries at 2^31 to avoid nelems overflow. */
 	ht->max_elems = 1u << 31;
-	if (ht->p.max_size < ht->max_elems / 2)
-		ht->max_elems = ht->p.max_size * 2;
+
+	if (params->max_size) {
+		ht->p.max_size = rounddown_pow_of_two(params->max_size);
+		if (ht->p.max_size < ht->max_elems / 2)
+			ht->max_elems = ht->p.max_size * 2;
+	}
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

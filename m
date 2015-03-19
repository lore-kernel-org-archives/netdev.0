From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Round up/down min/max_size to ensure we
 respect limit
Date: Thu, 19 Mar 2015 22:31:13 +0000
Message-ID: <20150319223113.GD4190@casper.infradead.org>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
 <20150319210239.GB9601@gondor.apana.org.au>
 <20150319211546.GA4190@casper.infradead.org>
 <20150319214933.GA11937@gondor.apana.org.au>
 <20150319220248.GA12428@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35408 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbCSWbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 18:31:14 -0400
Content-Disposition: inline
In-Reply-To: <20150319220248.GA12428@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Round up min_size respectively round down max_size to the next power
of two to make sure we always respect the limit specified by the
user. This is required because we compare the table size against the
limit before we expand or shrink.

Also fixes a minor bug where we modified min_size in the params
provided instead of the copy stored in struct rhashtable.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
Herbert: I'm fine with either approach. I figured you expected the
user to take care of this, hence the added warning. This is perfectly
fine with me me as well.

 lib/rhashtable.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5f8fe3e..e75c48d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -933,8 +933,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
 		return -EINVAL;
 
-	params->min_size = max(params->min_size, HASH_MIN_SIZE);
-
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(params);
 
@@ -942,6 +940,14 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	mutex_init(&ht->mutex);
 	memcpy(&ht->p, params, sizeof(*params));
 
+	if (params->min_size)
+		ht->p.min_size = roundup_pow_of_two(params->min_size);
+
+	if (params->max_size)
+		ht->p.max_size = rounddown_pow_of_two(params->max_size);
+
+	ht->p.min_size = max(params->min_size, HASH_MIN_SIZE);
+
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
 	else
-- 
1.9.3

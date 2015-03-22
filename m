From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 2/10] rhashtable: Eliminate unnecessary branch in rht_key_hashfn
Date: Sun, 22 Mar 2015 18:53:44 +1100
Message-ID: <E1YZahc-0000hb-W6@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35729 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbCVHyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rht_key_hashfn is called from rhashtable itself and params
is equal to ht->p, there is no point in checking params.key_len
and falling back to ht->p.key_len.

For some reason gcc couldn't figure out that params is the same
as ht->p.  So let's help it by only checking params.key_len when
it's a constant.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 18a6488..287b609 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -199,8 +199,11 @@ static inline unsigned int rht_key_hashfn(
 	struct rhashtable *ht, const struct bucket_table *tbl,
 	const void *key, const struct rhashtable_params params)
 {
-	return rht_bucket_index(tbl, params.hashfn(key, params.key_len ?:
-							ht->p.key_len,
+	unsigned key_len = __builtin_constant_p(params.key_len) ?
+			   (params.key_len ?: ht->p.key_len) :
+			   params.key_len;
+
+	return rht_bucket_index(tbl, params.hashfn(key, key_len,
 						   tbl->hash_rnd));
 }
 

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netfilter: Use rhashtable walk iterator
Date: Sat, 31 Jan 2015 15:31:51 +1100
Message-ID: <20150131043151.GA27524@gondor.apana.org.au>
References: <20150122084924.GA4720@gondor.apana.org.au>
 <20150125232040.GA17936@gondor.apana.org.au>
 <20150127231950.GA11374@gondor.apana.org.au>
 <20150129.144246.1383921666389409323.davem@davemloft.net>
 <20150131031356.GA26781@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150131031356.GA26781@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2015 at 02:13:56PM +1100, Herbert Xu wrote:
> 
> No problems.  Here is a new version of these two patches which
> hopefully should work on netfilter as well.

And here is the patch for netfilter.

-- >8 --
This patch gets rid of the manual rhashtable walk in nft_hash
which touches rhashtable internals that should not be exposed.
It does so by using the rhashtable iterator primitives.
    
Note that I'm leaving nft_hash_destroy alone since it's only
invoked on shutdown and it shouldn't be affected by changes
to rhashtable internals (or at least not what I'm planning to
change).
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 75887d7..61e6c40 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -130,31 +130,50 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl;
 	const struct nft_hash_elem *he;
+	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
-	unsigned int i;
+	int err;
 
-	tbl = rht_dereference_rcu(priv->tbl, priv);
-	for (i = 0; i < tbl->size; i++) {
-		struct rhash_head *pos;
+	err = rhashtable_walk_init(priv, &hti);
+	iter->err = err;
+	if (err)
+		return;
+
+	err = rhashtable_walk_start(&hti);
+	if (err && err != -EAGAIN) {
+		iter->err = err;
+		goto out;
+	}
 
-		rht_for_each_entry_rcu(he, pos, tbl, i, node) {
-			if (iter->count < iter->skip)
-				goto cont;
+	while ((he = rhashtable_walk_next(&hti))) {
+		if (IS_ERR(he)) {
+			err = PTR_ERR(he);
+			if (err != -EAGAIN) {
+				iter->err = err;
+				goto out;
+			}
+		}
+
+		if (iter->count < iter->skip)
+			goto cont;
+
+		memcpy(&elem.key, &he->key, sizeof(elem.key));
+		if (set->flags & NFT_SET_MAP)
+			memcpy(&elem.data, he->data, sizeof(elem.data));
+		elem.flags = 0;
 
-			memcpy(&elem.key, &he->key, sizeof(elem.key));
-			if (set->flags & NFT_SET_MAP)
-				memcpy(&elem.data, he->data, sizeof(elem.data));
-			elem.flags = 0;
+		iter->err = iter->fn(ctx, set, iter, &elem);
+		if (iter->err < 0)
+			goto out;
 
-			iter->err = iter->fn(ctx, set, iter, &elem);
-			if (iter->err < 0)
-				return;
 cont:
-			iter->count++;
-		}
+		iter->count++;
 	}
+
+out:
+	rhashtable_walk_stop(&hti);
+	rhashtable_walk_exit(&hti);
 }
 
 static unsigned int nft_hash_privsize(const struct nlattr * const nla[])

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

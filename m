From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] netfilter: Move mutex_is_held under PROVE_LOCKING
Date: Thu, 13 Nov 2014 18:11:19 +0800
Message-ID: <E1XorN1-0000zF-Fd@gondolin.me.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
To: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58499 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218AbaKMKLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:11:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rhashtable function mutex_is_held is only used when PROVE_LOCKING
is enabled.  This patch modifies netfilter so that we can rhashtable.h
itself can later make mutex_is_held optional depending on PROVE_LOCKING.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netfilter/nft_hash.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 8892b7b..b86305c 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -153,10 +153,12 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 	return sizeof(struct rhashtable);
 }
 
+#ifdef CONFIG_PROVE_LOCKING
 static int lockdep_nfnl_lock_is_held(void)
 {
 	return lockdep_nfnl_is_held(NFNL_SUBSYS_NFTABLES);
 }
+#endif
 
 static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
@@ -171,7 +173,9 @@ static int nft_hash_init(const struct nft_set *set,
 		.hashfn = jhash,
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
+#ifdef CONFIG_PROVE_LOCKING
 		.mutex_is_held = lockdep_nfnl_lock_is_held,
+#endif
 	};
 
 	return rhashtable_init(priv, &params);

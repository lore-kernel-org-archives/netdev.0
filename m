From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/29] netfilter: nf_tables: no size estimation if number of set elements is unknown
Date: Fri, 30 Jun 2017 00:53:09 +0200
Message-ID: <1498776807-11124-12-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57636 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752289AbdF2Wxv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 36F03BDF4E
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 27196D1CB1
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0AC5BDA80A
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:32 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This size estimation is ignored by the existing set backend selection
logic, since this estimation structure is stack allocated, set this to
~0 to make it easier to catch bugs in future changes.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c   | 17 ++++-------------
 net/netfilter/nft_set_rbtree.c |  8 +++-----
 2 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 850be3a00e62..1f1cc33895fd 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -365,22 +365,13 @@ static void nft_hash_destroy(const struct nft_set *set)
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 			      struct nft_set_estimate *est)
 {
-	unsigned int esize;
-
-	esize = sizeof(struct nft_hash_elem);
-	if (desc->size) {
+	if (desc->size)
 		est->size = sizeof(struct nft_hash) +
 			    roundup_pow_of_two(desc->size * 4 / 3) *
 			    sizeof(struct nft_hash_elem *) +
-			    desc->size * esize;
-	} else {
-		/* Resizing happens when the load drops below 30% or goes
-		 * above 75%. The average of 52.5% load (approximated by 50%)
-		 * is used for the size estimation of the hash buckets,
-		 * meaning we calculate two buckets per element.
-		 */
-		est->size = esize + 2 * sizeof(struct nft_hash_elem *);
-	}
+			    desc->size * sizeof(struct nft_hash_elem);
+	else
+		est->size = ~0;
 
 	est->lookup = NFT_SET_CLASS_O_1;
 	est->space  = NFT_SET_CLASS_O_N;
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index e97e2fb53f0a..fbfb3cbb3916 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -283,13 +283,11 @@ static void nft_rbtree_destroy(const struct nft_set *set)
 static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 				struct nft_set_estimate *est)
 {
-	unsigned int nsize;
-
-	nsize = sizeof(struct nft_rbtree_elem);
 	if (desc->size)
-		est->size = sizeof(struct nft_rbtree) + desc->size * nsize;
+		est->size = sizeof(struct nft_rbtree) +
+			    desc->size * sizeof(struct nft_rbtree_elem);
 	else
-		est->size = nsize;
+		est->size = ~0;
 
 	est->lookup = NFT_SET_CLASS_O_LOG_N;
 	est->space  = NFT_SET_CLASS_O_N;
-- 
2.1.4

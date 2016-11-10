From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/14] netfilter: nf_tables: fix race when create new element in dynset
Date: Thu, 10 Nov 2016 01:23:36 +0100
Message-ID: <1478737427-1574-4-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37750 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754593AbcKJAYF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D4BC496213
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C3604DA80B
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BDB72DA81A
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:23:59 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Packets may race when create the new element in nft_hash_update:
       CPU0                 CPU1
  lookup_fast - fail     lookup_fast - fail
       new - ok             new - ok
     insert - ok         insert - fail(EEXIST)

So when race happened, we reuse the existing element. Otherwise,
these *racing* packets will not be handled properly.

Fixes: 22fe54d5fefc ("netfilter: nf_tables: add support for dynamic set updates")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 88d9fc8343e7..a3dface3e6e6 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -98,7 +98,7 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 			    const struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he;
+	struct nft_hash_elem *he, *prev;
 	struct nft_hash_cmp_arg arg = {
 		.genmask = NFT_GENMASK_ANY,
 		.set	 = set,
@@ -112,9 +112,18 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 	he = new(set, expr, regs);
 	if (he == NULL)
 		goto err1;
-	if (rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
-					 nft_hash_params))
+
+	prev = rhashtable_lookup_get_insert_key(&priv->ht, &arg, &he->node,
+						nft_hash_params);
+	if (IS_ERR(prev))
 		goto err2;
+
+	/* Another cpu may race to insert the element with the same key */
+	if (prev) {
+		nft_set_elem_destroy(set, he, true);
+		he = prev;
+	}
+
 out:
 	*ext = &he->ext;
 	return true;
-- 
2.1.4

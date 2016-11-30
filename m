From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/11] netfilter: nf_tables: fix inconsistent element expiration calculation
Date: Wed, 30 Nov 2016 22:57:21 +0100
Message-ID: <1480543045-3389-8-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754830AbcK3V5q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:57:46 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 46A3C13C0EB
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 33D4DDA86E
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 28F03DA861
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:42 +0100 (CET)
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Anders K. Pedersen" <akp@cohaesio.com>

As Liping Zhang reports, after commit a8b1e36d0d1d ("netfilter: nft_dynset:
fix element timeout for HZ != 1000"), priv->timeout was stored in jiffies,
while set->timeout was stored in milliseconds. This is inconsistent and
incorrect.

Firstly, we already call msecs_to_jiffies in nft_set_elem_init, so
priv->timeout will be converted to jiffies twice.

Secondly, if the user did not specify the NFTA_DYNSET_TIMEOUT attr,
set->timeout will be used, but we forget to call msecs_to_jiffies
when do update elements.

Fix this by using jiffies internally for traditional sets and doing the
conversions to/from msec when interacting with userspace - as dynset
already does.

This is preferable to doing the conversions, when elements are inserted or
updated, because this can happen very frequently on busy dynsets.

Fixes: a8b1e36d0d1d ("netfilter: nft_dynset: fix element timeout for HZ != 1000")
Reported-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Anders K. Pedersen <akp@cohaesio.com>
Acked-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  2 +-
 net/netfilter/nf_tables_api.c     | 14 +++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d79d1e9b9546..b02af0bf5777 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -313,7 +313,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@size: maximum set size
  * 	@nelems: number of elements
  * 	@ndeact: number of deactivated elements queued for removal
- * 	@timeout: default timeout value in msecs
+ *	@timeout: default timeout value in jiffies
  * 	@gc_int: garbage collection interval in msecs
  *	@policy: set parameterization (see enum nft_set_policies)
  *	@udlen: user data length
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 026581b04ea8..e5194f6f906c 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2570,7 +2570,8 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 	}
 
 	if (set->timeout &&
-	    nla_put_be64(skb, NFTA_SET_TIMEOUT, cpu_to_be64(set->timeout),
+	    nla_put_be64(skb, NFTA_SET_TIMEOUT,
+			 cpu_to_be64(jiffies_to_msecs(set->timeout)),
 			 NFTA_SET_PAD))
 		goto nla_put_failure;
 	if (set->gc_int &&
@@ -2859,7 +2860,8 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	if (nla[NFTA_SET_TIMEOUT] != NULL) {
 		if (!(flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
-		timeout = be64_to_cpu(nla_get_be64(nla[NFTA_SET_TIMEOUT]));
+		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
+						nla[NFTA_SET_TIMEOUT])));
 	}
 	gc_int = 0;
 	if (nla[NFTA_SET_GC_INTERVAL] != NULL) {
@@ -3178,7 +3180,8 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT) &&
 	    nla_put_be64(skb, NFTA_SET_ELEM_TIMEOUT,
-			 cpu_to_be64(*nft_set_ext_timeout(ext)),
+			 cpu_to_be64(jiffies_to_msecs(
+						*nft_set_ext_timeout(ext))),
 			 NFTA_SET_ELEM_PAD))
 		goto nla_put_failure;
 
@@ -3447,7 +3450,7 @@ void *nft_set_elem_init(const struct nft_set *set,
 		memcpy(nft_set_ext_data(ext), data, set->dlen);
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION))
 		*nft_set_ext_expiration(ext) =
-			jiffies + msecs_to_jiffies(timeout);
+			jiffies + timeout;
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT))
 		*nft_set_ext_timeout(ext) = timeout;
 
@@ -3535,7 +3538,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_TIMEOUT] != NULL) {
 		if (!(set->flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
-		timeout = be64_to_cpu(nla_get_be64(nla[NFTA_SET_ELEM_TIMEOUT]));
+		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
+					nla[NFTA_SET_ELEM_TIMEOUT])));
 	} else if (set->flags & NFT_SET_TIMEOUT) {
 		timeout = set->timeout;
 	}
-- 
2.1.4

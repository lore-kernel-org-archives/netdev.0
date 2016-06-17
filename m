From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: nf_tables: fix wrong destroy anonymous sets if binding fails
Date: Fri, 17 Jun 2016 20:25:16 +0200
Message-ID: <1466187919-12800-5-git-send-email-pablo@netfilter.org>
References: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44641 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933024AbcFQSZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 14:25:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A7754E5A59
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 96BE29EBB4
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 15C829EBB4
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:40 +0200 (CEST)
In-Reply-To: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

When we add a nft rule like follows:
  # nft add rule filter test tcp dport vmap {1: jump test}
-ELOOP error will be returned, and the anonymous set will be
destroyed.

But after that, nf_tables_abort will also try to remove the
element and destroy the set, which was already destroyed and
freed.

If we add a nft wrong rule, nft_tables_abort will do the cleanup
work rightly, so nf_tables_set_destroy call here is redundant and
wrong, remove it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0fd6998..2c88187 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2958,13 +2958,8 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 		iter.fn		= nf_tables_bind_check_setelem;
 
 		set->ops->walk(ctx, set, &iter);
-		if (iter.err < 0) {
-			/* Destroy anonymous sets if binding fails */
-			if (set->flags & NFT_SET_ANONYMOUS)
-				nf_tables_set_destroy(ctx, set);
-
+		if (iter.err < 0)
 			return iter.err;
-		}
 	}
 bind:
 	binding->chain = ctx->chain;
-- 
2.1.4

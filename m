From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nf_tables: fix oob access
Date: Thu,  5 Jan 2017 12:19:50 +0100
Message-ID: <1483615193-2931-4-git-send-email-pablo@netfilter.org>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49672 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761880AbdAELUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:20:09 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0601F5231C
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E5120A7E9A
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:04 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B49F5A7DB8
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:02 +0100 (CET)
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

BUG: KASAN: slab-out-of-bounds in nf_tables_rule_destroy+0xf1/0x130 at addr ffff88006a4c35c8
Read of size 8 by task nft/1607

When we've destroyed last valid expr, nft_expr_next() returns an invalid expr.
We must not dereference it unless it passes != nft_expr_last() check.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a019a87e58ee..0db5f9782265 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2115,7 +2115,7 @@ static void nf_tables_rule_destroy(const struct nft_ctx *ctx,
 	 * is called on error from nf_tables_newrule().
 	 */
 	expr = nft_expr_first(rule);
-	while (expr->ops && expr != nft_expr_last(rule)) {
+	while (expr != nft_expr_last(rule) && expr->ops) {
 		nf_tables_expr_destroy(ctx, expr);
 		expr = nft_expr_next(expr);
 	}
-- 
2.1.4

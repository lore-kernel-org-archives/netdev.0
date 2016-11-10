From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/14] netfilter: nf_tables: destroy the set if fail to add transaction
Date: Thu, 10 Nov 2016 01:23:41 +0100
Message-ID: <1478737427-1574-9-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37758 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754765AbcKJAYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BD37C9B7F3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AC627DA7E0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A930FDA803
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:04 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

When the memory is exhausted, then we will fail to add the NFT_MSG_NEWSET
transaction. In such case, we should destroy the set before we free it.

Fixes: 958bee14d071 ("netfilter: nf_tables: use new transaction infrastructure to handle sets")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 365d31b86816..7d6a626b08f1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2956,12 +2956,14 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 
 	err = nft_trans_set_add(&ctx, NFT_MSG_NEWSET, set);
 	if (err < 0)
-		goto err2;
+		goto err3;
 
 	list_add_tail_rcu(&set->list, &table->sets);
 	table->use++;
 	return 0;
 
+err3:
+	ops->destroy(set);
 err2:
 	kfree(set);
 err1:
-- 
2.1.4

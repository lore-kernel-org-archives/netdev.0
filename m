From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nf-next 4/5] netfilter: nf_tables: use NLM_F_NONREC for deletion requests
Date: Sun,  3 Sep 2017 23:56:00 +0200
Message-ID: <1504475761-11454-2-git-send-email-pablo@netfilter.org>
References: <1504475761-11454-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47202 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752983AbdICV4S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 17:56:18 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 94C0811D8F6
        for <netdev@vger.kernel.org>; Sun,  3 Sep 2017 23:55:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 85EA1B5027
        for <netdev@vger.kernel.org>; Sun,  3 Sep 2017 23:55:51 +0200 (CEST)
In-Reply-To: <1504475761-11454-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bail out if user requests non-recursive deletion for tables and sets.
This new flags tells nf_tables netlink interface to reject deletions if
tables and sets have content.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 8b86acbb9770..2ea043e5b344 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -860,6 +860,10 @@ static int nf_tables_deltable(struct net *net, struct sock *nlsk,
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
+	if (nlh->nlmsg_flags & NLM_F_NONREC &&
+	    table->use > 0)
+		return -EBUSY;
+
 	ctx.afi = afi;
 	ctx.table = table;
 
@@ -3225,7 +3229,9 @@ static int nf_tables_delset(struct net *net, struct sock *nlsk,
 	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME], genmask);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
-	if (!list_empty(&set->bindings))
+
+	if (!list_empty(&set->bindings) ||
+	    (nlh->nlmsg_flags & NLM_F_NONREC && atomic_read(&set->nelems) > 0))
 		return -EBUSY;
 
 	return nft_delset(&ctx, set);
-- 
2.1.4

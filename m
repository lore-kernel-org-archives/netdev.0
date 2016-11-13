From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/39] netfilter: use switch() to handle verdict cases from nf_hook_slow()
Date: Sun, 13 Nov 2016 23:25:01 +0100
Message-ID: <1479075933-4491-8-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47634 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964795AbcKMW0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BE65EA7E92
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AE309DA85D
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B170DDA817
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:03 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use switch() for verdict handling and add explicit handling for
NF_STOLEN and other non-conventional verdicts.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 14f97b624f98..64623374bc5f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -328,22 +328,32 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 {
 	struct nf_hook_entry *entry;
 	unsigned int verdict;
-	int ret = 0;
+	int ret;
 
 	entry = rcu_dereference(state->hook_entries);
 next_hook:
 	verdict = nf_iterate(skb, state, &entry);
-	if (verdict == NF_ACCEPT) {
+	switch (verdict & NF_VERDICT_MASK) {
+	case NF_ACCEPT:
 		ret = 1;
-	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
+		break;
+	case NF_DROP:
 		kfree_skb(skb);
 		ret = NF_DROP_GETERR(verdict);
 		if (ret == 0)
 			ret = -EPERM;
-	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+		break;
+	case NF_QUEUE:
 		ret = nf_queue(skb, state, &entry, verdict);
 		if (ret == 1 && entry)
 			goto next_hook;
+		/* Fall through. */
+	default:
+		/* Implicit handling for NF_STOLEN, as well as any other non
+		 * conventional verdicts.
+		 */
+		ret = 0;
+		break;
 	}
 	return ret;
 }
-- 
2.1.4

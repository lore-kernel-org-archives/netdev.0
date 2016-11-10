From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/14] netfilter: connmark: ignore skbs with magic untracked conntrack objects
Date: Thu, 10 Nov 2016 01:23:44 +0100
Message-ID: <1478737427-1574-12-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37756 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932197AbcKJAYK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:10 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 411AA9B7F7
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 20F82DA81A
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2FFD6DA841
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:07 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The (percpu) untracked conntrack entries can end up with nonzero connmarks.

The 'untracked' conntrack objects are merely a way to distinguish INVALID
(i.e. protocol connection tracker says payload doesn't meet some
requirements or packet was never seen by the connection tracking code)
from packets that are intentionally not tracked (some icmpv6 types such as
neigh solicitation, or by using 'iptables -j CT --notrack' option).

Untracked conntrack objects are implementation detail, we might as well use
invalid magic address instead to tell INVALID and UNTRACKED apart.

Check skb->nfct for untracked dummy and behave as if skb->nfct is NULL.

Reported-by: XU Tianwen <evan.xu.tianwen@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connmark.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 69f78e96fdb4..b83e158e116a 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -44,7 +44,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	u_int32_t newmark;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (ct == NULL || nf_ct_is_untracked(ct))
 		return XT_CONTINUE;
 
 	switch (info->mode) {
@@ -97,7 +97,7 @@ connmark_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct nf_conn *ct;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (ct == NULL || nf_ct_is_untracked(ct))
 		return false;
 
 	return ((ct->mark & info->mask) == info->mark) ^ info->invert;
-- 
2.1.4

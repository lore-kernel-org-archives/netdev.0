From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/50] netfilter: convert while loops to for loops
Date: Wed,  7 Dec 2016 22:52:28 +0100
Message-ID: <1481147576-5690-23-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60248 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933270AbcLGVxp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:45 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9FD24B6C9E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 904C5DA865
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7604CDA86E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:35 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

This is to facilitate converting from a singly-linked list to an array
of elements.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c | 8 ++++----
 net/netfilter/core.c            | 6 ++----
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index adad2eed29e6..b12501a77f18 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1008,10 +1008,10 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 	struct nf_hook_state state;
 	int ret;
 
-	elem = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
-
-	while (elem && (nf_hook_entry_priority(elem) <= NF_BR_PRI_BRNF))
-		elem = rcu_dereference(elem->next);
+	for (elem = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
+	     elem && nf_hook_entry_priority(elem) <= NF_BR_PRI_BRNF;
+	     elem = rcu_dereference(elem->next))
+		;
 
 	if (!elem)
 		return okfn(net, sk, skb);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 2bb46e2d8d30..ce6adfae521a 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -107,10 +107,9 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 
 	/* Find the spot in the list */
-	while ((p = nf_entry_dereference(*pp)) != NULL) {
+	for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
 		if (reg->priority < nf_hook_entry_priority(p))
 			break;
-		pp = &p->next;
 	}
 	rcu_assign_pointer(entry->next, p);
 	rcu_assign_pointer(*pp, entry);
@@ -137,12 +136,11 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 		return;
 
 	mutex_lock(&nf_hook_mutex);
-	while ((p = nf_entry_dereference(*pp)) != NULL) {
+	for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
 		if (nf_hook_entry_ops(p) == reg) {
 			rcu_assign_pointer(*pp, p->next);
 			break;
 		}
-		pp = &p->next;
 	}
 	mutex_unlock(&nf_hook_mutex);
 	if (!p) {
-- 
2.1.4

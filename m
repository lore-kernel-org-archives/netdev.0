From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 42/47] netfilter: debug: check for sorted array
Date: Mon,  4 Sep 2017 00:42:49 +0200
Message-ID: <1504478574-13281-7-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53062 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753500AbdICWnM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:43:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 549CA190F66
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:42:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 446CFB5030
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:42:46 +0200 (CEST)
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Make sure our grow/shrink routine places them in the correct order.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 1a9e23c9ab98..164ad20d0bd2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -157,6 +157,27 @@ nf_hook_entries_grow(const struct nf_hook_entries *old,
 	return new;
 }
 
+static void hooks_validate(const struct nf_hook_entries *hooks)
+{
+#ifdef CONFIG_DEBUG_KERNEL
+	struct nf_hook_ops **orig_ops;
+	int prio = INT_MIN;
+	size_t i = 0;
+
+	orig_ops = nf_hook_entries_get_hook_ops(hooks);
+
+	for (i = 0; i < hooks->num_hook_entries; i++) {
+		if (orig_ops[i] == &dummy_ops)
+			continue;
+
+		WARN_ON(orig_ops[i]->priority < prio);
+
+		if (orig_ops[i]->priority > prio)
+			prio = orig_ops[i]->priority;
+	}
+#endif
+}
+
 /*
  * __nf_hook_entries_try_shrink - try to shrink hook array
  *
@@ -210,6 +231,7 @@ static void *__nf_hook_entries_try_shrink(struct nf_hook_entries __rcu **pp)
 		new_ops[j] = (void *)orig_ops[i];
 		j++;
 	}
+	hooks_validate(new);
 out_assign:
 	rcu_assign_pointer(*pp, new);
 	return old;
@@ -261,6 +283,7 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	if (IS_ERR(new_hooks))
 		return PTR_ERR(new_hooks);
 
+	hooks_validate(new_hooks);
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
 		net_inc_ingress_queue();
-- 
2.1.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/50] netfilter: ingress: translate 0 nf_hook_slow retval to -1
Date: Wed,  7 Dec 2016 22:52:36 +0100
Message-ID: <1481147576-5690-31-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60188 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933376AbcLGVxq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:46 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 34C0296ED2
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 16310DA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 07884DA848
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:42 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The caller assumes that < 0 means that skb was stolen (or free'd).

All other return values continue skb processing.

nf_hook_slow returns 3 different return value types:

A) a (negative) errno value: the skb was dropped (NF_DROP, e.g.
by iptables '-j DROP' rule).

B) 0. The skb was stolen by the hook or queued to userspace.

C) 1. all hooks returned NF_ACCEPT so the caller should invoke
   the okfn so packet processing can continue.

nft ingress facility currently doesn't have the 'okfn' that
the NF_HOOK() macros use; there is no nfqueue support either.

So 1 means that nf_hook_ingress() caller should go on processing the skb.

In order to allow use of NF_STOLEN from ingress we need to translate
this to an errno number, else we'd crash because we continue with
already-free'd (or about to be free-d) skb.

The errno value isn't checked, its just important that its less than 0,
so return -1.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ingress.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 2dc3b49b804a..59476061de86 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -19,6 +19,7 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 {
 	struct nf_hook_entry *e = rcu_dereference(skb->dev->nf_hooks_ingress);
 	struct nf_hook_state state;
+	int ret;
 
 	/* Must recheck the ingress hook head, in the event it became NULL
 	 * after the check in nf_hook_ingress_active evaluated to true.
@@ -29,7 +30,11 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 	nf_hook_state_init(&state, NF_NETDEV_INGRESS,
 			   NFPROTO_NETDEV, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
-	return nf_hook_slow(skb, &state, e);
+	ret = nf_hook_slow(skb, &state, e);
+	if (ret == 0)
+		return -1;
+
+	return ret;
 }
 
 static inline void nf_hook_ingress_init(struct net_device *dev)
-- 
2.1.4

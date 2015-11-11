From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/10] netfilter: ingress: don't use nf_hook_list_active
Date: Wed, 11 Nov 2015 18:33:34 +0100
Message-ID: <1447263223-22662-2-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48380 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbbKKRdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:33:53 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 961721392B7
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:52 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7655312214E
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:52 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 75B475AE
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:50 +0100 (CET)
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nf_hook_list_active() always returns true once at least one device has
NF_INGRESS hook enabled.

Thus, don't use this function. Instead, inverse the test and use the static
key to elide list_empty test if no NF_INGRESS hooks are active.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ingress.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 187feab..ba7ce88 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -5,10 +5,13 @@
 #include <linux/netdevice.h>
 
 #ifdef CONFIG_NETFILTER_INGRESS
-static inline int nf_hook_ingress_active(struct sk_buff *skb)
+static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
 {
-	return nf_hook_list_active(&skb->dev->nf_hooks_ingress,
-				   NFPROTO_NETDEV, NF_NETDEV_INGRESS);
+#ifdef HAVE_JUMP_LABEL
+	if (!static_key_false(&nf_hooks_needed[NFPROTO_NETDEV][NF_NETDEV_INGRESS]))
+		return false;
+#endif
+	return !list_empty(&skb->dev->nf_hooks_ingress);
 }
 
 static inline int nf_hook_ingress(struct sk_buff *skb)
-- 
2.1.4

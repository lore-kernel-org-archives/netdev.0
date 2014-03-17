From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/38] netfilter: nfnetlink: add rcu_dereference_protected() helpers
Date: Mon, 17 Mar 2014 13:42:25 +0100
Message-ID: <1395060178-11833-6-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59315 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933093AbaCQMn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:26 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add a lockdep_nfnl_is_held() function and a nfnl_dereference() macro for
RCU dereferences protected by a NFNL subsystem mutex.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h |   21 +++++++++++++++++++++
 net/netfilter/nfnetlink.c           |    8 ++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 28c7436..e955d47 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -44,6 +44,27 @@ int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 
 void nfnl_lock(__u8 subsys_id);
 void nfnl_unlock(__u8 subsys_id);
+#ifdef CONFIG_PROVE_LOCKING
+int lockdep_nfnl_is_held(__u8 subsys_id);
+#else
+static inline int lockdep_nfnl_is_held(__u8 subsys_id)
+{
+	return 1;
+}
+#endif /* CONFIG_PROVE_LOCKING */
+
+/*
+ * nfnl_dereference - fetch RCU pointer when updates are prevented by subsys mutex
+ *
+ * @p: The pointer to read, prior to dereferencing
+ * @ss: The nfnetlink subsystem ID
+ *
+ * Return the value of the specified RCU-protected pointer, but omit
+ * both the smp_read_barrier_depends() and the ACCESS_ONCE(), because
+ * caller holds the NFNL subsystem mutex.
+ */
+#define nfnl_dereference(p, ss)					\
+	rcu_dereference_protected(p, lockdep_nfnl_is_held(ss))
 
 #define MODULE_ALIAS_NFNL_SUBSYS(subsys) \
 	MODULE_ALIAS("nfnetlink-subsys-" __stringify(subsys))
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 046aa13..e8138da 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -61,6 +61,14 @@ void nfnl_unlock(__u8 subsys_id)
 }
 EXPORT_SYMBOL_GPL(nfnl_unlock);
 
+#ifdef CONFIG_PROVE_LOCKING
+int lockdep_nfnl_is_held(u8 subsys_id)
+{
+	return lockdep_is_held(&table[subsys_id].mutex);
+}
+EXPORT_SYMBOL_GPL(lockdep_nfnl_is_held);
+#endif
+
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 {
 	nfnl_lock(n->subsys_id);
-- 
1.7.10.4

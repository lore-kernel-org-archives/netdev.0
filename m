From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv4 next 2/3] net: Add _nf_(un)register_hooks symbols
Date: Fri, 16 Sep 2016 12:59:13 -0700
Message-ID: <1474055953-12494-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35418 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933663AbcIPT7Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:59:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id 6so1034296pfl.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:59:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Add _nf_register_hooks() and _nf_unregister_hooks() calls which allow
caller to hold RTNL mutex.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |  2 ++
 net/netfilter/core.c      | 51 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 9230f9aee896..e82b76781bf6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -133,6 +133,8 @@ int nf_register_hook(struct nf_hook_ops *reg);
 void nf_unregister_hook(struct nf_hook_ops *reg);
 int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
 void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
+int _nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
+void _nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
 
 /* Functions to register get/setsockopt ranges (non-inclusive).  You
    need to check permissions yourself! */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index f39276d1c2d7..2c5327e43a88 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -188,19 +188,17 @@ EXPORT_SYMBOL(nf_unregister_net_hooks);
 
 static LIST_HEAD(nf_hook_list);
 
-int nf_register_hook(struct nf_hook_ops *reg)
+static int _nf_register_hook(struct nf_hook_ops *reg)
 {
 	struct net *net, *last;
 	int ret;
 
-	rtnl_lock();
 	for_each_net(net) {
 		ret = nf_register_net_hook(net, reg);
 		if (ret && ret != -ENOENT)
 			goto rollback;
 	}
 	list_add_tail(&reg->list, &nf_hook_list);
-	rtnl_unlock();
 
 	return 0;
 rollback:
@@ -210,19 +208,34 @@ rollback:
 			break;
 		nf_unregister_net_hook(net, reg);
 	}
+	return ret;
+}
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = _nf_register_hook(reg);
 	rtnl_unlock();
+
 	return ret;
 }
 EXPORT_SYMBOL(nf_register_hook);
 
-void nf_unregister_hook(struct nf_hook_ops *reg)
+static void _nf_unregister_hook(struct nf_hook_ops *reg)
 {
 	struct net *net;
 
-	rtnl_lock();
 	list_del(&reg->list);
 	for_each_net(net)
 		nf_unregister_net_hook(net, reg);
+}
+
+void nf_unregister_hook(struct nf_hook_ops *reg)
+{
+	rtnl_lock();
+	_nf_unregister_hook(reg);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL(nf_unregister_hook);
@@ -246,6 +259,26 @@ err:
 }
 EXPORT_SYMBOL(nf_register_hooks);
 
+/* Caller MUST take rtnl_lock() */
+int _nf_register_hooks(struct nf_hook_ops *reg, unsigned int n)
+{
+	unsigned int i;
+	int err = 0;
+
+	for (i = 0; i < n; i++) {
+		err = _nf_register_hook(&reg[i]);
+		if (err)
+			goto err;
+	}
+	return err;
+
+err:
+	if (i > 0)
+		_nf_unregister_hooks(reg, i);
+	return err;
+}
+EXPORT_SYMBOL(_nf_register_hooks);
+
 void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 {
 	while (n-- > 0)
@@ -253,6 +286,14 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 }
 EXPORT_SYMBOL(nf_unregister_hooks);
 
+/* Caller MUST take rtnl_lock */
+void _nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
+{
+	while (n-- > 0)
+		_nf_unregister_hook(&reg[n]);
+}
+EXPORT_SYMBOL(_nf_unregister_hooks);
+
 unsigned int nf_iterate(struct list_head *head,
 			struct sk_buff *skb,
 			struct nf_hook_state *state,
-- 
2.8.0.rc3.226.g39d4020

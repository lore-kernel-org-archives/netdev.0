From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] rtnetlink: remove __rtnl_af_unregister
Date: Wed,  4 Oct 2017 15:58:49 +0200
Message-ID: <20171004135849.4368-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53280 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752238AbdJDN6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switch the only caller to rtnl_af_unregister.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/rtnetlink.h |  2 --
 net/core/rtnetlink.c    | 14 +-------------
 net/ipv6/addrconf.c     |  4 ++--
 3 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 6520993ff449..e3ca8e2e3103 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -151,8 +151,6 @@ struct rtnl_af_ops {
 	size_t			(*get_stats_af_size)(const struct net_device *dev);
 };
 
-void __rtnl_af_unregister(struct rtnl_af_ops *ops);
-
 void rtnl_af_register(struct rtnl_af_ops *ops);
 void rtnl_af_unregister(struct rtnl_af_ops *ops);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b63c5759641f..3fb1ca33cba4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -476,25 +476,13 @@ void rtnl_af_register(struct rtnl_af_ops *ops)
 EXPORT_SYMBOL_GPL(rtnl_af_register);
 
 /**
- * __rtnl_af_unregister - Unregister rtnl_af_ops from rtnetlink.
- * @ops: struct rtnl_af_ops * to unregister
- *
- * The caller must hold the rtnl_mutex.
- */
-void __rtnl_af_unregister(struct rtnl_af_ops *ops)
-{
-	list_del(&ops->list);
-}
-EXPORT_SYMBOL_GPL(__rtnl_af_unregister);
-
-/**
  * rtnl_af_unregister - Unregister rtnl_af_ops from rtnetlink.
  * @ops: struct rtnl_af_ops * to unregister
  */
 void rtnl_af_unregister(struct rtnl_af_ops *ops)
 {
 	rtnl_lock();
-	__rtnl_af_unregister(ops);
+	list_del(&ops->list);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(rtnl_af_unregister);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f553f72d0bee..837418ff2d4b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6618,9 +6618,9 @@ void addrconf_cleanup(void)
 	unregister_pernet_subsys(&addrconf_ops);
 	ipv6_addr_label_cleanup();
 
-	rtnl_lock();
+	rtnl_af_unregister(&inet6_ops);
 
-	__rtnl_af_unregister(&inet6_ops);
+	rtnl_lock();
 
 	/* clean dev list */
 	for_each_netdev(&init_net, dev) {
-- 
2.13.6

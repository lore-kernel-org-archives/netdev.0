From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 3/6] netns: Add get_net_ns_by_id() to get a reference to a
	network namespace from its nsid
Date: Tue, 28 Oct 2008 18:43:22 +0100
Message-ID: <20081028174322.GC8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmzraw4.extranet.thmulti.com ([141.11.234.72]:33290 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596AbYJ1RnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:43:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a __get_net_ns_by_id() to obtain look for and obtain a reference to a network namespace via its nsid.
The corresponding get_net_ns_by_id() takes the rtnl_lock.

---
 include/net/net_namespace.h |   34 +++++++++++++++++++++++++++++++---
 net/core/net_namespace.c    |   12 ++++++++++++
 2 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 8bde629..afb2578 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -104,8 +104,13 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 
 extern struct list_head net_namespace_list;
 
+
+#define for_each_net(VAR)				\
+	list_for_each_entry(VAR, &net_namespace_list, list)
+
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
+extern struct net *get_net_ns_by_id(int id);
 
 static inline int net_alive(struct net *net)
 {
@@ -141,6 +146,19 @@ int net_eq(const struct net *net1, const struct net *net2)
 {
 	return net1 == net2;
 }
+
+static inline struct net *__get_net_ns_by_id(int id)
+{
+	struct net *net;
+
+	for_each_net(net)
+		if (net->id == id)
+			return maybe_get_net(net);
+
+	return NULL;
+}
+extern struct net *get_net_ns_by_id(int id);
+
 #else
 
 static inline int net_alive(struct net *net)
@@ -167,6 +185,19 @@ int net_eq(const struct net *net1, const struct net *net2)
 {
 	return 1;
 }
+
+static inline struct net *__get_net_ns_by_id(int id)
+{
+	if (id == 0)
+		return &init_net;
+	return NULL;
+}
+
+static inline struct net *get_net_ns_by_id(int id)
+{
+	return __get_net_ns_by_id(id);
+}
+
 #endif
 
 
@@ -195,9 +226,6 @@ static inline void release_net(struct net *net)
 #endif
 
 
-#define for_each_net(VAR)				\
-	list_for_each_entry(VAR, &net_namespace_list, list)
-
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 418abe0..596cb83 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -203,6 +203,18 @@ void __put_net(struct net *net)
 }
 EXPORT_SYMBOL_GPL(__put_net);
 
+struct net *get_net_ns_by_id(int id)
+{
+	struct net *net;
+
+	rtnl_lock();
+	net = __get_net_ns_by_id(id);
+	rtnl_unlock();
+
+	return net;
+}
+EXPORT_SYMBOL_GPL(get_net_ns_by_id);
+
 #else
 struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 {
-- 
1.5.4.4


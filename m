From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/5] Relax the reference counting of init_net_ns
Date: Wed, 31 Oct 2007 22:25:18 +0300
Message-ID: <4728D69E.6030808@openvz.org>
References: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44536 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247AbXJaSXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 14:23:07 -0400
In-Reply-To: <4728D54F.2080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the CONFIG_NET_NS is n there's no need in refcounting
the initial net namespace. So relax this code by making a
stupid stubs for the "n" case.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5279466..1fd449a 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -51,13 +51,12 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 }
 #endif
 
+#ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
 
 static inline struct net *get_net(struct net *net)
 {
-#ifdef CONFIG_NET
 	atomic_inc(&net->count);
-#endif
 	return net;
 }
 
@@ -75,26 +74,44 @@ static inline struct net *maybe_get_net(struct net *net)
 
 static inline void put_net(struct net *net)
 {
-#ifdef CONFIG_NET
 	if (atomic_dec_and_test(&net->count))
 		__put_net(net);
-#endif
 }
 
 static inline struct net *hold_net(struct net *net)
 {
-#ifdef CONFIG_NET
 	atomic_inc(&net->use_count);
-#endif
 	return net;
 }
 
 static inline void release_net(struct net *net)
 {
-#ifdef CONFIG_NET
 	atomic_dec(&net->use_count);
-#endif
 }
+#else
+static inline struct net *get_net(struct net *net)
+{
+	return net;
+}
+
+static inline void put_net(struct net *net)
+{
+}
+
+static inline struct net *hold_net(struct net *net)
+{
+	return net;
+}
+
+static inline void release_net(struct net *net)
+{
+}
+
+static inline struct net *maybe_get_net(struct net *net)
+{
+	return net;
+}
+#endif
 
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
-- 
1.5.3.4


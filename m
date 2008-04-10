From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/14][RTNL]: Introduce the rtnl_kill_links call.
Date: Thu, 10 Apr 2008 19:10:57 +0400
Message-ID: <47FE2E01.6030000@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60951 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756376AbYDJOrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:47:31 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... which will kill all the devices in the given net with
the given rtnl_link_ops. Will be used in VLAN patches later.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/rtnetlink.h |    1 +
 net/core/rtnetlink.c    |   29 +++++++++++++++++++++--------
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 793863e..3c1895e 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -74,6 +74,7 @@ struct rtnl_link_ops {
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	__rtnl_link_unregister(struct rtnl_link_ops *ops);
+extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
 
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index da99ac0..bc39e41 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -269,6 +269,26 @@ int rtnl_link_register(struct rtnl_link_ops *ops)
 
 EXPORT_SYMBOL_GPL(rtnl_link_register);
 
+static void __rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
+{
+	struct net_device *dev;
+restart:
+	for_each_netdev(net, dev) {
+		if (dev->rtnl_link_ops == ops) {
+			ops->dellink(dev);
+			goto restart;
+		}
+	}
+}
+
+void rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
+{
+	rtnl_lock();
+	__rtnl_kill_links(net, ops);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL_GPL(rtnl_kill_links);
+
 /**
  * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
  * @ops: struct rtnl_link_ops * to unregister
@@ -277,17 +297,10 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
  */
 void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 {
-	struct net_device *dev, *n;
 	struct net *net;
 
 	for_each_net(net) {
-restart:
-		for_each_netdev_safe(net, dev, n) {
-			if (dev->rtnl_link_ops == ops) {
-				ops->dellink(dev);
-				goto restart;
-			}
-		}
+		__rtnl_kill_links(net, ops);
 	}
 	list_del(&ops->list);
 }
-- 
1.5.3.4


From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/10][RTNL]: Introduce the rtnl_kill_links helper.
Date: Tue, 15 Apr 2008 16:03:32 +0400
Message-ID: <48049994.7050405@openvz.org>
References: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39976 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbYDOL3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:29:17 -0400
In-Reply-To: <4804989F.1060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is responsible for calling ->dellink on each net
device found in net to help with vlan net_exit hook in the
nearest future.

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
index edc6dbf..bc39e41 100644
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
-	struct net_device *dev;
 	struct net *net;
 
 	for_each_net(net) {
-restart:
-		for_each_netdev(net, dev) {
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


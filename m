From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bridge: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 16:35:35 +0100
Message-ID: <4AE864C7.3060100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34796 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbZJ1Pfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 11:35:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_if.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index b1b3b0f..2117e5b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -154,7 +154,7 @@ static void del_nbp(struct net_bridge_port *p)
 }
 
 /* called with RTNL */
-static void del_br(struct net_bridge *br)
+static void del_br(struct net_bridge *br, struct list_head *head)
 {
 	struct net_bridge_port *p, *n;
 
@@ -165,7 +165,7 @@ static void del_br(struct net_bridge *br)
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
-	unregister_netdevice(br->dev);
+	unregister_netdevice_queue(br->dev, head);
 }
 
 static struct net_device *new_bridge_dev(struct net *net, const char *name)
@@ -323,7 +323,7 @@ int br_del_bridge(struct net *net, const char *name)
 	}
 
 	else
-		del_br(netdev_priv(dev));
+		del_br(netdev_priv(dev), NULL);
 
 	rtnl_unlock();
 	return ret;
@@ -462,15 +462,14 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 void br_net_exit(struct net *net)
 {
 	struct net_device *dev;
+	LIST_HEAD(list);
 
 	rtnl_lock();
-restart:
-	for_each_netdev(net, dev) {
-		if (dev->priv_flags & IFF_EBRIDGE) {
-			del_br(netdev_priv(dev));
-			goto restart;
-		}
-	}
+	for_each_netdev(net, dev)
+		if (dev->priv_flags & IFF_EBRIDGE)
+			del_br(netdev_priv(dev), &list);
+
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 
 }

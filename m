From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 11/13] bridge: Add multicast_snooping sysfs toggle
Date: Sun, 28 Feb 2010 13:41:50 +0800
Message-ID: <E1NlbuY-00021v-EJ@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42764 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752097Ab0B1Fl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast_snooping sysfs toggle

This patch allows the user to disable IGMP snooping completely
through a sysfs toggle.  It also allows the user to reenable
snooping when it has been automatically disabled due to hash
collisions.  If the collisions have not been resolved however
the system will refuse to reenable snooping.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |   61 ++++++++++++++++++++++++++++++++++++++++++----
 net/bridge/br_private.h   |    1 
 net/bridge/br_sysfs_br.c  |   18 +++++++++++++
 3 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 674224b..c7a1095 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -656,6 +656,15 @@ void br_multicast_del_port(struct net_bridge_port *port)
 	del_timer_sync(&port->multicast_router_timer);
 }
 
+static void __br_multicast_enable_port(struct net_bridge_port *port)
+{
+	port->multicast_startup_queries_sent = 0;
+
+	if (try_to_del_timer_sync(&port->multicast_query_timer) >= 0 ||
+	    del_timer(&port->multicast_query_timer))
+		mod_timer(&port->multicast_query_timer, jiffies);
+}
+
 void br_multicast_enable_port(struct net_bridge_port *port)
 {
 	struct net_bridge *br = port->br;
@@ -664,11 +673,7 @@ void br_multicast_enable_port(struct net_bridge_port *port)
 	if (br->multicast_disabled || !netif_running(br->dev))
 		goto out;
 
-	port->multicast_startup_queries_sent = 0;
-
-	if (try_to_del_timer_sync(&port->multicast_query_timer) >= 0 ||
-	    del_timer(&port->multicast_query_timer))
-		mod_timer(&port->multicast_query_timer, jiffies);
+	__br_multicast_enable_port(port);
 
 out:
 	spin_unlock(&br->multicast_lock);
@@ -1210,3 +1215,49 @@ unlock:
 
 	return err;
 }
+
+int br_multicast_toggle(struct net_bridge *br, unsigned long val)
+{
+	struct net_bridge_port *port;
+	int err = -ENOENT;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev))
+		goto unlock;
+
+	err = 0;
+	if (br->multicast_disabled == !val)
+		goto unlock;
+
+	br->multicast_disabled = !val;
+	if (br->multicast_disabled)
+		goto unlock;
+
+	if (br->mdb) {
+		if (br->mdb->old) {
+			err = -EEXIST;
+rollback:
+			br->multicast_disabled = !!val;
+			goto unlock;
+		}
+
+		err = br_mdb_rehash(&br->mdb, br->mdb->max,
+				    br->hash_elasticity);
+		if (err)
+			goto rollback;
+	}
+
+	br_multicast_open(br);
+	list_for_each_entry(port, &br->port_list, list) {
+		if (port->state == BR_STATE_DISABLED ||
+		    port->state == BR_STATE_BLOCKING)
+			continue;
+
+		__br_multicast_enable_port(port);
+	}
+
+unlock:
+	spin_unlock(&br->multicast_lock);
+
+	return err;
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2d3df82..4467904 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -301,6 +301,7 @@ extern void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
 extern int br_multicast_set_router(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_port_router(struct net_bridge_port *p,
 					unsigned long val);
+extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index cb74201..0ab2883 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -361,6 +361,23 @@ static ssize_t store_multicast_router(struct device *d,
 }
 static DEVICE_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
 		   store_multicast_router);
+
+static ssize_t show_multicast_snooping(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", !br->multicast_disabled);
+}
+
+static ssize_t store_multicast_snooping(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_multicast_toggle);
+}
+static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
+		   show_multicast_snooping, store_multicast_snooping);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -384,6 +401,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_flush.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
+	&dev_attr_multicast_snooping.attr,
 #endif
 	NULL
 };

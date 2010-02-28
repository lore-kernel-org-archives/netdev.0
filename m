From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Sun, 28 Feb 2010 13:41:49 +0800
Message-ID: <E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752198Ab0B1Flz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast_router sysfs entries

This patch allows the user to forcibly enable/disable ports as
having multicast routers attached.  A port with a multicast router
will receive all multicast traffic.

The value 0 disables it completely.  The default is 1 which lets
the system automatically detect the presence of routers (currently
this is limited to picking up queries), and 2 means that the port
will always receive all multicast traffic.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |  105 +++++++++++++++++++++++++++++++++++++++-------
 net/bridge/br_private.h   |    3 +
 net/bridge/br_sysfs_br.c  |   21 +++++++++
 net/bridge/br_sysfs_if.c  |   18 +++++++
 4 files changed, 133 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 746b5a6..674224b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -746,12 +746,30 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 	return err;
 }
 
+static void br_multicast_add_router(struct net_bridge *br,
+				    struct net_bridge_port *port)
+{
+	struct hlist_node *p;
+	struct hlist_node **h;
+
+	for (h = &br->router_list.first;
+	     (p = *h) &&
+	     (unsigned long)container_of(p, struct net_bridge_port, rlist) >
+	     (unsigned long)port;
+	     h = &p->next)
+		;
+
+	port->rlist.pprev = h;
+	port->rlist.next = p;
+	rcu_assign_pointer(*h, &port->rlist);
+	if (p)
+		p->pprev = &port->rlist.next;
+}
+
 static void br_multicast_mark_router(struct net_bridge *br,
 				     struct net_bridge_port *port)
 {
 	unsigned long now = jiffies;
-	struct hlist_node *p;
-	struct hlist_node **h;
 
 	if (!port) {
 		if (br->multicast_router == 1)
@@ -766,18 +784,7 @@ static void br_multicast_mark_router(struct net_bridge *br,
 	if (!hlist_unhashed(&port->rlist))
 		goto timer;
 
-	for (h = &br->router_list.first;
-	     (p = *h) &&
-	     (unsigned long)container_of(p, struct net_bridge_port, rlist) >
-	     (unsigned long)port;
-	     h = &p->next)
-		;
-
-	port->rlist.pprev = h;
-	port->rlist.next = p;
-	rcu_assign_pointer(*h, &port->rlist);
-	if (p)
-		p->pprev = &port->rlist.next;
+	br_multicast_add_router(br, port);
 
 timer:
 	mod_timer(&port->multicast_router_timer,
@@ -1133,3 +1140,73 @@ void br_multicast_stop(struct net_bridge *br)
 out:
 	spin_unlock_bh(&br->multicast_lock);
 }
+
+int br_multicast_set_router(struct net_bridge *br, unsigned long val)
+{
+	int err = -ENOENT;
+
+	spin_lock_bh(&br->multicast_lock);
+	if (!netif_running(br->dev))
+		goto unlock;
+
+	switch (val) {
+	case 0:
+	case 2:
+		del_timer(&br->multicast_router_timer);
+		/* fall through */
+	case 1:
+		br->multicast_router = val;
+		err = 0;
+		break;
+
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+unlock:
+	spin_unlock_bh(&br->multicast_lock);
+
+	return err;
+}
+
+int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
+{
+	struct net_bridge *br = p->br;
+	int err = -ENOENT;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) || p->state == BR_STATE_DISABLED)
+		goto unlock;
+
+	switch (val) {
+	case 0:
+	case 1:
+	case 2:
+		p->multicast_router = val;
+		err = 0;
+
+		if (val < 2 && !hlist_unhashed(&p->rlist))
+			hlist_del_init_rcu(&p->rlist);
+
+		if (val == 1)
+			break;
+
+		del_timer(&p->multicast_router_timer);
+
+		if (val == 0)
+			break;
+
+		br_multicast_add_router(br, p);
+		break;
+
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+unlock:
+	spin_unlock(&br->multicast_lock);
+
+	return err;
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f2dd411..2d3df82 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -298,6 +298,9 @@ extern void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 				 struct sk_buff *skb);
 extern void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
 				 struct sk_buff *skb, struct sk_buff *skb2);
+extern int br_multicast_set_router(struct net_bridge *br, unsigned long val);
+extern int br_multicast_set_port_router(struct net_bridge_port *p,
+					unsigned long val);
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index bee4f30..cb74201 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -345,6 +345,24 @@ static ssize_t store_flush(struct device *d,
 }
 static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+static ssize_t show_multicast_router(struct device *d,
+				     struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->multicast_router);
+}
+
+static ssize_t store_multicast_router(struct device *d,
+				      struct device_attribute *attr,
+				      const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_multicast_set_router);
+}
+static DEVICE_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
+		   store_multicast_router);
+#endif
+
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -364,6 +382,9 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	&dev_attr_multicast_router.attr,
+#endif
 	NULL
 };
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 820643a..696596c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -159,6 +159,21 @@ static ssize_t store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
 static BRPORT_ATTR(hairpin_mode, S_IRUGO | S_IWUSR,
 		   show_hairpin_mode, store_hairpin_mode);
 
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->multicast_router);
+}
+
+static ssize_t store_multicast_router(struct net_bridge_port *p,
+				      unsigned long v)
+{
+	return br_multicast_set_port_router(p, v);
+}
+static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
+		   store_multicast_router);
+#endif
+
 static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -176,6 +191,9 @@ static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_hold_timer,
 	&brport_attr_flush,
 	&brport_attr_hairpin_mode,
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	&brport_attr_multicast_router,
+#endif
 	NULL
 };
 

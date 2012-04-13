From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] bridge: Add multicast_querier toggle and disable queries by default
Date: Fri, 13 Apr 2012 20:37:42 +0800
Message-ID: <E1SIfl0-0000Df-Ri@gondolin.me.apana.org.au>
References: <20120413123641.GA758@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:59576 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754739Ab2DMMho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 08:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast_querier toggle and disable queries by default

Sending general queries was implemented as an optimisation to speed
up convergence on start-up.  In order to prevent interference with
multicast routers a zero source address has to be used.

Unfortunately these packets appear to cause some multicast-aware
switches to misbehave, e.g., by disrupting multicast packets to us.

Since the multicast snooping feature still functions without sending
our own queries, this patch will change the default to not send
queries.

For those that need queries in order to speed up convergence on start-up,
a toggle is provided to restore the previous behaviour.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |   20 ++++++++++++++++++++
 net/bridge/br_private.h   |    2 ++
 net/bridge/br_sysfs_br.c  |   18 ++++++++++++++++++
 3 files changed, 40 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b0796d7..26df642 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -783,6 +783,7 @@ static void br_multicast_send_query(struct net_bridge *br,
 	struct br_ip br_group;
 
 	if (!netif_running(br->dev) || br->multicast_disabled ||
+	    !br->multicast_querier ||
 	    timer_pending(&br->multicast_querier_timer))
 		return;
 
@@ -1565,6 +1566,7 @@ void br_multicast_init(struct net_bridge *br)
 	br->hash_max = 512;
 
 	br->multicast_router = 1;
+	br->multicast_querier = 0;
 	br->multicast_last_member_count = 2;
 	br->multicast_startup_query_count = 2;
 
@@ -1760,6 +1762,24 @@ unlock:
 	return err;
 }
 
+int br_multicast_set_querier(struct net_bridge *br, unsigned long val)
+{
+	val = !!val;
+
+	spin_lock_bh(&br->multicast_lock);
+	if (br->multicast_querier == val)
+		goto unlock;
+
+	br->multicast_querier = val;
+	if (val)
+		br_multicast_start_querier(br);
+
+unlock:
+	spin_unlock_bh(&br->multicast_lock);
+
+	return 0;
+}
+
 int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
 {
 	int err = -ENOENT;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e1d8822..f8ffd8c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -224,6 +224,7 @@ struct net_bridge
 	unsigned char			multicast_router;
 
 	u8				multicast_disabled:1;
+	u8				multicast_querier:1;
 
 	u32				hash_elasticity;
 	u32				hash_max;
@@ -417,6 +418,7 @@ extern int br_multicast_set_router(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_port_router(struct net_bridge_port *p,
 					unsigned long val);
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
+extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
 
 static inline bool br_multicast_is_router(struct net_bridge *br)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c236c0e..a27243e 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -379,6 +379,23 @@ static ssize_t store_multicast_snooping(struct device *d,
 static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
 		   show_multicast_snooping, store_multicast_snooping);
 
+static ssize_t show_multicast_querier(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->multicast_querier);
+}
+
+static ssize_t store_multicast_querier(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_multicast_set_querier);
+}
+static DEVICE_ATTR(multicast_querier, S_IRUGO | S_IWUSR,
+		   show_multicast_querier, store_multicast_querier);
+
 static ssize_t show_hash_elasticity(struct device *d,
 				    struct device_attribute *attr, char *buf)
 {
@@ -702,6 +719,7 @@ static struct attribute *bridge_attrs[] = {
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
+	&dev_attr_multicast_querier.attr,
 	&dev_attr_hash_elasticity.attr,
 	&dev_attr_hash_max.attr,
 	&dev_attr_multicast_last_member_count.attr,

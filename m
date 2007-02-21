From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] bridge: add flush attribute
Date: Wed, 21 Feb 2007 14:41:11 -0800
Message-ID: <20070221224255.897039436@linux-foundation.org>
References: <20070221224107.741532037@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53656 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423235AbXBUWrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 17:47:16 -0500
Content-Disposition: inline; filename=bridge-fdb-flush.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a flush attribute to sysfs to allow flushing forwarding table.
This can be used by user level spanning tree protocol to clear state.

---
 net/bridge/br_fdb.c      |   11 ++++++++---
 net/bridge/br_sysfs_br.c |   14 ++++++++++++++
 net/bridge/br_sysfs_if.c |    8 ++++++++
 3 files changed, 30 insertions(+), 3 deletions(-)

--- bridge.orig/net/bridge/br_sysfs_br.c	2007-02-21 14:28:49.000000000 -0800
+++ bridge/net/bridge/br_sysfs_br.c	2007-02-21 14:39:50.000000000 -0800
@@ -310,6 +310,19 @@
 		   show_group_addr, store_group_addr);
 
 
+static ssize_t store_flush(struct device *d, struct device_attribute *attr,
+			   const char *buf, size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	br_fdb_delete_by_port(br, NULL, 0);
+	return len;
+}
+static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
+
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -328,6 +341,7 @@
 	&dev_attr_topology_change_timer.attr,
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
+	&dev_attr_flush.attr,
 	NULL
 };
 
--- bridge.orig/net/bridge/br_sysfs_if.c	2007-02-21 14:29:25.000000000 -0800
+++ bridge/net/bridge/br_sysfs_if.c	2007-02-21 14:29:27.000000000 -0800
@@ -137,6 +137,13 @@
 }
 static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
 
+static ssize_t store_flush(struct net_bridge_port *p, unsigned long v)
+{
+	br_fdb_delete_by_port(p->br, p, 0); // Don't delete local entry
+	return 0;
+}
+static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
+
 static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -152,6 +159,7 @@
 	&brport_attr_message_age_timer,
 	&brport_attr_forward_delay_timer,
 	&brport_attr_hold_timer,
+	&brport_attr_flush,
 	NULL
 };
 
--- bridge.orig/net/bridge/br_fdb.c	2007-02-21 14:28:49.000000000 -0800
+++ bridge/net/bridge/br_fdb.c	2007-02-21 14:29:27.000000000 -0800
@@ -128,7 +128,11 @@
 	mod_timer(&br->gc_timer, jiffies + HZ/10);
 }
 
-
+/*
+ * Flush all forwarding entries for a port.
+ * if p is NULL, it means flush for all ports.
+ * if do_all is non-zero, then flush static entries as well
+ */
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p,
 			   int do_all)
@@ -142,7 +146,8 @@
 		hlist_for_each_safe(h, g, &br->hash[i]) {
 			struct net_bridge_fdb_entry *f
 				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-			if (f->dst != p)
+
+			if (p && f->dst != p)
 				continue;
 
 			if (f->is_static && !do_all)
@@ -152,7 +157,7 @@
 			 * then when one port is deleted, assign
 			 * the local entry to other port
 			 */
-			if (f->is_local) {
+			if (p && f->is_local) {
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&

--
Stephen Hemminger <shemminger@linux-foundation.org>


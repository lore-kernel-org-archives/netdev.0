From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/4] bridge: add template for bridge port flags
Date: Tue, 13 Nov 2012 09:53:06 -0800
Message-ID: <20121113175346.592260730@vyatta.com>
References: <20121113175304.628996029@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:36665 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566Ab2KMR56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:57:58 -0500
Content-Disposition: inline; filename=brport-flags-sysfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide macro to build sysfs data structures and functions
for accessing flag bits.  If flag bits change do netlink
notification.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_sysfs_if.c	2012-11-12 07:58:35.411139543 -0800
+++ b/net/bridge/br_sysfs_if.c	2012-11-12 13:52:42.319080923 -0800
@@ -34,6 +34,28 @@ const struct brport_attribute brport_att
 	.store	= _store,					\
 };
 
+#define BRPORT_ATTR_FLAG(_name, _mask)				\
+static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
+{								\
+	return sprintf(buf, "%d\n", !!(p->flags & _mask));	\
+}								\
+static int store_##_name(struct net_bridge_port *p, unsigned long v) \
+{								\
+	unsigned long flags = p->flags;				\
+	if (v)							\
+		flags |= _mask;					\
+	else							\
+		flags &= ~_mask;				\
+	if (flags != p->flags) {				\
+		p->flags = flags;				\
+		br_ifinfo_notify(RTM_NEWLINK, p);		\
+	}							\
+	return 0;						\
+}								\
+static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
+		   show_##_name, store_##_name)
+
+
 static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->path_cost);
@@ -133,21 +155,7 @@ static int store_flush(struct net_bridge
 }
 static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 
-static ssize_t show_hairpin_mode(struct net_bridge_port *p, char *buf)
-{
-	int hairpin_mode = (p->flags & BR_HAIRPIN_MODE) ? 1 : 0;
-	return sprintf(buf, "%d\n", hairpin_mode);
-}
-static int store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
-{
-	if (v)
-		p->flags |= BR_HAIRPIN_MODE;
-	else
-		p->flags &= ~BR_HAIRPIN_MODE;
-	return 0;
-}
-static BRPORT_ATTR(hairpin_mode, S_IRUGO | S_IWUSR,
-		   show_hairpin_mode, store_hairpin_mode);
+BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] bridge: make path cost setting persistent
Date: Wed, 21 Feb 2007 14:41:10 -0800
Message-ID: <20070221224255.790379091@linux-foundation.org>
References: <20070221224107.741532037@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org,
	Srinivas Aji <Aji_Srinivas@emc.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53666 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423241AbXBUWr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 17:47:26 -0500
Content-Disposition: inline; filename=bridge-admin-path-cost.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to keep an STP port path cost which was set by a user from
replaced by the link-speed based path cost whenever the link goes down
and comes back up. 
An admin_cost field is added to struct net_bridge_port to
indicate whether there is a user specified path cost.

Signed-Off-By: Srinivas Aji <Aji_Srinivas@emc.com>
Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>

---
 net/bridge/br_if.c       |    8 ++++----
 net/bridge/br_private.h  |    2 ++
 net/bridge/br_stp.c      |    1 -
 net/bridge/br_stp_if.c   |   13 ++++++++++---
 net/bridge/br_sysfs_if.c |   10 +++++++---
 5 files changed, 23 insertions(+), 11 deletions(-)

--- bridge.orig/net/bridge/br_if.c	2007-02-21 14:28:51.000000000 -0800
+++ bridge/net/bridge/br_if.c	2007-02-21 14:29:25.000000000 -0800
@@ -33,7 +33,7 @@
  * ethtool, use ethtool_ops.  Also, since driver might sleep need to
  * not be holding any locks.
  */
-static int port_cost(struct net_device *dev)
+int br_port_cost(struct net_device *dev)
 {
 	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
 	struct ifreq ifr;
@@ -82,8 +82,8 @@
 	struct net_device *dev = p->dev;
 	struct net_bridge *br = p->br;
 
-	if (netif_carrier_ok(dev))
-		p->path_cost = port_cost(dev);
+	if (netif_carrier_ok(dev) && p->admin_cost == 0)
+		p->path_cost = br_port_cost(dev);
 
 	if (netif_running(br->dev)) {
 		spin_lock_bh(&br->lock);
@@ -260,7 +260,7 @@
 	p->br = br;
 	dev_hold(dev);
 	p->dev = dev;
-	p->path_cost = port_cost(dev);
+	p->path_cost = br_port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
 	br_init_port(p);
--- bridge.orig/net/bridge/br_private.h	2007-02-21 14:29:09.000000000 -0800
+++ bridge/net/bridge/br_private.h	2007-02-21 14:29:25.000000000 -0800
@@ -73,6 +73,7 @@
 	bridge_id			designated_root;
 	bridge_id			designated_bridge;
 	u32				path_cost;
+	u32				admin_cost;
 	u32				designated_cost;
 
 	struct timer_list		forward_delay_timer;
@@ -169,6 +170,7 @@
 		      int clone);
 
 /* br_if.c */
+extern int br_port_cost(struct net_device *dev);
 extern void br_port_carrier_check(struct net_bridge_port *p);
 extern int br_add_bridge(const char *name);
 extern int br_del_bridge(const char *name);
--- bridge.orig/net/bridge/br_stp.c	2007-02-21 14:28:51.000000000 -0800
+++ bridge/net/bridge/br_stp.c	2007-02-21 14:29:25.000000000 -0800
@@ -39,7 +39,6 @@
 
 }
 
-/* called under bridge lock */
 struct net_bridge_port *br_get_port(struct net_bridge *br, u16 port_no)
 {
 	struct net_bridge_port *p;
--- bridge.orig/net/bridge/br_stp_if.c	2007-02-21 14:28:51.000000000 -0800
+++ bridge/net/bridge/br_stp_if.c	2007-02-21 14:29:25.000000000 -0800
@@ -212,12 +212,19 @@
 	}
 }
 
-/* called under bridge lock */
-void br_stp_set_path_cost(struct net_bridge_port *p, u32 path_cost)
+void br_stp_set_path_cost(struct net_bridge_port *p, u32 cost)
 {
-	p->path_cost = path_cost;
+	struct net_bridge *br = p->br;
+
+	ASSERT_RTNL();
+
+	p->admin_cost = cost;
+	p->path_cost = cost ? : br_port_cost(p->dev);
+
+	spin_lock_bh(&br->lock);
 	br_configuration_update(p->br);
 	br_port_state_selection(p->br);
+	spin_unlock_bh(&br->lock);
 }
 
 ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id)
--- bridge.orig/net/bridge/br_sysfs_if.c	2007-02-21 14:28:51.000000000 -0800
+++ bridge/net/bridge/br_sysfs_if.c	2007-02-21 14:29:25.000000000 -0800
@@ -184,9 +184,13 @@
 	if (endp != buf) {
 		rtnl_lock();
 		if (p->dev && p->br && brport_attr->store) {
-			spin_lock_bh(&p->br->lock);
-			ret = brport_attr->store(p, val);
-			spin_unlock_bh(&p->br->lock);
+			if (brport_attr->store == store_path_cost)
+				ret = store_path_cost(p, val);
+			else {
+				spin_lock_bh(&p->br->lock);
+				ret = brport_attr->store(p, val);
+				spin_unlock_bh(&p->br->lock);
+			}
 			if (ret == 0)
 				ret = count;
 		}

--
Stephen Hemminger <shemminger@linux-foundation.org>


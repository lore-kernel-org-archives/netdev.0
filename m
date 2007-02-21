From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] bridge: eliminate workqueue for carrier check
Date: Wed, 21 Feb 2007 14:41:09 -0800
Message-ID: <20070221224255.686055172@linux-foundation.org>
References: <20070221224107.741532037@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53661 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423234AbXBUWrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 17:47:22 -0500
Content-Disposition: inline; filename=bridge-port-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Having a work queue for checking carrier leads to lots of race issues.
Simpler to just get the cost when data structure is created and
update on change.

Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>

---
 net/bridge/br_if.c      |   30 +++++-------------------------
 net/bridge/br_notify.c  |   25 +++++++++++--------------
 net/bridge/br_private.h |    4 +---
 3 files changed, 17 insertions(+), 42 deletions(-)

--- bridge.orig/net/bridge/br_if.c	2007-02-21 10:57:06.000000000 -0800
+++ bridge/net/bridge/br_if.c	2007-02-21 14:28:51.000000000 -0800
@@ -77,26 +77,15 @@
  * Called from work queue to allow for calling functions that
  * might sleep (such as speed check), and to debounce.
  */
-static void port_carrier_check(struct work_struct *work)
+void br_port_carrier_check(struct net_bridge_port *p)
 {
-	struct net_bridge_port *p;
-	struct net_device *dev;
-	struct net_bridge *br;
-
-	dev = container_of(work, struct net_bridge_port,
-			   carrier_check.work)->dev;
-	work_release(work);
-
-	rtnl_lock();
-	p = dev->br_port;
-	if (!p)
-		goto done;
-	br = p->br;
+	struct net_device *dev = p->dev;
+	struct net_bridge *br = p->br;
 
 	if (netif_carrier_ok(dev))
 		p->path_cost = port_cost(dev);
 
-	if (br->dev->flags & IFF_UP) {
+	if (netif_running(br->dev)) {
 		spin_lock_bh(&br->lock);
 		if (netif_carrier_ok(dev)) {
 			if (p->state == BR_STATE_DISABLED)
@@ -107,9 +96,6 @@
 		}
 		spin_unlock_bh(&br->lock);
 	}
-done:
-	dev_put(dev);
-	rtnl_unlock();
 }
 
 static void release_nbp(struct kobject *kobj)
@@ -162,9 +148,6 @@
 
 	dev_set_promiscuity(dev, -1);
 
-	if (cancel_delayed_work(&p->carrier_check))
-		dev_put(dev);
-
 	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
 	spin_unlock_bh(&br->lock);
@@ -282,7 +265,6 @@
 	p->port_no = index;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
-	INIT_DELAYED_WORK_NAR(&p->carrier_check, port_carrier_check);
 	br_stp_port_timer_init(p);
 
 	kobject_init(&p->kobj);
@@ -446,12 +428,10 @@
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
-	if (schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE))
-		dev_hold(dev);
-
 	spin_unlock_bh(&br->lock);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
+
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
--- bridge.orig/net/bridge/br_notify.c	2007-02-21 10:57:06.000000000 -0800
+++ bridge/net/bridge/br_notify.c	2007-02-21 10:57:37.000000000 -0800
@@ -42,51 +42,48 @@
 
 	br = p->br;
 
-	spin_lock_bh(&br->lock);
 	switch (event) {
 	case NETDEV_CHANGEMTU:
 		dev_set_mtu(br->dev, br_min_mtu(br));
 		break;
 
 	case NETDEV_CHANGEADDR:
+		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
 		br_ifinfo_notify(RTM_NEWLINK, p);
 		br_stp_recalculate_bridge_id(br);
+		spin_unlock_bh(&br->lock);
 		break;
 
 	case NETDEV_CHANGE:
-		if (br->dev->flags & IFF_UP)
-			if (schedule_delayed_work(&p->carrier_check,
-						BR_PORT_DEBOUNCE))
-				dev_hold(dev);
+		br_port_carrier_check(p);
 		break;
 
 	case NETDEV_FEAT_CHANGE:
-		if (br->dev->flags & IFF_UP)
+		spin_lock_bh(&br->lock);
+		if (netif_running(br->dev))
 			br_features_recompute(br);
-
-		/* could do recursive feature change notification
-		 * but who would care??
-		 */
+		spin_unlock_bh(&br->lock);
 		break;
 
 	case NETDEV_DOWN:
+		spin_lock_bh(&br->lock);
 		if (br->dev->flags & IFF_UP)
 			br_stp_disable_port(p);
+		spin_unlock_bh(&br->lock);
 		break;
 
 	case NETDEV_UP:
+		spin_lock_bh(&br->lock);
 		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP))
 			br_stp_enable_port(p);
+		spin_unlock_bh(&br->lock);
 		break;
 
 	case NETDEV_UNREGISTER:
-		spin_unlock_bh(&br->lock);
 		br_del_if(br, dev);
-		goto done;
+		break;
 	}
-	spin_unlock_bh(&br->lock);
 
- done:
 	return NOTIFY_DONE;
 }
--- bridge.orig/net/bridge/br_private.h	2007-02-21 10:57:30.000000000 -0800
+++ bridge/net/bridge/br_private.h	2007-02-21 14:29:09.000000000 -0800
@@ -26,8 +26,6 @@
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
 
-#define BR_PORT_DEBOUNCE (HZ/10)
-
 #define BR_VERSION	"2.2"
 
 typedef struct bridge_id bridge_id;
@@ -81,7 +79,6 @@
 	struct timer_list		hold_timer;
 	struct timer_list		message_age_timer;
 	struct kobject			kobj;
-	struct delayed_work		carrier_check;
 	struct rcu_head			rcu;
 };
 
@@ -172,6 +169,7 @@
 		      int clone);
 
 /* br_if.c */
+extern void br_port_carrier_check(struct net_bridge_port *p);
 extern int br_add_bridge(const char *name);
 extern int br_del_bridge(const char *name);
 extern void br_cleanup_bridges(void);

--
Stephen Hemminger <shemminger@linux-foundation.org>


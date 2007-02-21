From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] bridge: eliminate port_check workqueue
Date: Wed, 21 Feb 2007 10:55:55 -0800
Message-ID: <20070221105555.4d1b40a6@freekitty>
References: <20070220221941.GA707@tv-sign.ru>
	<20070220162434.72d3ad7b@freekitty>
	<20070221082345.GB1662@ff.dom.local>
	<20070221142342.GB134@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422814AbXBUS40@vger.kernel.org>
In-Reply-To: <20070221142342.GB134@tv-sign.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is what I was suggesting by getting rid of the work queue completely.

---
 net/bridge/br_if.c      |   34 ++++++++--------------------------
 net/bridge/br_notify.c  |   25 +++++++++++--------------
 net/bridge/br_private.h |    5 ++---
 3 files changed, 21 insertions(+), 43 deletions(-)

--- bridge.orig/net/bridge/br_if.c	2007-02-21 10:22:46.000000000 -0800
+++ bridge/net/bridge/br_if.c	2007-02-21 10:53:25.000000000 -0800
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
@@ -442,16 +424,16 @@
 	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
-
+
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
-	if (schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE))
-		dev_hold(dev);
-
 	spin_unlock_bh(&br->lock);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
+
+	br_port_carrier_check(p);
+
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
--- bridge.orig/net/bridge/br_notify.c	2007-02-21 10:26:26.000000000 -0800
+++ bridge/net/bridge/br_notify.c	2007-02-21 10:34:12.000000000 -0800
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
--- bridge.orig/net/bridge/br_private.h	2007-02-21 10:22:43.000000000 -0800
+++ bridge/net/bridge/br_private.h	2007-02-21 10:53:49.000000000 -0800
@@ -16,7 +16,6 @@
 #define _BR_PRIVATE_H
 
 #include <linux/netdevice.h>
-#include <linux/miscdevice.h>
 #include <linux/if_bridge.h>
 
 #define BR_HASH_BITS 8
@@ -29,7 +28,7 @@
 
 #define BR_PORT_DEBOUNCE (HZ/10)
 
-#define BR_VERSION	"2.2"
+#define BR_VERSION	"2.3"
 
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
@@ -82,7 +81,6 @@
 	struct timer_list		hold_timer;
 	struct timer_list		message_age_timer;
 	struct kobject			kobj;
-	struct delayed_work		carrier_check;
 	struct rcu_head			rcu;
 };
 
@@ -173,6 +171,7 @@
 		      int clone);
 
 /* br_if.c */
+extern void br_port_carrier_check(struct net_bridge_port *p);
 extern int br_add_bridge(const char *name);
 extern int br_del_bridge(const char *name);
 extern void br_cleanup_bridges(void);

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix bridge timer race
Date: Tue, 22 Jul 2003 23:45:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722234508.0af40e80.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
   Christian Mautner <linux@mautner.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This should fix several startup/shutdown timer races in the bridge
driver.  Added some paranoia checks for dangling timers.

diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_device.c linux-2.5-bridge/net/bridge/br_device.c
--- linux-2.6.0-test1/net/bridge/br_device.c	2003-07-20 19:21:47.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_device.c	2003-07-22 08:51:22.000000000 -0400
@@ -110,23 +110,38 @@
 	return -1;
 }
 
+/* convert later to direct kfree */
+static void br_dev_free(struct net_device *dev)
+{
+	struct net_bridge *br = dev->priv;
+
+	WARN_ON(!list_empty(&br->port_list));
+	WARN_ON(!list_empty(&br->age_list));
+
+	BUG_ON(timer_pending(&br->hello_timer));
+	BUG_ON(timer_pending(&br->tcn_timer));
+	BUG_ON(timer_pending(&br->topology_change_timer));
+	BUG_ON(timer_pending(&br->gc_timer));
+
+	kfree(dev);
+}
 
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
 
+	ether_setup(dev);
+
 	dev->do_ioctl = br_dev_do_ioctl;
 	dev->get_stats = br_dev_get_stats;
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
-	dev->destructor = (void (*)(struct net_device *))kfree;
+	dev->destructor = br_dev_free;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
 	dev->accept_fastpath = br_dev_accept_fastpath;
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
 	dev->priv_flags = IFF_EBRIDGE;
-
-	ether_setup(dev);
 }
diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_if.c linux-2.5-bridge/net/bridge/br_if.c
--- linux-2.6.0-test1/net/bridge/br_if.c	2003-07-20 19:21:47.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_if.c	2003-07-22 09:54:57.000000000 -0400
@@ -41,6 +41,13 @@
 static void destroy_nbp(void *arg)
 {
 	struct net_bridge_port *p = arg;
+
+	p->dev->br_port = NULL;
+
+	BUG_ON(timer_pending(&p->message_age_timer));
+	BUG_ON(timer_pending(&p->forward_delay_timer));
+	BUG_ON(timer_pending(&p->hold_timer));
+
 	dev_put(p->dev);
 	kfree(p);
 }
@@ -53,16 +60,19 @@
 	br_stp_disable_port(p);
 
 	dev_set_promiscuity(dev, -1);
-	dev->br_port = NULL;
 
 	list_del_rcu(&p->list);
 
 	br_fdb_delete_by_port(p->br, p);
 
+	del_timer(&p->message_age_timer);
+	del_timer(&p->forward_delay_timer);
+	del_timer(&p->hold_timer);
+	
 	call_rcu(&p->rcu, destroy_nbp, p);
 }
 
-static void del_ifs(struct net_bridge *br)
+static void del_br(struct net_bridge *br)
 {
 	struct list_head *p, *n;
 
@@ -71,6 +81,10 @@
 		del_nbp(list_entry(p, struct net_bridge_port, list));
 	}
 	spin_unlock_bh(&br->lock);
+
+	del_timer_sync(&br->gc_timer);
+
+ 	unregister_netdevice(br->dev);
 }
 
 static struct net_bridge *new_nb(const char *name)
@@ -182,15 +196,14 @@
 		ret = -EBUSY;
 	} 
 
-	else {
-		del_ifs((struct net_bridge *) dev->priv);
-		unregister_netdevice(dev);
-	}
+	else 
+		del_br(dev->priv);
 
 	rtnl_unlock();
 	return ret;
 }
 
+/* called under bridge lock */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
@@ -205,7 +218,6 @@
 		return -ELOOP;
 
 	dev_hold(dev);
-	spin_lock_bh(&br->lock);
 	if ((p = new_nbp(br, dev)) == NULL) {
 		spin_unlock_bh(&br->lock);
 		dev_put(dev);
@@ -218,26 +230,21 @@
 	br_fdb_insert(br, p, dev->dev_addr, 1);
 	if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
 		br_stp_enable_port(p);
-	spin_unlock_bh(&br->lock);
 
 	return 0;
 }
 
+/* called under bridge lock */
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
-	int retval = 0;
 
-	spin_lock_bh(&br->lock);
 	if ((p = dev->br_port) == NULL || p->br != br)
-		retval = -EINVAL;
-	else {
-		del_nbp(p);
-		br_stp_recalculate_bridge_id(br);
-	}
-	spin_unlock_bh(&br->lock);
+		return -EINVAL;
 
-	return retval;
+	del_nbp(p);
+	br_stp_recalculate_bridge_id(br);
+	return 0;
 }
 
 int br_get_bridge_ifindices(int *indices, int num)
@@ -274,13 +281,8 @@
 	rtnl_lock();
 	for (dev = dev_base; dev; dev = nxt) {
 		nxt = dev->next;
-		if (dev->priv_flags & IFF_EBRIDGE) {
-			pr_debug("cleanup %s\n", dev->name);
-
-			del_ifs((struct net_bridge *) dev->priv);
-			
-			unregister_netdevice(dev);
-		}
+		if (dev->priv_flags & IFF_EBRIDGE)
+			del_br(dev->priv);
 	}
 	rtnl_unlock();
 
diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_ioctl.c linux-2.5-bridge/net/bridge/br_ioctl.c
--- linux-2.6.0-test1/net/bridge/br_ioctl.c	2003-07-20 19:21:47.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_ioctl.c	2003-07-21 21:33:04.000000000 -0400
@@ -59,10 +59,12 @@
 		if (dev == NULL)
 			return -EINVAL;
 
+		spin_lock_bh(&br->lock);
 		if (cmd == BRCTL_ADD_IF)
 			ret = br_add_if(br, dev);
 		else
 			ret = br_del_if(br, dev);
+		spin_unlock_bh(&br->lock);
 
 		dev_put(dev);
 		return ret;
diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_notify.c linux-2.5-bridge/net/bridge/br_notify.c
--- linux-2.6.0-test1/net/bridge/br_notify.c	2003-07-20 19:21:47.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_notify.c	2003-07-21 21:33:04.000000000 -0400
@@ -38,39 +38,27 @@
 
 	br = p->br;
 
+	spin_lock_bh(&br->lock);
 	switch (event) 
 	{
 	case NETDEV_CHANGEADDR:
-		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
 		br_stp_recalculate_bridge_id(br);
-		spin_unlock_bh(&br->lock);
-		break;
-
-	case NETDEV_GOING_DOWN:
-		/* extend the protocol to send some kind of notification? */
 		break;
 
 	case NETDEV_DOWN:
-		if (br->dev->flags & IFF_UP) {
-			spin_lock_bh(&br->lock);
-			br_stp_disable_port(p);
-			spin_unlock_bh(&br->lock);
-		}
+		br_stp_disable_port(p);
 		break;
 
 	case NETDEV_UP:
-		if (!(br->dev->flags & IFF_UP)) {
-			spin_lock_bh(&br->lock);
-			br_stp_enable_port(p);
-			spin_unlock_bh(&br->lock);
-		}
+		br_stp_enable_port(p);
 		break;
 
 	case NETDEV_UNREGISTER:
 		br_del_if(br, dev);
 		break;
 	}
+	spin_unlock_bh(&br->lock);
 
 	return NOTIFY_DONE;
 }
diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_stp_if.c linux-2.5-bridge/net/bridge/br_stp_if.c
--- linux-2.6.0-test1/net/bridge/br_stp_if.c	2003-07-20 19:21:48.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_stp_if.c	2003-07-22 00:44:46.000000000 -0400
@@ -43,8 +43,7 @@
 	struct net_bridge_port *p;
 
 	spin_lock_bh(&br->lock);
-	br->hello_timer.expires = jiffies + br->hello_time;
-	add_timer(&br->hello_timer);
+	mod_timer(&br->hello_timer, jiffies + br->hello_time);
 	br_config_bpdu_generation(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
@@ -74,8 +73,6 @@
 	del_timer_sync(&br->hello_timer);
 	del_timer_sync(&br->topology_change_timer);
 	del_timer_sync(&br->tcn_timer);
-	del_timer_sync(&br->gc_timer);
-
 }
 
 /* called under bridge lock */
diff -urN -X dontdiff linux-2.6.0-test1/net/bridge/br_stp_timer.c linux-2.5-bridge/net/bridge/br_stp_timer.c
--- linux-2.6.0-test1/net/bridge/br_stp_timer.c	2003-07-20 19:21:48.000000000 -0400
+++ linux-2.5-bridge/net/bridge/br_stp_timer.c	2003-07-22 10:08:46.000000000 -0400
@@ -43,8 +43,7 @@
 	if (br->dev->flags & IFF_UP) {
 		br_config_bpdu_generation(br);
 
-		br->hello_timer.expires = jiffies + br->hello_time;
-		add_timer(&br->hello_timer);
+		mod_timer(&br->hello_timer, jiffies + br->hello_time);
 	}
 	spin_unlock_bh(&br->lock);
 }
@@ -73,6 +72,8 @@
 	 * check is redundant. I'm leaving it in for now, though.
 	 */
 	spin_lock_bh(&br->lock);
+	if (p->state == BR_STATE_DISABLED)
+		goto unlock;
 	was_root = br_is_root_bridge(br);
 
 	br_become_designated_port(p);
@@ -80,6 +81,7 @@
 	br_port_state_selection(br);
 	if (br_is_root_bridge(br) && !was_root)
 		br_become_root_bridge(br);
+ unlock:
 	spin_unlock_bh(&br->lock);
 }
 
@@ -93,8 +95,8 @@
 	spin_lock_bh(&br->lock);
 	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
-		p->forward_delay_timer.expires = jiffies + br->forward_delay;
-		add_timer(&p->forward_delay_timer);
+		mod_timer(&p->forward_delay_timer,
+			  jiffies + br->forward_delay);
 	} else if (p->state == BR_STATE_LEARNING) {
 		p->state = BR_STATE_FORWARDING;
 		if (br_is_designated_for_some_port(br))
@@ -113,8 +115,7 @@
 	if (br->dev->flags & IFF_UP) {
 		br_transmit_tcn(br);
 	
-		br->tcn_timer.expires = jiffies + br->bridge_hello_time;
-		add_timer(&br->tcn_timer);
+		mod_timer(&br->tcn_timer,jiffies + br->bridge_hello_time);
 	}
 	spin_unlock_bh(&br->lock);
 }

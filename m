From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68] [BRIDGE] Use RCU for port table
Date: Fri, 25 Apr 2003 13:30:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030425133049.52238301.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use RCU instead of reader/writer lock for the port table. This is cleaner
and simpler, and eliminates dependency on brlock. This patch assumes earlier
patch that uses list_* macros.

Also, fixes issues with timer not getting write lock.  Introduced a little
bit of use of 'const' in the receive side path, just because paranoid that
receive code was only doing read's. Moved locking from dev_open into 
br_stp_enable_bridge because then disable/enable are symmetrical.

Tested with stresstest on 8-way SMP.


diff -Nru a/include/linux/list.h b/include/linux/list.h
--- a/include/linux/list.h	Fri Apr 25 13:19:34 2003
+++ b/include/linux/list.h	Fri Apr 25 13:19:34 2003
@@ -320,6 +320,21 @@
 	for (pos = (head)->next, n = pos->next; pos != (head); \
 		pos = n, ({ smp_read_barrier_depends(); 0;}), n = pos->next)
 
+/**
+ * list_for_each_entry_rcu	-	iterate over rcu list of given type
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_rcu(pos, head, member)			\
+	for (pos = list_entry((head)->next, typeof(*pos), member),	\
+		     prefetch(pos->member.next);			\
+	     &pos->member != (head); 					\
+	     pos = list_entry(pos->member.next, typeof(*pos), member),	\
+		     ({ smp_read_barrier_depends(); 0;}),		\
+		     prefetch(pos->member.next))
+
+
 /* 
  * Double linked lists with a single pointer list head. 
  * Mostly useful for hash tables where the two pointer list head is 
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_device.c	Fri Apr 25 13:19:34 2003
@@ -74,27 +74,20 @@
 
 int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_bridge *br;
 	int ret;
 
-	br = dev->priv;
-	read_lock(&br->lock);
+	rcu_read_lock();
 	ret = __br_dev_xmit(skb, dev);
-	read_unlock(&br->lock);
+	rcu_read_unlock();
 
 	return ret;
 }
 
 static int br_dev_open(struct net_device *dev)
 {
-	struct net_bridge *br;
-
 	netif_start_queue(dev);
 
-	br = dev->priv;
-	write_lock(&br->lock);
-	br_stp_enable_bridge(br);
-	write_unlock(&br->lock);
+	br_stp_enable_bridge(dev->priv);
 
 	return 0;
 }
diff -Nru a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_forward.c	Fri Apr 25 13:19:34 2003
@@ -21,7 +21,8 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
-static inline int should_deliver(struct net_bridge_port *p, struct sk_buff *skb)
+static inline int should_deliver(const struct net_bridge_port *p, 
+				 const struct sk_buff *skb)
 {
 	if (skb->dev == p->dev ||
 	    p->state != BR_STATE_FORWARDING)
@@ -52,7 +53,7 @@
 	return 0;
 }
 
-static void __br_deliver(struct net_bridge_port *to, struct sk_buff *skb)
+static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	skb->dev = to->dev;
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -62,7 +63,7 @@
 			br_forward_finish);
 }
 
-static void __br_forward(struct net_bridge_port *to, struct sk_buff *skb)
+static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	struct net_device *indev;
 
@@ -73,8 +74,8 @@
 			br_forward_finish);
 }
 
-/* called under bridge lock */
-void br_deliver(struct net_bridge_port *to, struct sk_buff *skb)
+/* called with rcu_read_lock */
+void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	if (should_deliver(to, skb)) {
 		__br_deliver(to, skb);
@@ -84,8 +85,8 @@
 	kfree_skb(skb);
 }
 
-/* called under bridge lock */
-void br_forward(struct net_bridge_port *to, struct sk_buff *skb)
+/* called with rcu_read_lock */
+void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	if (should_deliver(to, skb)) {
 		__br_forward(to, skb);
@@ -97,7 +98,8 @@
 
 /* called under bridge lock */
 static void br_flood(struct net_bridge *br, struct sk_buff *skb, int clone,
-	void (*__packet_hook)(struct net_bridge_port *p, struct sk_buff *skb))
+	void (*__packet_hook)(const struct net_bridge_port *p, 
+			      struct sk_buff *skb))
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
@@ -115,7 +117,7 @@
 
 	prev = NULL;
 
-	list_for_each_entry(p, &br->port_list, list) {
+	list_for_each_entry_rcu(p, &br->port_list, list) {
 		if (should_deliver(p, skb)) {
 			if (prev != NULL) {
 				struct sk_buff *skb2;
@@ -141,7 +143,8 @@
 	kfree_skb(skb);
 }
 
-/* called under bridge lock */
+
+/* called with rcu_read_lock */
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, int clone)
 {
 	br_flood(br, skb, clone, __br_deliver);
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_if.c	Fri Apr 25 13:19:34 2003
@@ -19,7 +19,6 @@
 #include <linux/inetdevice.h>
 #include <linux/module.h>
 #include <linux/rtnetlink.h>
-#include <linux/brlock.h>
 #include <net/sock.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -38,7 +37,14 @@
 	return 100;
 }
 
-/* called under BR_NETPROTO_LOCK and bridge lock */
+static void destroy_nbp(void *arg)
+{
+	struct net_bridge_port *p = arg;
+	dev_put(p->dev);
+	kfree(p);
+}
+
+/* called under bridge lock */
 static void del_nbp(struct net_bridge_port *p)
 {
 	struct net_device *dev = p->dev;
@@ -48,24 +54,22 @@
 	dev_set_promiscuity(dev, -1);
 	dev->br_port = NULL;
 
-	list_del(&p->list);
+	list_del_rcu(&p->list);
 
 	br_fdb_delete_by_port(p->br, p);
-	kfree(p);
-	dev_put(dev);
+
+	call_rcu(&p->rcu, destroy_nbp, p);
 }
 
 static void del_ifs(struct net_bridge *br)
 {
 	struct list_head *p, *n;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-	write_lock(&br->lock);
+	spin_lock_bh(&br->lock);
 	list_for_each_safe(p, n, &br->port_list) {
 		del_nbp(list_entry(p, struct net_bridge_port, list));
 	}
-	write_unlock(&br->lock);
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&br->lock);
 }
 
 static struct net_bridge *new_nb(const char *name)
@@ -87,7 +91,7 @@
 	ether_setup(dev);
 	br_dev_setup(dev);
 
-	br->lock = RW_LOCK_UNLOCKED;
+	br->lock = SPIN_LOCK_UNLOCKED;
 	INIT_LIST_HEAD(&br->port_list);
 	br->hash_lock = RW_LOCK_UNLOCKED;
 
@@ -145,7 +149,7 @@
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 
-	list_add(&p->list, &br->port_list);
+	list_add_rcu(&p->list, &br->port_list);
 
 	return p;
 }
@@ -207,9 +211,9 @@
 		return -ELOOP;
 
 	dev_hold(dev);
-	write_lock_bh(&br->lock);
+	spin_lock_bh(&br->lock);
 	if ((p = new_nbp(br, dev)) == NULL) {
-		write_unlock_bh(&br->lock);
+		spin_unlock_bh(&br->lock);
 		dev_put(dev);
 		return -EXFULL;
 	}
@@ -220,7 +224,7 @@
 	br_fdb_insert(br, p, dev->dev_addr, 1);
 	if ((br->dev.flags & IFF_UP) && (dev->flags & IFF_UP))
 		br_stp_enable_port(p);
-	write_unlock_bh(&br->lock);
+	spin_unlock_bh(&br->lock);
 
 	return 0;
 }
@@ -230,16 +234,14 @@
 	struct net_bridge_port *p;
 	int retval = 0;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-	write_lock(&br->lock);
+	spin_lock_bh(&br->lock);
 	if ((p = dev->br_port) == NULL || p->br != br)
 		retval = -EINVAL;
 	else {
 		del_nbp(p);
 		br_stp_recalculate_bridge_id(br);
 	}
-	write_unlock(&br->lock);
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&br->lock);
 
 	return retval;
 }
@@ -263,11 +265,11 @@
 {
 	struct net_bridge_port *p;
 
-	read_lock(&br->lock);
-	list_for_each_entry(p, &br->port_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(p, &br->port_list, list) {
 		ifindices[p->port_no] = p->dev->ifindex;
 	}
-	read_unlock(&br->lock);
+	rcu_read_unlock();
 }
 
 
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_input.c	Fri Apr 25 13:19:34 2003
@@ -59,15 +59,16 @@
 
 	dest = skb->mac.ethernet->h_dest;
 
+	rcu_read_lock();
 	p = skb->dev->br_port;
-	if (p == NULL)
-		goto err_nolock;
+	smp_read_barrier_depends();
 
-	br = p->br;
-	read_lock(&br->lock);
-	if (skb->dev->br_port == NULL)
-		goto err;
+	if (p == NULL || p->state == BR_STATE_DISABLED) {
+		kfree(skb);
+		goto out;
+	}
 
+	br = p->br;
 	passedup = 0;
 	if (br->dev.flags & IFF_PROMISC) {
 		struct sk_buff *skb2;
@@ -105,35 +106,20 @@
 	br_flood_forward(br, skb, 0);
 
 out:
-	read_unlock(&br->lock);
-	return 0;
-
-err:
-	read_unlock(&br->lock);
-err_nolock:
-	kfree_skb(skb);
+	rcu_read_unlock();
 	return 0;
 }
 
 int br_handle_frame(struct sk_buff *skb)
 {
-	struct net_bridge *br;
 	unsigned char *dest;
 	struct net_bridge_port *p;
 
 	dest = skb->mac.ethernet->h_dest;
 
+	rcu_read_lock();
 	p = skb->dev->br_port;
-	if (p == NULL)
-		goto err_nolock;
-
-	br = p->br;
-	read_lock(&br->lock);
-	if (skb->dev->br_port == NULL)
-		goto err;
-
-	if (!(br->dev.flags & IFF_UP) ||
-	    p->state == BR_STATE_DISABLED)
+	if (p == NULL || p->state == BR_STATE_DISABLED)
 		goto err;
 
 	if (skb->mac.ethernet->h_source[0] & 1)
@@ -141,34 +127,30 @@
 
 	if (p->state == BR_STATE_LEARNING ||
 	    p->state == BR_STATE_FORWARDING)
-		br_fdb_insert(br, p, skb->mac.ethernet->h_source, 0);
+		br_fdb_insert(p->br, p, skb->mac.ethernet->h_source, 0);
 
-	if (br->stp_enabled &&
+	if (p->br->stp_enabled &&
 	    !memcmp(dest, bridge_ula, 5) &&
-	    !(dest[5] & 0xF0))
-		goto handle_special_frame;
+	    !(dest[5] & 0xF0)) {
+		if (!dest[5]) 
+			br_stp_handle_bpdu(skb);
+		goto err;
+	}
 
 	if (p->state == BR_STATE_FORWARDING) {
 		if (br_should_route_hook && br_should_route_hook(&skb)) {
-			read_unlock(&br->lock);
+			rcu_read_unlock();
 			return -1;
 		}
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
-		read_unlock(&br->lock);
+		rcu_read_unlock();
 		return 0;
 	}
 
 err:
-	read_unlock(&br->lock);
-err_nolock:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
-
-handle_special_frame:
-	read_unlock(&br->lock);
-	if (!dest[5]) 
-		br_stp_handle_bpdu(skb);
-	goto err_nolock;
 }
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_ioctl.c	Fri Apr 25 13:19:34 2003
@@ -71,8 +71,8 @@
 	{
 		struct __bridge_info b;
 
-	        read_lock(&br->lock);
 		memset(&b, 0, sizeof(struct __bridge_info));
+		rcu_read_lock();
 		memcpy(&b.designated_root, &br->designated_root, 8);
 		memcpy(&b.bridge_id, &br->bridge_id, 8);
 		b.root_path_cost = br->root_path_cost;
@@ -92,7 +92,7 @@
 		b.tcn_timer_value = timer_residue(&br->tcn_timer);
 		b.topology_change_timer_value = timer_residue(&br->topology_change_timer);
 		b.gc_timer_value = timer_residue(&br->gc_timer);
-	        read_unlock(&br->lock);
+	        rcu_read_unlock();
 
 		if (copy_to_user((void *)arg0, &b, sizeof(b)))
 			return -EFAULT;
@@ -119,27 +119,27 @@
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		br->bridge_forward_delay = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
 			br->forward_delay = br->bridge_forward_delay;
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return 0;
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		br->bridge_hello_time = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
 			br->hello_time = br->bridge_hello_time;
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return 0;
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		br->bridge_max_age = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
 			br->max_age = br->bridge_max_age;
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return 0;
 
 	case BRCTL_SET_AGEING_TIME:
@@ -155,9 +155,9 @@
 		struct __port_info p;
 		struct net_bridge_port *pt;
 
-		read_lock(&br->lock);
+		rcu_read_lock();
 		if ((pt = br_get_port(br, arg1)) == NULL) {
-			read_unlock(&br->lock);
+			rcu_read_unlock();
 			return -EINVAL;
 		}
 
@@ -175,7 +175,7 @@
 		p.forward_delay_timer_value = timer_residue(&pt->forward_delay_timer);
 		p.hold_timer_value = timer_residue(&pt->hold_timer);
 
-		read_unlock(&br->lock);
+		rcu_read_unlock();
 
 		if (copy_to_user((void *)arg0, &p, sizeof(p)))
 			return -EFAULT;
@@ -188,9 +188,9 @@
 		return 0;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		br_stp_set_bridge_priority(br, arg0);
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return 0;
 
 	case BRCTL_SET_PORT_PRIORITY:
@@ -198,12 +198,12 @@
 		struct net_bridge_port *p;
 		int ret = 0;
 
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, arg0)) == NULL) 
 			ret = -EINVAL;
 		else
 			br_stp_set_port_priority(p, arg1);
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return ret;
 	}
 
@@ -212,12 +212,12 @@
 		struct net_bridge_port *p;
 		int ret = 0;
 
-		write_lock(&br->lock);
+		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, arg0)) == NULL)
 			ret = -EINVAL;
 		else
 			br_stp_set_path_cost(p, arg1);
-		write_unlock(&br->lock);
+		spin_unlock_bh(&br->lock);
 		return ret;
 	}
 
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_notify.c	Fri Apr 25 13:19:34 2003
@@ -41,10 +41,10 @@
 	switch (event) 
 	{
 	case NETDEV_CHANGEADDR:
-		write_lock_bh(&br->lock);
+		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
 		br_stp_recalculate_bridge_id(br);
-		write_unlock_bh(&br->lock);
+		spin_unlock_bh(&br->lock);
 		break;
 
 	case NETDEV_GOING_DOWN:
@@ -53,17 +53,17 @@
 
 	case NETDEV_DOWN:
 		if (br->dev.flags & IFF_UP) {
-			write_lock_bh(&br->lock);
+			spin_lock_bh(&br->lock);
 			br_stp_disable_port(p);
-			write_unlock_bh(&br->lock);
+			spin_unlock_bh(&br->lock);
 		}
 		break;
 
 	case NETDEV_UP:
 		if (!(br->dev.flags & IFF_UP)) {
-			write_lock_bh(&br->lock);
+			spin_lock_bh(&br->lock);
 			br_stp_enable_port(p);
-			write_unlock_bh(&br->lock);
+			spin_unlock_bh(&br->lock);
 		}
 		break;
 
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_private.h	Fri Apr 25 13:19:34 2003
@@ -75,11 +75,13 @@
 	struct br_timer			forward_delay_timer;
 	struct br_timer			hold_timer;
 	struct br_timer			message_age_timer;
+
+	struct rcu_head			rcu;
 };
 
 struct net_bridge
 {
-	rwlock_t			lock;
+	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		dev;
 	struct net_device_stats		statistics;
@@ -137,10 +139,10 @@
 		   int is_local);
 
 /* br_forward.c */
-extern void br_deliver(struct net_bridge_port *to,
+extern void br_deliver(const struct net_bridge_port *to,
 		struct sk_buff *skb);
 extern int br_dev_queue_push_xmit(struct sk_buff *skb);
-extern void br_forward(struct net_bridge_port *to,
+extern void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb);
 extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br,
diff -Nru a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_stp_bpdu.c	Fri Apr 25 13:19:34 2003
@@ -143,7 +143,7 @@
 	p = skb->dev->br_port;
 	br = p->br;
 
-	write_lock_bh(&br->lock);
+	spin_lock_bh(&br->lock);
 	if (p->state == BR_STATE_DISABLED 
 	    || !(br->dev.flags & IFF_UP)
 	    || !br->stp_enabled 
@@ -192,5 +192,5 @@
 		goto out;
 	}
  out:
-	write_unlock_bh(&br->lock);
+	spin_unlock_bh(&br->lock);
 }
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_stp_if.c	Fri Apr 25 13:19:34 2003
@@ -44,6 +44,7 @@
 	struct net_bridge_port *p;
 	struct timer_list *timer = &br->tick;
 
+	spin_lock_bh(&br->lock);
 	init_timer(timer);
 	timer->data = (unsigned long) br;
 	timer->function = br_tick;
@@ -59,6 +60,7 @@
 	}
 
 	br_timer_set(&br->gc_timer, jiffies);
+	spin_unlock_bh(&br->lock);
 }
 
 /* NO locks held */
@@ -66,7 +68,7 @@
 {
 	struct net_bridge_port *p;
 
-	write_lock(&br->lock);
+	spin_lock_bh(&br->lock);
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
 	br_timer_clear(&br->hello_timer);
@@ -79,7 +81,7 @@
 		if (p->state != BR_STATE_DISABLED)
 			br_stp_disable_port(p);
 	}
-	write_unlock(&br->lock);
+	spin_unlock_bh(&br->lock);
 
 	del_timer_sync(&br->tick);
 }
diff -Nru a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
--- a/net/bridge/br_stp_timer.c	Fri Apr 25 13:19:34 2003
+++ b/net/bridge/br_stp_timer.c	Fri Apr 25 13:19:34 2003
@@ -169,10 +169,10 @@
 {
 	struct net_bridge *br = (struct net_bridge *)__data;
 
-	read_lock(&br->lock);
-	br_check_timers(br);
-	read_unlock(&br->lock);
-
+	if (spin_trylock_bh(&br->lock)) {
+		br_check_timers(br);
+		spin_unlock_bh(&br->lock);
+	}
 	br->tick.expires = jiffies + 1;
 	add_timer(&br->tick);
 }

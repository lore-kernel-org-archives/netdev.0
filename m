From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68] [BRIDGE] Use list_ macros for bridge port list.
Date: Thu, 24 Apr 2003 13:54:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030424135431.11cf3fe6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This replaces the singly linked list in net_bridge structure with the
list_ macro's (doubly linked).   It makes deleting an interface easier
since no lookup required; but the real motivation is to setup for the
next step where bridge rwlock is replaced with spin_lock and RCU.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1130  -> 1.1131 
#	 net/bridge/br_stp.c	1.3     -> 1.4    
#	net/bridge/br_private.h	1.8     -> 1.9    
#	net/bridge/br_forward.c	1.7     -> 1.8    
#	net/bridge/br_stp_timer.c	1.1     -> 1.2    
#	net/bridge/br_stp_if.c	1.4     -> 1.5    
#	  net/bridge/br_if.c	1.8     -> 1.9    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/24	shemminger@dev4-009.pdx.osdl.net	1.1131
# ebr-port-list.patch
# --------------------------------------------
#
diff -Nru a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_forward.c	Thu Apr 24 13:41:28 2003
@@ -99,7 +99,7 @@
 static void br_flood(struct net_bridge *br, struct sk_buff *skb, int clone,
 	void (*__packet_hook)(struct net_bridge_port *p, struct sk_buff *skb))
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 	struct net_bridge_port *prev;
 
 	if (clone) {
@@ -115,8 +115,10 @@
 
 	prev = NULL;
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (should_deliver(p, skb)) {
 			if (prev != NULL) {
 				struct sk_buff *skb2;
@@ -132,8 +134,6 @@
 
 			prev = p;
 		}
-
-		p = p->next;
 	}
 
 	if (prev != NULL) {
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_if.c	Thu Apr 24 13:41:28 2003
@@ -39,42 +39,31 @@
 }
 
 /* called under BR_NETPROTO_LOCK and bridge lock */
-static int __br_del_if(struct net_bridge *br, struct net_device *dev)
+static void del_nbp(struct net_bridge_port *p)
 {
-	struct net_bridge_port *p;
-	struct net_bridge_port **pptr;
-
-	if ((p = dev->br_port) == NULL)
-		return -EINVAL;
+	struct net_device *dev = p->dev;
 
 	br_stp_disable_port(p);
 
 	dev_set_promiscuity(dev, -1);
 	dev->br_port = NULL;
 
-	pptr = &br->port_list;
-	while (*pptr != NULL) {
-		if (*pptr == p) {
-			*pptr = p->next;
-			break;
-		}
-
-		pptr = &((*pptr)->next);
-	}
+	list_del(&p->list);
 
-	br_fdb_delete_by_port(br, p);
+	br_fdb_delete_by_port(p->br, p);
 	kfree(p);
 	dev_put(dev);
-
-	return 0;
 }
 
 static void del_ifs(struct net_bridge *br)
 {
+	struct list_head *p, *n;
+
 	br_write_lock_bh(BR_NETPROTO_LOCK);
 	write_lock(&br->lock);
-	while (br->port_list != NULL)
-		__br_del_if(br, br->port_list->dev);
+	list_for_each_safe(p, n, &br->port_list) {
+		del_nbp(list_entry(p, struct net_bridge_port, list));
+	}
 	write_unlock(&br->lock);
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
@@ -99,6 +88,7 @@
 	br_dev_setup(dev);
 
 	br->lock = RW_LOCK_UNLOCKED;
+	INIT_LIST_HEAD(&br->port_list);
 	br->hash_lock = RW_LOCK_UNLOCKED;
 
 	br->bridge_id.prio[0] = 0x80;
@@ -155,8 +145,7 @@
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 
-	p->next = br->port_list;
-	br->port_list = p;
+	list_add(&p->list, &br->port_list);
 
 	return p;
 }
@@ -238,12 +227,17 @@
 
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
-	int retval;
+	struct net_bridge_port *p;
+	int retval = 0;
 
 	br_write_lock_bh(BR_NETPROTO_LOCK);
 	write_lock(&br->lock);
-	retval = __br_del_if(br, dev);
-	br_stp_recalculate_bridge_id(br);
+	if ((p = dev->br_port) == NULL || p->br != br)
+		retval = -EINVAL;
+	else {
+		del_nbp(p);
+		br_stp_recalculate_bridge_id(br);
+	}
 	write_unlock(&br->lock);
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 
@@ -267,13 +261,13 @@
 
 void br_get_port_ifindices(struct net_bridge *br, int *ifindices)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 
 	read_lock(&br->lock);
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 		ifindices[p->port_no] = p->dev->ifindex;
-		p = p->next;
 	}
 	read_unlock(&br->lock);
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_private.h	Thu Apr 24 13:41:28 2003
@@ -55,9 +55,9 @@
 
 struct net_bridge_port
 {
-	struct net_bridge_port		*next;
 	struct net_bridge		*br;
 	struct net_device		*dev;
+	struct list_head		list;
 	int				port_no;
 
 	/* STP */
@@ -80,7 +80,7 @@
 struct net_bridge
 {
 	rwlock_t			lock;
-	struct net_bridge_port		*port_list;
+	struct list_head		port_list;
 	struct net_device		dev;
 	struct net_device_stats		statistics;
 	rwlock_t			hash_lock;
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_stp.c	Thu Apr 24 13:41:28 2003
@@ -38,14 +38,14 @@
 /* called under bridge lock */
 struct net_bridge_port *br_get_port(struct net_bridge *br, int port_no)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
+
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 
-	p = br->port_list;
-	while (p != NULL) {
 		if (p->port_no == port_no)
 			return p;
-
-		p = p->next;
 	}
 
 	return NULL;
@@ -104,17 +104,18 @@
 /* called under bridge lock */
 static void br_root_selection(struct net_bridge *br)
 {
+	struct list_head *l;
 	struct net_bridge_port *p;
 	int root_port;
 
 	root_port = 0;
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		p = list_entry(l, struct net_bridge_port, list);
+
 		if (br_should_become_root_port(p, root_port))
 			root_port = p->port_no;
 
-		p = p->next;
 	}
 
 	br->root_port = root_port;
@@ -239,15 +240,16 @@
 /* called under bridge lock */
 static void br_designated_port_selection(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
+
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 
-	p = br->port_list;
-	while (p != NULL) {
 		if (p->state != BR_STATE_DISABLED &&
 		    br_should_become_designated_port(p))
 			br_become_designated_port(p);
 
-		p = p->next;
 	}
 }
 
@@ -311,15 +313,15 @@
 /* called under bridge lock */
 void br_config_bpdu_generation(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
+
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 
-	p = br->port_list;
-	while (p != NULL) {
 		if (p->state != BR_STATE_DISABLED &&
 		    br_is_designated_port(p))
 			br_transmit_config(p);
-
-		p = p->next;
 	}
 }
 
@@ -389,10 +391,12 @@
 /* called under bridge lock */
 void br_port_state_selection(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
+
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 
-	p = br->port_list;
-	while (p != NULL) {
 		if (p->state != BR_STATE_DISABLED) {
 			if (p->port_no == br->root_port) {
 				p->config_pending = 0;
@@ -407,8 +411,6 @@
 				br_make_blocking(p);
 			}
 		}
-
-		p = p->next;
 	}
 }
 
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_stp_if.c	Thu Apr 24 13:41:28 2003
@@ -41,7 +41,7 @@
 /* called under bridge lock */
 void br_stp_enable_bridge(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 	struct timer_list *timer = &br->tick;
 
 	init_timer(timer);
@@ -53,12 +53,12 @@
 	br_timer_set(&br->hello_timer, jiffies);
 	br_config_bpdu_generation(br);
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (p->dev->flags & IFF_UP)
 			br_stp_enable_port(p);
-
-		p = p->next;
 	}
 
 	br_timer_set(&br->gc_timer, jiffies);
@@ -67,7 +67,7 @@
 /* NO locks held */
 void br_stp_disable_bridge(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 
 	write_lock(&br->lock);
 	br->topology_change = 0;
@@ -78,12 +78,12 @@
 	br_timer_clear(&br->gc_timer);
 	br_fdb_cleanup(br);
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (p->state != BR_STATE_DISABLED)
 			br_stp_disable_port(p);
-
-		p = p->next;
 	}
 	write_unlock(&br->lock);
 
@@ -126,7 +126,7 @@
 static void br_stp_change_bridge_id(struct net_bridge *br, unsigned char *addr)
 {
 	unsigned char oldaddr[6];
-	struct net_bridge_port *p;
+	struct list_head *l;
 	int wasroot;
 
 	wasroot = br_is_root_bridge(br);
@@ -135,15 +135,16 @@
 	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
 	memcpy(br->dev.dev_addr, addr, ETH_ALEN);
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (!memcmp(p->designated_bridge.addr, oldaddr, ETH_ALEN))
 			memcpy(p->designated_bridge.addr, addr, ETH_ALEN);
 
 		if (!memcmp(p->designated_root.addr, oldaddr, ETH_ALEN))
 			memcpy(p->designated_root.addr, addr, ETH_ALEN);
 
-		p = p->next;
 	}
 
 	br_configuration_update(br);
@@ -158,17 +159,18 @@
 void br_stp_recalculate_bridge_id(struct net_bridge *br)
 {
 	unsigned char *addr;
-	struct net_bridge_port *p;
+	struct list_head *l;
 
 	addr = br_mac_zero;
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (addr == br_mac_zero ||
 		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
 			addr = p->dev->dev_addr;
 
-		p = p->next;
 	}
 
 	if (memcmp(br->bridge_id.addr, addr, ETH_ALEN))
@@ -178,20 +180,21 @@
 /* called under bridge lock */
 void br_stp_set_bridge_priority(struct net_bridge *br, int newprio)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 	int wasroot;
 
 	wasroot = br_is_root_bridge(br);
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
+
 		if (p->state != BR_STATE_DISABLED &&
 		    br_is_designated_port(p)) {
 			p->designated_bridge.prio[0] = (newprio >> 8) & 0xFF;
 			p->designated_bridge.prio[1] = newprio & 0xFF;
 		}
 
-		p = p->next;
 	}
 
 	br->bridge_id.prio[0] = (newprio >> 8) & 0xFF;
diff -Nru a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
--- a/net/bridge/br_stp_timer.c	Thu Apr 24 13:41:28 2003
+++ b/net/bridge/br_stp_timer.c	Thu Apr 24 13:41:28 2003
@@ -30,15 +30,14 @@
 /* called under bridge lock */
 static int br_is_designated_for_some_port(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 		if (p->state != BR_STATE_DISABLED &&
 		    !memcmp(&p->designated_bridge, &br->bridge_id, 8))
 			return 1;
-
-		p = p->next;
 	}
 
 	return 0;
@@ -140,7 +139,7 @@
 /* called under bridge lock */
 static void br_check_timers(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	struct list_head *l;
 
 	if (br_timer_has_expired(&br->gc_timer, br->gc_interval)) {
 		br_timer_set(&br->gc_timer, jiffies);
@@ -162,12 +161,11 @@
 		br_topology_change_timer_expired(br);
 	}
 
-	p = br->port_list;
-	while (p != NULL) {
+	list_for_each(l, &br->port_list) {
+		struct net_bridge_port *p
+			= list_entry(l, struct net_bridge_port, list);
 		if (p->state != BR_STATE_DISABLED)
 			br_check_port_timers(p);
-
-		p = p->next;
 	}
 }
 

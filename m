From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] Bridge timer performance enhancement
Date: Fri, 9 May 2003 13:20:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509132012.598602ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@math.leidenuniv.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Existing bridge code was waking up every jiffie then scanning internal
structures for what internal timers had expired.  This is a waste of
CPU especially given the efficient kernel timer interface. With this
patch, code should scale better to 1000's of forward table entries and
many ports.

- Change Ethernet bridge to use multiple kernel timers.
- Prevent restarting timers during shutdown.
- Keep ordered list of forward table entries, so oldest entries
  show up first; then only older entries need to be scanned.
- Automatically adjust GC interval to the next entry to delete
  existing parameter is ignored.

No visible changes to the API or other devices.

diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_fdb.c linux-2.5-bridge/net/bridge/br_fdb.c
--- linux-2.5-b1/net/bridge/br_fdb.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_fdb.c	2003-05-09 09:37:28.000000000 -0700
@@ -20,25 +20,19 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-static __inline__ unsigned long __timeout(struct net_bridge *br)
+/* if topology_changing then use forward_delay (default 15 sec)
+ * otherwise keep longer (default 5 minutes)
+ */
+static __inline__ unsigned long hold_time(const struct net_bridge *br)
 {
-	unsigned long timeout;
-
-	timeout = jiffies - br->ageing_time;
-	if (br->topology_change)
-		timeout = jiffies - br->forward_delay;
-
-	return timeout;
+	return br->topology_change ? br->forward_delay : br->ageing_time;
 }
 
-static __inline__ int has_expired(struct net_bridge *br,
-				  struct net_bridge_fdb_entry *fdb)
+static __inline__ int has_expired(const struct net_bridge *br,
+				  const struct net_bridge_fdb_entry *fdb)
 {
-	if (!fdb->is_static &&
-	    time_before_eq(fdb->ageing_timer, __timeout(br)))
-		return 1;
-
-	return 0;
+	return !fdb->is_static 
+		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
 
 static __inline__ void copy_fdb(struct __fdb_entry *ent, 
@@ -52,7 +46,7 @@ static __inline__ void copy_fdb(struct _
 		: ((jiffies - f->ageing_timer) * USER_HZ) / HZ;
 }
 
-static __inline__ int br_mac_hash(unsigned char *mac)
+static __inline__ int br_mac_hash(const unsigned char *mac)
 {
 	unsigned long x;
 
@@ -68,7 +62,14 @@ static __inline__ int br_mac_hash(unsign
 	return x & (BR_HASH_SIZE - 1);
 }
 
-void br_fdb_changeaddr(struct net_bridge_port *p, unsigned char *newaddr)
+static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
+{
+	hlist_del(&f->hlist);
+	list_del(&f->age_list);
+	br_fdb_put(f);
+}
+
+void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br;
 	int i;
@@ -98,25 +99,29 @@ void br_fdb_changeaddr(struct net_bridge
 	write_unlock_bh(&br->hash_lock);
 }
 
-void br_fdb_cleanup(struct net_bridge *br)
+void br_fdb_cleanup(unsigned long _data)
 {
-	int i;
-	unsigned long timeout;
-
-	timeout = __timeout(br);
+	struct net_bridge *br = (struct net_bridge *)_data;
+	struct list_head *l, *n;
+	unsigned long delay;
 
 	write_lock_bh(&br->hash_lock);
-	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct hlist_node *h, *g;
-		
-		hlist_for_each_safe(h, g, &br->hash[i]) {
-			struct net_bridge_fdb_entry *f
-				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-			if (!f->is_static &&
-			    time_before_eq(f->ageing_timer, timeout)) {
-				hlist_del(&f->hlist);
-				br_fdb_put(f);
+	delay = hold_time(br);
+
+	list_for_each_safe(l, n, &br->age_list) {
+		struct net_bridge_fdb_entry *f
+			= list_entry(l, struct net_bridge_fdb_entry, age_list);
+		unsigned long expires = f->ageing_timer + delay;
+
+		if (time_before_eq(expires, jiffies)) {
+			if (!f->is_static) {
+				pr_debug("expire age %lu jiffies %lu\n",
+					 f->ageing_timer, jiffies);
+				fdb_delete(f);
 			}
+		} else {
+			mod_timer(&br->gc_timer, expires);
+			break;
 		}
 	}
 	write_unlock_bh(&br->hash_lock);
@@ -134,8 +139,7 @@ void br_fdb_delete_by_port(struct net_br
 			struct net_bridge_fdb_entry *f
 				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (f->dst == p) {
-				hlist_del(&f->hlist);
-				br_fdb_put(f);
+				fdb_delete(f);
 			}
 		}
 	}
@@ -237,55 +241,46 @@ int br_fdb_get_entries(struct net_bridge
 	return num;
 }
 
-static __inline__ void __fdb_possibly_replace(struct net_bridge_fdb_entry *fdb,
-					      struct net_bridge_port *source,
-					      int is_local)
-{
-	if (!fdb->is_static || is_local) {
-		fdb->dst = source;
-		fdb->is_local = is_local;
-		fdb->is_static = is_local;
-		fdb->ageing_timer = jiffies;
-	}
-}
-
-void br_fdb_insert(struct net_bridge *br,
-		   struct net_bridge_port *source,
-		   unsigned char *addr,
-		   int is_local)
+void br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		   const unsigned char *addr, int is_local)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
-	int hash;
-
-	hash = br_mac_hash(addr);
+	int hash = br_mac_hash(addr);
 
 	write_lock_bh(&br->hash_lock);
 	hlist_for_each(h, &br->hash[hash]) {
 		fdb = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 		if (!fdb->is_local &&
 		    !memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
-			__fdb_possibly_replace(fdb, source, is_local);
-			write_unlock_bh(&br->hash_lock);
-			return;
+			if (likely(!fdb->is_static || is_local)) {
+				/* move to end of age list */
+				list_del(&fdb->age_list);
+				goto update;
+			}
+			goto out;
 		}
-
 	}
 
 	fdb = kmalloc(sizeof(*fdb), GFP_ATOMIC);
-	if (fdb == NULL) {
-		write_unlock_bh(&br->hash_lock);
-		return;
-	}
+	if (fdb == NULL) 
+		goto out;
 
 	memcpy(fdb->addr.addr, addr, ETH_ALEN);
 	atomic_set(&fdb->use_count, 1);
+	hlist_add_head(&fdb->hlist, &br->hash[hash]);
+
+	if (!timer_pending(&br->gc_timer)) {
+		br->gc_timer.expires = jiffies + hold_time(br);
+		add_timer(&br->gc_timer);
+	}
+
+ update:
 	fdb->dst = source;
 	fdb->is_local = is_local;
 	fdb->is_static = is_local;
 	fdb->ageing_timer = jiffies;
-
-	hlist_add_head(&fdb->hlist, &br->hash[hash]);
-
+	list_add_tail(&fdb->age_list, &br->age_list);
+ out:
 	write_unlock_bh(&br->hash_lock);
 }
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_if.c linux-2.5-bridge/net/bridge/br_if.c
--- linux-2.5-b1/net/bridge/br_if.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_if.c	2003-05-09 09:37:28.000000000 -0700
@@ -84,8 +84,6 @@ static struct net_bridge *new_nb(const c
 	memset(br, 0, sizeof(*br));
 	dev = &br->dev;
 
-	init_timer(&br->tick);
-
 	strncpy(dev->name, name, IFNAMSIZ);
 	dev->priv = br;
 	dev->priv_flags = IFF_EBRIDGE;
@@ -109,12 +107,10 @@ static struct net_bridge *new_nb(const c
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
-	br_timer_clear(&br->hello_timer);
-	br_timer_clear(&br->tcn_timer);
-	br_timer_clear(&br->topology_change_timer);
-
 	br->ageing_time = 300 * HZ;
-	br->gc_interval = 4 * HZ;
+	INIT_LIST_HEAD(&br->age_list);
+
+	br_stp_timer_init(br);
 
 	return br;
 }
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_ioctl.c linux-2.5-bridge/net/bridge/br_ioctl.c
--- linux-2.5-b1/net/bridge/br_ioctl.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_ioctl.c	2003-05-09 09:37:28.000000000 -0700
@@ -32,9 +32,10 @@ static inline unsigned long ticks_to_use
 }
 
 /* Report time remaining in user HZ  */
-static unsigned long timer_residue(const struct br_timer *timer)
+static unsigned long timer_residue(const struct timer_list *timer)
 {
-	return ticks_to_user(timer->running ? (jiffies - timer->expires) : 0);
+	return ticks_to_user(timer_pending(timer) 
+			     ? (timer->expires - jiffies) : 0);
 }
 
 static int br_ioctl_device(struct net_bridge *br,
@@ -87,7 +88,6 @@ static int br_ioctl_device(struct net_br
 		b.root_port = br->root_port;
 		b.stp_enabled = br->stp_enabled;
 		b.ageing_time = ticks_to_user(br->ageing_time);
-		b.gc_interval = ticks_to_user(br->gc_interval);
 		b.hello_timer_value = timer_residue(&br->hello_timer);
 		b.tcn_timer_value = timer_residue(&br->tcn_timer);
 		b.topology_change_timer_value = timer_residue(&br->topology_change_timer);
@@ -146,8 +146,7 @@ static int br_ioctl_device(struct net_br
 		br->ageing_time = user_to_ticks(arg0);
 		return 0;
 
-	case BRCTL_SET_GC_INTERVAL:
-		br->gc_interval = user_to_ticks(arg0);
+	case BRCTL_SET_GC_INTERVAL:	 /* no longer used */
 		return 0;
 
 	case BRCTL_GET_PORT_INFO:
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_private.h linux-2.5-bridge/net/bridge/br_private.h
--- linux-2.5-b1/net/bridge/br_private.h	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_private.h	2003-05-09 09:37:28.000000000 -0700
@@ -18,7 +18,6 @@
 #include <linux/netdevice.h>
 #include <linux/miscdevice.h>
 #include <linux/if_bridge.h>
-#include "br_private_timer.h"
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -44,10 +43,11 @@ struct mac_addr
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
-	atomic_t			use_count;
-	mac_addr			addr;
 	struct net_bridge_port		*dst;
+	struct list_head		age_list;
+	atomic_t			use_count;
 	unsigned long			ageing_timer;
+	mac_addr			addr;
 	unsigned			is_local:1;
 	unsigned			is_static:1;
 };
@@ -71,10 +71,9 @@ struct net_bridge_port
 	unsigned			config_pending:1;
 	int				priority;
 
-	struct br_timer			forward_delay_timer;
-	struct br_timer			hold_timer;
-	struct br_timer			message_age_timer;
-
+	struct timer_list		forward_delay_timer;
+	struct timer_list		hold_timer;
+	struct timer_list		message_age_timer;
 	struct rcu_head			rcu;
 };
 
@@ -86,7 +85,7 @@ struct net_bridge
 	struct net_device_stats		statistics;
 	rwlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-	struct timer_list		tick;
+	struct list_head		age_list;
 
 	/* STP */
 	bridge_id			designated_root;
@@ -103,13 +102,12 @@ struct net_bridge
 	unsigned			topology_change:1;
 	unsigned			topology_change_detected:1;
 
-	struct br_timer			hello_timer;
-	struct br_timer			tcn_timer;
-	struct br_timer			topology_change_timer;
-	struct br_timer			gc_timer;
+	struct timer_list		hello_timer;
+	struct timer_list		tcn_timer;
+	struct timer_list		topology_change_timer;
+	struct timer_list		gc_timer;
 
 	int				ageing_time;
-	int				gc_interval;
 };
 
 extern struct notifier_block br_device_notifier;
@@ -128,8 +126,8 @@ extern int br_dev_xmit(struct sk_buff *s
 
 /* br_fdb.c */
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
-		       unsigned char *newaddr);
-extern void br_fdb_cleanup(struct net_bridge *br);
+			      const unsigned char *newaddr);
+extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 			   struct net_bridge_port *p);
 extern struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br,
@@ -140,9 +138,9 @@ extern int  br_fdb_get_entries(struct ne
 			int maxnum,
 			int offset);
 extern void br_fdb_insert(struct net_bridge *br,
-		   struct net_bridge_port *source,
-		   unsigned char *addr,
-		   int is_local);
+			  struct net_bridge_port *source,
+			  const unsigned char *addr,
+			  int is_local);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,
@@ -188,10 +186,10 @@ extern int br_netfilter_init(void);
 extern void br_netfilter_fini(void);
 
 /* br_stp.c */
+extern void br_log_state(const struct net_bridge_port *p);
 extern struct net_bridge_port *br_get_port(struct net_bridge *br,
 				    int port_no);
 extern void br_init_port(struct net_bridge_port *p);
-extern port_id br_make_port_id(struct net_bridge_port *p);
 extern void br_become_designated_port(struct net_bridge_port *p);
 
 /* br_stp_if.c */
@@ -210,4 +208,8 @@ extern void br_stp_set_path_cost(struct 
 /* br_stp_bpdu.c */
 extern void br_stp_handle_bpdu(struct sk_buff *skb);
 
+/* br_stp_timer.c */
+extern void br_stp_timer_init(struct net_bridge *br);
+extern void br_stp_port_timer_init(struct net_bridge_port *p);
+
 #endif
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_private_stp.h linux-2.5-bridge/net/bridge/br_private_stp.h
--- linux-2.5-b1/net/bridge/br_private_stp.h	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_private_stp.h	2003-05-07 15:11:52.000000000 -0700
@@ -47,7 +47,6 @@ extern void br_configuration_update(stru
 extern void br_port_state_selection(struct net_bridge *);
 extern void br_received_config_bpdu(struct net_bridge_port *p, struct br_config_bpdu *bpdu);
 extern void br_received_tcn_bpdu(struct net_bridge_port *p);
-extern void br_tick(unsigned long __data);
 extern void br_transmit_config(struct net_bridge_port *p);
 extern void br_transmit_tcn(struct net_bridge *br);
 extern void br_topology_change_detection(struct net_bridge *br);
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_private_timer.h linux-2.5-bridge/net/bridge/br_private_timer.h
--- linux-2.5-b1/net/bridge/br_private_timer.h	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_private_timer.h	1969-12-31 16:00:00.000000000 -0800
@@ -1,54 +0,0 @@
-/*
- *	Linux ethernet bridge
- *
- *	Authors:
- *	Lennert Buytenhek		<buytenh@gnu.org>
- *
- *	$Id: br_private_timer.h,v 1.1 2000/02/18 16:47:13 davem Exp $
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- */
-
-#ifndef _BR_PRIVATE_TIMER_H
-#define _BR_PRIVATE_TIMER_H
-
-struct br_timer
-{
-	int running;
-	unsigned long expires;
-};
-
-extern __inline__ void br_timer_clear(struct br_timer *t)
-{
-	t->running = 0;
-}
-
-extern __inline__ unsigned long br_timer_get_residue(struct br_timer *t)
-{
-	if (t->running)
-		return jiffies - t->expires;
-
-	return 0;
-}
-
-extern __inline__ void br_timer_set(struct br_timer *t, unsigned long x)
-{
-	t->expires = x;
-	t->running = 1;
-}
-
-extern __inline__ int br_timer_is_running(struct br_timer *t)
-{
-	return t->running;
-}
-
-extern __inline__ int br_timer_has_expired(struct br_timer *t, unsigned long to)
-{
-	return t->running && time_after_eq(jiffies, t->expires + to);
-}
-
-
-#endif
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_stp.c linux-2.5-bridge/net/bridge/br_stp.c
--- linux-2.5-b1/net/bridge/br_stp.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_stp.c	2003-05-09 09:26:05.000000000 -0700
@@ -12,7 +12,6 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  */
-
 #include <linux/kernel.h>
 #include <linux/if_bridge.h>
 #include <linux/smp_lock.h>
@@ -20,6 +19,18 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
+static const char *br_port_state_names[] = {
+	"disabled", "learning", "forwarding", "blocking",
+};
+
+void br_log_state(const struct net_bridge_port *p)
+{
+	pr_info("%s: port %d(%s) entering %s state\n",
+		p->br->dev.name, p->port_no, p->dev->name, 
+		br_port_state_names[p->state]);
+
+}
+
 /* called under bridge lock */
 struct net_bridge_port *br_get_port(struct net_bridge *br, int port_no)
 {
@@ -34,7 +45,8 @@ struct net_bridge_port *br_get_port(stru
 }
 
 /* called under bridge lock */
-static int br_should_become_root_port(struct net_bridge_port *p, int root_port)
+static int br_should_become_root_port(const struct net_bridge_port *p, 
+				      int root_port)
 {
 	struct net_bridge *br;
 	struct net_bridge_port *rp;
@@ -116,9 +128,12 @@ void br_become_root_bridge(struct net_br
 	br->hello_time = br->bridge_hello_time;
 	br->forward_delay = br->bridge_forward_delay;
 	br_topology_change_detection(br);
-	br_timer_clear(&br->tcn_timer);
-	br_config_bpdu_generation(br);
-	br_timer_set(&br->hello_timer, jiffies);
+	del_timer(&br->tcn_timer);
+
+	if (br->dev.flags & IFF_UP) {
+		br_config_bpdu_generation(br);
+		mod_timer(&br->hello_timer, jiffies + br->hello_time);
+	}
 }
 
 /* called under bridge lock */
@@ -127,7 +142,8 @@ void br_transmit_config(struct net_bridg
 	struct br_config_bpdu bpdu;
 	struct net_bridge *br;
 
-	if (br_timer_is_running(&p->hold_timer)) {
+
+	if (timer_pending(&p->hold_timer)) {
 		p->config_pending = 1;
 		return;
 	}
@@ -142,12 +158,11 @@ void br_transmit_config(struct net_bridg
 	bpdu.port_id = p->port_id;
 	bpdu.message_age = 0;
 	if (!br_is_root_bridge(br)) {
-		struct net_bridge_port *root;
-		unsigned long age;
+		struct net_bridge_port *root
+			= br_get_port(br, br->root_port);
+		bpdu.max_age = root->message_age_timer.expires - jiffies;
 
-		root = br_get_port(br, br->root_port);
-		age = br_timer_get_residue(&root->message_age_timer) + 1;
-		bpdu.message_age = age;
+		if (bpdu.max_age <= 0) bpdu.max_age = 1;
 	}
 	bpdu.max_age = br->max_age;
 	bpdu.hello_time = br->hello_time;
@@ -157,22 +172,26 @@ void br_transmit_config(struct net_bridg
 
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
-	br_timer_set(&p->hold_timer, jiffies);
+	
+	mod_timer(&p->hold_timer, jiffies + BR_HOLD_TIME);
 }
 
 /* called under bridge lock */
-static void br_record_config_information(struct net_bridge_port *p, struct br_config_bpdu *bpdu)
+static inline void br_record_config_information(struct net_bridge_port *p, 
+						const struct br_config_bpdu *bpdu)
 {
 	p->designated_root = bpdu->root;
 	p->designated_cost = bpdu->root_path_cost;
 	p->designated_bridge = bpdu->bridge_id;
 	p->designated_port = bpdu->port_id;
 
-	br_timer_set(&p->message_age_timer, jiffies - bpdu->message_age);
+	mod_timer(&p->message_age_timer, jiffies 
+		  + (p->br->max_age - bpdu->message_age));
 }
 
 /* called under bridge lock */
-static void br_record_config_timeout_values(struct net_bridge *br, struct br_config_bpdu *bpdu)
+static inline void br_record_config_timeout_values(struct net_bridge *br, 
+					    const struct br_config_bpdu *bpdu)
 {
 	br->max_age = bpdu->max_age;
 	br->hello_time = bpdu->hello_time;
@@ -187,7 +206,7 @@ void br_transmit_tcn(struct net_bridge *
 }
 
 /* called under bridge lock */
-static int br_should_become_designated_port(struct net_bridge_port *p)
+static int br_should_become_designated_port(const struct net_bridge_port *p)
 {
 	struct net_bridge *br;
 	int t;
@@ -261,25 +280,28 @@ static int br_supersedes_port_info(struc
 }
 
 /* called under bridge lock */
-static void br_topology_change_acknowledged(struct net_bridge *br)
+static inline void br_topology_change_acknowledged(struct net_bridge *br)
 {
 	br->topology_change_detected = 0;
-	br_timer_clear(&br->tcn_timer);
+	del_timer(&br->tcn_timer);
 }
 
 /* called under bridge lock */
 void br_topology_change_detection(struct net_bridge *br)
 {
-	printk(KERN_INFO "%s: topology change detected", br->dev.name);
+	if (!(br->dev.flags & IFF_UP))
+		return;
 
+	pr_info("%s: topology change detected", br->dev.name);
 	if (br_is_root_bridge(br)) {
 		printk(", propagating");
 		br->topology_change = 1;
-		br_timer_set(&br->topology_change_timer, jiffies);
+		mod_timer(&br->topology_change_timer, jiffies
+			  + br->bridge_forward_delay + br->bridge_max_age);
 	} else if (!br->topology_change_detected) {
 		printk(", sending tcn bpdu");
 		br_transmit_tcn(br);
-		br_timer_set(&br->tcn_timer, jiffies);
+		mod_timer(&br->tcn_timer, jiffies + br->bridge_hello_time);
 	}
 
 	printk("\n");
@@ -299,7 +321,7 @@ void br_config_bpdu_generation(struct ne
 }
 
 /* called under bridge lock */
-static void br_reply(struct net_bridge_port *p)
+static inline void br_reply(struct net_bridge_port *p)
 {
 	br_transmit_config(p);
 }
@@ -323,6 +345,7 @@ void br_become_designated_port(struct ne
 	p->designated_port = p->port_id;
 }
 
+
 /* called under bridge lock */
 static void br_make_blocking(struct net_bridge_port *p)
 {
@@ -332,11 +355,9 @@ static void br_make_blocking(struct net_
 		    p->state == BR_STATE_LEARNING)
 			br_topology_change_detection(p->br);
 
-		printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-		       p->br->dev.name, p->port_no, p->dev->name, "blocking");
-
 		p->state = BR_STATE_BLOCKING;
-		br_timer_clear(&p->forward_delay_timer);
+		br_log_state(p);
+		del_timer(&p->forward_delay_timer);
 	}
 }
 
@@ -345,20 +366,12 @@ static void br_make_forwarding(struct ne
 {
 	if (p->state == BR_STATE_BLOCKING) {
 		if (p->br->stp_enabled) {
-			printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-			       p->br->dev.name, p->port_no, p->dev->name,
-			       "listening");
-
 			p->state = BR_STATE_LISTENING;
 		} else {
-			printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-			       p->br->dev.name, p->port_no, p->dev->name,
-			       "learning");
-
 			p->state = BR_STATE_LEARNING;
 		}
-		br_timer_set(&p->forward_delay_timer, jiffies);
-	}
+		br_log_state(p);
+		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);	}
 }
 
 /* called under bridge lock */
@@ -373,7 +386,7 @@ void br_port_state_selection(struct net_
 				p->topology_change_ack = 0;
 				br_make_forwarding(p);
 			} else if (br_is_designated_port(p)) {
-				br_timer_clear(&p->message_age_timer);
+				del_timer(&p->message_age_timer);
 				br_make_forwarding(p);
 			} else {
 				p->config_pending = 0;
@@ -381,11 +394,12 @@ void br_port_state_selection(struct net_
 				br_make_blocking(p);
 			}
 		}
+
 	}
 }
 
 /* called under bridge lock */
-static void br_topology_change_acknowledge(struct net_bridge_port *p)
+static inline void br_topology_change_acknowledge(struct net_bridge_port *p)
 {
 	p->topology_change_ack = 1;
 	br_transmit_config(p);
@@ -396,20 +410,23 @@ void br_received_config_bpdu(struct net_
 {
 	struct net_bridge *br;
 	int was_root;
-
+ 
 	br = p->br;
 	was_root = br_is_root_bridge(br);
+
 	if (br_supersedes_port_info(p, bpdu)) {
 		br_record_config_information(p, bpdu);
 		br_configuration_update(br);
 		br_port_state_selection(br);
 
 		if (!br_is_root_bridge(br) && was_root) {
-			br_timer_clear(&br->hello_timer);
+			del_timer(&br->hello_timer);
 			if (br->topology_change_detected) {
-				br_timer_clear(&br->topology_change_timer);
+				del_timer(&br->topology_change_timer);
 				br_transmit_tcn(br);
-				br_timer_set(&br->tcn_timer, jiffies);
+
+				mod_timer(&br->tcn_timer, 
+					  jiffies + br->bridge_hello_time);
 			}
 		}
 
@@ -428,7 +445,7 @@ void br_received_config_bpdu(struct net_
 void br_received_tcn_bpdu(struct net_bridge_port *p)
 {
 	if (br_is_designated_port(p)) {
-		printk(KERN_INFO "%s: received tcn bpdu on port %i(%s)\n",
+		pr_info("%s: received tcn bpdu on port %i(%s)\n",
 		       p->br->dev.name, p->port_no, p->dev->name);
 
 		br_topology_change_detection(p->br);
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_stp_if.c linux-2.5-bridge/net/bridge/br_stp_if.c
--- linux-2.5-b1/net/bridge/br_stp_if.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_stp_if.c	2003-05-09 09:37:28.000000000 -0700
@@ -20,7 +20,7 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-__u16 br_make_port_id(struct net_bridge_port *p)
+static inline __u16 br_make_port_id(const struct net_bridge_port *p)
 {
 	return (p->priority << 8) | p->port_no;
 }
@@ -33,33 +33,25 @@ void br_init_port(struct net_bridge_port
 	p->state = BR_STATE_BLOCKING;
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
-	br_timer_clear(&p->message_age_timer);
-	br_timer_clear(&p->forward_delay_timer);
-	br_timer_clear(&p->hold_timer);
+
+	br_stp_port_timer_init(p);
 }
 
 /* called under bridge lock */
 void br_stp_enable_bridge(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	struct timer_list *timer = &br->tick;
 
 	spin_lock_bh(&br->lock);
-	init_timer(timer);
-	timer->data = (unsigned long) br;
-	timer->function = br_tick;
-	timer->expires = jiffies + 1;
-	add_timer(timer);
-
-	br_timer_set(&br->hello_timer, jiffies);
+	br->hello_timer.expires = jiffies + br->hello_time;
+	add_timer(&br->hello_timer);
 	br_config_bpdu_generation(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (p->dev->flags & IFF_UP)
 			br_stp_enable_port(p);
-	}
 
-	br_timer_set(&br->gc_timer, jiffies);
+	}
 	spin_unlock_bh(&br->lock);
 }
 
@@ -68,22 +60,22 @@ void br_stp_disable_bridge(struct net_br
 {
 	struct net_bridge_port *p;
 
-	spin_lock_bh(&br->lock);
-	br->topology_change = 0;
-	br->topology_change_detected = 0;
-	br_timer_clear(&br->hello_timer);
-	br_timer_clear(&br->topology_change_timer);
-	br_timer_clear(&br->tcn_timer);
-	br_timer_clear(&br->gc_timer);
-	br_fdb_cleanup(br);
-
+	spin_lock(&br->lock);
 	list_for_each_entry(p, &br->port_list, list) {
 		if (p->state != BR_STATE_DISABLED)
 			br_stp_disable_port(p);
+
 	}
-	spin_unlock_bh(&br->lock);
 
-	del_timer_sync(&br->tick);
+	br->topology_change = 0;
+	br->topology_change_detected = 0;
+	spin_unlock(&br->lock);
+
+	del_timer_sync(&br->hello_timer);
+	del_timer_sync(&br->topology_change_timer);
+	del_timer_sync(&br->tcn_timer);
+	del_timer_sync(&br->gc_timer);
+
 }
 
 /* called under bridge lock */
@@ -108,10 +100,13 @@ void br_stp_disable_port(struct net_brid
 	p->state = BR_STATE_DISABLED;
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
-	br_timer_clear(&p->message_age_timer);
-	br_timer_clear(&p->forward_delay_timer);
-	br_timer_clear(&p->hold_timer);
+
+	del_timer(&p->message_age_timer);
+	del_timer(&p->forward_delay_timer);
+	del_timer(&p->hold_timer);
+
 	br_configuration_update(br);
+
 	br_port_state_selection(br);
 
 	if (br_is_root_bridge(br) && !wasroot)
diff -urNp -X dontdiff linux-2.5-b1/net/bridge/br_stp_timer.c linux-2.5-bridge/net/bridge/br_stp_timer.c
--- linux-2.5-b1/net/bridge/br_stp_timer.c	2003-05-09 11:58:20.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_stp_timer.c	2003-05-09 09:37:28.000000000 -0700
@@ -20,51 +20,59 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-static void dump_bridge_id(bridge_id *id)
-{
-	printk("%.2x%.2x.%.2x:%.2x:%.2x:%.2x:%.2x:%.2x", id->prio[0],
-	       id->prio[1], id->addr[0], id->addr[1], id->addr[2], id->addr[3],
-	       id->addr[4], id->addr[5]);
-}
-
 /* called under bridge lock */
-static int br_is_designated_for_some_port(struct net_bridge *br)
+static int br_is_designated_for_some_port(const struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (p->state != BR_STATE_DISABLED &&
-		    !memcmp(&p->designated_bridge, &br->bridge_id, 8))
+		    !memcmp(&p->designated_bridge, &br->bridge_id, 8)) 
 			return 1;
 	}
 
 	return 0;
 }
 
-/* called under bridge lock */
-static void br_hello_timer_expired(struct net_bridge *br)
+static void br_hello_timer_expired(unsigned long arg)
 {
-	br_config_bpdu_generation(br);
-	br_timer_set(&br->hello_timer, jiffies);
+	struct net_bridge *br = (struct net_bridge *)arg;
+	
+	pr_debug("%s: hello timer expired\n", br->dev.name);
+	spin_lock_bh(&br->lock);
+	if (br->dev.flags & IFF_UP) {
+		br_config_bpdu_generation(br);
+
+		br->hello_timer.expires = jiffies + br->hello_time;
+		add_timer(&br->hello_timer);
+	}
+	spin_unlock_bh(&br->lock);
 }
 
-/* called under bridge lock */
-static void br_message_age_timer_expired(struct net_bridge_port *p)
+static void br_message_age_timer_expired(unsigned long arg)
 {
-	struct net_bridge *br;
+	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge *br = p->br;
+	const bridge_id *id = &p->designated_bridge;
 	int was_root;
 
-	br = p->br;
-	printk(KERN_INFO "%s: ", br->dev.name);
-	printk("neighbour ");
-	dump_bridge_id(&p->designated_bridge);
-	printk(" lost on port %i(%s)\n", p->port_no, p->dev->name);
+	if (p->state == BR_STATE_DISABLED)
+		return;
+
+	
+	pr_info("%s: neighbor %.2x%.2x.%.2x:%.2x:%.2x:%.2x:%.2x:%.2x lost on port %d(%s)\n",
+		br->dev.name, 
+		id->prio[0], id->prio[1], 
+		id->addr[0], id->addr[1], id->addr[2], 
+		id->addr[3], id->addr[4], id->addr[5],
+		p->port_no, p->dev->name);
 
 	/*
 	 * According to the spec, the message age timer cannot be
 	 * running when we are the root bridge. So..  this was_root
 	 * check is redundant. I'm leaving it in for now, though.
 	 */
+	spin_lock_bh(&br->lock);
 	was_root = br_is_root_bridge(br);
 
 	br_become_designated_port(p);
@@ -72,107 +80,101 @@ static void br_message_age_timer_expired
 	br_port_state_selection(br);
 	if (br_is_root_bridge(br) && !was_root)
 		br_become_root_bridge(br);
+	spin_unlock_bh(&br->lock);
 }
 
-/* called under bridge lock */
-static void br_forward_delay_timer_expired(struct net_bridge_port *p)
+static void br_forward_delay_timer_expired(unsigned long arg)
 {
-	if (p->state == BR_STATE_LISTENING) {
-		printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-		       p->br->dev.name, p->port_no, p->dev->name, "learning");
+	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge *br = p->br;
 
+	pr_debug("%s: %d(%s) forward delay timer\n",
+		 br->dev.name, p->port_no, p->dev->name);
+	spin_lock_bh(&br->lock);
+	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
-		br_timer_set(&p->forward_delay_timer, jiffies);
+		p->forward_delay_timer.expires = jiffies + br->forward_delay;
+		add_timer(&p->forward_delay_timer);
 	} else if (p->state == BR_STATE_LEARNING) {
-		printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-		       p->br->dev.name, p->port_no, p->dev->name, "forwarding");
-
 		p->state = BR_STATE_FORWARDING;
-		if (br_is_designated_for_some_port(p->br))
-			br_topology_change_detection(p->br);
+		if (br_is_designated_for_some_port(br))
+			br_topology_change_detection(br);
 	}
+	br_log_state(p);
+	spin_unlock_bh(&br->lock);
 }
 
-/* called under bridge lock */
-static void br_tcn_timer_expired(struct net_bridge *br)
+static void br_tcn_timer_expired(unsigned long arg)
 {
-	printk(KERN_INFO "%s: retransmitting tcn bpdu\n", br->dev.name);
-	br_transmit_tcn(br);
-	br_timer_set(&br->tcn_timer, jiffies);
+	struct net_bridge *br = (struct net_bridge *) arg;
+
+	pr_debug("%s: tcn timer expired\n", br->dev.name);
+	spin_lock_bh(&br->lock);
+	if (br->dev.flags & IFF_UP) {
+		br_transmit_tcn(br);
+	
+		br->tcn_timer.expires = jiffies + br->bridge_hello_time;
+		add_timer(&br->tcn_timer);
+	}
+	spin_unlock_bh(&br->lock);
 }
 
-/* called under bridge lock */
-static void br_topology_change_timer_expired(struct net_bridge *br)
+static void br_topology_change_timer_expired(unsigned long arg)
 {
+	struct net_bridge *br = (struct net_bridge *) arg;
+
+	pr_debug("%s: topo change timer expired\n", br->dev.name);
+	spin_lock_bh(&br->lock);
 	br->topology_change_detected = 0;
 	br->topology_change = 0;
+	spin_unlock_bh(&br->lock);
 }
 
-/* called under bridge lock */
-static void br_hold_timer_expired(struct net_bridge_port *p)
+static void br_hold_timer_expired(unsigned long arg)
 {
+	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+
+	pr_debug("%s: %d(%s) hold timer expired\n", 
+		 p->br->dev.name,  p->port_no, p->dev->name);
+
+	spin_lock_bh(&p->br->lock);
 	if (p->config_pending)
 		br_transmit_config(p);
+	spin_unlock_bh(&p->br->lock);
 }
 
-/* called under bridge lock */
-static void br_check_port_timers(struct net_bridge_port *p)
+static inline void br_timer_init(struct timer_list *timer,
+			  void (*_function)(unsigned long),
+			  unsigned long _data)
 {
-	if (br_timer_has_expired(&p->message_age_timer, p->br->max_age)) {
-		br_timer_clear(&p->message_age_timer);
-		br_message_age_timer_expired(p);
-	}
-
-	if (br_timer_has_expired(&p->forward_delay_timer, p->br->forward_delay)) {
-		br_timer_clear(&p->forward_delay_timer);
-		br_forward_delay_timer_expired(p);
-	}
-
-	if (br_timer_has_expired(&p->hold_timer, BR_HOLD_TIME)) {
-		br_timer_clear(&p->hold_timer);
-		br_hold_timer_expired(p);
-	}
+	init_timer(timer);
+	timer->function = _function;
+	timer->data = _data;
 }
 
-/* called under bridge lock */
-static void br_check_timers(struct net_bridge *br)
+void br_stp_timer_init(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
+	br_timer_init(&br->hello_timer, br_hello_timer_expired,
+		      (unsigned long) br);
 
-	if (br_timer_has_expired(&br->gc_timer, br->gc_interval)) {
-		br_timer_set(&br->gc_timer, jiffies);
-		br_fdb_cleanup(br);
-	}
+	br_timer_init(&br->tcn_timer, br_tcn_timer_expired, 
+		      (unsigned long) br);
 
-	if (br_timer_has_expired(&br->hello_timer, br->hello_time)) {
-		br_timer_clear(&br->hello_timer);
-		br_hello_timer_expired(br);
-	}
-
-	if (br_timer_has_expired(&br->tcn_timer, br->bridge_hello_time)) {
-		br_timer_clear(&br->tcn_timer);
-		br_tcn_timer_expired(br);
-	}
-
-	if (br_timer_has_expired(&br->topology_change_timer, br->bridge_forward_delay + br->bridge_max_age)) {
-		br_timer_clear(&br->topology_change_timer);
-		br_topology_change_timer_expired(br);
-	}
+	br_timer_init(&br->topology_change_timer,
+		      br_topology_change_timer_expired,
+		      (unsigned long) br);
 
-	list_for_each_entry(p, &br->port_list, list) {
-		if (p->state != BR_STATE_DISABLED)
-			br_check_port_timers(p);
-	}
+	br_timer_init(&br->gc_timer, br_fdb_cleanup, (unsigned long) br);
 }
 
-void br_tick(unsigned long __data)
+void br_stp_port_timer_init(struct net_bridge_port *p)
 {
-	struct net_bridge *br = (struct net_bridge *)__data;
+	br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
+		      (unsigned long) p);
 
-	if (spin_trylock_bh(&br->lock)) {
-		br_check_timers(br);
-		spin_unlock_bh(&br->lock);
-	}
-	br->tick.expires = jiffies + 1;
-	add_timer(&br->tick);
-}
+	br_timer_init(&p->forward_delay_timer, br_forward_delay_timer_expired,
+		      (unsigned long) p);
+		      
+	br_timer_init(&p->hold_timer, br_hold_timer_expired,
+		      (unsigned long) p);
+}	

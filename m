From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) bridge: get rid of threaded link for forwarding
 timeout
Date: Thu, 10 Mar 2005 15:44:34 -0800
Message-ID: <20050310154434.52f8f561@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6, I changed the bridge forwarding table timeout code to keep
a threaded list of in order entries. Well, it turns out that this is
a performance hit because we end up constantly moving entries around
in the list.  Later patch changes this to be in place update with RCU.

This version just uses a 100ms garbage collection timer.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- a/net/bridge/br_fdb.c	2005-03-10 15:06:38 -08:00
+++ b/net/bridge/br_fdb.c	2005-03-10 15:06:38 -08:00
@@ -64,9 +64,6 @@
 static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
 {
 	hlist_del_rcu(&f->hlist);
-	if (!f->is_static)
-		list_del(&f->u.age_list);
-
 	br_fdb_put(f);
 }
 
@@ -113,30 +110,23 @@
 void br_fdb_cleanup(unsigned long _data)
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
-	struct list_head *l, *n;
-	unsigned long delay;
+	unsigned long delay = hold_time(br);
+	int i;
 
 	spin_lock_bh(&br->hash_lock);
-	delay = hold_time(br);
-
-	list_for_each_safe(l, n, &br->age_list) {
+	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
-		unsigned long expires;
+		struct hlist_node *h, *n;
 
-		f = list_entry(l, struct net_bridge_fdb_entry, u.age_list);
-		expires = f->ageing_timer + delay;
-
-		if (time_before_eq(expires, jiffies)) {
-			WARN_ON(f->is_static);
-			pr_debug("expire age %lu jiffies %lu\n",
-				 f->ageing_timer, jiffies);
-			fdb_delete(f);
-		} else {
-			mod_timer(&br->gc_timer, expires);
-			break;
+		hlist_for_each_entry_safe(f, h, n, &br->hash[i], hlist) {
+			if (!f->is_static && 
+			    time_before_eq(f->ageing_timer + delay, jiffies)) 
+				fdb_delete(f);
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
+
+	mod_timer(&br->gc_timer, jiffies + HZ/10);
 }
 
 void br_fdb_delete_by_port(struct net_bridge *br, struct net_bridge_port *p)
@@ -212,7 +202,7 @@
 static void fdb_rcu_free(struct rcu_head *head)
 {
 	struct net_bridge_fdb_entry *ent
-		= container_of(head, struct net_bridge_fdb_entry, u.rcu);
+		= container_of(head, struct net_bridge_fdb_entry, rcu);
 	kmem_cache_free(br_fdb_cache, ent);
 }
 
@@ -220,7 +210,7 @@
 void br_fdb_put(struct net_bridge_fdb_entry *ent)
 {
 	if (atomic_dec_and_test(&ent->use_count))
-		call_rcu(&ent->u.rcu, fdb_rcu_free);
+		call_rcu(&ent->rcu, fdb_rcu_free);
 }
 
 /*
@@ -305,8 +295,6 @@
 			if (fdb->is_static)
 				return 0;
 
-			/* move to end of age list */
-			list_del(&fdb->u.age_list);
 			goto update;
 		}
 	}
@@ -329,8 +317,6 @@
 	fdb->is_local = is_local;
 	fdb->is_static = is_local;
 	fdb->ageing_timer = jiffies;
-	if (!is_local) 
-		list_add_tail(&fdb->u.age_list, &br->age_list);
 
 	return 0;
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2005-03-10 15:06:38 -08:00
+++ b/net/bridge/br_private.h	2005-03-10 15:06:38 -08:00
@@ -46,10 +46,8 @@
 {
 	struct hlist_node		hlist;
 	struct net_bridge_port		*dst;
-	union {
-		struct list_head	age_list;
-		struct rcu_head		rcu;
-	} u;
+
+	struct rcu_head			rcu;
 	atomic_t			use_count;
 	unsigned long			ageing_timer;
 	mac_addr			addr;
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	2005-03-10 15:06:38 -08:00
+++ b/net/bridge/br_stp_if.c	2005-03-10 15:06:38 -08:00
@@ -49,6 +49,8 @@
 
 	spin_lock_bh(&br->lock);
 	mod_timer(&br->hello_timer, jiffies + br->hello_time);
+	mod_timer(&br->gc_timer, jiffies + HZ/10);
+	
 	br_config_bpdu_generation(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
@@ -78,6 +80,7 @@
 	del_timer_sync(&br->hello_timer);
 	del_timer_sync(&br->topology_change_timer);
 	del_timer_sync(&br->tcn_timer);
+	del_timer_sync(&br->gc_timer);
 }
 
 /* called under bridge lock */
diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2005-03-10 15:07:12 -08:00
+++ b/net/bridge/br_fdb.c	2005-03-10 15:07:12 -08:00
@@ -307,11 +307,6 @@
 	atomic_set(&fdb->use_count, 1);
 	hlist_add_head_rcu(&fdb->hlist, &br->hash[hash]);
 
-	if (!timer_pending(&br->gc_timer)) {
-		br->gc_timer.expires = jiffies + hold_time(br);
-		add_timer(&br->gc_timer);
-	}
-
  update:
 	fdb->dst = source;
 	fdb->is_local = is_local;

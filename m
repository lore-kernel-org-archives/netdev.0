From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/11) bridge -- forwarding table sanity checks
Date: Fri, 21 May 2004 16:39:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163923.4d558723@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forwarding table paranoia:
* Solve some potential problems if a device changes address and one or
  more device has the same address.  
* Warn if new device added to a bridge matches a entry that has shown
  up on the network.
* Also don't put static entries in the timer list, they don't time
  out so shouldn't be there.
 
diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2004-05-21 15:39:18 -07:00
+++ b/net/bridge/br_fdb.c	2004-05-21 15:39:18 -07:00
@@ -23,6 +23,8 @@
 #include "br_private.h"
 
 static kmem_cache_t *br_fdb_cache;
+static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		      const unsigned char *addr, int is_local);
 
 void __init br_fdb_init(void)
 {
@@ -72,37 +74,49 @@
 static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
 {
 	hlist_del(&f->hlist);
-	list_del(&f->age_list);
+	if (!f->is_static)
+		list_del(&f->age_list);
+
 	br_fdb_put(f);
 }
 
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
-	struct net_bridge *br;
+	struct net_bridge *br = p->br;
 	int i;
-	int newhash = br_mac_hash(newaddr);
-
-	br = p->br;
+	
 	write_lock_bh(&br->hash_lock);
-	for (i=0;i<BR_HASH_SIZE;i++) {
+
+	/* Search all chains since old address/hash is unknown */
+	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct hlist_node *h;
-		
 		hlist_for_each(h, &br->hash[i]) {
-			struct net_bridge_fdb_entry *f
-				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
+			struct net_bridge_fdb_entry *f;
 
+			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (f->dst == p && f->is_local) {
-				memcpy(f->addr.addr, newaddr, ETH_ALEN);
-				if (newhash != i) {
-					hlist_del(&f->hlist);
-					hlist_add_head(&f->hlist,
-						       &br->hash[newhash]);
+				/* maybe another port has same hw addr? */
+				struct net_bridge_port *op;
+				list_for_each_entry(op, &br->port_list, list) {
+					if (op != p && 
+					    !memcmp(op->dev->dev_addr,
+						    f->addr.addr, ETH_ALEN)) {
+						f->dst = op;
+						goto insert;
+					}
 				}
-				goto out;
+
+				/* delete old one */
+				fdb_delete(f);
+				goto insert;
 			}
 		}
 	}
- out:
+ insert:
+	/* insert new address,  may fail if invalid address or dup. */
+	fdb_insert(br, p, newaddr, 1);
+
+
 	write_unlock_bh(&br->hash_lock);
 }
 
@@ -121,11 +135,10 @@
 		unsigned long expires = f->ageing_timer + delay;
 
 		if (time_before_eq(expires, jiffies)) {
-			if (!f->is_static) {
-				pr_debug("expire age %lu jiffies %lu\n",
-					 f->ageing_timer, jiffies);
-				fdb_delete(f);
-			}
+			WARN_ON(f->is_static);
+			pr_debug("expire age %lu jiffies %lu\n",
+				 f->ageing_timer, jiffies);
+			fdb_delete(f);
 		} else {
 			mod_timer(&br->gc_timer, expires);
 			break;
@@ -139,7 +152,7 @@
 	int i;
 
 	write_lock_bh(&br->hash_lock);
-	for (i=0;i<BR_HASH_SIZE;i++) {
+	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct hlist_node *h, *g;
 		
 		hlist_for_each_safe(h, g, &br->hash[i]) {
@@ -247,50 +260,52 @@
 	return num;
 }
 
-int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr, int is_local)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 	int hash = br_mac_hash(addr);
-	int ret = 0;
 
 	if (!is_valid_ether_addr(addr))
 		return -EADDRNOTAVAIL;
 
-	write_lock_bh(&br->hash_lock);
-	hlist_for_each(h, &br->hash[hash]) {
-		fdb = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
+	hlist_for_each_entry(fdb, h, &br->hash[hash], hlist) {
 		if (!memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
 			/* attempt to update an entry for a local interface */
-			if (unlikely(fdb->is_local)) {
+			if (fdb->is_local) {
 				/* it is okay to have multiple ports with same 
 				 * address, just don't allow to be spoofed.
 				 */
-				if (!is_local) {
-					if (net_ratelimit()) 
-						printk(KERN_WARNING "%s: received packet with "
-						       " own address as source address\n",
-						       source->dev->name);
-					ret = -EEXIST;
-				}
-				goto out;
+				if (is_local) 
+					return 0;
+
+				if (net_ratelimit()) 
+					printk(KERN_WARNING "%s: received packet with "
+					       " own address as source address\n",
+					       source->dev->name);
+				return -EEXIST;
 			}
 
-			if (likely(!fdb->is_static || is_local)) {
-				/* move to end of age list */
-				list_del(&fdb->age_list);
+			if (is_local) {
+				printk(KERN_WARNING "%s adding interface with same address "
+				       "as a received packet\n",
+				       source->dev->name);
 				goto update;
 			}
-			goto out;
+
+			if (fdb->is_static)
+				return 0;
+
+			/* move to end of age list */
+			list_del(&fdb->age_list);
+			goto update;
 		}
 	}
 
 	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
-	if (unlikely(fdb == NULL)) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!fdb)
+		return ENOMEM;
 
 	memcpy(fdb->addr.addr, addr, ETH_ALEN);
 	atomic_set(&fdb->use_count, 1);
@@ -306,9 +321,19 @@
 	fdb->is_local = is_local;
 	fdb->is_static = is_local;
 	fdb->ageing_timer = jiffies;
-	list_add_tail(&fdb->age_list, &br->age_list);
- out:
-	write_unlock_bh(&br->hash_lock);
+	if (!is_local) 
+		list_add_tail(&fdb->age_list, &br->age_list);
+
+	return 0;
+}
+
+int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		  const unsigned char *addr, int is_local)
+{
+	int ret;
 
+	write_lock_bh(&br->hash_lock);
+	ret = fdb_insert(br, source, addr, is_local);
+	write_unlock_bh(&br->hash_lock);
 	return ret;
 }

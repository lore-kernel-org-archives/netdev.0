From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [BRIDGE] Change bridge forwarding table to use hlist
Date: Tue, 29 Apr 2003 10:35:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429103524.15f56cbf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Switch bridge functional table to using hlist_macros.  The code
was using the same form of hash list already, this just uses the convient
macros.  

Needed to add one more macro for hlist_for_each_safe in the same style
as list_for_each_safe.  Thought about doing hlist_for_each_entry, but
it gets too ugly.

diff -urNp -X dontdiff linux-2.5/include/linux/list.h linux-2.5-bridge/include/linux/list.h
--- linux-2.5/include/linux/list.h	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-bridge/include/linux/list.h	2003-04-29 10:13:03.000000000 -0700
@@ -437,6 +437,10 @@ static __inline__ void hlist_add_before(
 	for (pos = (head)->first; pos; \
 	     pos = pos->next) 
 
+#define hlist_for_each_safe(pos, n, head) \
+	for (pos = (head)->first; n = pos ? pos->next : 0, pos; \
+	     pos = n)
+
 #else
 #warning "don't include kernel headers in userspace"
 #endif /* __KERNEL__ */
diff -urNp -X dontdiff linux-2.5/net/bridge/br_fdb.c linux-2.5-bridge/net/bridge/br_fdb.c
--- linux-2.5/net/bridge/br_fdb.c	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_fdb.c	2003-04-29 10:13:03.000000000 -0700
@@ -68,28 +68,6 @@ static __inline__ int br_mac_hash(unsign
 	return x & (BR_HASH_SIZE - 1);
 }
 
-static __inline__ void __hash_link(struct net_bridge *br,
-				   struct net_bridge_fdb_entry *ent,
-				   int hash)
-{
-	ent->next_hash = br->hash[hash];
-	if (ent->next_hash != NULL)
-		ent->next_hash->pprev_hash = &ent->next_hash;
-	br->hash[hash] = ent;
-	ent->pprev_hash = &br->hash[hash];
-}
-
-static __inline__ void __hash_unlink(struct net_bridge_fdb_entry *ent)
-{
-	*(ent->pprev_hash) = ent->next_hash;
-	if (ent->next_hash != NULL)
-		ent->next_hash->pprev_hash = ent->pprev_hash;
-	ent->next_hash = NULL;
-	ent->pprev_hash = NULL;
-}
-
-
-
 void br_fdb_changeaddr(struct net_bridge_port *p, unsigned char *newaddr)
 {
 	struct net_bridge *br;
@@ -99,22 +77,24 @@ void br_fdb_changeaddr(struct net_bridge
 	br = p->br;
 	write_lock_bh(&br->hash_lock);
 	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct net_bridge_fdb_entry *f;
+		struct hlist_node *h;
+		
+		hlist_for_each(h, &br->hash[i]) {
+			struct net_bridge_fdb_entry *f
+				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 
-		f = br->hash[i];
-		while (f != NULL) {
 			if (f->dst == p && f->is_local) {
 				memcpy(f->addr.addr, newaddr, ETH_ALEN);
 				if (newhash != i) {
-					__hash_unlink(f);
-					__hash_link(br, f, newhash);
+					hlist_del(&f->hlist);
+					hlist_add_head(&f->hlist,
+						       &br->hash[newhash]);
 				}
-				write_unlock_bh(&br->hash_lock);
-				return;
+				goto out;
 			}
-			f = f->next_hash;
 		}
 	}
+ out:
 	write_unlock_bh(&br->hash_lock);
 }
 
@@ -127,19 +107,16 @@ void br_fdb_cleanup(struct net_bridge *b
 
 	write_lock_bh(&br->hash_lock);
 	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct net_bridge_fdb_entry *f;
-
-		f = br->hash[i];
-		while (f != NULL) {
-			struct net_bridge_fdb_entry *g;
-
-			g = f->next_hash;
+		struct hlist_node *h, *g;
+		
+		hlist_for_each_safe(h, g, &br->hash[i]) {
+			struct net_bridge_fdb_entry *f
+				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (!f->is_static &&
 			    time_before_eq(f->ageing_timer, timeout)) {
-				__hash_unlink(f);
+				hlist_del(&f->hlist);
 				br_fdb_put(f);
 			}
-			f = g;
 		}
 	}
 	write_unlock_bh(&br->hash_lock);
@@ -151,18 +128,15 @@ void br_fdb_delete_by_port(struct net_br
 
 	write_lock_bh(&br->hash_lock);
 	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct net_bridge_fdb_entry *f;
-
-		f = br->hash[i];
-		while (f != NULL) {
-			struct net_bridge_fdb_entry *g;
-
-			g = f->next_hash;
+		struct hlist_node *h, *g;
+		
+		hlist_for_each_safe(h, g, &br->hash[i]) {
+			struct net_bridge_fdb_entry *f
+				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (f->dst == p) {
-				__hash_unlink(f);
+				hlist_del(&f->hlist);
 				br_fdb_put(f);
 			}
-			f = g;
 		}
 	}
 	write_unlock_bh(&br->hash_lock);
@@ -170,25 +144,24 @@ void br_fdb_delete_by_port(struct net_br
 
 struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br, unsigned char *addr)
 {
-	struct net_bridge_fdb_entry *fdb;
+	struct hlist_node *h;
 
 	read_lock_bh(&br->hash_lock);
-	fdb = br->hash[br_mac_hash(addr)];
-	while (fdb != NULL) {
+		
+	hlist_for_each(h, &br->hash[br_mac_hash(addr)]) {
+		struct net_bridge_fdb_entry *fdb
+			= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
+
 		if (!memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
-			if (!has_expired(br, fdb)) {
-				atomic_inc(&fdb->use_count);
-				read_unlock_bh(&br->hash_lock);
-				return fdb;
-			}
+			if (has_expired(br, fdb))
+				goto ret_null;
 
+			atomic_inc(&fdb->use_count);
 			read_unlock_bh(&br->hash_lock);
-			return NULL;
+			return fdb;
 		}
-
-		fdb = fdb->next_hash;
 	}
-
+ ret_null:
 	read_unlock_bh(&br->hash_lock);
 	return NULL;
 }
@@ -213,12 +186,16 @@ int br_fdb_get_entries(struct net_bridge
 
 	read_lock_bh(&br->hash_lock);
 	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct net_bridge_fdb_entry *f;
-
-		for (f = br->hash[i]; f != NULL && num < maxnum;
-		     f = f->next_hash) {
+		struct hlist_node *h;
+		
+		hlist_for_each(h, &br->hash[i]) {
+			struct net_bridge_fdb_entry *f
+				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			struct __fdb_entry ent;
 
+			if (num >= maxnum)
+				goto out;
+
 			if (has_expired(br, f)) 
 				continue;
 
@@ -277,14 +254,15 @@ void br_fdb_insert(struct net_bridge *br
 		   unsigned char *addr,
 		   int is_local)
 {
+	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 	int hash;
 
 	hash = br_mac_hash(addr);
 
 	write_lock_bh(&br->hash_lock);
-	fdb = br->hash[hash];
-	while (fdb != NULL) {
+	hlist_for_each(h, &br->hash[hash]) {
+		fdb = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 		if (!fdb->is_local &&
 		    !memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
 			__fdb_possibly_replace(fdb, source, is_local);
@@ -292,7 +270,6 @@ void br_fdb_insert(struct net_bridge *br
 			return;
 		}
 
-		fdb = fdb->next_hash;
 	}
 
 	fdb = kmalloc(sizeof(*fdb), GFP_ATOMIC);
@@ -308,7 +285,7 @@ void br_fdb_insert(struct net_bridge *br
 	fdb->is_static = is_local;
 	fdb->ageing_timer = jiffies;
 
-	__hash_link(br, fdb, hash);
+	hlist_add_head(&fdb->hlist, &br->hash[hash]);
 
 	write_unlock_bh(&br->hash_lock);
 }
diff -urNp -X dontdiff linux-2.5/net/bridge/br_private.h linux-2.5-bridge/net/bridge/br_private.h
--- linux-2.5/net/bridge/br_private.h	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_private.h	2003-04-29 10:13:03.000000000 -0700
@@ -43,8 +43,7 @@ struct mac_addr
 
 struct net_bridge_fdb_entry
 {
-	struct net_bridge_fdb_entry	*next_hash;
-	struct net_bridge_fdb_entry	**pprev_hash;
+	struct hlist_node		hlist;
 	atomic_t			use_count;
 	mac_addr			addr;
 	struct net_bridge_port		*dst;
@@ -86,7 +85,7 @@ struct net_bridge
 	struct net_device		dev;
 	struct net_device_stats		statistics;
 	rwlock_t			hash_lock;
-	struct net_bridge_fdb_entry	*hash[BR_HASH_SIZE];
+	struct hlist_head		hash[BR_HASH_SIZE];
 	struct timer_list		tick;
 
 	/* STP */

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) bridge forwarding table RCU
Date: Wed, 28 Jul 2004 16:24:23 -0700
Sender: bridge-bounces@lists.osdl.org
Message-ID: <20040728162423.6e4f8bb9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============30422491057718992=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@redhat.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============30422491057718992==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Convert the bridge forwarding database over to using RCU.
This avoids a read_lock and atomic_inc/dec in the fast path
of output.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/list.h b/include/linux/list.h
--- a/include/linux/list.h	2004-07-28 15:30:04 -07:00
+++ b/include/linux/list.h	2004-07-28 15:30:04 -07:00
@@ -678,6 +678,24 @@
 	     pos && ({ n = pos->next; 1; }) && 				 \
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
 	     pos = n)
+
+/**
+ * hlist_for_each_entry_rcu - iterate over rcu list of given type
+ * @pos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ * This list-traversal primitive may safely run concurrently with
+ * the _rcu list-mutation primitives such as hlist_add_rcu()
+ * as long as the traversal is guarded by rcu_read_lock().
+ */
+#define hlist_for_each_entry_rcu(tpos, pos, head, member)		 \
+	for (pos = (head)->first;					 \
+	     pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next, ({ smp_read_barrier_depends(); 0; }) )
+
 #else
 #warning "don't include kernel headers in userspace"
 #endif /* __KERNEL__ */
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	2004-07-28 15:30:04 -07:00
+++ b/net/bridge/br_device.c	2004-07-28 15:30:04 -07:00
@@ -43,10 +43,9 @@
 	rcu_read_lock();
 	if (dest[0] & 1) 
 		br_flood_deliver(br, skb, 0);
-	else if ((dst = br_fdb_get(br, dest)) != NULL) {
+	else if ((dst = __br_fdb_get(br, dest)) != NULL)
 		br_deliver(dst->dst, skb);
-		br_fdb_put(dst);
-	} else
+	else
 		br_flood_deliver(br, skb, 0);
 
 	rcu_read_unlock();
diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2004-07-28 15:30:04 -07:00
+++ b/net/bridge/br_fdb.c	2004-07-28 15:30:04 -07:00
@@ -73,7 +73,7 @@
 
 static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
 {
-	hlist_del(&f->hlist);
+	hlist_del_rcu(&f->hlist);
 	if (!f->is_static)
 		list_del(&f->age_list);
 
@@ -85,7 +85,7 @@
 	struct net_bridge *br = p->br;
 	int i;
 	
-	write_lock_bh(&br->hash_lock);
+	spin_lock_bh(&br->hash_lock);
 
 	/* Search all chains since old address/hash is unknown */
 	for (i = 0; i < BR_HASH_SIZE; i++) {
@@ -117,7 +117,7 @@
 	fdb_insert(br, p, newaddr, 1);
 
 
-	write_unlock_bh(&br->hash_lock);
+	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_cleanup(unsigned long _data)
@@ -126,7 +126,7 @@
 	struct list_head *l, *n;
 	unsigned long delay;
 
-	write_lock_bh(&br->hash_lock);
+	spin_lock_bh(&br->hash_lock);
 	delay = hold_time(br);
 
 	list_for_each_safe(l, n, &br->age_list) {
@@ -144,14 +144,14 @@
 			break;
 		}
 	}
-	write_unlock_bh(&br->hash_lock);
+	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_delete_by_port(struct net_bridge *br, struct net_bridge_port *p)
 {
 	int i;
 
-	write_lock_bh(&br->hash_lock);
+	spin_lock_bh(&br->hash_lock);
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct hlist_node *h, *g;
 		
@@ -182,33 +182,42 @@
 		skip_delete: ;
 		}
 	}
-	write_unlock_bh(&br->hash_lock);
+	spin_unlock_bh(&br->hash_lock);
 }
 
-struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br, unsigned char *addr)
+/* No locking or refcounting, assumes caller has no preempt (rcu_read_lock) */
+struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
+					  const unsigned char *addr)
 {
 	struct hlist_node *h;
+	struct net_bridge_fdb_entry *fdb;
 
-	read_lock_bh(&br->hash_lock);
-		
-	hlist_for_each(h, &br->hash[br_mac_hash(addr)]) {
-		struct net_bridge_fdb_entry *fdb
-			= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-
+	hlist_for_each_entry_rcu(fdb, h, &br->hash[br_mac_hash(addr)], hlist) {
 		if (!memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
-			if (has_expired(br, fdb))
-				goto ret_null;
-
-			atomic_inc(&fdb->use_count);
-			read_unlock_bh(&br->hash_lock);
+			if (unlikely(has_expired(br, fdb)))
+				break;
 			return fdb;
 		}
 	}
- ret_null:
-	read_unlock_bh(&br->hash_lock);
+
 	return NULL;
 }
 
+/* Interface used by ATM hook that keeps a ref count */
+struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br, 
+					unsigned char *addr)
+{
+	struct net_bridge_fdb_entry *fdb;
+
+	rcu_read_lock();
+	fdb = __br_fdb_get(br, addr);
+	if (fdb) 
+		atomic_inc(&fdb->use_count);
+	rcu_read_unlock();
+	return fdb;
+}
+
+
 void br_fdb_put(struct net_bridge_fdb_entry *ent)
 {
 	if (atomic_dec_and_test(&ent->use_count))
@@ -229,9 +238,9 @@
 
 	memset(buf, 0, maxnum*sizeof(struct __fdb_entry));
 
-	read_lock_bh(&br->hash_lock);
+	rcu_read_lock();
 	for (i = 0; i < BR_HASH_SIZE; i++) {
-		hlist_for_each_entry(f, h, &br->hash[i], hlist) {
+		hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
 			if (num >= maxnum)
 				goto out;
 
@@ -255,7 +264,7 @@
 	}
 
  out:
-	read_unlock_bh(&br->hash_lock);
+	rcu_read_unlock();
 
 	return num;
 }
@@ -309,7 +318,7 @@
 
 	memcpy(fdb->addr.addr, addr, ETH_ALEN);
 	atomic_set(&fdb->use_count, 1);
-	hlist_add_head(&fdb->hlist, &br->hash[hash]);
+	hlist_add_head_rcu(&fdb->hlist, &br->hash[hash]);
 
 	if (!timer_pending(&br->gc_timer)) {
 		br->gc_timer.expires = jiffies + hold_time(br);
@@ -332,8 +341,8 @@
 {
 	int ret;
 
-	write_lock_bh(&br->hash_lock);
+	spin_lock_bh(&br->hash_lock);
 	ret = fdb_insert(br, source, addr, is_local);
-	write_unlock_bh(&br->hash_lock);
+	spin_unlock_bh(&br->hash_lock);
 	return ret;
 }
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-07-28 15:30:04 -07:00
+++ b/net/bridge/br_if.c	2004-07-28 15:30:04 -07:00
@@ -149,7 +149,7 @@
 
 	br->lock = SPIN_LOCK_UNLOCKED;
 	INIT_LIST_HEAD(&br->port_list);
-	br->hash_lock = RW_LOCK_UNLOCKED;
+	br->hash_lock = SPIN_LOCK_UNLOCKED;
 
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	2004-07-28 15:30:04 -07:00
+++ b/net/bridge/br_input.c	2004-07-28 15:30:04 -07:00
@@ -83,19 +83,17 @@
 		goto out;
 	}
 
-	dst = br_fdb_get(br, dest);
+	dst = __br_fdb_get(br, dest);
 	if (dst != NULL && dst->is_local) {
 		if (!passedup)
 			br_pass_frame_up(br, skb);
 		else
 			kfree_skb(skb);
-		br_fdb_put(dst);
 		goto out;
 	}
 
 	if (dst != NULL) {
 		br_forward(dst->dst, skb);
-		br_fdb_put(dst);
 		goto out;
 	}
 
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-07-28 15:30:04 -07:00
+++ b/net/bridge/br_private.h	2004-07-28 15:30:04 -07:00
@@ -86,7 +86,7 @@
 	struct list_head		port_list;
 	struct net_device		*dev;
 	struct net_device_stats		statistics;
-	rwlock_t			hash_lock;
+	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
 
@@ -136,8 +136,10 @@
 extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 			   struct net_bridge_port *p);
+extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
+						 const unsigned char *addr);
 extern struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br,
-					unsigned char *addr);
+					       unsigned char *addr);
 extern void br_fdb_put(struct net_bridge_fdb_entry *ent);
 extern int br_fdb_fillbuf(struct net_bridge *br, void *buf, 
 			  unsigned long count, unsigned long off);

--===============30422491057718992==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============30422491057718992==--

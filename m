From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) bridge: forwarding table lockless update
Date: Thu, 10 Mar 2005 15:44:37 -0800
Message-ID: <20050310154437.1223b6e9@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Optimize bridge forwarding table for the fastpath of updating
an existing entry. Use RCU to find the entry and change it's time.
Fallback to normal locking for insert. This gives about a 1/3
improvement in packets forwarding per second on SMP.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2005-03-10 15:25:50 -08:00
+++ b/net/bridge/br_fdb.c	2005-03-10 15:25:50 -08:00
@@ -25,7 +25,7 @@
 
 static kmem_cache_t *br_fdb_cache;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		      const unsigned char *addr, int is_local);
+		      const unsigned char *addr);
 
 void __init br_fdb_init(void)
 {
@@ -101,8 +101,7 @@
 	}
  insert:
 	/* insert new address,  may fail if invalid address or dup. */
-	fdb_insert(br, p, newaddr, 1);
-
+	fdb_insert(br, p, newaddr);
 
 	spin_unlock_bh(&br->hash_lock);
 }
@@ -258,71 +257,108 @@
 	return num;
 }
 
-static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr, int is_local)
+static inline struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
+						    const unsigned char *addr)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
-	int hash = br_mac_hash(addr);
 
-	if (!is_valid_ether_addr(addr))
-		return -EADDRNOTAVAIL;
+	hlist_for_each_entry_rcu(fdb, h, head, hlist) {
+		if (!memcmp(fdb->addr.addr, addr, ETH_ALEN))
+			return fdb;
+	}
+	return NULL;
+}
 
-	hlist_for_each_entry(fdb, h, &br->hash[hash], hlist) {
-		if (!memcmp(fdb->addr.addr, addr, ETH_ALEN)) {
-			/* attempt to update an entry for a local interface */
-			if (fdb->is_local) {
-				/* it is okay to have multiple ports with same 
-				 * address, just don't allow to be spoofed.
-				 */
-				if (is_local) 
-					return 0;
-
-				if (net_ratelimit()) 
-					printk(KERN_WARNING "%s: received packet with "
-					       " own address as source address\n",
-					       source->dev->name);
-				return -EEXIST;
-			}
+static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
+					       struct net_bridge_port *source,
+					       const unsigned char *addr, 
+					       int is_local)
+{
+	struct net_bridge_fdb_entry *fdb;
 
-			if (is_local) {
-				printk(KERN_WARNING "%s adding interface with same address "
-				       "as a received packet\n",
-				       source->dev->name);
-				goto update;
-			}
+	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
+	if (fdb) {
+		memcpy(fdb->addr.addr, addr, ETH_ALEN);
+		atomic_set(&fdb->use_count, 1);
+		hlist_add_head_rcu(&fdb->hlist, head);
+
+		fdb->dst = source;
+		fdb->is_local = is_local;
+		fdb->is_static = is_local;
+		fdb->ageing_timer = jiffies;
+	}
+	return fdb;
+}
 
-			if (fdb->is_static)
-				return 0;
+static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		  const unsigned char *addr)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct net_bridge_fdb_entry *fdb;
 
-			goto update;
-		}
-	}
+	if (!is_valid_ether_addr(addr))
+		return -EINVAL;
 
-	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
-	if (!fdb)
-		return ENOMEM;
+	fdb = fdb_find(head, addr);
+	if (fdb) {
+		/* it is okay to have multiple ports with same 
+		 * address, just use the first one.
+		 */
+		if (fdb->is_local) 
+			return 0;
+
+		printk(KERN_WARNING "%s adding interface with same address "
+		       "as a received packet\n",
+		       source->dev->name);
+		fdb_delete(fdb);
+ 	}
 
-	memcpy(fdb->addr.addr, addr, ETH_ALEN);
-	atomic_set(&fdb->use_count, 1);
-	hlist_add_head_rcu(&fdb->hlist, &br->hash[hash]);
-
- update:
-	fdb->dst = source;
-	fdb->is_local = is_local;
-	fdb->is_static = is_local;
-	fdb->ageing_timer = jiffies;
+	if (!fdb_create(head, source, addr, 1))
+		return -ENOMEM;
 
 	return 0;
 }
 
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr, int is_local)
+		  const unsigned char *addr)
 {
 	int ret;
 
 	spin_lock_bh(&br->hash_lock);
-	ret = fdb_insert(br, source, addr, is_local);
+	ret = fdb_insert(br, source, addr);
 	spin_unlock_bh(&br->hash_lock);
 	return ret;
+}
+
+void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
+		   const unsigned char *addr)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct net_bridge_fdb_entry *fdb;
+
+	rcu_read_lock();
+	fdb = fdb_find(head, addr);
+	if (likely(fdb)) {
+		/* attempt to update an entry for a local interface */
+		if (unlikely(fdb->is_local)) {
+			if (net_ratelimit()) 
+				printk(KERN_WARNING "%s: received packet with "
+				       " own address as source address\n",
+				       source->dev->name);
+		} else {
+			/* fastpath: update of existing entry */
+			fdb->dst = source;
+			fdb->ageing_timer = jiffies;
+		}
+	} else {
+		spin_lock_bh(&br->hash_lock);
+		if (!fdb_find(head, addr))
+			fdb_create(head, source, addr, 0);
+		/* else  we lose race and someone else inserts
+		 * it first, don't bother updating
+		 */
+		spin_unlock_bh(&br->hash_lock);
+	}
+	rcu_read_unlock();
 }
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2005-03-10 15:25:50 -08:00
+++ b/net/bridge/br_if.c	2005-03-10 15:25:50 -08:00
@@ -332,7 +332,7 @@
 	if (IS_ERR(p = new_nbp(br, dev, br_initial_port_cost(dev))))
 		return PTR_ERR(p);
 
- 	if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
+ 	if ((err = br_fdb_insert(br, p, dev->dev_addr)))
 		destroy_nbp(p);
  
 	else if ((err = br_sysfs_addif(p)))
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	2005-03-10 15:25:50 -08:00
+++ b/net/bridge/br_input.c	2005-03-10 15:25:50 -08:00
@@ -105,12 +105,12 @@
 	if (p->state == BR_STATE_DISABLED)
 		goto err;
 
-	if (eth_hdr(skb)->h_source[0] & 1)
+	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto err;
 
 	if (p->state == BR_STATE_LEARNING ||
 	    p->state == BR_STATE_FORWARDING)
-		br_fdb_insert(p->br, p, eth_hdr(skb)->h_source, 0);
+		br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
 
 	if (p->br->stp_enabled &&
 	    !memcmp(dest, bridge_ula, 5) &&
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2005-03-10 15:25:50 -08:00
+++ b/net/bridge/br_private.h	2005-03-10 15:25:50 -08:00
@@ -146,8 +146,10 @@
 			  unsigned long count, unsigned long off);
 extern int br_fdb_insert(struct net_bridge *br,
 			 struct net_bridge_port *source,
-			 const unsigned char *addr,
-			 int is_local);
+			 const unsigned char *addr);
+extern void br_fdb_update(struct net_bridge *br,
+			  struct net_bridge_port *source,
+			  const unsigned char *addr);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/11) bridge -- read forwarding table chunk at a time.
Date: Fri, 21 May 2004 16:39:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163907.725b5be5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change how the read of forwarding table works.  Instead of copying
entries to user one at a time, use an intermediate kernel buffer and
do up to a page at a chunk.

This gets rid of some awkward code dealing with entries getting deleted
during the copy.  And allows same function to be used by later sysfs
hook.
 
diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	2004-05-20 09:59:49 -07:00
+++ b/net/bridge/br_fdb.c	2004-05-20 09:59:49 -07:00
@@ -16,11 +16,10 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/spinlock.h>
-#include <linux/if_bridge.h>
 #include <linux/times.h>
+#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <asm/atomic.h>
-#include <asm/uaccess.h>
 #include "br_private.h"
 
 static kmem_cache_t *br_fdb_cache;
@@ -54,17 +53,6 @@
 		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
 
-static inline void copy_fdb(struct __fdb_entry *ent, 
-				const struct net_bridge_fdb_entry *f)
-{
-	memset(ent, 0, sizeof(struct __fdb_entry));
-	memcpy(ent->mac_addr, f->addr.addr, ETH_ALEN);
-	ent->port_no = f->dst?f->dst->port_no:0;
-	ent->is_local = f->is_local;
-	ent->ageing_timer_value = f->is_static ? 0 
-		: jiffies_to_clock_t(jiffies - f->ageing_timer);
-}
-
 static __inline__ int br_mac_hash(const unsigned char *mac)
 {
 	unsigned long x;
@@ -214,68 +202,48 @@
 		kmem_cache_free(br_fdb_cache, ent);
 }
 
-int br_fdb_get_entries(struct net_bridge *br,
-		       unsigned char *_buf,
-		       int maxnum,
-		       int offset)
+/*
+ * Fill buffer with forwarding table records in 
+ * the API format.
+ */
+int br_fdb_fillbuf(struct net_bridge *br, void *buf,
+		   unsigned long maxnum, unsigned long skip)
 {
-	int i;
-	int num;
-	struct __fdb_entry *walk;
+	struct __fdb_entry *fe = buf;
+	int i, num = 0;
+	struct hlist_node *h;
+	struct net_bridge_fdb_entry *f;
 
-	num = 0;
-	walk = (struct __fdb_entry *)_buf;
+	memset(buf, 0, maxnum*sizeof(struct __fdb_entry));
 
 	read_lock_bh(&br->hash_lock);
-	for (i=0;i<BR_HASH_SIZE;i++) {
-		struct hlist_node *h;
-		
-		hlist_for_each(h, &br->hash[i]) {
-			struct net_bridge_fdb_entry *f
-				= hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-			struct __fdb_entry ent;
-
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		hlist_for_each_entry(f, h, &br->hash[i], hlist) {
 			if (num >= maxnum)
 				goto out;
 
 			if (has_expired(br, f)) 
 				continue;
 
-			if (offset) {
-				offset--;
+			if (skip) {
+				--skip;
 				continue;
 			}
 
-			copy_fdb(&ent, f);
-
-			atomic_inc(&f->use_count);
-			read_unlock_bh(&br->hash_lock);
-			
-			if (copy_to_user(walk, &ent, sizeof(struct __fdb_entry)))
-				return -EFAULT;
-
-			read_lock_bh(&br->hash_lock);
-			
-			/* entry was deleted during copy_to_user */
-			if (atomic_dec_and_test(&f->use_count)) {
-				kmem_cache_free(br_fdb_cache, f);
-				num = -EAGAIN;
-				goto out;
-			}
-
-			/* entry changed address hash while copying */
-			if (br_mac_hash(f->addr.addr) != i) {
-				num = -EAGAIN;
-				goto out;
-			}
-
-			num++;
-			walk++;
+			/* convert from internal format to API */
+			memcpy(fe->mac_addr, f->addr.addr, ETH_ALEN);
+			fe->port_no = f->dst->port_no;
+			fe->is_local = f->is_local;
+			if (!f->is_static)
+				fe->ageing_timer_value = jiffies_to_clock_t(jiffies - f->ageing_timer);
+			++fe;
+			++num;
 		}
 	}
 
  out:
 	read_unlock_bh(&br->hash_lock);
+
 	return num;
 }
 
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	2004-05-20 09:59:49 -07:00
+++ b/net/bridge/br_ioctl.c	2004-05-20 09:59:49 -07:00
@@ -52,6 +52,39 @@
 	}
 }
 
+/*
+ * Format up to a page worth of forwarding table entries
+ * userbuf -- where to copy result
+ * maxnum  -- maximum number of entries desired
+ *            (limited to a page for sanity)
+ * offset  -- number of records to skip
+ */
+static int get_fdb_entries(struct net_bridge *br, void __user *userbuf, 
+			   unsigned long maxnum, unsigned long offset)
+{
+	int num;
+	void *buf;
+	size_t size = maxnum * sizeof(struct __fdb_entry);
+
+	if (size > PAGE_SIZE) {
+		size = PAGE_SIZE;
+		maxnum = PAGE_SIZE/sizeof(struct __fdb_entry);
+	}
+
+	buf = kmalloc(size, GFP_USER);
+	if (!buf)
+		return -ENOMEM;
+	
+	num = br_fdb_fillbuf(br, buf, maxnum, offset);
+	if (num > 0) {
+		if (copy_to_user(userbuf, buf, num*sizeof(struct __fdb_entry)))
+			num = -EFAULT;
+	}
+	kfree(buf);
+
+	return num;
+}
+
 int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -270,7 +303,8 @@
 	}
 
 	case BRCTL_GET_FDB_ENTRIES:
-		return br_fdb_get_entries(br, (void *)args[1], args[2], args[3]);
+		return get_fdb_entries(br, (void __user *)args[1], 
+				       args[2], args[3]);
 	}
 
 	return -EOPNOTSUPP;
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-05-20 09:59:49 -07:00
+++ b/net/bridge/br_private.h	2004-05-20 09:59:49 -07:00
@@ -135,10 +135,8 @@
 extern struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br,
 					unsigned char *addr);
 extern void br_fdb_put(struct net_bridge_fdb_entry *ent);
-extern int  br_fdb_get_entries(struct net_bridge *br,
-			unsigned char *_buf,
-			int maxnum,
-			int offset);
+extern int br_fdb_fillbuf(struct net_bridge *br, void *buf, 
+			  unsigned long count, unsigned long off);
 extern int br_fdb_insert(struct net_bridge *br,
 			 struct net_bridge_port *source,
 			 const unsigned char *addr,

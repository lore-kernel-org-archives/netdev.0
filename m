From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (9/9) bridge - fdb cache alloc
Date: Tue, 13 Apr 2004 15:34:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413153453.4765b26a@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since forwarding database gets a lot of memory alloc/free on a busy
bridge, use kmem_cache_alloc to provide cache and better stats.

diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	Tue Apr 13 13:17:16 2004
+++ b/net/bridge/br.c	Tue Apr 13 13:17:16 2004
@@ -31,6 +31,8 @@
 
 static int __init br_init(void)
 {
+	br_fdb_init();
+
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (br_netfilter_init())
 		return 1;
@@ -65,6 +67,7 @@
 #endif
 
 	br_handle_frame_hook = NULL;
+	br_fdb_fini();
 }
 
 EXPORT_SYMBOL(br_should_route_hook);
diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	Tue Apr 13 13:17:16 2004
+++ b/net/bridge/br_fdb.c	Tue Apr 13 13:17:16 2004
@@ -22,6 +22,22 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
+static kmem_cache_t *br_fdb_cache;
+
+void __init br_fdb_init(void)
+{
+	br_fdb_cache = kmem_cache_create("bridge_fdb_cache",
+					 sizeof(struct net_bridge_fdb_entry),
+					 0,
+					 SLAB_HWCACHE_ALIGN, NULL, NULL);
+}
+
+void __exit br_fdb_fini(void)
+{
+	kmem_cache_destroy(br_fdb_cache);
+}
+
+
 /* if topology_changing then use forward_delay (default 15 sec)
  * otherwise keep longer (default 5 minutes)
  */
@@ -37,7 +53,7 @@
 		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
 
-static __inline__ void copy_fdb(struct __fdb_entry *ent, 
+static inline void copy_fdb(struct __fdb_entry *ent, 
 				const struct net_bridge_fdb_entry *f)
 {
 	memset(ent, 0, sizeof(struct __fdb_entry));
@@ -180,7 +196,7 @@
 void br_fdb_put(struct net_bridge_fdb_entry *ent)
 {
 	if (atomic_dec_and_test(&ent->use_count))
-		kfree(ent);
+		kmem_cache_free(br_fdb_cache, ent);
 }
 
 int br_fdb_get_entries(struct net_bridge *br, void __user *buf,
@@ -224,7 +240,7 @@
 			
 			/* entry was deleted during copy_to_user */
 			if (atomic_dec_and_test(&f->use_count)) {
-				kfree(f);
+				kmem_cache_free(br_fdb_cache, f);
 				num = -EAGAIN;
 				goto out;
 			}
@@ -283,7 +299,7 @@
 		}
 	}
 
-	fdb = kmalloc(sizeof(*fdb), GFP_ATOMIC);
+	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
 	if (unlikely(fdb == NULL)) {
 		ret = -ENOMEM;
 		goto out;
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Tue Apr 13 13:17:16 2004
+++ b/net/bridge/br_private.h	Tue Apr 13 13:17:16 2004
@@ -127,6 +127,8 @@
 extern int br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* br_fdb.c */
+extern void br_fdb_init(void);
+extern void br_fdb_fini(void);
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
 			      const unsigned char *newaddr);
 extern void br_fdb_cleanup(unsigned long arg);

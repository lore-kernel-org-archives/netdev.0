From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (6/9) bridge - forwarding database changes
Date: Tue, 13 Apr 2004 15:28:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413152838.181eb743@dell_ss3.pdx.osdl.net>
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

Make forwarding database more robust.  
  + Don't insert invalid ether address,
  + Report errors back so adding an interface to bridge can fail
  + get rid of unneeded explicit pads in data structure
  + replace bitfields with byte's for simple booleans.

diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	Mon Apr 12 16:10:50 2004
+++ b/net/bridge/br_fdb.c	Mon Apr 12 16:10:50 2004
@@ -17,6 +17,7 @@
 #include <linux/spinlock.h>
 #include <linux/if_bridge.h>
 #include <linux/times.h>
+#include <linux/etherdevice.h>
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -243,12 +244,16 @@
 	return num;
 }
 
-void br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, int is_local)
+int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		  const unsigned char *addr, int is_local)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 	int hash = br_mac_hash(addr);
+	int ret = 0;
+
+	if (!is_valid_ether_addr(addr))
+		return -EADDRNOTAVAIL;
 
 	write_lock_bh(&br->hash_lock);
 	hlist_for_each(h, &br->hash[hash]) {
@@ -264,6 +269,7 @@
 					printk(KERN_WARNING "%s: received packet with "
 					       " own address as source address\n",
 					       source->dev->name);
+				ret = -EEXIST;
 				goto out;
 			}
 
@@ -278,8 +284,10 @@
 	}
 
 	fdb = kmalloc(sizeof(*fdb), GFP_ATOMIC);
-	if (fdb == NULL) 
+	if (unlikely(fdb == NULL)) {
+		ret = -ENOMEM;
 		goto out;
+	}
 
 	memcpy(fdb->addr.addr, addr, ETH_ALEN);
 	atomic_set(&fdb->use_count, 1);
@@ -298,4 +306,6 @@
 	list_add_tail(&fdb->age_list, &br->age_list);
  out:
 	write_unlock_bh(&br->hash_lock);
+
+	return ret;
 }
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Mon Apr 12 16:10:50 2004
+++ b/net/bridge/br_if.c	Mon Apr 12 16:10:50 2004
@@ -277,13 +277,15 @@
 	else if (IS_ERR(p = new_nbp(br, dev, cost)))
 		err = PTR_ERR(p);
 
+ 	else if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
+ 		 destroy_nbp(p);
+ 
 	else {
 		dev_set_promiscuity(dev, 1);
 
 		list_add_rcu(&p->list, &br->port_list);
 
 		br_stp_recalculate_bridge_id(br);
-		br_fdb_insert(br, p, dev->dev_addr, 1);
 		if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
 			br_stp_enable_port(p);
 
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Mon Apr 12 16:10:50 2004
+++ b/net/bridge/br_private.h	Mon Apr 12 16:10:50 2004
@@ -37,7 +37,6 @@
 struct mac_addr
 {
 	unsigned char	addr[6];
-	unsigned char	pad[2];
 };
 
 struct net_bridge_fdb_entry
@@ -48,8 +47,8 @@
 	atomic_t			use_count;
 	unsigned long			ageing_timer;
 	mac_addr			addr;
-	unsigned			is_local:1;
-	unsigned			is_static:1;
+	unsigned char			is_local;
+	unsigned char			is_static;
 };
 
 struct net_bridge_port
@@ -135,10 +134,10 @@
 extern void br_fdb_put(struct net_bridge_fdb_entry *ent);
 extern int  br_fdb_get_entries(struct net_bridge *br, void __user *buf,
 			       int maxnum, int offset);
-extern void br_fdb_insert(struct net_bridge *br,
-			  struct net_bridge_port *source,
-			  const unsigned char *addr,
-			  int is_local);
+extern int br_fdb_insert(struct net_bridge *br,
+			 struct net_bridge_port *source,
+			 const unsigned char *addr,
+			 int is_local);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,

From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][2.4] lane/mpoa locking cleanup
Date: Mon, 08 Sep 2003 17:32:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309082132.h88LWRSa004358@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this is a backport of the 2.6 lane/mpoa locking cleanup.
please apply to 2.4 -- thanks

[ATM]: lane/mpoa module locking cleanup

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1119.3.2 -> 1.1119.3.3
#	       net/atm/lec.c	1.17    -> 1.18   
#	       net/atm/mpc.h	1.1     -> 1.2    
#	      net/atm/proc.c	1.9     -> 1.10   
#	       net/atm/lec.h	1.5     -> 1.6    
#	       net/atm/mpc.c	1.8     -> 1.9    
#	    net/atm/common.c	1.17    -> 1.18   
#
# --------------------------------------------
# 03/09/05	chas@relax.cmf.nrl.navy.mil	1.1119.3.3
# [ATM]: lane/mpoa module locking cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Sep  8 17:29:52 2003
+++ b/net/atm/common.c	Mon Sep  8 17:29:52 2003
@@ -33,21 +33,61 @@
 #include <linux/atmlec.h>
 #include "lec.h"
 #include "lec_arpc.h"
-struct atm_lane_ops atm_lane_ops;
-#endif
-#ifdef CONFIG_ATM_LANE_MODULE
+struct atm_lane_ops *atm_lane_ops;
+static DECLARE_MUTEX(atm_lane_ops_mutex);
+
+void atm_lane_ops_set(struct atm_lane_ops *hook)
+{
+	down(&atm_lane_ops_mutex);
+	atm_lane_ops = hook;
+	up(&atm_lane_ops_mutex);
+}
+
+int try_atm_lane_ops(void)
+{
+	down(&atm_lane_ops_mutex);
+	if (atm_lane_ops && try_inc_mod_count(atm_lane_ops->owner)) {
+		up(&atm_lane_ops_mutex);
+		return 1;
+	}
+	up(&atm_lane_ops_mutex);
+	return 0;
+}
+
+#if defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_ATM_MPOA_MODULE)
 EXPORT_SYMBOL(atm_lane_ops);
+EXPORT_SYMBOL(try_atm_lane_ops);
+EXPORT_SYMBOL(atm_lane_ops_set);
+#endif
 #endif
 
 #if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
 #include <linux/atmmpc.h>
 #include "mpc.h"
-struct atm_mpoa_ops atm_mpoa_ops;
-#endif
+struct atm_mpoa_ops *atm_mpoa_ops;
+static DECLARE_MUTEX(atm_mpoa_ops_mutex);
+
+void atm_mpoa_ops_set(struct atm_mpoa_ops *hook)
+{
+	down(&atm_mpoa_ops_mutex);
+	atm_mpoa_ops = hook;
+	up(&atm_mpoa_ops_mutex);
+}
+
+int try_atm_mpoa_ops(void)
+{
+	down(&atm_mpoa_ops_mutex);
+	if (atm_mpoa_ops && try_inc_mod_count(atm_mpoa_ops->owner)) {
+		up(&atm_mpoa_ops_mutex);
+		return 1;
+	}
+	up(&atm_mpoa_ops_mutex);
+	return 0;
+}
 #ifdef CONFIG_ATM_MPOA_MODULE
 EXPORT_SYMBOL(atm_mpoa_ops);
-#ifndef CONFIG_ATM_LANE_MODULE
-EXPORT_SYMBOL(atm_lane_ops);
+EXPORT_SYMBOL(try_atm_mpoa_ops);
+EXPORT_SYMBOL(atm_mpoa_ops_set);
 #endif
 #endif
 
@@ -739,27 +779,43 @@
 				ret_val = -EPERM;
 				goto done;
 			}
-                        if (atm_lane_ops.lecd_attach == NULL)
-				atm_lane_init();
-                        if (atm_lane_ops.lecd_attach == NULL) { /* try again */
+#if defined(CONFIG_ATM_LANE_MODULE)
+                        if (!atm_lane_ops)
+				request_module("lec");
+#endif
+			if (try_atm_lane_ops()) {
+				error = atm_lane_ops->lecd_attach(vcc, (int) arg);
+				if (atm_lane_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+				if (error >= 0)
+					sock->state = SS_CONNECTED;
+				ret_val =  error;
+			} else
 				ret_val = -ENOSYS;
-				goto done;
-			}
-			error = atm_lane_ops.lecd_attach(vcc, (int)arg);
-			if (error >= 0) sock->state = SS_CONNECTED;
-			ret_val =  error;
 			goto done;
                 case ATMLEC_MCAST:
-			if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN)) {
 				ret_val = -EPERM;
-			else
-				ret_val = atm_lane_ops.mcast_attach(vcc, (int)arg);
+				goto done;
+			}
+			if (try_atm_lane_ops()) {
+				ret_val = atm_lane_ops->mcast_attach(vcc, (int) arg);
+				if (atm_lane_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+			} else
+				ret_val = -ENOSYS;
 			goto done;
                 case ATMLEC_DATA:
-			if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN)) {
 				ret_val = -EPERM;
-			else
-				ret_val = atm_lane_ops.vcc_attach(vcc, (void*)arg);
+				goto done;
+			}
+			if (try_atm_lane_ops()) {
+				ret_val = atm_lane_ops->vcc_attach(vcc, (void *) arg);
+				if (atm_lane_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+			} else
+				ret_val = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
@@ -768,21 +824,31 @@
 				ret_val = -EPERM;
 				goto done;
 			}
-			if (atm_mpoa_ops.mpoad_attach == NULL)
-                                atm_mpoa_init();
-			if (atm_mpoa_ops.mpoad_attach == NULL) { /* try again */
+#if defined(CONFIG_ATM_MPOA_MODULE)
+			if (!atm_mpoa_ops)
+                                request_module("mpoa");
+#endif
+			if (try_atm_mpoa_ops()) {
+				error = atm_mpoa_ops->mpoad_attach(vcc, (int) arg);
+				if (atm_mpoa_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
+				if (error >= 0)
+					sock->state = SS_CONNECTED;
+				ret_val = error;
+			} else
 				ret_val = -ENOSYS;
-				goto done;
-			}
-			error = atm_mpoa_ops.mpoad_attach(vcc, (int)arg);
-			if (error >= 0) sock->state = SS_CONNECTED;
-			ret_val = error;
 			goto done;
 		case ATMMPC_DATA:
-			if (!capable(CAP_NET_ADMIN)) 
+			if (!capable(CAP_NET_ADMIN)) {
 				ret_val = -EPERM;
-			else
-				ret_val = atm_mpoa_ops.vcc_attach(vcc, arg);
+				goto done;
+			}
+			if (try_atm_mpoa_ops()) {
+				ret_val = atm_mpoa_ops->vcc_attach(vcc, arg);
+				if (atm_mpoa_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
+			} else
+				ret_val = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
@@ -1167,40 +1233,6 @@
 }
 
 
-/*
- * lane_mpoa_init.c: A couple of helper functions
- * to make modular LANE and MPOA client easier to implement
- */
-
-/*
- * This is how it goes:
- *
- * if xxxx is not compiled as module, call atm_xxxx_init_ops()
- *    from here
- * else call atm_mpoa_init_ops() from init_module() within
- *    the kernel when xxxx module is loaded
- *
- * In either case function pointers in struct atm_xxxx_ops
- * are initialized to their correct values. Either they
- * point to functions in the module or in the kernel
- */
- 
-extern struct atm_mpoa_ops atm_mpoa_ops; /* in common.c */
-extern struct atm_lane_ops atm_lane_ops; /* in common.c */
-
-#if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
-void atm_mpoa_init(void)
-{
-#ifndef CONFIG_ATM_MPOA_MODULE /* not module */
-        atm_mpoa_init_ops(&atm_mpoa_ops);
-#else
-	request_module("mpoa");
-#endif
-
-        return;
-}
-#endif
-
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
@@ -1211,18 +1243,8 @@
 EXPORT_SYMBOL(br_fdb_put_hook);
 #endif /* defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_BRIDGE_MODULE) */
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
+#endif /* defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE) */
 
-void atm_lane_init(void)
-{
-#ifndef CONFIG_ATM_LANE_MODULE /* not module */
-        atm_lane_init_ops(&atm_lane_ops);
-#else
-	request_module("lec");
-#endif
-
-        return;
-}        
-#endif
 
 static int __init atm_init(void)
 {
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Sep  8 17:29:52 2003
+++ b/net/atm/lec.c	Mon Sep  8 17:29:52 2003
@@ -11,6 +11,7 @@
 /* We are ethernet device */
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
 #include <net/sock.h>
 #include <linux/skbuff.h>
@@ -57,8 +58,6 @@
 	unsigned char *addr);
 extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
-static spinlock_t lec_arp_spinlock = SPIN_LOCK_UNLOCKED;
-
 #define DUMP_PACKETS 0 /* 0 = None,
                         * 1 = 30 first bytes
                         * 2 = Whole packet
@@ -72,9 +71,9 @@
 static int lec_close(struct net_device *dev);
 static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
-static __inline__ struct lec_arp_table* lec_arp_find(struct lec_priv *priv,
+static inline struct lec_arp_table* lec_arp_find(struct lec_priv *priv,
                                                      unsigned char *mac_addr);
-static __inline__ int lec_arp_remove(struct lec_arp_table **lec_arp_tables,
+static inline int lec_arp_remove(struct lec_priv *priv,
 				     struct lec_arp_table *to_remove);
 /* LANE2 functions */
 static void lane2_associate_ind (struct net_device *dev, u8 *mac_address,
@@ -96,8 +95,18 @@
 static struct net_device *dev_lec[MAX_LEC_ITF];
 
 /* This will be called from proc.c via function pointer */
-struct net_device **get_dev_lec (void) {
-        return &dev_lec[0];
+struct net_device *get_dev_lec(int itf)
+{
+	struct net_device *dev;
+
+	if (itf >= MAX_LEC_ITF)
+		return NULL;
+	rtnl_lock();
+	dev = dev_lec[itf];
+	if (dev)
+		dev_hold(dev);
+	rtnl_unlock();
+	return dev;
 }
 
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
@@ -433,7 +442,7 @@
                 break;
         case l_narp_req: /* LANE2: see 7.1.35 in the lane2 spec */
                 entry = lec_arp_find(priv, mesg->content.normal.mac_addr);
-                lec_arp_remove(priv->lec_arp_tables, entry);
+                lec_arp_remove(priv, entry);
 
                 if (mesg->content.normal.no_source_le_narp)
                         break;
@@ -834,37 +843,28 @@
         return i;
 }
 
-void atm_lane_init_ops(struct atm_lane_ops *ops)
+static struct atm_lane_ops __atm_lane_ops = 
 {
-        ops->lecd_attach = lecd_attach;
-        ops->mcast_attach = lec_mcast_attach;
-        ops->vcc_attach = lec_vcc_attach;
-        ops->get_lecs = get_dev_lec;
-
-        printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
-
-	return;
-}
+	.lecd_attach =	lecd_attach,
+	.mcast_attach =	lec_mcast_attach,
+	.vcc_attach = 	lec_vcc_attach,
+	.get_lec = 	get_dev_lec,
+	.owner = 	THIS_MODULE
+};
 
 static int __init lane_module_init(void)
 {
-        extern struct atm_lane_ops atm_lane_ops;
-
-        atm_lane_init_ops(&atm_lane_ops);
-
+        atm_lane_ops_set(&__atm_lane_ops);
+        printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
         return 0;
 }
 
 static void __exit lane_module_cleanup(void)
 {
         int i;
-        extern struct atm_lane_ops atm_lane_ops;
         struct lec_priv *priv;
 
-        atm_lane_ops.lecd_attach = NULL;
-        atm_lane_ops.mcast_attach = NULL;
-        atm_lane_ops.vcc_attach = NULL;
-        atm_lane_ops.get_lecs = NULL;
+        atm_lane_ops_set(NULL);
 
         for (i = 0; i < MAX_LEC_ITF; i++) {
                 if (dev_lec[i] != NULL) {
@@ -874,7 +874,7 @@
                         	unregister_trdev(dev_lec[i]);
                 	else
 #endif
-                        unregister_netdev(dev_lec[i]);
+				unregister_netdev(dev_lec[i]);
                         kfree(dev_lec[i]);
                         dev_lec[i] = NULL;
                 }
@@ -1074,6 +1074,7 @@
         for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 priv->lec_arp_tables[i] = NULL;
         }        
+	spin_lock_init(&priv->lec_arp_lock);
         init_timer(&priv->lec_arp_timer);
         priv->lec_arp_timer.expires = jiffies+LEC_ARP_REFRESH_INTERVAL;
         priv->lec_arp_timer.data = (unsigned long)priv;
@@ -1110,21 +1111,20 @@
  * Insert entry to lec_arp_table
  * LANE2: Add to the end of the list to satisfy 8.1.13
  */
-static __inline__ void 
-lec_arp_add(struct lec_arp_table **lec_arp_tables, 
-            struct lec_arp_table *to_add)
+static inline void 
+lec_arp_add(struct lec_priv *priv, struct lec_arp_table *to_add)
 {
         unsigned long flags;
         unsigned short place;
         struct lec_arp_table *tmp;
 
-        spin_lock_irqsave(&lec_arp_spinlock, flags);
+        spin_lock_irqsave(&priv->lec_arp_lock, flags);
 
         place = HASH(to_add->mac_addr[ETH_ALEN-1]);
-        tmp = lec_arp_tables[place];
+        tmp = priv->lec_arp_tables[place];
         to_add->next = NULL;
         if (tmp == NULL)
-                lec_arp_tables[place] = to_add;
+                priv->lec_arp_tables[place] = to_add;
   
         else {  /* add to the end */
                 while (tmp->next)
@@ -1132,7 +1132,7 @@
                 tmp->next = to_add;
         }
 
-        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
         DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_add->mac_addr[0], 0xff&to_add->mac_addr[1],
@@ -1143,8 +1143,8 @@
 /*
  * Remove entry from lec_arp_table
  */
-static __inline__ int 
-lec_arp_remove(struct lec_arp_table **lec_arp_tables,
+static inline int 
+lec_arp_remove(struct lec_priv *priv,
                struct lec_arp_table *to_remove)
 {
         unsigned long flags;
@@ -1152,22 +1152,22 @@
         struct lec_arp_table *tmp;
         int remove_vcc=1;
 
-        spin_lock_irqsave(&lec_arp_spinlock, flags);
+        spin_lock_irqsave(&priv->lec_arp_lock, flags);
 
         if (!to_remove) {
-                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 return -1;
         }
         place = HASH(to_remove->mac_addr[ETH_ALEN-1]);
-        tmp = lec_arp_tables[place];
+        tmp = priv->lec_arp_tables[place];
         if (tmp == to_remove) {
-                lec_arp_tables[place] = tmp->next;
+                priv->lec_arp_tables[place] = tmp->next;
         } else {
                 while(tmp && tmp->next != to_remove) {
                         tmp = tmp->next;
                 }
                 if (!tmp) {/* Entry was not found */
-                        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+                        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                         return -1;
                 }
         }
@@ -1181,7 +1181,7 @@
                  * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
                  */
                 for(place=0;place<LEC_ARP_TABLE_SIZE;place++) {
-                        for(tmp=lec_arp_tables[place];tmp!=NULL;tmp=tmp->next){
+                        for(tmp = priv->lec_arp_tables[place]; tmp != NULL; tmp = tmp->next) {
                                 if (memcmp(tmp->atm_addr, to_remove->atm_addr,
                                            ATM_ESA_LEN)==0) {
                                         remove_vcc=0;
@@ -1194,7 +1194,7 @@
         }
         skb_queue_purge(&to_remove->tx_wait); /* FIXME: good place for this? */
 
-        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
         DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_remove->mac_addr[0], 0xff&to_remove->mac_addr[1],
@@ -1390,7 +1390,7 @@
         for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 for(entry =priv->lec_arp_tables[i];entry != NULL; entry=next) {
                         next = entry->next;
-                        lec_arp_remove(priv->lec_arp_tables, entry);
+                        lec_arp_remove(priv, entry);
                         kfree(entry);
                 }
         }
@@ -1430,7 +1430,7 @@
 /* 
  * Find entry by mac_address
  */
-static __inline__ struct lec_arp_table*
+static inline struct lec_arp_table*
 lec_arp_find(struct lec_priv *priv,
              unsigned char *mac_addr)
 {
@@ -1568,8 +1568,6 @@
 lec_arp_check_expire(unsigned long data)
 {
         struct lec_priv *priv = (struct lec_priv *)data;
-        struct lec_arp_table **lec_arp_tables =
-                (struct lec_arp_table **)priv->lec_arp_tables;
         struct lec_arp_table *entry, *next;
         unsigned long now;
         unsigned long time_to_check;
@@ -1585,7 +1583,7 @@
                 lec_arp_get(priv);
                 now = jiffies;
                 for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                        for(entry = lec_arp_tables[i];entry != NULL;) {
+                        for(entry = priv->lec_arp_tables[i]; entry != NULL; ) {
                                 if ((entry->flags) & LEC_REMOTE_FLAG && 
                                     priv->topology_change)
                                         time_to_check=priv->forward_delay_time;
@@ -1601,7 +1599,7 @@
                                         /* Remove entry */
                                         DPRINTK("LEC:Entry timed out\n");
                                         next = entry->next;      
-                                        lec_arp_remove(lec_arp_tables, entry);
+                                        lec_arp_remove(priv, entry);
                                         kfree(entry);
                                         entry = next;
                                 } else {
@@ -1690,7 +1688,7 @@
                 if (!entry) {
                         return priv->mcast_vcc;
                 }
-                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_add(priv, entry);
                 /* We want arp-request(s) to be sent */
                 entry->packets_flooded =1;
                 entry->status = ESI_ARP_PENDING;
@@ -1723,7 +1721,7 @@
                         if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
                             && (permanent || 
                                 !(entry->flags & LEC_PERMANENT_FLAG))) {
-                                lec_arp_remove(priv->lec_arp_tables, entry);
+                                lec_arp_remove(priv, entry);
                                 kfree(entry);
                         }
                         lec_arp_put(priv);
@@ -1789,7 +1787,7 @@
                                 entry->status = ESI_FORWARD_DIRECT;
                                 memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
                                 entry->last_used = jiffies;
-                                lec_arp_add(priv->lec_arp_tables, entry);
+                                lec_arp_add(priv, entry);
                         }
                         if (remoteflag)
                                 entry->flags|=LEC_REMOTE_FLAG;
@@ -1809,7 +1807,7 @@
                         return;
                 }
                 entry->status = ESI_UNKNOWN;
-                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_add(priv, entry);
                 /* Temporary, changes before end of function */
         }
         memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
@@ -2056,7 +2054,7 @@
         to_add->old_push = vcc->push;
         vcc->push = lec_push;
         priv->mcast_vcc = vcc;
-        lec_arp_add(priv->lec_arp_tables, to_add);
+        lec_arp_add(priv, to_add);
         lec_arp_put(priv);
         return 0;
 }
@@ -2074,7 +2072,7 @@
                 for(entry = priv->lec_arp_tables[i];entry; entry=next) {
                         next = entry->next;
                         if (vcc == entry->vcc) {
-                                lec_arp_remove(priv->lec_arp_tables,entry);
+                                lec_arp_remove(priv, entry);
                                 kfree(entry);
                                 if (priv->mcast_vcc == vcc) {
                                         priv->mcast_vcc = NULL;
@@ -2154,23 +2152,23 @@
         lec_arp_get(priv);
         entry = priv->lec_arp_empty_ones;
         if (vcc == entry->vcc) {
-		spin_lock_irqsave(&lec_arp_spinlock, flags);
+		spin_lock_irqsave(&priv->lec_arp_lock, flags);
                 del_timer(&entry->timer);
                 memcpy(entry->mac_addr, src, ETH_ALEN);
                 entry->status = ESI_FORWARD_DIRECT;
                 entry->last_used = jiffies;
                 priv->lec_arp_empty_ones = entry->next;
-                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 /* We might have got an entry */
                 if ((prev=lec_arp_find(priv,src))) {
-                        lec_arp_remove(priv->lec_arp_tables, prev);
+                        lec_arp_remove(priv, prev);
                         kfree(prev);
                 }
-                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_add(priv, entry);
                 lec_arp_put(priv);
                 return;
         }
-        spin_lock_irqsave(&lec_arp_spinlock, flags);
+        spin_lock_irqsave(&priv->lec_arp_lock, flags);
         prev = entry;
         entry = entry->next;
         while (entry && entry->vcc != vcc) {
@@ -2180,7 +2178,7 @@
         if (!entry) {
                 DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
                 lec_arp_put(priv);
-                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 return;
         }
         del_timer(&entry->timer);
@@ -2188,12 +2186,12 @@
         entry->status = ESI_FORWARD_DIRECT;
         entry->last_used = jiffies;
         prev->next = entry->next;
-        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
         if ((prev = lec_arp_find(priv, src))) {
-                lec_arp_remove(priv->lec_arp_tables,prev);
+                lec_arp_remove(priv, prev);
                 kfree(prev);
         }
-        lec_arp_add(priv->lec_arp_tables,entry);
+        lec_arp_add(priv, entry);
         lec_arp_put(priv);  
 }
 MODULE_LICENSE("GPL");
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	Mon Sep  8 17:29:52 2003
+++ b/net/atm/lec.h	Mon Sep  8 17:29:52 2003
@@ -64,7 +64,8 @@
         int (*lecd_attach)(struct atm_vcc *vcc, int arg);
         int (*mcast_attach)(struct atm_vcc *vcc, int arg);
         int (*vcc_attach)(struct atm_vcc *vcc, void *arg);
-        struct net_device **(*get_lecs)(void);
+        struct net_device * (*get_lec)(int itf);
+        struct module *owner;
 };
 
 /*
@@ -102,6 +103,7 @@
            collects all those VCCs. LANEv1 client has only one item in this
            list. These entries are not aged out. */
         atomic_t lec_arp_users;
+        spinlock_t lec_arp_lock;
         struct atm_vcc *mcast_vcc; /* Default Multicast Send VCC */
         struct atm_vcc *lecd;
         struct timer_list lec_arp_timer;
@@ -148,14 +150,16 @@
 int lecd_attach(struct atm_vcc *vcc, int arg);
 int lec_vcc_attach(struct atm_vcc *vcc, void *arg);
 int lec_mcast_attach(struct atm_vcc *vcc, int arg);
-struct net_device **get_dev_lec(void);
+struct net_device *get_dev_lec(int itf);
 int make_lec(struct atm_vcc *vcc);
 int send_to_lecd(struct lec_priv *priv,
                  atmlec_msg_type type, unsigned char *mac_addr,
                  unsigned char *atm_addr, struct sk_buff *data);
 void lec_push(struct atm_vcc *vcc, struct sk_buff *skb);
 
-void atm_lane_init(void);
-void atm_lane_init_ops(struct atm_lane_ops *ops);
+extern struct atm_lane_ops *atm_lane_ops;
+void atm_lane_ops_set(struct atm_lane_ops *hook);
+int try_atm_lane_ops(void);
+
 #endif /* _LEC_H_ */
 
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Mon Sep  8 17:29:52 2003
+++ b/net/atm/mpc.c	Mon Sep  8 17:29:52 2003
@@ -251,12 +251,14 @@
 
 static struct net_device *find_lec_by_itfnum(int itf)
 {
-	extern struct atm_lane_ops atm_lane_ops; /* in common.c */
-	
-	if (atm_lane_ops.get_lecs == NULL)
+	struct net_device *dev;
+	if (!try_atm_lane_ops())
 		return NULL;
 
-	return atm_lane_ops.get_lecs()[itf]; /* FIXME: something better */
+	dev = atm_lane_ops->get_lec(itf);
+	if (atm_lane_ops->owner)
+		__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+	return dev;
 }
 
 static struct mpoa_client *alloc_mpc(void)
@@ -777,9 +779,10 @@
 
 	if (mpc->dev) { /* check if the lec is LANE2 capable */
 		priv = (struct lec_priv *)mpc->dev->priv;
-		if (priv->lane_version < 2)
+		if (priv->lane_version < 2) {
+			dev_put(mpc->dev);
 			mpc->dev = NULL;
-		else
+		} else
 			priv->lane2_ops->associate_indicator = lane2_assoc_ind;  
 	}
 
@@ -837,6 +840,7 @@
 		struct lec_priv *priv = (struct lec_priv *)mpc->dev->priv;
 		priv->lane2_ops->associate_indicator = NULL;
 		stop_mpc(mpc);
+		dev_put(mpc->dev);
 	}
 
 	mpc->in_ops->destroy_cache(mpc);
@@ -973,6 +977,7 @@
 		}
 		mpc->dev_num = priv->itfnum;
 		mpc->dev = dev;
+		dev_hold(dev);
 		dprintk("mpoa: (%s) was initialized\n", dev->name);
 		break;
 	case NETDEV_UNREGISTER:
@@ -982,6 +987,7 @@
 			break;
 		dprintk("mpoa: device (%s) was deallocated\n", dev->name);
 		stop_mpc(mpc);
+		dev_put(mpc->dev);
 		mpc->dev = NULL;
 		break;
 	case NETDEV_UP:
@@ -1391,13 +1397,18 @@
 	return;
 }
 
-void atm_mpoa_init_ops(struct atm_mpoa_ops *ops)
+static struct atm_mpoa_ops __atm_mpoa_ops = {
+	.mpoad_attach =	atm_mpoa_mpoad_attach,
+	.vcc_attach =	atm_mpoa_vcc_attach,
+	.owner = THIS_MODULE
+};
+
+static __init int atm_mpoa_init(void)
 {
-	ops->mpoad_attach = atm_mpoa_mpoad_attach;
-	ops->vcc_attach = atm_mpoa_vcc_attach;
+	atm_mpoa_ops_set(&__atm_mpoa_ops);
 
 #ifdef CONFIG_PROC_FS
-	if(mpc_proc_init() != 0)
+	if (mpc_proc_init() != 0)
 		printk(KERN_INFO "mpoa: failed to initialize /proc/mpoa\n");
 	else
 		printk(KERN_INFO "mpoa: /proc/mpoa initialized\n");
@@ -1405,22 +1416,11 @@
 
 	printk("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
 
-	return;
-}
-
-#ifdef MODULE
-int init_module(void)
-{
-	extern struct atm_mpoa_ops atm_mpoa_ops;
-
-	atm_mpoa_init_ops(&atm_mpoa_ops);
-
 	return 0;
 }
 
-void cleanup_module(void)
+void __exit atm_mpoa_cleanup(void)
 {
-	extern struct atm_mpoa_ops atm_mpoa_ops;
 	struct mpoa_client *mpc, *tmp;
 	struct atm_mpoa_qos *qos, *nextqos;
 	struct lec_priv *priv;
@@ -1435,8 +1435,7 @@
 
 	del_timer(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
-	atm_mpoa_ops.mpoad_attach = NULL;
-	atm_mpoa_ops.vcc_attach = NULL;
+	atm_mpoa_ops_set(NULL);
 
 	mpc = mpcs;
 	mpcs = NULL;
@@ -1471,5 +1470,8 @@
 
 	return;
 }
-#endif /* MODULE */
+
+module_init(atm_mpoa_init);
+module_exit(atm_mpoa_cleanup);
+
 MODULE_LICENSE("GPL");
diff -Nru a/net/atm/mpc.h b/net/atm/mpc.h
--- a/net/atm/mpc.h	Mon Sep  8 17:29:52 2003
+++ b/net/atm/mpc.h	Mon Sep  8 17:29:52 2003
@@ -48,11 +48,13 @@
 struct atm_mpoa_ops {
         int (*mpoad_attach)(struct atm_vcc *vcc, int arg);  /* attach mpoa daemon  */
         int (*vcc_attach)(struct atm_vcc *vcc, long arg);   /* attach shortcut vcc */
+	struct module *owner;
 };
 
 /* Boot/module initialization function */
-void atm_mpoa_init(void);
-void atm_mpoa_init_ops(struct atm_mpoa_ops *ops);
+extern struct atm_mpoa_ops *atm_mpoa_ops;
+int try_atm_mpoa_ops(void);
+void atm_mpoa_ops_set(struct atm_mpoa_ops *hook);
 
 /* MPOA QoS operations */
 struct atm_mpoa_qos *atm_mpoa_add_qos(uint32_t dst_ip, struct atm_qos *qos);
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Mon Sep  8 17:29:52 2003
+++ b/net/atm/proc.c	Mon Sep  8 17:29:52 2003
@@ -47,7 +47,6 @@
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 #include "lec.h"
 #include "lec_arpc.h"
-extern struct atm_lane_ops atm_lane_ops; /* in common.c */
 #endif
 
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
@@ -482,57 +481,77 @@
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 static int atm_lec_info(loff_t pos,char *buf)
 {
+	unsigned long flags;
 	struct lec_priv *priv;
 	struct lec_arp_table *entry;
 	int i, count, d, e;
-	struct net_device **dev_lec;
+	struct net_device *dev;
 
 	if (!pos) {
 		return sprintf(buf,"Itf  MAC          ATM destination"
 		    "                          Status            Flags "
 		    "VPI/VCI Recv VPI/VCI\n");
 	}
-	if (atm_lane_ops.get_lecs == NULL)
+	if (!try_atm_lane_ops())
 		return 0; /* the lane module is not there yet */
-	else
-		dev_lec = atm_lane_ops.get_lecs();
 
 	count = pos;
-	for(d=0;d<MAX_LEC_ITF;d++) {
-		if (!dev_lec[d] || !(priv =
-		    (struct lec_priv *) dev_lec[d]->priv)) continue;
-		for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-			entry = priv->lec_arp_tables[i];
-			for(;entry;entry=entry->next) {
-				if (--count) continue;
-				e=sprintf(buf,"%s ",
-				    dev_lec[d]->name);
-				lec_info(entry,buf+e);
+	for(d = 0; d < MAX_LEC_ITF; d++) {
+		dev = atm_lane_ops->get_lec(d);
+		if (!dev || !(priv = (struct lec_priv *) dev->priv))
+			continue;
+		spin_lock_irqsave(&priv->lec_arp_lock, flags);
+		for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+			for(entry = priv->lec_arp_tables[i]; entry; entry = entry->next) {
+				if (--count)
+					continue;
+				e = sprintf(buf,"%s ", dev->name);
+				lec_info(entry, buf+e);
+				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+				dev_put(dev);
+				if (atm_lane_ops->owner)
+					__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 				return strlen(buf);
 			}
 		}
-		for(entry=priv->lec_arp_empty_ones; entry;
-		    entry=entry->next) {
-			if (--count) continue;
-			e=sprintf(buf,"%s ",dev_lec[d]->name);
+		for(entry = priv->lec_arp_empty_ones; entry; entry = entry->next) {
+			if (--count)
+				continue;
+			e = sprintf(buf,"%s ", dev->name);
 			lec_info(entry, buf+e);
+			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+			dev_put(dev);
+			if (atm_lane_ops->owner)
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			return strlen(buf);
 		}
-		for(entry=priv->lec_no_forward; entry;
-		    entry=entry->next) {
-			if (--count) continue;
-			e=sprintf(buf,"%s ",dev_lec[d]->name);
+		for(entry = priv->lec_no_forward; entry; entry=entry->next) {
+			if (--count)
+				continue;
+			e = sprintf(buf,"%s ", dev->name);
 			lec_info(entry, buf+e);
+			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+			dev_put(dev);
+			if (atm_lane_ops->owner)
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			return strlen(buf);
 		}
-		for(entry=priv->mcast_fwds; entry;
-		    entry=entry->next) {
-			if (--count) continue;
-			e=sprintf(buf,"%s ",dev_lec[d]->name);
+		for(entry = priv->mcast_fwds; entry; entry = entry->next) {
+			if (--count)
+				continue;
+			e = sprintf(buf,"%s ", dev->name);
 			lec_info(entry, buf+e);
+			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+			dev_put(dev);
+			if (atm_lane_ops->owner)
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			return strlen(buf);
 		}
+		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+		dev_put(dev);
 	}
+	if (atm_lane_ops->owner)
+		__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 	return 0;
 }
 #endif

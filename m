From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2.4] more atm backports for 2.4
Date: Mon, 14 Jul 2003 12:30:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307141630.h6EGUDmZ007717@locutus.cmf.nrl.navy.mil>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[atm]: cleanup lane and mpoa module interface

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1015  -> 1.1016 
#	       net/atm/lec.c	1.16    -> 1.17   
#	       net/atm/mpc.h	1.1     -> 1.2    
#	       net/atm/mpc.c	1.8     -> 1.9    
#	      net/atm/proc.c	1.8     -> 1.9    
#	       net/atm/lec.h	1.4     -> 1.5    
#	    net/atm/common.c	1.17    -> 1.18   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/27	chas@relax.cmf.nrl.navy.mil	1.1016
# cleanup lane and mpoa module interface
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 30 13:21:44 2003
+++ b/net/atm/common.c	Mon Jun 30 13:21:44 2003
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
 
@@ -734,27 +774,40 @@
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
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
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
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
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
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+			} else
+				ret_val = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
@@ -763,21 +816,29 @@
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
+				__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
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
+				__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
+			} else
+				ret_val = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
@@ -1162,40 +1223,6 @@
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
@@ -1206,18 +1233,8 @@
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
--- a/net/atm/lec.c	Mon Jun 30 13:21:44 2003
+++ b/net/atm/lec.c	Mon Jun 30 13:21:44 2003
@@ -11,6 +11,7 @@
 /* We are ethernet device */
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
 #include <net/sock.h>
 #include <linux/skbuff.h>
@@ -56,8 +57,6 @@
 	unsigned char *addr);
 extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
-static spinlock_t lec_arp_spinlock = SPIN_LOCK_UNLOCKED;
-
 #define DUMP_PACKETS 0 /* 0 = None,
                         * 1 = 30 first bytes
                         * 2 = Whole packet
@@ -71,9 +70,9 @@
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
@@ -95,8 +94,18 @@
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
@@ -432,7 +441,7 @@
                 break;
         case l_narp_req: /* LANE2: see 7.1.35 in the lane2 spec */
                 entry = lec_arp_find(priv, mesg->content.normal.mac_addr);
-                lec_arp_remove(priv->lec_arp_tables, entry);
+                lec_arp_remove(priv, entry);
 
                 if (mesg->content.normal.no_source_le_narp)
                         break;
@@ -833,37 +842,28 @@
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
@@ -873,7 +873,7 @@
                         	unregister_trdev(dev_lec[i]);
                 	else
 #endif
-                        unregister_netdev(dev_lec[i]);
+				unregister_netdev(dev_lec[i]);
                         kfree(dev_lec[i]);
                         dev_lec[i] = NULL;
                 }
@@ -1073,6 +1073,7 @@
         for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 priv->lec_arp_tables[i] = NULL;
         }        
+	spin_lock_init(&priv->lec_arp_lock);
         init_timer(&priv->lec_arp_timer);
         priv->lec_arp_timer.expires = jiffies+LEC_ARP_REFRESH_INTERVAL;
         priv->lec_arp_timer.data = (unsigned long)priv;
@@ -1109,21 +1110,20 @@
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
@@ -1131,7 +1131,7 @@
                 tmp->next = to_add;
         }
 
-        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
         DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_add->mac_addr[0], 0xff&to_add->mac_addr[1],
@@ -1142,8 +1142,8 @@
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
@@ -1151,22 +1151,22 @@
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
@@ -1180,7 +1180,7 @@
                  * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
                  */
                 for(place=0;place<LEC_ARP_TABLE_SIZE;place++) {
-                        for(tmp=lec_arp_tables[place];tmp!=NULL;tmp=tmp->next){
+                        for(tmp = priv->lec_arp_tables[place]; tmp != NULL; tmp = tmp->next) {
                                 if (memcmp(tmp->atm_addr, to_remove->atm_addr,
                                            ATM_ESA_LEN)==0) {
                                         remove_vcc=0;
@@ -1193,7 +1193,7 @@
         }
         skb_queue_purge(&to_remove->tx_wait); /* FIXME: good place for this? */
 
-        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
         DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_remove->mac_addr[0], 0xff&to_remove->mac_addr[1],
@@ -1389,7 +1389,7 @@
         for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 for(entry =priv->lec_arp_tables[i];entry != NULL; entry=next) {
                         next = entry->next;
-                        lec_arp_remove(priv->lec_arp_tables, entry);
+                        lec_arp_remove(priv, entry);
                         kfree(entry);
                 }
         }
@@ -1429,7 +1429,7 @@
 /* 
  * Find entry by mac_address
  */
-static __inline__ struct lec_arp_table*
+static inline struct lec_arp_table*
 lec_arp_find(struct lec_priv *priv,
              unsigned char *mac_addr)
 {
@@ -1567,8 +1567,6 @@
 lec_arp_check_expire(unsigned long data)
 {
         struct lec_priv *priv = (struct lec_priv *)data;
-        struct lec_arp_table **lec_arp_tables =
-                (struct lec_arp_table **)priv->lec_arp_tables;
         struct lec_arp_table *entry, *next;
         unsigned long now;
         unsigned long time_to_check;
@@ -1584,7 +1582,7 @@
                 lec_arp_get(priv);
                 now = jiffies;
                 for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                        for(entry = lec_arp_tables[i];entry != NULL;) {
+                        for(entry = priv->lec_arp_tables[i]; entry != NULL; ) {
                                 if ((entry->flags) & LEC_REMOTE_FLAG && 
                                     priv->topology_change)
                                         time_to_check=priv->forward_delay_time;
@@ -1600,7 +1598,7 @@
                                         /* Remove entry */
                                         DPRINTK("LEC:Entry timed out\n");
                                         next = entry->next;      
-                                        lec_arp_remove(lec_arp_tables, entry);
+                                        lec_arp_remove(priv, entry);
                                         kfree(entry);
                                         entry = next;
                                 } else {
@@ -1689,7 +1687,7 @@
                 if (!entry) {
                         return priv->mcast_vcc;
                 }
-                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_add(priv, entry);
                 /* We want arp-request(s) to be sent */
                 entry->packets_flooded =1;
                 entry->status = ESI_ARP_PENDING;
@@ -1722,7 +1720,7 @@
                         if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
                             && (permanent || 
                                 !(entry->flags & LEC_PERMANENT_FLAG))) {
-                                lec_arp_remove(priv->lec_arp_tables, entry);
+                                lec_arp_remove(priv, entry);
                                 kfree(entry);
                         }
                         lec_arp_put(priv);
@@ -1788,7 +1786,7 @@
                                 entry->status = ESI_FORWARD_DIRECT;
                                 memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
                                 entry->last_used = jiffies;
-                                lec_arp_add(priv->lec_arp_tables, entry);
+                                lec_arp_add(priv, entry);
                         }
                         if (remoteflag)
                                 entry->flags|=LEC_REMOTE_FLAG;
@@ -1808,7 +1806,7 @@
                         return;
                 }
                 entry->status = ESI_UNKNOWN;
-                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_add(priv, entry);
                 /* Temporary, changes before end of function */
         }
         memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
@@ -2055,7 +2053,7 @@
         to_add->old_push = vcc->push;
         vcc->push = lec_push;
         priv->mcast_vcc = vcc;
-        lec_arp_add(priv->lec_arp_tables, to_add);
+        lec_arp_add(priv, to_add);
         lec_arp_put(priv);
         return 0;
 }
@@ -2073,7 +2071,7 @@
                 for(entry = priv->lec_arp_tables[i];entry; entry=next) {
                         next = entry->next;
                         if (vcc == entry->vcc) {
-                                lec_arp_remove(priv->lec_arp_tables,entry);
+                                lec_arp_remove(priv, entry);
                                 kfree(entry);
                                 if (priv->mcast_vcc == vcc) {
                                         priv->mcast_vcc = NULL;
@@ -2153,23 +2151,23 @@
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
@@ -2179,7 +2177,7 @@
         if (!entry) {
                 DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
                 lec_arp_put(priv);
-                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 return;
         }
         del_timer(&entry->timer);
@@ -2187,12 +2185,12 @@
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
--- a/net/atm/lec.h	Mon Jun 30 13:21:44 2003
+++ b/net/atm/lec.h	Mon Jun 30 13:21:44 2003
@@ -64,7 +64,8 @@
         int (*lecd_attach)(struct atm_vcc *vcc, int arg);
         int (*mcast_attach)(struct atm_vcc *vcc, int arg);
         int (*vcc_attach)(struct atm_vcc *vcc, void *arg);
-        struct net_device **(*get_lecs)(void);
+        struct net_device * (*get_lec)(int itf);
+        struct module *owner;
 };
 
 /*
@@ -101,7 +102,8 @@
            establishes multiple Multicast Forward VCCs to us. This list
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
--- a/net/atm/mpc.c	Mon Jun 30 13:21:44 2003
+++ b/net/atm/mpc.c	Mon Jun 30 13:21:44 2003
@@ -251,12 +251,13 @@
 
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
+	__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
+	return dev;
 }
 
 static struct mpoa_client *alloc_mpc(void)
@@ -777,9 +778,10 @@
 
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
 
@@ -837,6 +839,7 @@
 		struct lec_priv *priv = (struct lec_priv *)mpc->dev->priv;
 		priv->lane2_ops->associate_indicator = NULL;
 		stop_mpc(mpc);
+		dev_put(mpc->dev);
 	}
 
 	mpc->in_ops->destroy_cache(mpc);
@@ -973,6 +976,7 @@
 		}
 		mpc->dev_num = priv->itfnum;
 		mpc->dev = dev;
+		dev_hold(dev);
 		dprintk("mpoa: (%s) was initialized\n", dev->name);
 		break;
 	case NETDEV_UNREGISTER:
@@ -982,6 +986,7 @@
 			break;
 		dprintk("mpoa: device (%s) was deallocated\n", dev->name);
 		stop_mpc(mpc);
+		dev_put(mpc->dev);
 		mpc->dev = NULL;
 		break;
 	case NETDEV_UP:
@@ -1391,13 +1396,18 @@
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
@@ -1405,22 +1415,11 @@
 
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
@@ -1435,8 +1434,7 @@
 
 	del_timer(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
-	atm_mpoa_ops.mpoad_attach = NULL;
-	atm_mpoa_ops.vcc_attach = NULL;
+	atm_mpoa_ops_set(NULL);
 
 	mpc = mpcs;
 	mpcs = NULL;
@@ -1471,5 +1469,8 @@
 
 	return;
 }
-#endif /* MODULE */
+
+module_init(atm_mpoa_init);
+module_exit(atm_mpoa_cleanup);
+
 MODULE_LICENSE("GPL");
diff -Nru a/net/atm/mpc.h b/net/atm/mpc.h
--- a/net/atm/mpc.h	Mon Jun 30 13:21:44 2003
+++ b/net/atm/mpc.h	Mon Jun 30 13:21:44 2003
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
--- a/net/atm/proc.c	Mon Jun 30 13:21:44 2003
+++ b/net/atm/proc.c	Mon Jun 30 13:21:44 2003
@@ -47,7 +47,6 @@
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 #include "lec.h"
 #include "lec_arpc.h"
-extern struct atm_lane_ops atm_lane_ops; /* in common.c */
 #endif
 
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
@@ -479,57 +478,72 @@
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
+				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
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
+			__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
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
+			__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
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
+			__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			return strlen(buf);
 		}
+		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+		dev_put(dev);
 	}
+	__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 	return 0;
 }
 #endif



[atm]: split atm_ioctl into vcc_ioctl and atm_dev_ioctl

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1016  -> 1.1017 
#	       net/atm/pvc.c	1.4     -> 1.5    
#	 net/atm/resources.c	1.6     -> 1.7    
#	       net/atm/svc.c	1.4     -> 1.5    
#	    net/atm/common.h	1.2     -> 1.3    
#	 net/atm/resources.h	1.3     -> 1.4    
#	    net/atm/common.c	1.18    -> 1.19   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/27	davem@nuts.ninka.net	1.1011.1.19
# [NET]: net/bluetooth/cmtp/core.c needs linux/init.h
# --------------------------------------------
# 03/06/27	davem@nuts.ninka.net	1.1011.1.20
# [NET]: Scale DST/ipv6 intervals like we did for ipv4.
# --------------------------------------------
# 03/06/28	chas@relax.cmf.nrl.navy.mil	1.1017
# svc.c, resources.h, resources.c, pvc.c, common.h, common.c:
#   split atm_ioctl into vcc_ioctl and atm_dev_ioctl
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 30 13:21:27 2003
+++ b/net/atm/common.c	Mon Jun 30 13:21:27 2003
@@ -564,129 +564,51 @@
 }
 
 
-static void copy_aal_stats(struct k_atm_aal_stats *from,
-    struct atm_aal_stats *to)
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
-#define __HANDLE_ITEM(i) to->i = atomic_read(&from->i)
-	__AAL_STAT_ITEMS
-#undef __HANDLE_ITEM
-}
-
-
-static void subtract_aal_stats(struct k_atm_aal_stats *from,
-    struct atm_aal_stats *to)
-{
-#define __HANDLE_ITEM(i) atomic_sub(to->i,&from->i)
-	__AAL_STAT_ITEMS
-#undef __HANDLE_ITEM
-}
-
-
-static int fetch_stats(struct atm_dev *dev,struct atm_dev_stats *arg,int zero)
-{
-	struct atm_dev_stats tmp;
-	int error = 0;
-
-	copy_aal_stats(&dev->stats.aal0,&tmp.aal0);
-	copy_aal_stats(&dev->stats.aal34,&tmp.aal34);
-	copy_aal_stats(&dev->stats.aal5,&tmp.aal5);
-	if (arg) error = copy_to_user(arg,&tmp,sizeof(tmp));
-	if (zero && !error) {
-		subtract_aal_stats(&dev->stats.aal0,&tmp.aal0);
-		subtract_aal_stats(&dev->stats.aal34,&tmp.aal34);
-		subtract_aal_stats(&dev->stats.aal5,&tmp.aal5);
-	}
-	return error ? -EFAULT : 0;
-}
-
-
-int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg)
-{
-	struct atm_dev *dev;
-	struct list_head *p;
 	struct atm_vcc *vcc;
-	int *tmp_buf, *tmp_p;
-	void *buf;
-	int error,len,size,number, ret_val;
+	int error;
 
-	ret_val = 0;
 	vcc = ATM_SD(sock);
 	switch (cmd) {
 		case SIOCOUTQ:
 			if (sock->state != SS_CONNECTED ||
-			    !test_bit(ATM_VF_READY,&vcc->flags)) {
-				ret_val =  -EINVAL;
+			    !test_bit(ATM_VF_READY, &vcc->flags)) {
+				error =  -EINVAL;
 				goto done;
 			}
-			ret_val =  put_user(vcc->sk->sndbuf-
-			    atomic_read(&vcc->sk->wmem_alloc),
-			    (int *) arg) ? -EFAULT : 0;
+			error =  put_user(vcc->sk->sndbuf-
+					  atomic_read(&vcc->sk->wmem_alloc),
+					  (int *) arg) ? -EFAULT : 0;
 			goto done;
 		case SIOCINQ:
 			{
 				struct sk_buff *skb;
 
 				if (sock->state != SS_CONNECTED) {
-					ret_val = -EINVAL;
+					error = -EINVAL;
 					goto done;
 				}
 				skb = skb_peek(&vcc->sk->receive_queue);
-				ret_val = put_user(skb ? skb->len : 0,(int *) arg)
-				    ? -EFAULT : 0;
-				goto done;
-			}
-		case ATM_GETNAMES:
-			if (get_user(buf,
-				     &((struct atm_iobuf *) arg)->buffer)) {
-				ret_val = -EFAULT;
-				goto done;
-			}
-			if (get_user(len,
-				     &((struct atm_iobuf *) arg)->length)) {
-				ret_val = -EFAULT;
+				error = put_user(skb ? skb->len : 0,
+						 (int *) arg) ? -EFAULT : 0;
 				goto done;
 			}
-			size = 0;
-			spin_lock(&atm_dev_lock);
-			list_for_each(p, &atm_devs)
-				size += sizeof(int);
-			if (size > len) {
-				spin_unlock(&atm_dev_lock);
-				ret_val = -E2BIG;
-				goto done;
-			}
-			tmp_buf = kmalloc(size, GFP_ATOMIC);
-			if (!tmp_buf) {
-				spin_unlock(&atm_dev_lock);
-				ret_val = -ENOMEM;
-				goto done;
-			}
-			tmp_p = tmp_buf;
-			list_for_each(p, &atm_devs) {
-				dev = list_entry(p, struct atm_dev, dev_list);
-				*tmp_p++ = dev->number;
-			}
-			spin_unlock(&atm_dev_lock);
-		        ret_val = ((copy_to_user(buf, tmp_buf, size)) ||
-			    put_user(size, &((struct atm_iobuf *) arg)->length)
-			    ) ? -EFAULT : 0;
-			kfree(tmp_buf);
-			goto done;
 		case SIOCGSTAMP: /* borrowed from IP */
 			if (!vcc->sk->stamp.tv_sec) {
-				ret_val = -ENOENT;
+				error = -ENOENT;
 				goto done;
 			}
-			ret_val = copy_to_user((void *) arg, &vcc->sk->stamp,
-			    sizeof(struct timeval)) ? -EFAULT : 0;
+			error = copy_to_user((void *) arg, &vcc->sk->stamp,
+					     sizeof(struct timeval)) ? -EFAULT : 0;
 			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
-			ret_val = 0;
+			error = 0;
 			goto done;
 		case ATMSIGD_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			/*
@@ -697,28 +619,28 @@
 			 * have the same privledges that /proc/kcore needs
 			 */
 			if (!capable(CAP_SYS_RAWIO)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			error = sigd_attach(vcc);
-			if (!error) sock->state = SS_CONNECTED;
-			ret_val = error;
+			if (!error)
+				sock->state = SS_CONNECTED;
 			goto done;
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 		case SIOCMKCLIP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_create(arg);
+				error = atm_clip_ops->clip_create(arg);
 				__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARPD_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_CLIP_MODULE)
@@ -730,48 +652,47 @@
 				__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
 				if (!error)
 					sock->state = SS_CONNECTED;
-				ret_val = error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_MKIP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_mkip(vcc, arg);
+				error = atm_clip_ops->clip_mkip(vcc, arg);
 				__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_SETENTRY:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_setentry(vcc, arg);
+				error = atm_clip_ops->clip_setentry(vcc, arg);
 				__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_ENCAP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_encap(vcc, arg);
+				error = atm_clip_ops->clip_encap(vcc, arg);
 				__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
                 case ATMLEC_CTRL:
                         if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_LANE_MODULE)
@@ -783,37 +704,36 @@
 				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 				if (error >= 0)
 					sock->state = SS_CONNECTED;
-				ret_val =  error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
                 case ATMLEC_MCAST:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_lane_ops()) {
-				ret_val = atm_lane_ops->mcast_attach(vcc, (int) arg);
+				error = atm_lane_ops->mcast_attach(vcc, (int) arg);
 				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
                 case ATMLEC_DATA:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_lane_ops()) {
-				ret_val = atm_lane_ops->vcc_attach(vcc, (void *) arg);
+				error = atm_lane_ops->vcc_attach(vcc, (void *) arg);
 				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
 		case ATMMPC_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_MPOA_MODULE)
@@ -825,63 +745,62 @@
 				__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
 				if (error >= 0)
 					sock->state = SS_CONNECTED;
-				ret_val = error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMMPC_DATA:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_mpoa_ops()) {
-				ret_val = atm_mpoa_ops->vcc_attach(vcc, arg);
+				error = atm_mpoa_ops->vcc_attach(vcc, arg);
 				__MOD_DEC_USE_COUNT(atm_mpoa_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
 		case SIOCSIFATMTCP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.attach) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
-			fops_get (&atm_tcp_ops);
-			error = atm_tcp_ops.attach(vcc,(int) arg);
-			if (error >= 0) sock->state = SS_CONNECTED;
-			else            fops_put (&atm_tcp_ops);
-			ret_val = error;
+			fops_get(&atm_tcp_ops);
+			error = atm_tcp_ops.attach(vcc, (int) arg);
+			if (error >= 0)
+				sock->state = SS_CONNECTED;
+			else
+				fops_put (&atm_tcp_ops);
 			goto done;
 		case ATMTCP_CREATE:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.create_persistent) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
 			error = atm_tcp_ops.create_persistent((int) arg);
-			if (error < 0) fops_put (&atm_tcp_ops);
-			ret_val = error;
+			if (error < 0)
+				fops_put(&atm_tcp_ops);
 			goto done;
 		case ATMTCP_REMOVE:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.remove_persistent) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
 			error = atm_tcp_ops.remove_persistent((int) arg);
-			fops_put (&atm_tcp_ops);
-			ret_val = error;
+			fops_put(&atm_tcp_ops);
 			goto done;
 #endif
 		default:
@@ -889,183 +808,23 @@
 	}
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
 	if (pppoatm_ioctl_hook) {
-		ret_val = pppoatm_ioctl_hook(vcc, cmd, arg);
-		if (ret_val != -ENOIOCTLCMD)
+		error = pppoatm_ioctl_hook(vcc, cmd, arg);
+		if (error != -ENOIOCTLCMD)
 			goto done;
 	}
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
 	if (br2684_ioctl_hook) {
-		ret_val = br2684_ioctl_hook(vcc, cmd, arg);
-		if (ret_val != -ENOIOCTLCMD)
+		error = br2684_ioctl_hook(vcc, cmd, arg);
+		if (error != -ENOIOCTLCMD)
 			goto done;
 	}
 #endif
 
-	if (get_user(buf,&((struct atmif_sioc *) arg)->arg)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (get_user(len,&((struct atmif_sioc *) arg)->length)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (get_user(number,&((struct atmif_sioc *) arg)->number)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (!(dev = atm_dev_lookup(number))) {
-		ret_val = -ENODEV;
-		goto done;
-	}
-	
-	size = 0;
-	switch (cmd) {
-		case ATM_GETTYPE:
-			size = strlen(dev->type)+1;
-			if (copy_to_user(buf,dev->type,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_GETESI:
-			size = ESI_LEN;
-			if (copy_to_user(buf,dev->esi,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_SETESI:
-			{
-				int i;
-
-				for (i = 0; i < ESI_LEN; i++)
-					if (dev->esi[i]) {
-						ret_val = -EEXIST;
-						goto done_release;
-					}
-			}
-			/* fall through */
-		case ATM_SETESIF:
-			{
-				unsigned char esi[ESI_LEN];
-
-				if (!capable(CAP_NET_ADMIN)) {
-					ret_val = -EPERM;
-					goto done_release;
-				}
-				if (copy_from_user(esi,buf,ESI_LEN)) {
-					ret_val = -EFAULT;
-					goto done_release;
-				}
-				memcpy(dev->esi,esi,ESI_LEN);
-				ret_val =  ESI_LEN;
-				goto done_release;
-			}
-		case ATM_GETSTATZ:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			/* fall through */
-		case ATM_GETSTAT:
-			size = sizeof(struct atm_dev_stats);
-			error = fetch_stats(dev,buf,cmd == ATM_GETSTATZ);
-			if (error) {
-				ret_val = error;
-				goto done_release;
-			}
-			break;
-		case ATM_GETCIRANGE:
-			size = sizeof(struct atm_cirange);
-			if (copy_to_user(buf,&dev->ci_range,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_GETLINKRATE:
-			size = sizeof(int);
-			if (copy_to_user(buf,&dev->link_rate,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_RSTADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			atm_reset_addr(dev);
-			break;
-		case ATM_ADDADDR:
-		case ATM_DELADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			{
-				struct sockaddr_atmsvc addr;
-
-				if (copy_from_user(&addr,buf,sizeof(addr))) {
-					ret_val = -EFAULT;
-					goto done_release;
-				}
-				if (cmd == ATM_ADDADDR)
-					ret_val = atm_add_addr(dev,&addr);
-				else
-					ret_val = atm_del_addr(dev,&addr);
-				goto done_release;
-			}
-		case ATM_GETADDR:
-			size = atm_get_addr(dev,buf,len);
-			if (size < 0)
-				ret_val = size;
-			else
-			/* may return 0, but later on size == 0 means "don't
-			   write the length" */
-				ret_val = put_user(size,
-						   &((struct atmif_sioc *) arg)->length) ? -EFAULT : 0;
-			goto done_release;
-		case ATM_SETLOOP:
-			if (__ATM_LM_XTRMT((int) (long) buf) &&
-			    __ATM_LM_XTLOC((int) (long) buf) >
-			    __ATM_LM_XTRMT((int) (long) buf)) {
-				ret_val = -EINVAL;
-				goto done_release;
-			}
-			/* fall through */
-		case ATM_SETCIRANGE:
-		case SONET_GETSTATZ:
-		case SONET_SETDIAG:
-		case SONET_CLRDIAG:
-		case SONET_SETFRAMING:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			/* fall through */
-		default:
-			if (!dev->ops->ioctl) {
-				ret_val = -EINVAL;
-				goto done_release;
-			}
-			size = dev->ops->ioctl(dev,cmd,buf);
-			if (size < 0) {
-				ret_val = (size == -ENOIOCTLCMD ? -EINVAL : size);
-				goto done_release;
-			}
-	}
-	
-	if (size)
-		ret_val =  put_user(size,&((struct atmif_sioc *) arg)->length) ?
-			-EFAULT : 0;
-	else
-		ret_val = 0;
-done_release:
-	atm_dev_release(dev);
+	error = atm_dev_ioctl(cmd, arg);
 
 done:
-	return ret_val;
+	return error;
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 30 13:21:27 2003
+++ b/net/atm/common.h	Mon Jun 30 13:21:27 2003
@@ -18,7 +18,7 @@
 int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
   struct scm_cookie *scm);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
-int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg);
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
     int optlen);
 int atm_getsockopt(struct socket *sock,int level,int optname,char *optval,
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Jun 30 13:21:27 2003
+++ b/net/atm/pvc.c	Mon Jun 30 13:21:27 2003
@@ -74,24 +74,24 @@
 
 
 static struct proto_ops SOCKOPS_WRAPPED(pvc_proto_ops) = {
-	family:		PF_ATMPVC,
+	.family =	PF_ATMPVC,
 
-	release:	atm_release,
-	bind:		pvc_bind,
-	connect:	pvc_connect,
-	socketpair:	sock_no_socketpair,
-	accept:		sock_no_accept,
-	getname:	pvc_getname,
-	poll:		atm_poll,
-	ioctl:		atm_ioctl,
-	listen:		sock_no_listen,
-	shutdown:	pvc_shutdown,
-	setsockopt:	atm_setsockopt,
-	getsockopt:	atm_getsockopt,
-	sendmsg:	atm_sendmsg,
-	recvmsg:	atm_recvmsg,
-	mmap:		sock_no_mmap,
-	sendpage:	sock_no_sendpage,
+	.release =	atm_release,
+	.bind =		pvc_bind,
+	.connect =	pvc_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	pvc_getname,
+	.poll =		atm_poll,
+	.ioctl =	vcc_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	pvc_shutdown,
+	.setsockopt =	atm_setsockopt,
+	.getsockopt =	atm_getsockopt,
+	.sendmsg =	atm_sendmsg,
+	.recvmsg =	atm_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
 };
 
 
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	Mon Jun 30 13:21:27 2003
+++ b/net/atm/resources.c	Mon Jun 30 13:21:27 2003
@@ -7,6 +7,7 @@
 #include <linux/ctype.h>
 #include <linux/string.h>
 #include <linux/atmdev.h>
+#include <linux/sonet.h>
 #include <linux/kernel.h> /* for barrier */
 #include <linux/module.h>
 #include <linux/bitops.h>
@@ -15,6 +16,7 @@
 
 #include "common.h"
 #include "resources.h"
+#include "addr.h"
 
 
 #ifndef NULL
@@ -170,6 +172,240 @@
 		dev->ops->dev_close(dev);
 	atm_dev_deregister(dev);
 }
+
+
+static void copy_aal_stats(struct k_atm_aal_stats *from,
+    struct atm_aal_stats *to)
+{
+#define __HANDLE_ITEM(i) to->i = atomic_read(&from->i)
+	__AAL_STAT_ITEMS
+#undef __HANDLE_ITEM
+}
+
+
+static void subtract_aal_stats(struct k_atm_aal_stats *from,
+    struct atm_aal_stats *to)
+{
+#define __HANDLE_ITEM(i) atomic_sub(to->i, &from->i)
+	__AAL_STAT_ITEMS
+#undef __HANDLE_ITEM
+}
+
+
+static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats *arg, int zero)
+{
+	struct atm_dev_stats tmp;
+	int error = 0;
+
+	copy_aal_stats(&dev->stats.aal0, &tmp.aal0);
+	copy_aal_stats(&dev->stats.aal34, &tmp.aal34);
+	copy_aal_stats(&dev->stats.aal5, &tmp.aal5);
+	if (arg)
+		error = copy_to_user(arg, &tmp, sizeof(tmp));
+	if (zero && !error) {
+		subtract_aal_stats(&dev->stats.aal0, &tmp.aal0);
+		subtract_aal_stats(&dev->stats.aal34, &tmp.aal34);
+		subtract_aal_stats(&dev->stats.aal5, &tmp.aal5);
+	}
+	return error ? -EFAULT : 0;
+}
+
+
+int atm_dev_ioctl(unsigned int cmd, unsigned long arg)
+{
+	void *buf;
+	int error, len, number, size = 0;
+	struct atm_dev *dev;
+	struct list_head *p;
+	int *tmp_buf, *tmp_p;
+
+	switch (cmd) {
+		case ATM_GETNAMES:
+			if (get_user(buf, &((struct atm_iobuf *) arg)->buffer))
+				return -EFAULT;
+			if (get_user(len, &((struct atm_iobuf *) arg)->length))
+				return -EFAULT;
+			spin_lock(&atm_dev_lock);
+			list_for_each(p, &atm_devs)
+				size += sizeof(int);
+			if (size > len) {
+				spin_unlock(&atm_dev_lock);
+				return -E2BIG;
+			}
+			tmp_buf = kmalloc(size, GFP_ATOMIC);
+			if (!tmp_buf) {
+				spin_unlock(&atm_dev_lock);
+				return -ENOMEM;
+			}
+			tmp_p = tmp_buf;
+			list_for_each(p, &atm_devs) {
+				dev = list_entry(p, struct atm_dev, dev_list);
+				*tmp_p++ = dev->number;
+			}
+			spin_unlock(&atm_dev_lock);
+		        error = ((copy_to_user(buf, tmp_buf, size)) ||
+					put_user(size, &((struct atm_iobuf *) arg)->length))
+						? -EFAULT : 0;
+			kfree(tmp_buf);
+			return error;
+		default:
+			break;
+	}
+
+	if (get_user(buf, &((struct atmif_sioc *) arg)->arg))
+		return -EFAULT;
+	if (get_user(len, &((struct atmif_sioc *) arg)->length))
+		return -EFAULT;
+	if (get_user(number, &((struct atmif_sioc *) arg)->number))
+		return -EFAULT;
+
+	if (!(dev = atm_dev_lookup(number)))
+		return -ENODEV;
+	
+	switch (cmd) {
+		case ATM_GETTYPE:
+			size = strlen(dev->type) + 1;
+			if (copy_to_user(buf, dev->type, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_GETESI:
+			size = ESI_LEN;
+			if (copy_to_user(buf, dev->esi, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_SETESI:
+			{
+				int i;
+
+				for (i = 0; i < ESI_LEN; i++)
+					if (dev->esi[i]) {
+						error = -EEXIST;
+						goto done;
+					}
+			}
+			/* fall through */
+		case ATM_SETESIF:
+			{
+				unsigned char esi[ESI_LEN];
+
+				if (!capable(CAP_NET_ADMIN)) {
+					error = -EPERM;
+					goto done;
+				}
+				if (copy_from_user(esi, buf, ESI_LEN)) {
+					error = -EFAULT;
+					goto done;
+				}
+				memcpy(dev->esi, esi, ESI_LEN);
+				error =  ESI_LEN;
+				goto done;
+			}
+		case ATM_GETSTATZ:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			/* fall through */
+		case ATM_GETSTAT:
+			size = sizeof(struct atm_dev_stats);
+			error = fetch_stats(dev, buf, cmd == ATM_GETSTATZ);
+			if (error)
+				goto done;
+			break;
+		case ATM_GETCIRANGE:
+			size = sizeof(struct atm_cirange);
+			if (copy_to_user(buf, &dev->ci_range, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_GETLINKRATE:
+			size = sizeof(int);
+			if (copy_to_user(buf, &dev->link_rate, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_RSTADDR:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			atm_reset_addr(dev);
+			break;
+		case ATM_ADDADDR:
+		case ATM_DELADDR:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			{
+				struct sockaddr_atmsvc addr;
+
+				if (copy_from_user(&addr, buf, sizeof(addr))) {
+					error = -EFAULT;
+					goto done;
+				}
+				if (cmd == ATM_ADDADDR)
+					error = atm_add_addr(dev, &addr);
+				else
+					error = atm_del_addr(dev, &addr);
+				goto done;
+			}
+		case ATM_GETADDR:
+			error = atm_get_addr(dev, buf, len);
+			if (error < 0)
+				goto done;
+			size = error;
+			/* may return 0, but later on size == 0 means "don't
+			   write the length" */
+			error = put_user(size, &((struct atmif_sioc *) arg)->length)
+				? -EFAULT : 0;
+			goto done;
+		case ATM_SETLOOP:
+			if (__ATM_LM_XTRMT((int) (long) buf) &&
+			    __ATM_LM_XTLOC((int) (long) buf) >
+			    __ATM_LM_XTRMT((int) (long) buf)) {
+				error = -EINVAL;
+				goto done;
+			}
+			/* fall through */
+		case ATM_SETCIRANGE:
+		case SONET_GETSTATZ:
+		case SONET_SETDIAG:
+		case SONET_CLRDIAG:
+		case SONET_SETFRAMING:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			/* fall through */
+		default:
+			if (!dev->ops->ioctl) {
+				error = -EINVAL;
+				goto done;
+			}
+			size = dev->ops->ioctl(dev, cmd, buf);
+			if (size < 0) {
+				error = (size == -ENOIOCTLCMD ? -EINVAL : size);
+				goto done;
+			}
+	}
+	
+	if (size)
+		error = put_user(size, &((struct atmif_sioc *) arg)->length)
+			? -EFAULT : 0;
+	else
+		error = 0;
+done:
+	atm_dev_release(dev);
+	return error;
+}
+
 
 
 /* Handler for sk->destruct, invoked by sk_free() */
diff -Nru a/net/atm/resources.h b/net/atm/resources.h
--- a/net/atm/resources.h	Mon Jun 30 13:21:27 2003
+++ b/net/atm/resources.h	Mon Jun 30 13:21:27 2003
@@ -16,6 +16,7 @@
 
 struct sock *alloc_atm_vcc_sk(int family);
 void free_atm_vcc_sk(struct sock *sk);
+int atm_dev_ioctl(unsigned int cmd, unsigned long arg);
 
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 30 13:21:27 2003
+++ b/net/atm/svc.c	Mon Jun 30 13:21:27 2003
@@ -392,24 +392,24 @@
 
 
 static struct proto_ops SOCKOPS_WRAPPED(svc_proto_ops) = {
-	family:		PF_ATMSVC,
+	.family =	PF_ATMSVC,
 
-	release:	svc_release,
-	bind:		svc_bind,
-	connect:	svc_connect,
-	socketpair:	sock_no_socketpair,
-	accept:		svc_accept,
-	getname:	svc_getname,
-	poll:		atm_poll,
-	ioctl:		atm_ioctl,
-	listen:		svc_listen,
-	shutdown:	svc_shutdown,
-	setsockopt:	svc_setsockopt,
-	getsockopt:	svc_getsockopt,
-	sendmsg:	atm_sendmsg,
-	recvmsg:	atm_recvmsg,
-	mmap:		sock_no_mmap,
-	sendpage:	sock_no_sendpage,
+	.release =	svc_release,
+	.bind =		svc_bind,
+	.connect =	svc_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	svc_accept,
+	.getname =	svc_getname,
+	.poll =		atm_poll,
+	.ioctl =	vcc_ioctl,
+	.listen =	svc_listen,
+	.shutdown =	svc_shutdown,
+	.setsockopt =	svc_setsockopt,
+	.getsockopt =	svc_getsockopt,
+	.sendmsg =	atm_sendmsg,
+	.recvmsg =	atm_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
 };
 



[atm]: cleanup warnings during compiles
 
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1017  -> 1.1018 
#	       net/atm/lec.c	1.17    -> 1.18   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/28	chas@relax.cmf.nrl.navy.mil	1.1018
# lec.c:
#   cleanup warnings during compiles
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 30 13:21:08 2003
+++ b/net/atm/lec.c	Mon Jun 30 13:21:08 2003
@@ -37,6 +37,10 @@
 #include <linux/if_bridge.h>
 #include "../bridge/br_private.h"
 static unsigned char bridge_ula_lec[] = {0x01, 0x80, 0xc2, 0x00, 0x00};
+
+extern struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
+       unsigned char *addr);
+extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 #endif
 
 /* Modular too */
@@ -52,10 +56,6 @@
 #else
 #define DPRINTK(format,args...)
 #endif
-
-extern struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
-	unsigned char *addr);
-extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
 #define DUMP_PACKETS 0 /* 0 = None,
                         * 1 = 30 first bytes



[atm]: send queued packets right after path switch completes

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1018  -> 1.1019 
#	       net/atm/lec.c	1.18    -> 1.19   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/28	chas@relax.cmf.nrl.navy.mil	1.1019
# lec.c:
#   send queued packets right after path switch completes
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 30 13:20:52 2003
+++ b/net/atm/lec.c	Mon Jun 30 13:20:52 2003
@@ -207,6 +207,22 @@
         return 0;
 }
 
+static __inline__ void
+lec_send(struct atm_vcc *vcc, struct sk_buff *skb, struct lec_priv *priv)
+{
+	if (atm_may_send(vcc, skb->len)) {
+		atomic_add(skb->truesize, &vcc->sk->wmem_alloc);
+	        ATM_SKB(skb)->vcc = vcc;
+	        ATM_SKB(skb)->atm_options = vcc->atm_options;
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len;
+		vcc->send(vcc, skb);
+	} else {
+		priv->stats.tx_dropped++;
+		dev_kfree_skb(skb);
+	}
+}
+
 static int 
 lec_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
@@ -351,33 +367,10 @@
                 DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
                         lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
                         lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
-                ATM_SKB(skb2)->vcc = send_vcc;
-                ATM_SKB(skb2)->atm_options = send_vcc->atm_options;
-                DPRINTK("%s:sending to vpi:%d vci:%d\n", dev->name,
-                        send_vcc->vpi, send_vcc->vci);       
-                if (atm_may_send(send_vcc, skb2->len)) {
-			atomic_add(skb2->truesize, &send_vcc->sk->wmem_alloc);
-                        priv->stats.tx_packets++;
-                        priv->stats.tx_bytes += skb2->len;
-                        send_vcc->send(send_vcc, skb2);
-                } else {
-                        priv->stats.tx_dropped++;
-                        dev_kfree_skb(skb2);
-		}
+                lec_send(send_vcc, skb2, priv);
         }
 
-        ATM_SKB(skb)->vcc = send_vcc;
-        ATM_SKB(skb)->atm_options = send_vcc->atm_options;
-        if (atm_may_send(send_vcc, skb->len)) {
-                atomic_add(skb->truesize, &send_vcc->sk->wmem_alloc);
-                priv->stats.tx_packets++;
-                priv->stats.tx_bytes += skb->len;
-                send_vcc->send(send_vcc, skb);
-        } else {
-                priv->stats.tx_dropped++;
-                dev_kfree_skb(skb);
-	}
-
+        lec_send(send_vcc, skb, priv);
 #if 0
         /* Should we wait for card's device driver to notify us? */
         dev->tbusy=0;
@@ -1617,6 +1610,10 @@
                                            &&
                                            time_after_eq(now, entry->timestamp+
                                            priv->path_switching_delay)) {
+			                        struct sk_buff *skb;
+
+ 				                while ((skb = skb_dequeue(&entry->tx_wait)))
+					                lec_send(entry->vcc, skb, entry->priv);
                                                 entry->last_used = jiffies;
                                                 entry->status = 
                                                         ESI_FORWARD_DIRECT;
@@ -2010,6 +2007,10 @@
                 for (entry=priv->lec_arp_tables[i];entry;entry=entry->next) {
                         if (entry->flush_tran_id == tran_id &&
                             entry->status == ESI_FLUSH_PENDING) {
+			        struct sk_buff *skb;
+
+ 				while ((skb = skb_dequeue(&entry->tx_wait)))
+					lec_send(entry->vcc, skb, entry->priv);
                                 entry->status = ESI_FORWARD_DIRECT;
                                 DPRINTK("LEC_ARP: Flushed\n");
                         }


[atm]: cleanup pppoatm_ioctl_hook

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1019  -> 1.1020 
#	   net/atm/pppoatm.c	1.5     -> 1.6    
#	    net/atm/common.h	1.3     -> 1.4    
#	    net/atm/common.c	1.19    -> 1.20   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/28	chas@relax.cmf.nrl.navy.mil	1.1020
# pppoatm.c, common.h, common.c:
#   cleanup pppoatm_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 30 13:20:21 2003
+++ b/net/atm/common.c	Mon Jun 30 13:20:21 2003
@@ -130,8 +130,19 @@
 #endif
 
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-EXPORT_SYMBOL(pppoatm_ioctl_hook);
+static DECLARE_MUTEX(pppoatm_ioctl_mutex);
+
+static int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&pppoatm_ioctl_mutex);
+	pppoatm_ioctl_hook = hook;
+	up(&pppoatm_ioctl_mutex);
+}
+#ifdef CONFIG_PPPOATM_MODULE
+EXPORT_SYMBOL(pppoatm_ioctl_set);
+#endif
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
@@ -806,12 +817,14 @@
 		default:
 			break;
 	}
+	error = -ENOIOCTLCMD;
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-	if (pppoatm_ioctl_hook) {
+	down(&pppoatm_ioctl_mutex);
+	if (pppoatm_ioctl_hook)
 		error = pppoatm_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&pppoatm_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
 	if (br2684_ioctl_hook) {
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 30 13:20:21 2003
+++ b/net/atm/common.h	Mon Jun 30 13:20:21 2003
@@ -28,6 +28,8 @@
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+
 int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Mon Jun 30 13:20:21 2003
+++ b/net/atm/pppoatm.c	Mon Jun 30 13:20:21 2003
@@ -44,6 +44,8 @@
 #include <linux/ppp_channel.h>
 #include <linux/atmppp.h>
 
+#include "common.h"
+
 #if 0
 #define DPRINTK(format, args...) \
 	printk(KERN_DEBUG "pppoatm: " format, ##args)
@@ -344,17 +346,15 @@
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
-extern int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 static int __init UNUSED pppoatm_init(void)
 {
-	pppoatm_ioctl_hook = pppoatm_ioctl;
+	pppoatm_ioctl_set(pppoatm_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED pppoatm_exit(void)
 {
-	pppoatm_ioctl_hook = NULL;
+	pppoatm_ioctl_set(NULL);
 }
 
 module_init(pppoatm_init);




[atm]: cleanup br2684_ioctl_hook

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1020  -> 1.1021 
#	    net/atm/common.h	1.4     -> 1.5    
#	    net/atm/common.c	1.20    -> 1.21   
#	    net/atm/br2684.c	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/28	chas@relax.cmf.nrl.navy.mil	1.1021
# common.h, common.c, br2684.c:
#   cleanup br2684_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Jun 30 13:20:06 2003
+++ b/net/atm/br2684.c	Mon Jun 30 13:20:06 2003
@@ -16,9 +16,12 @@
 #include <linux/ip.h>
 #include <asm/uaccess.h>
 #include <net/arp.h>
+#include <linux/atm.h>
+#include <linux/atmdev.h>
 
 #include <linux/atmbr2684.h>
 
+#include "common.h"
 #include "ipcommon.h"
 
 /*
@@ -768,8 +771,6 @@
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
 
-extern int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
@@ -779,14 +780,14 @@
 	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
 		return -ENOMEM;
 	p->proc_fops = &br2684_proc_operations;
-	br2684_ioctl_hook = br2684_ioctl;
+	br2684_ioctl_set(br2684_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED br2684_exit(void)
 {
 	struct br2684_dev *brdev;
-	br2684_ioctl_hook = NULL;
+	br2684_ioctl_set(NULL);
 	remove_proc_entry("br2684", atm_proc_root);
 	while (!list_empty(&br2684_devs)) {
 		brdev = list_entry_brdev(br2684_devs.next);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 30 13:20:06 2003
+++ b/net/atm/common.c	Mon Jun 30 13:20:06 2003
@@ -146,10 +146,19 @@
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-#endif
+static DECLARE_MUTEX(br2684_ioctl_mutex);
+ 
+static int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+ 
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&br2684_ioctl_mutex);
+	br2684_ioctl_hook = hook;
+	up(&br2684_ioctl_mutex);
+}
 #ifdef CONFIG_ATM_BR2684_MODULE
-EXPORT_SYMBOL(br2684_ioctl_hook);
+EXPORT_SYMBOL(br2684_ioctl_set);
+#endif
 #endif
 
 #include "resources.h"		/* atm_find_dev */
@@ -827,11 +836,12 @@
 		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-	if (br2684_ioctl_hook) {
+	down(&br2684_ioctl_mutex);
+	if (br2684_ioctl_hook)
 		error = br2684_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&br2684_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 
 	error = atm_dev_ioctl(cmd, arg);
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 30 13:20:06 2003
+++ b/net/atm/common.h	Mon Jun 30 13:20:06 2003
@@ -29,6 +29,7 @@
 void atm_shutdown_dev(struct atm_dev *dev);
 
 void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
 
 int atmpvc_init(void);
 void atmpvc_exit(void);

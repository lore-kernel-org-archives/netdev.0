From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2 of 7][ATM]: [lec] rewrite to eliminate lec_arp_users in favor of lec_arp_lock
Date: Tue, 18 Jan 2005 14:03:50 -0500
Message-ID: <200501181903.j0IJ3oxB022242@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/06 13:15:38-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lec] rewrite to eliminate lec_arp_users in favor of lec_arp_lock
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.h
#   2005/01/06 13:15:22-05:00 chas@relax.cmf.nrl.navy.mil +0 -1
#   [ATM]: [lec] rewrite to eliminate lec_arp_users in favor of lec_arp_lock
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.c
#   2005/01/06 13:15:21-05:00 chas@relax.cmf.nrl.navy.mil +157 -165
#   [ATM]: [lec] rewrite to eliminate lec_arp_users in favor of lec_arp_lock
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	2005-01-14 08:42:30 -05:00
+++ b/net/atm/lec.c	2005-01-14 08:42:30 -05:00
@@ -422,6 +422,7 @@
 static int 
 lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
+	unsigned long flags;
         struct net_device *dev = (struct net_device*)vcc->proto_data;
         struct lec_priv *priv = (struct lec_priv*)dev->priv;
         struct atmlec_msg *mesg;
@@ -456,8 +457,10 @@
                 lec_flush_complete(priv, mesg->content.normal.flag);
                 break;
         case l_narp_req: /* LANE2: see 7.1.35 in the lane2 spec */
+		spin_lock_irqsave(&priv->lec_arp_lock, flags);
                 entry = lec_arp_find(priv, mesg->content.normal.mac_addr);
                 lec_arp_remove(priv, entry);
+		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
                 if (mesg->content.normal.no_source_le_narp)
                         break;
@@ -1222,17 +1225,20 @@
 static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
     u8 **tlvs, u32 *sizeoftlvs)
 {
+	unsigned long flags;
         struct lec_priv *priv = (struct lec_priv *)dev->priv;
         struct lec_arp_table *table;
         struct sk_buff *skb;
         int retval;
 
         if (force == 0) {
+		spin_lock_irqsave(&priv->lec_arp_lock, flags);
                 table = lec_arp_find(priv, dst_mac);
+		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 if(table == NULL)
                         return -1;
                 
-                *tlvs = kmalloc(table->sizeoftlvs, GFP_KERNEL);
+                *tlvs = kmalloc(table->sizeoftlvs, GFP_ATOMIC);
                 if (*tlvs == NULL)
                         return -1;
                 
@@ -1377,18 +1383,6 @@
 
 #define HASH(ch) (ch & (LEC_ARP_TABLE_SIZE -1))
 
-static __inline__ void 
-lec_arp_get(struct lec_priv *priv)
-{
-        atomic_inc(&priv->lec_arp_users);
-}
-
-static __inline__ void 
-lec_arp_put(struct lec_priv *priv)
-{
-        atomic_dec(&priv->lec_arp_users);
-}
-
 /*
  * Initialization of arp-cache
  */
@@ -1397,12 +1391,12 @@
 {
         unsigned short i;
 
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
+        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
                 priv->lec_arp_tables[i] = NULL;
         }        
 	spin_lock_init(&priv->lec_arp_lock);
         init_timer(&priv->lec_arp_timer);
-        priv->lec_arp_timer.expires = jiffies+LEC_ARP_REFRESH_INTERVAL;
+        priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
         priv->lec_arp_timer.data = (unsigned long)priv;
         priv->lec_arp_timer.function = lec_arp_check_expire;
         add_timer(&priv->lec_arp_timer);
@@ -1439,12 +1433,9 @@
 static inline void 
 lec_arp_add(struct lec_priv *priv, struct lec_arp_table *to_add)
 {
-        unsigned long flags;
         unsigned short place;
         struct lec_arp_table *tmp;
 
-        spin_lock_irqsave(&priv->lec_arp_lock, flags);
-
         place = HASH(to_add->mac_addr[ETH_ALEN-1]);
         tmp = priv->lec_arp_tables[place];
         to_add->next = NULL;
@@ -1457,8 +1448,6 @@
                 tmp->next = to_add;
         }
 
-        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-
         DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_add->mac_addr[0], 0xff&to_add->mac_addr[1],
                 0xff&to_add->mac_addr[2], 0xff&to_add->mac_addr[3],
@@ -1472,15 +1461,11 @@
 lec_arp_remove(struct lec_priv *priv,
                struct lec_arp_table *to_remove)
 {
-        unsigned long flags;
         unsigned short place;
         struct lec_arp_table *tmp;
         int remove_vcc=1;
 
-        spin_lock_irqsave(&priv->lec_arp_lock, flags);
-
         if (!to_remove) {
-                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 return -1;
         }
         place = HASH(to_remove->mac_addr[ETH_ALEN-1]);
@@ -1492,7 +1477,6 @@
                         tmp = tmp->next;
                 }
                 if (!tmp) {/* Entry was not found */
-                        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                         return -1;
                 }
         }
@@ -1505,7 +1489,7 @@
                 /*
                  * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
                  */
-                for(place=0;place<LEC_ARP_TABLE_SIZE;place++) {
+                for(place = 0; place < LEC_ARP_TABLE_SIZE; place++) {
                         for(tmp = priv->lec_arp_tables[place]; tmp != NULL; tmp = tmp->next) {
                                 if (memcmp(tmp->atm_addr, to_remove->atm_addr,
                                            ATM_ESA_LEN)==0) {
@@ -1519,8 +1503,6 @@
         }
         skb_queue_purge(&to_remove->tx_wait); /* FIXME: good place for this? */
 
-        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-
         DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_remove->mac_addr[0], 0xff&to_remove->mac_addr[1],
                 0xff&to_remove->mac_addr[2], 0xff&to_remove->mac_addr[3],
@@ -1704,6 +1686,7 @@
 void
 lec_arp_destroy(struct lec_priv *priv)
 {
+	unsigned long flags;
         struct lec_arp_table *entry, *next;
         int i;
 
@@ -1712,8 +1695,10 @@
         /*
          * Remove all entries
          */
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for(entry =priv->lec_arp_tables[i];entry != NULL; entry=next) {
+
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+                for(entry = priv->lec_arp_tables[i]; entry != NULL; entry=next) {
                         next = entry->next;
                         lec_arp_remove(priv, entry);
                         kfree(entry);
@@ -1748,7 +1733,8 @@
         priv->mcast_fwds = NULL;
         priv->mcast_vcc = NULL;
         memset(priv->lec_arp_tables, 0, 
-               sizeof(struct lec_arp_table*)*LEC_ARP_TABLE_SIZE);
+               sizeof(struct lec_arp_table *) * LEC_ARP_TABLE_SIZE);
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
 
@@ -1765,18 +1751,15 @@
         DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 mac_addr[0]&0xff, mac_addr[1]&0xff, mac_addr[2]&0xff, 
                 mac_addr[3]&0xff, mac_addr[4]&0xff, mac_addr[5]&0xff);
-        lec_arp_get(priv);
         place = HASH(mac_addr[ETH_ALEN-1]);
   
         to_return = priv->lec_arp_tables[place];
         while(to_return) {
                 if (memcmp(mac_addr, to_return->mac_addr, ETH_ALEN) == 0) {
-                        lec_arp_put(priv);
                         return to_return;
                 }
                 to_return = to_return->next;
         }
-        lec_arp_put(priv);
         return NULL;
 }
 
@@ -1785,17 +1768,17 @@
 {
         struct lec_arp_table *to_return;
 
-        to_return=(struct lec_arp_table *)kmalloc(sizeof(struct lec_arp_table),
-                                                  GFP_ATOMIC);
+        to_return = (struct lec_arp_table *) kmalloc(sizeof(struct lec_arp_table),
+						     GFP_ATOMIC);
         if (!to_return) {
                 printk("LEC: Arp entry kmalloc failed\n");
                 return NULL;
         }
-        memset(to_return,0,sizeof(struct lec_arp_table));
+        memset(to_return, 0, sizeof(struct lec_arp_table));
         memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
         init_timer(&to_return->timer);
         to_return->timer.function = lec_arp_expire_arp;
-        to_return->timer.data = (unsigned long)to_return;
+        to_return->timer.data = (unsigned long) to_return;
         to_return->last_used = jiffies;
         to_return->priv = priv;
         skb_queue_head_init(&to_return->tx_wait);
@@ -1835,6 +1818,7 @@
 static void
 lec_arp_expire_vcc(unsigned long data)
 {
+	unsigned flags;
         struct lec_arp_table *to_remove = (struct lec_arp_table*)data;
         struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
         struct lec_arp_table *entry = NULL;
@@ -1846,6 +1830,8 @@
                 to_remove->vcc?to_remove->recv_vcc->vpi:0,
                 to_remove->vcc?to_remove->recv_vcc->vci:0);
         DPRINTK("eo:%p nf:%p\n",priv->lec_arp_empty_ones,priv->lec_no_forward);
+
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         if (to_remove == priv->lec_arp_empty_ones)
                 priv->lec_arp_empty_ones = to_remove->next;
         else {
@@ -1866,6 +1852,8 @@
                                 entry->next = to_remove->next;
                 }
 	}
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+
         lec_arp_clear_vccs(to_remove);
         kfree(to_remove);
 }
@@ -1889,69 +1877,67 @@
 static void
 lec_arp_check_expire(unsigned long data)
 {
+	unsigned long flags;
         struct lec_priv *priv = (struct lec_priv *)data;
         struct lec_arp_table *entry, *next;
         unsigned long now;
         unsigned long time_to_check;
         int i;
 
-        DPRINTK("lec_arp_check_expire %p,%d\n",priv,
-                atomic_read(&priv->lec_arp_users));
+        DPRINTK("lec_arp_check_expire %p\n",priv);
         DPRINTK("expire: eo:%p nf:%p\n",priv->lec_arp_empty_ones,
                 priv->lec_no_forward);
-        if (!atomic_read(&priv->lec_arp_users)) {
-                lec_arp_get(priv);
-                now = jiffies;
-                for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                        for(entry = priv->lec_arp_tables[i]; entry != NULL; ) {
-                                if ((entry->flags) & LEC_REMOTE_FLAG && 
-                                    priv->topology_change)
-                                        time_to_check=priv->forward_delay_time;
-                                else
-                                        time_to_check = priv->aging_time;
-
-                                DPRINTK("About to expire: %lx - %lx > %lx\n",
-                                        now,entry->last_used, time_to_check);
-                                if( time_after(now, entry->last_used+
-                                   time_to_check) && 
-                                    !(entry->flags & LEC_PERMANENT_FLAG) &&
-                                    !(entry->mac_addr[0] & 0x01) ) { /* LANE2: 7.1.20 */
-                                        /* Remove entry */
-                                        DPRINTK("LEC:Entry timed out\n");
-                                        next = entry->next;      
-                                        lec_arp_remove(priv, entry);
-                                        kfree(entry);
-                                        entry = next;
-                                } else {
-                                        /* Something else */
-                                        if ((entry->status == ESI_VC_PENDING ||
-                                             entry->status == ESI_ARP_PENDING) 
-                                            && time_after_eq(now,
-                                            entry->timestamp +
-                                            priv->max_unknown_frame_time)) {
-                                                entry->timestamp = jiffies;
-                                                entry->packets_flooded = 0;
-                                                if (entry->status == ESI_VC_PENDING)
-                                                        send_to_lecd(priv, l_svc_setup, entry->mac_addr, entry->atm_addr, NULL);
-                                        }
-                                        if (entry->status == ESI_FLUSH_PENDING 
-                                           &&
-                                           time_after_eq(now, entry->timestamp+
-                                           priv->path_switching_delay)) {
-			                        struct sk_buff *skb;
-
- 				                while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
-					                lec_send(entry->vcc, skb, entry->priv);
-                                                entry->last_used = jiffies;
-                                                entry->status = 
-                                                        ESI_FORWARD_DIRECT;
-                                        }
-                                        entry = entry->next;
-                                }
-                        }
-                }
-                lec_arp_put(priv);
-        }
+	now = jiffies;
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+	for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for(entry = priv->lec_arp_tables[i]; entry != NULL; ) {
+			if ((entry->flags) & LEC_REMOTE_FLAG && 
+			    priv->topology_change)
+				time_to_check = priv->forward_delay_time;
+			else
+				time_to_check = priv->aging_time;
+
+			DPRINTK("About to expire: %lx - %lx > %lx\n",
+				now,entry->last_used, time_to_check);
+			if( time_after(now, entry->last_used+
+			   time_to_check) && 
+			    !(entry->flags & LEC_PERMANENT_FLAG) &&
+			    !(entry->mac_addr[0] & 0x01) ) { /* LANE2: 7.1.20 */
+				/* Remove entry */
+				DPRINTK("LEC:Entry timed out\n");
+				next = entry->next;      
+				lec_arp_remove(priv, entry);
+				kfree(entry);
+				entry = next;
+			} else {
+				/* Something else */
+				if ((entry->status == ESI_VC_PENDING ||
+				     entry->status == ESI_ARP_PENDING) 
+				    && time_after_eq(now,
+				    entry->timestamp +
+				    priv->max_unknown_frame_time)) {
+					entry->timestamp = jiffies;
+					entry->packets_flooded = 0;
+					if (entry->status == ESI_VC_PENDING)
+						send_to_lecd(priv, l_svc_setup, entry->mac_addr, entry->atm_addr, NULL);
+				}
+				if (entry->status == ESI_FLUSH_PENDING 
+				   &&
+				   time_after_eq(now, entry->timestamp+
+				   priv->path_switching_delay)) {
+					struct sk_buff *skb;
+
+					while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
+						lec_send(entry->vcc, skb, entry->priv);
+					entry->last_used = jiffies;
+					entry->status = 
+						ESI_FORWARD_DIRECT;
+				}
+				entry = entry->next;
+			}
+		}
+	}
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
         mod_timer(&priv->lec_arp_timer, jiffies + LEC_ARP_REFRESH_INTERVAL);
 }
@@ -1963,9 +1949,11 @@
 lec_arp_resolve(struct lec_priv *priv, unsigned char *mac_to_find, int is_rdesc,
                 struct lec_arp_table **ret_entry)
 {
+	unsigned long flags;
         struct lec_arp_table *entry;
+	struct atm_vcc *found;
 
-        if (mac_to_find[0]&0x01) {
+        if (mac_to_find[0] & 0x01) {
                 switch (priv->lane_version) {
                 case 1:
                         return priv->mcast_vcc;
@@ -1979,6 +1967,7 @@
                 }
         }
 
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         entry = lec_arp_find(priv, mac_to_find);
   
         if (entry) {
@@ -1986,7 +1975,8 @@
                         /* Connection Ok */
                         entry->last_used = jiffies;
                         *ret_entry = entry;
-                        return entry->vcc;
+                        found = entry->vcc;
+			goto out;
                 }
                 /* Data direct VC not yet set up, check to see if the unknown
                    frame count is greater than the limit. If the limit has
@@ -1996,7 +1986,8 @@
                     entry->packets_flooded<priv->maximum_unknown_frame_count) {
                         entry->packets_flooded++;
                         DPRINTK("LEC_ARP: Flooding..\n");
-                        return priv->mcast_vcc;
+                        found = priv->mcast_vcc;
+			goto out;
                 }
 		/* We got here because entry->status == ESI_FLUSH_PENDING
 		 * or BUS flood limit was reached for an entry which is
@@ -2004,13 +1995,14 @@
 		 */
                 *ret_entry = entry;
                 DPRINTK("lec: entry->status %d entry->vcc %p\n", entry->status, entry->vcc);
-                return NULL;
+                found = NULL;
         } else {
                 /* No matching entry was found */
                 entry = make_entry(priv, mac_to_find);
                 DPRINTK("LEC_ARP: Making entry\n");
                 if (!entry) {
-                        return priv->mcast_vcc;
+                        found = priv->mcast_vcc;
+			goto out;
                 }
                 lec_arp_add(priv, entry);
                 /* We want arp-request(s) to be sent */
@@ -2026,33 +2018,38 @@
                 entry->timer.expires = jiffies + (1*HZ);
                 entry->timer.function = lec_arp_expire_arp;
                 add_timer(&entry->timer);
-                return priv->mcast_vcc;
+                found = priv->mcast_vcc;
         }
+
+out:
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+	return found;
 }
 
 int
 lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr, 
                 unsigned long permanent)
 {
+	unsigned long flags;
         struct lec_arp_table *entry, *next;
         int i;
 
-        lec_arp_get(priv);
         DPRINTK("lec_addr_delete\n");
-        for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for(entry=priv->lec_arp_tables[i];entry != NULL; entry=next) {
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+        for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+                for(entry = priv->lec_arp_tables[i]; entry != NULL; entry = next) {
                         next = entry->next;
                         if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
                             && (permanent || 
                                 !(entry->flags & LEC_PERMANENT_FLAG))) {
-                                lec_arp_remove(priv, entry);
+				lec_arp_remove(priv, entry);
                                 kfree(entry);
                         }
-                        lec_arp_put(priv);
+			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                         return 0;
                 }
         }
-        lec_arp_put(priv);
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
         return -1;
 }
 
@@ -2064,6 +2061,7 @@
                unsigned char *atm_addr, unsigned long remoteflag,
                unsigned int targetless_le_arp)
 {
+	unsigned long flags;
         struct lec_arp_table *entry, *tmp;
         int i;
 
@@ -2072,12 +2070,12 @@
                 mac_addr[0],mac_addr[1],mac_addr[2],mac_addr[3],
                 mac_addr[4],mac_addr[5]);
 
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         entry = lec_arp_find(priv, mac_addr);
         if (entry == NULL && targetless_le_arp)
-                return;   /* LANE2: ignore targetless LE_ARPs for which
-                           * we have no entry in the cache. 7.1.30
-                           */
-        lec_arp_get(priv);
+                goto out;   /* LANE2: ignore targetless LE_ARPs for which
+                             * we have no entry in the cache. 7.1.30
+                             */
         if (priv->lec_arp_empty_ones) {
                 entry = priv->lec_arp_empty_ones;
                 if (!memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN)) {
@@ -2117,27 +2115,24 @@
                                 entry->flags|=LEC_REMOTE_FLAG;
                         else
                                 entry->flags&=~LEC_REMOTE_FLAG;
-                        lec_arp_put(priv);
                         DPRINTK("After update\n");
                         dump_arp_table(priv);
-                        return;
+                        goto out;
                 }
         }
         entry = lec_arp_find(priv, mac_addr);
         if (!entry) {
                 entry = make_entry(priv, mac_addr);
-                if (!entry) {
-                        lec_arp_put(priv);
-                        return;
-                }
+                if (!entry)
+			goto out;
                 entry->status = ESI_UNKNOWN;
                 lec_arp_add(priv, entry);
                 /* Temporary, changes before end of function */
         }
         memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
         del_timer(&entry->timer);
-        for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for(tmp=priv->lec_arp_tables[i];tmp;tmp=tmp->next) {
+        for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+                for(tmp = priv->lec_arp_tables[i]; tmp; tmp=tmp->next) {
                         if (entry != tmp &&
                             !memcmp(tmp->atm_addr, atm_addr,
                                     ATM_ESA_LEN)) { 
@@ -2166,7 +2161,8 @@
         }
         DPRINTK("After update2\n");
         dump_arp_table(priv);
-        lec_arp_put(priv);
+out:
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
 /*
@@ -2177,10 +2173,11 @@
               struct atm_vcc *vcc,
               void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb))
 {
+	unsigned long flags;
         struct lec_arp_table *entry;
         int i, found_entry=0;
 
-        lec_arp_get(priv);
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         if (ioc_data->receive == 2) {
                 /* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
 
@@ -2189,26 +2186,22 @@
                 entry = lec_arp_find(priv, bus_mac);
                 if (!entry) {
                         printk("LEC_ARP: Multicast entry not found!\n");
-                        lec_arp_put(priv);
-                        return;
+			goto out;
                 }
                 memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
                 entry->recv_vcc = vcc;
                 entry->old_recv_push = old_push;
 #endif
                 entry = make_entry(priv, bus_mac);
-                if (entry == NULL) {
-                        lec_arp_put(priv);
-                        return;
-                }
+                if (entry == NULL)
+			goto out;
                 del_timer(&entry->timer);
                 memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
                 entry->recv_vcc = vcc;
                 entry->old_recv_push = old_push;
                 entry->next = priv->mcast_fwds;
                 priv->mcast_fwds = entry;
-                lec_arp_put(priv);
-                return;
+                goto out;
         } else if (ioc_data->receive == 1) {
                 /* Vcc which we don't want to make default vcc, attach it
                    anyway. */
@@ -2224,10 +2217,8 @@
                         ioc_data->atm_addr[16],ioc_data->atm_addr[17],
                         ioc_data->atm_addr[18],ioc_data->atm_addr[19]);
                 entry = make_entry(priv, bus_mac);
-                if (entry == NULL) {
-                        lec_arp_put(priv);
-                        return;
-                }
+                if (entry == NULL)
+			goto out;
                 memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
                 memset(entry->mac_addr, 0, ETH_ALEN);
                 entry->recv_vcc = vcc;
@@ -2238,9 +2229,8 @@
                 add_timer(&entry->timer);
                 entry->next = priv->lec_no_forward;
                 priv->lec_no_forward = entry;
-                lec_arp_put(priv);
 		dump_arp_table(priv);
-                return;
+		goto out;
         }
         DPRINTK("LEC_ARP:Attaching data direct, default:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
                 ioc_data->atm_addr[0],ioc_data->atm_addr[1],
@@ -2253,8 +2243,8 @@
                 ioc_data->atm_addr[14],ioc_data->atm_addr[15],
                 ioc_data->atm_addr[16],ioc_data->atm_addr[17],
                 ioc_data->atm_addr[18],ioc_data->atm_addr[19]);
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for (entry = priv->lec_arp_tables[i];entry;entry=entry->next) {
+        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+                for (entry = priv->lec_arp_tables[i]; entry; entry=entry->next) {
                         if (memcmp(ioc_data->atm_addr, entry->atm_addr, 
                                    ATM_ESA_LEN)==0) {
                                 DPRINTK("LEC_ARP: Attaching data direct\n");
@@ -2297,18 +2287,15 @@
                 }
         }
         if (found_entry) {
-                lec_arp_put(priv);
                 DPRINTK("After vcc was added\n");
                 dump_arp_table(priv);
-                return;
+		goto out;
         }
         /* Not found, snatch address from first data packet that arrives from
            this vcc */
         entry = make_entry(priv, bus_mac);
-        if (!entry) {
-                lec_arp_put(priv);
-                return;
-        }
+        if (!entry)
+		goto out;
         entry->vcc = vcc;
         entry->old_push = old_push;
         memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -2319,20 +2306,23 @@
         entry->timer.expires = jiffies + priv->vcc_timeout_period;
         entry->timer.function = lec_arp_expire_vcc;
         add_timer(&entry->timer);
-        lec_arp_put(priv);
         DPRINTK("After vcc was added\n");
 	dump_arp_table(priv);
+out:
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
 void
 lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 {
+	unsigned long flags;
         struct lec_arp_table *entry;
         int i;
   
         DPRINTK("LEC:lec_flush_complete %lx\n",tran_id);
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for (entry=priv->lec_arp_tables[i];entry;entry=entry->next) {
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+                for (entry = priv->lec_arp_tables[i]; entry; entry=entry->next) {
                         if (entry->flush_tran_id == tran_id &&
                             entry->status == ESI_FLUSH_PENDING) {
 			        struct sk_buff *skb;
@@ -2344,6 +2334,7 @@
                         }
                 }
         }
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
         dump_arp_table(priv);
 }
 
@@ -2351,24 +2342,29 @@
 lec_set_flush_tran_id(struct lec_priv *priv,
                       unsigned char *atm_addr, unsigned long tran_id)
 {
+	unsigned long flags;
         struct lec_arp_table *entry;
         int i;
 
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++)
-                for(entry=priv->lec_arp_tables[i];entry;entry=entry->next)
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
+                for(entry = priv->lec_arp_tables[i]; entry; entry=entry->next)
                         if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
                                 entry->flush_tran_id = tran_id;
                                 DPRINTK("Set flush transaction id to %lx for %p\n",tran_id,entry);
                         }
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
 int 
 lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 {
+	unsigned long flags;
         unsigned char mac_addr[] = {
                 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
         struct lec_arp_table *to_add;
 	struct lec_vcc_priv *vpriv;
+	int err = 0;
   
 	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
 		return -ENOMEM;
@@ -2376,13 +2372,13 @@
 	vpriv->old_pop = vcc->pop;
 	vcc->user_back = vpriv;
         vcc->pop = lec_pop;
-        lec_arp_get(priv);
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         to_add = make_entry(priv, mac_addr);
         if (!to_add) {
-                lec_arp_put(priv);
 		vcc->pop = vpriv->old_pop;
 		kfree(vpriv);
-                return -ENOMEM;
+                err = -ENOMEM;
+		goto out;
         }
         memcpy(to_add->atm_addr, vcc->remote.sas_addr.prv, ATM_ESA_LEN);
         to_add->status = ESI_FORWARD_DIRECT;
@@ -2392,19 +2388,21 @@
         vcc->push = lec_push;
         priv->mcast_vcc = vcc;
         lec_arp_add(priv, to_add);
-        lec_arp_put(priv);
-        return 0;
+out:
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+        return err;
 }
 
 void
 lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 {
+	unsigned long flags;
         struct lec_arp_table *entry, *next;
         int i;
 
         DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n",vcc->vpi,vcc->vci);
         dump_arp_table(priv);
-        lec_arp_get(priv);
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 for(entry = priv->lec_arp_tables[i];entry; entry=next) {
                         next = entry->next;
@@ -2466,7 +2464,7 @@
                 entry = next;
         }
 
-        lec_arp_put(priv);
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 	dump_arp_table(priv);
 }
 
@@ -2486,26 +2484,22 @@
 #endif
         src = hdr->h_source;
 
-        lec_arp_get(priv);
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
         entry = priv->lec_arp_empty_ones;
         if (vcc == entry->vcc) {
-		spin_lock_irqsave(&priv->lec_arp_lock, flags);
                 del_timer(&entry->timer);
                 memcpy(entry->mac_addr, src, ETH_ALEN);
                 entry->status = ESI_FORWARD_DIRECT;
                 entry->last_used = jiffies;
                 priv->lec_arp_empty_ones = entry->next;
-                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
                 /* We might have got an entry */
-                if ((prev=lec_arp_find(priv,src))) {
+                if ((prev = lec_arp_find(priv,src))) {
                         lec_arp_remove(priv, prev);
                         kfree(prev);
                 }
                 lec_arp_add(priv, entry);
-                lec_arp_put(priv);
-                return;
+		goto out;
         }
-        spin_lock_irqsave(&priv->lec_arp_lock, flags);
         prev = entry;
         entry = entry->next;
         while (entry && entry->vcc != vcc) {
@@ -2514,21 +2508,19 @@
         }
         if (!entry) {
                 DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
-                lec_arp_put(priv);
-                spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-                return;
+		goto out;
         }
         del_timer(&entry->timer);
         memcpy(entry->mac_addr, src, ETH_ALEN);
         entry->status = ESI_FORWARD_DIRECT;
         entry->last_used = jiffies;
         prev->next = entry->next;
-        spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
         if ((prev = lec_arp_find(priv, src))) {
                 lec_arp_remove(priv, prev);
                 kfree(prev);
         }
         lec_arp_add(priv, entry);
-        lec_arp_put(priv);  
+out:
+	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 MODULE_LICENSE("GPL");
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	2005-01-14 08:42:30 -05:00
+++ b/net/atm/lec.h	2005-01-14 08:42:30 -05:00
@@ -95,7 +95,6 @@
            establishes multiple Multicast Forward VCCs to us. This list
            collects all those VCCs. LANEv1 client has only one item in this
            list. These entries are not aged out. */
-        atomic_t lec_arp_users;
         spinlock_t lec_arp_lock;
         struct atm_vcc *mcast_vcc; /* Default Multicast Send VCC */
         struct atm_vcc *lecd;

From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] minor cleanups for 2.5
Date: Wed, 16 Jul 2003 17:18:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307162120.h6GLKWsG023003@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

just some cleanup work for the 2.5 kernels.  one biggish
oopsy -- never checked the return code from atm_dev_lookup()
in vcc_connect.  found it last week, and someone else found it
recently as well.  the lec timers now use mod_timer() and go
away with del_timer_sync() (and how does __inline__ work
when its the timer function?)



[atm]:  make sigd_sleep conditional with WAIT_FOR_DEMON

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1364  -> 1.1365 
#	 net/atm/signaling.c	1.17    -> 1.18   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/21	chas@relax.cmf.nrl.navy.mil	1.1365
# signaling.c:
#   make sigd_sleep conditional with WAIT_FOR_DEMON
# --------------------------------------------
#
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 09:45:13 2003
+++ b/net/atm/signaling.c	Mon Jun 23 09:45:13 2003
@@ -31,7 +31,9 @@
 
 
 struct atm_vcc *sigd = NULL;
+#ifdef WAIT_FOR_DEMON
 static DECLARE_WAIT_QUEUE_HEAD(sigd_sleep);
+#endif
 
 
 static void sigd_put_skb(struct sk_buff *skb)
@@ -254,6 +256,8 @@
 	vcc_insert_socket(vcc->sk);
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
+#ifdef WAIT_FOR_DEMON
 	wake_up(&sigd_sleep);
+#endif
 	return 0;
 }





[atm]: return ENODEV if !dev

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1413  -> 1.1414 
#	    net/atm/common.c	1.43    -> 1.44   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/16	chas@relax.cmf.nrl.navy.mil	1.1414
# return ENODEV if !dev
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Wed Jul 16 17:06:05 2003
+++ b/net/atm/common.c	Wed Jul 16 17:06:05 2003
@@ -478,6 +478,8 @@
 		return -EINVAL;
 	if (itf != ATM_ITF_ANY) {
 		dev = atm_dev_lookup(itf);
+		if (!dev)
+			return -ENODEV;
 		error = __vcc_connect(vcc, dev, vpi, vci);
 		if (error) {
 			atm_dev_put(dev);



[atm]: if !IFF_UP drop the frames

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1380.1.43 -> 1.1380.1.44
#	       net/atm/lec.c	1.33    -> 1.34   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/08	chas@relax.cmf.nrl.navy.mil	1.1380.1.44
# if !IFF_UP drop the frames
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Jul 16 17:05:18 2003
+++ b/net/atm/lec.c	Wed Jul 16 17:05:18 2003
@@ -692,10 +692,11 @@
 
                 atm_return(vcc,skb->truesize);
                 if (*(uint16_t *)skb->data == htons(priv->lecid) ||
-                    !priv->lecd) { 
+                    !priv->lecd ||
+                    !(dev->flags & IFF_UP)) { 
                         /* Probably looping back, or if lecd is missing,
                            lecd has gone down */
-                        DPRINTK("Ignoring loopback frame...\n");
+                        DPRINTK("Ignoring frame...\n");
                         dev_kfree_skb(skb);
                         return;
                 }


[atm]: cleanup timers in lec

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1380.1.44 -> 1.1380.1.45
#	       net/atm/lec.c	1.34    -> 1.35   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/08	chas@relax.cmf.nrl.navy.mil	1.1380.1.45
# timer cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Jul 16 17:05:30 2003
+++ b/net/atm/lec.c	Wed Jul 16 17:05:30 2003
@@ -1031,7 +1031,7 @@
 #define LEC_ARP_REFRESH_INTERVAL (3*HZ)
 
 static void lec_arp_check_expire(unsigned long data);
-static __inline__ void lec_arp_expire_arp(unsigned long data);
+static void lec_arp_expire_arp(unsigned long data);
 void dump_arp_table(struct lec_priv *priv);
 
 /* 
@@ -1371,7 +1371,7 @@
         struct lec_arp_table *entry, *next;
         int i;
 
-        del_timer(&priv->lec_arp_timer);
+        del_timer_sync(&priv->lec_arp_timer);
         
         /*
          * Remove all entries
@@ -1386,7 +1386,7 @@
         entry = priv->lec_arp_empty_ones;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                del_timer_sync(&entry->timer);
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1395,7 +1395,7 @@
         entry = priv->lec_no_forward;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                del_timer_sync(&entry->timer);
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1404,7 +1404,7 @@
         entry = priv->mcast_fwds;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                /* No timer, LANEv2 7.1.20 and 2.3.5.3 */
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1478,8 +1478,6 @@
 
         entry = (struct lec_arp_table *)data;
 
-        del_timer(&entry->timer);
-
         DPRINTK("lec_arp_expire_arp\n");
         if (entry->status == ESI_ARP_PENDING) {
                 if (entry->no_tries <= entry->priv->max_retry_count) {
@@ -1489,8 +1487,7 @@
                                 send_to_lecd(entry->priv, l_arp_xmt, entry->mac_addr, NULL, NULL);
                         entry->no_tries++;
                 }
-                entry->timer.expires = jiffies + (1*HZ);
-                add_timer(&entry->timer);
+                mod_timer(&entry->timer, jiffies + (1*HZ));
         }
 }
 
@@ -1562,8 +1559,6 @@
         unsigned long time_to_check;
         int i;
 
-        del_timer(&priv->lec_arp_timer);
-
         DPRINTK("lec_arp_check_expire %p,%d\n",priv,
                 atomic_read(&priv->lec_arp_users));
         DPRINTK("expire: eo:%p nf:%p\n",priv->lec_arp_empty_ones,
@@ -1621,8 +1616,8 @@
                 }
                 lec_arp_put(priv);
         }
-        priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
-        add_timer(&priv->lec_arp_timer);
+
+        mod_timer(&priv->lec_arp_timer, jiffies + LEC_ARP_REFRESH_INTERVAL);
 }
 /*
  * Try to find vcc where mac_address is attached.

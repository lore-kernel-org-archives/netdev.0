From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lec] timer cleanup
Date: Wed, 25 Feb 2004 18:52:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402252352.i1PNq5g5006290@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

backport of similar patch for 2.6. 

please apply to 2.4 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1353  -> 1.1354 
#	       net/atm/lec.c	1.20    -> 1.21   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/25	chas@relax.cmf.nrl.navy.mil	1.1354
# [ATM]: [lec] timer cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Feb 25 15:33:49 2004
+++ b/net/atm/lec.c	Wed Feb 25 15:33:49 2004
@@ -1043,7 +1043,7 @@
 #define LEC_ARP_REFRESH_INTERVAL (3*HZ)
 
 static void lec_arp_check_expire(unsigned long data);
-static __inline__ void lec_arp_expire_arp(unsigned long data);
+static void lec_arp_expire_arp(unsigned long data);
 void dump_arp_table(struct lec_priv *priv);
 
 /* 
@@ -1383,7 +1383,7 @@
         struct lec_arp_table *entry, *next;
         int i;
 
-        del_timer(&priv->lec_arp_timer);
+        del_timer_sync(&priv->lec_arp_timer);
         
         /*
          * Remove all entries
@@ -1398,7 +1398,7 @@
         entry = priv->lec_arp_empty_ones;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                del_timer_sync(&entry->timer);
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1407,7 +1407,7 @@
         entry = priv->lec_no_forward;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                del_timer_sync(&entry->timer);
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1416,7 +1416,7 @@
         entry = priv->mcast_fwds;
         while(entry) {
                 next = entry->next;
-                del_timer(&entry->timer);
+                /* No timer, LANEv2 7.1.20 and 2.3.5.3 */
                 lec_arp_clear_vccs(entry);
                 kfree(entry);
                 entry = next;
@@ -1490,8 +1490,6 @@
 
         entry = (struct lec_arp_table *)data;
 
-        del_timer(&entry->timer);
-
         DPRINTK("lec_arp_expire_arp\n");
         if (entry->status == ESI_ARP_PENDING) {
                 if (entry->no_tries <= entry->priv->max_retry_count) {
@@ -1501,8 +1499,7 @@
                                 send_to_lecd(entry->priv, l_arp_xmt, entry->mac_addr, NULL, NULL);
                         entry->no_tries++;
                 }
-                entry->timer.expires = jiffies + (1*HZ);
-                add_timer(&entry->timer);
+                mod_timer(&entry->timer, jiffies + (1*HZ));
         }
 }
 
@@ -1574,8 +1571,6 @@
         unsigned long time_to_check;
         int i;
 
-        del_timer(&priv->lec_arp_timer);
-
         DPRINTK("lec_arp_check_expire %p,%d\n",priv,
                 atomic_read(&priv->lec_arp_users));
         DPRINTK("expire: eo:%p nf:%p\n",priv->lec_arp_empty_ones,
@@ -1629,8 +1624,8 @@
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

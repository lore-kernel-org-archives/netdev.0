From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: remove vcc reference on outstanding skbs (from ulrich.u.muller@nokia.com)
Date: Thu, 16 Oct 2003 07:23:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310161123.h9GBNskT010685@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 --thanks

[note, this isnt the right way to fix this problem but the real
fix is a bit off in the future.]

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1439  -> 1.1440 
#	drivers/atm/nicstar.c	1.23    -> 1.24   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/10	chas@relax.cmf.nrl.navy.mil	1.1440
# [ATM]: remove vcc reference on outstanding skbs (from ulrich.u.muller@nokia.com)
# --------------------------------------------
#
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	Wed Oct 15 14:49:23 2003
+++ b/drivers/atm/nicstar.c	Wed Oct 15 14:49:23 2003
@@ -1676,6 +1676,25 @@
       free_scq(vc->scq, vcc);
    }
 
+   /* remove all references to vcc before deleting it */
+   if (vcc->qos.txtp.traffic_class != ATM_NONE)
+   {
+     unsigned long flags;
+     scq_info *scq = card->scq0;
+
+     ns_grab_scq_lock(card, scq, flags);
+
+     for(i = 0; i < scq->num_entries; i++) {
+       if(scq->skb[i] && ATM_SKB(scq->skb[i])->vcc == vcc) {
+        ATM_SKB(scq->skb[i])->vcc = NULL;
+	atm_return(vcc, scq->skb[i]->truesize);
+        PRINTK("nicstar: deleted pending vcc mapping\n");
+       }
+     }
+
+     spin_unlock_irqrestore(&scq->lock, flags);
+   }
+
    vcc->dev_data = NULL;
    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
    clear_bit(ATM_VF_ADDR,&vcc->flags);
@@ -2074,7 +2093,7 @@
       if (skb != NULL)
       {
          vcc = ATM_SKB(skb)->vcc;
-	 if (vcc->pop != NULL) {
+	 if (vcc && vcc->pop != NULL) {
 	    vcc->pop(vcc, skb);
 	 } else {
 	    dev_kfree_skb_irq(skb);

From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lec] send queued packets immediately after path switch
Date: Wed, 25 Feb 2004 18:52:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402252352.i1PNqkg5006305@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1354  -> 1.1355 
#	       net/atm/lec.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/25	chas@relax.cmf.nrl.navy.mil	1.1355
# [ATM]: [lec] send queued packets immediately after path switch
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Feb 25 15:34:04 2004
+++ b/net/atm/lec.c	Wed Feb 25 15:34:04 2004
@@ -208,6 +208,22 @@
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
@@ -352,33 +368,10 @@
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
@@ -1614,6 +1607,10 @@
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
@@ -2007,6 +2004,10 @@
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

From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lec] put back pressure on network stack
Date: Wed, 25 Feb 2004 18:51:21 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402252351.i1PNpJg5006282@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

the lane client doesnt put back pressure on the network
stack when one of the transmit vcc's is full.  this can
yield spurious results with certain network performance
tests.

please apply to 2.6 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1643  -> 1.1644 
#	       net/atm/lec.h	1.7     -> 1.8    
#	       net/atm/lec.c	1.37    -> 1.38   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/25	chas@relax.cmf.nrl.navy.mil	1.1644
# [ATM]: [lec] put back pressure on network stack
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Feb 25 15:16:38 2004
+++ b/net/atm/lec.c	Wed Feb 25 15:16:38 2004
@@ -67,7 +67,7 @@
                                single destination while waiting for SVC */
 
 static int lec_open(struct net_device *dev);
-static int lec_send_packet(struct sk_buff *skb, struct net_device *dev);
+static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lec_close(struct net_device *dev);
 static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
@@ -211,26 +211,34 @@
 static __inline__ void
 lec_send(struct atm_vcc *vcc, struct sk_buff *skb, struct lec_priv *priv)
 {
-	if (atm_may_send(vcc, skb->len)) {
-		atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
-	        ATM_SKB(skb)->vcc = vcc;
-	        ATM_SKB(skb)->atm_options = vcc->atm_options;
-		priv->stats.tx_packets++;
-		priv->stats.tx_bytes += skb->len;
-		vcc->send(vcc, skb);
-	} else {
+	ATM_SKB(skb)->vcc = vcc;
+	ATM_SKB(skb)->atm_options = vcc->atm_options;
+
+	atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	if (vcc->send(vcc, skb) < 0) {
 		priv->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		return;
 	}
+
+	priv->stats.tx_packets++;
+	priv->stats.tx_bytes += skb->len;
+}
+
+static void
+lec_tx_timeout(struct net_device *dev)
+{
+	printk(KERN_INFO "%s: tx timeout\n", dev->name);
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
 }
 
 static int 
-lec_send_packet(struct sk_buff *skb, struct net_device *dev)
+lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
         struct sk_buff *skb2;
         struct lec_priv *priv = (struct lec_priv *)dev->priv;
         struct lecdatahdr_8023 *lec_h;
-        struct atm_vcc *send_vcc;
+        struct atm_vcc *vcc;
 	struct lec_arp_table *entry;
         unsigned char *dst;
 	int min_frame_size;
@@ -243,7 +251,7 @@
         int i=0;
 #endif /* DUMP_PACKETS >0 */
         
-        DPRINTK("Lec_send_packet called\n");  
+        DPRINTK("lec_start_xmit called\n");  
         if (!priv->lecd) {
                 printk("%s:No lecd attached\n",dev->name);
                 priv->stats.tx_errors++;
@@ -262,7 +270,7 @@
         /* Make sure we have room for lec_id */
         if (skb_headroom(skb) < 2) {
 
-                DPRINTK("lec_send_packet: reallocating skb\n");
+                DPRINTK("lec_start_xmit: reallocating skb\n");
                 skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
                 kfree_skb(skb);
                 if (skb2 == NULL) return 0;
@@ -337,18 +345,18 @@
         }
 #endif
         entry = NULL;
-        send_vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
-        DPRINTK("%s:send_vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
-                send_vcc, send_vcc?send_vcc->flags:0, entry);
-        if (!send_vcc || !test_bit(ATM_VF_READY,&send_vcc->flags)) {    
+        vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
+        DPRINTK("%s:vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
+                vcc, vcc?vcc->flags:0, entry);
+        if (!vcc || !test_bit(ATM_VF_READY,&vcc->flags)) {    
                 if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
-                        DPRINTK("%s:lec_send_packet: queuing packet, ", dev->name);
+                        DPRINTK("%s:lec_start_xmit: queuing packet, ", dev->name);
                         DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
                                 lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
                                 lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
                         skb_queue_tail(&entry->tx_wait, skb);
                 } else {
-                        DPRINTK("%s:lec_send_packet: tx queue full or no arp entry, dropping, ", dev->name);
+                        DPRINTK("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ", dev->name);
                         DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
                                 lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
                                 lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
@@ -360,7 +368,7 @@
                 
 #if DUMP_PACKETS > 0                    
         printk("%s:sending to vpi:%d vci:%d\n", dev->name,
-               send_vcc->vpi, send_vcc->vci);       
+               vcc->vpi, vcc->vci);       
 #endif /* DUMP_PACKETS > 0 */
                 
         while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
@@ -368,15 +376,28 @@
                 DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
                         lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
                         lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
-		lec_send(send_vcc, skb2, priv);
+		lec_send(vcc, skb2, priv);
         }
 
-	lec_send(send_vcc, skb, priv);
+	lec_send(vcc, skb, priv);
 
-#if 0
-        /* Should we wait for card's device driver to notify us? */
-        dev->tbusy=0;
-#endif        
+	if (!atm_may_send(vcc, 0)) {
+		struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
+
+		vpriv->xoff = 1;
+		netif_stop_queue(dev);
+
+		/*
+		 * vcc->pop() might have occurred in between, making
+		 * the vcc usuable again.  Since xmit is serialized,
+		 * this is the only situation we have to re-test.
+		 */
+
+		if (atm_may_send(vcc, 0))
+			netif_wake_queue(dev);
+	}
+
+	dev->trans_start = jiffies;
         return 0;
 }
 
@@ -635,7 +656,8 @@
         dev->change_mtu = lec_change_mtu;
         dev->open = lec_open;
         dev->stop = lec_close;
-        dev->hard_start_xmit = lec_send_packet;
+        dev->hard_start_xmit = lec_start_xmit;
+	dev->tx_timeout = lec_tx_timeout;
 
         dev->get_stats = lec_get_stats;
         dev->set_multicast_list = lec_set_multicast_list;
@@ -731,9 +753,30 @@
         }
 }
 
+void
+lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
+	struct net_device *dev = skb->dev;
+
+	if (vpriv == NULL) {
+		printk("lec_pop(): vpriv = NULL!?!?!?\n");
+		return;
+	}
+
+	vpriv->old_pop(vcc, skb);
+
+	if (vpriv->xoff && atm_may_send(vcc, 0)) {
+		vpriv->xoff = 0;
+		if (netif_running(dev) && netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+	}
+}
+
 int 
 lec_vcc_attach(struct atm_vcc *vcc, void *arg)
 {
+	struct lec_vcc_priv *vpriv;
         int bytes_left;
         struct atmlec_ioc ioc_data;
 
@@ -746,6 +789,12 @@
         if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF || 
             !dev_lec[ioc_data.dev_num])
                 return -EINVAL;
+	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
+		return -ENOMEM;
+	vpriv->xoff = 0;
+	vpriv->old_pop = vcc->pop;
+	LEC_VCC_PRIV(vcc) = vpriv;
+	vcc->pop = lec_pop;
         lec_vcc_added(dev_lec[ioc_data.dev_num]->priv, 
                       &ioc_data, vcc, vcc->push);
         vcc->push = lec_push;
@@ -1363,22 +1412,21 @@
 lec_arp_clear_vccs(struct lec_arp_table *entry)
 {
         if (entry->vcc) {
-                entry->vcc->push = entry->old_push;
-#if 0 /* August 6, 1998 */
-                set_bit(ATM_VF_RELEASED,&entry->vcc->flags);
-		clear_bit(ATM_VF_READY,&entry->vcc->flags);
-                entry->vcc->push(entry->vcc, NULL);
-#endif
-		vcc_release_async(entry->vcc, -EPIPE);
-                entry->vcc = NULL;
+		struct atm_vcc *vcc = entry->vcc;
+		struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
+		struct net_device *dev = (struct net_device*) vcc->proto_data;
+
+                vcc->pop = vpriv->old_pop;
+		if (vpriv->xoff)
+			netif_wake_queue(dev);
+		kfree(vpriv);
+		LEC_VCC_PRIV(vcc) = NULL;
+                vcc->push = entry->old_push;
+		vcc_release_async(vcc, -EPIPE);
+                vcc = NULL;
         }
         if (entry->recv_vcc) {
                 entry->recv_vcc->push = entry->old_recv_push;
-#if 0
-                set_bit(ATM_VF_RELEASED,&entry->recv_vcc->flags);
-		clear_bit(ATM_VF_READY,&entry->recv_vcc->flags);
-                entry->recv_vcc->push(entry->recv_vcc, NULL);
-#endif
 		vcc_release_async(entry->recv_vcc, -EPIPE);
                 entry->recv_vcc = NULL;
         }        
@@ -2320,11 +2368,20 @@
         unsigned char mac_addr[] = {
                 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
         struct lec_arp_table *to_add;
+	struct lec_vcc_priv *vpriv;
   
+	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
+		return -ENOMEM;
+	vpriv->xoff = 0;
+	vpriv->old_pop = vcc->pop;
+	LEC_VCC_PRIV(vcc) = vpriv;
+        vcc->pop = lec_pop;
         lec_arp_get(priv);
         to_add = make_entry(priv, mac_addr);
         if (!to_add) {
                 lec_arp_put(priv);
+		vcc->pop = vpriv->old_pop;
+		kfree(vpriv);
                 return -ENOMEM;
         }
         memcpy(to_add->atm_addr, vcc->remote.sas_addr.prv, ATM_ESA_LEN);
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	Wed Feb 25 15:16:38 2004
+++ b/net/atm/lec.h	Wed Feb 25 15:16:38 2004
@@ -139,6 +139,13 @@
         int is_trdev;      /* Device type, 0 = Ethernet, 1 = TokenRing */
 };
 
+struct lec_vcc_priv {
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
+	int xoff;
+};
+
+#define LEC_VCC_PRIV(vcc)	((struct lec_vcc_priv *)((vcc)->user_back))
+
 int lecd_attach(struct atm_vcc *vcc, int arg);
 int lec_vcc_attach(struct atm_vcc *vcc, void *arg);
 int lec_mcast_attach(struct atm_vcc *vcc, int arg);

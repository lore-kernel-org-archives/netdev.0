From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM][3/3] assorted changes for atm
Date: Fri, 20 Jun 2003 17:32:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306202134.h5KLYXsG019262@ginger.cmf.nrl.navy.mil>
References: <200306202055.h5KKt9sG018696@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Fri, 20 Jun 2003 16:53:05 EDT."
             <200306202055.h5KKt9sG018696@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ok, one more time.  maybe i could post the complete patch this time.

[atm]: move vcc's to global sk-based linked list

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1359  -> 1.1360 
#	    drivers/atm/he.c	1.15    -> 1.16   
#	  net/atm/atm_misc.c	1.7     -> 1.8    
#	   drivers/atm/eni.c	1.17    -> 1.18   
#	      net/atm/proc.c	1.20    -> 1.21   
#	       net/atm/pvc.c	1.16    -> 1.17   
#	drivers/atm/idt77252.c	1.17    -> 1.18   
#	       net/atm/lec.c	1.29    -> 1.30   
#	drivers/atm/atmtcp.c	1.10    -> 1.11   
#	       net/atm/svc.c	1.18    -> 1.19   
#	    net/atm/common.h	1.12    -> 1.13   
#	 net/atm/signaling.c	1.14    -> 1.15   
#	 net/atm/resources.h	1.7     -> 1.8    
#	       net/atm/mpc.c	1.20    -> 1.21   
#	include/linux/atmdev.h	1.18    -> 1.19   
#	 net/atm/resources.c	1.13    -> 1.14   
#	      net/atm/clip.c	1.17    -> 1.18   
#	drivers/atm/fore200e.c	1.18    -> 1.19   
#	    net/atm/common.c	1.35    -> 1.36   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/20	chas@relax.cmf.nrl.navy.mil	1.1360
# move vcc's to global sk-based linked list
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Fri Jun 20 17:33:36 2003
+++ b/drivers/atm/atmtcp.c	Fri Jun 20 17:33:36 2003
@@ -153,9 +153,10 @@
 
 static int atmtcp_v_ioctl(struct atm_dev *dev,unsigned int cmd,void *arg)
 {
-	unsigned long flags;
 	struct atm_cirange ci;
 	struct atm_vcc *vcc;
+	struct hlist_node *node;
+	struct sock *s;
 
 	if (cmd != ATM_SETCIRANGE) return -ENOIOCTLCMD;
 	if (copy_from_user(&ci,(void *) arg,sizeof(ci))) return -EFAULT;
@@ -163,14 +164,18 @@
 	if (ci.vci_bits == ATM_CI_MAX) ci.vci_bits = MAX_VCI_BITS;
 	if (ci.vpi_bits > MAX_VPI_BITS || ci.vpi_bits < 0 ||
 	    ci.vci_bits > MAX_VCI_BITS || ci.vci_bits < 0) return -EINVAL;
-	spin_lock_irqsave(&dev->lock, flags);
-	for (vcc = dev->vccs; vcc; vcc = vcc->next)
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		vcc = atm_sk(s);
+		if (vcc->dev != dev)
+			continue;
 		if ((vcc->vpi >> ci.vpi_bits) ||
 		    (vcc->vci >> ci.vci_bits)) {
-			spin_unlock_irqrestore(&dev->lock, flags);
+			read_unlock(&vcc_sklist_lock);
 			return -EBUSY;
 		}
-	spin_unlock_irqrestore(&dev->lock, flags);
+	}
+	read_unlock(&vcc_sklist_lock);
 	dev->ci_range = ci;
 	return 0;
 }
@@ -233,9 +238,10 @@
 
 static void atmtcp_c_close(struct atm_vcc *vcc)
 {
-	unsigned long flags;
 	struct atm_dev *atmtcp_dev;
 	struct atmtcp_dev_data *dev_data;
+	struct sock *s;
+	struct hlist_node *node;
 	struct atm_vcc *walk;
 
 	atmtcp_dev = (struct atm_dev *) vcc->dev_data;
@@ -246,19 +252,24 @@
 	kfree(dev_data);
 	shutdown_atm_dev(atmtcp_dev);
 	vcc->dev_data = NULL;
-	spin_lock_irqsave(&atmtcp_dev->lock, flags);
-	for (walk = atmtcp_dev->vccs; walk; walk = walk->next)
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		walk = atm_sk(s);
+		if (walk->dev != atmtcp_dev)
+			continue;
 		wake_up(&walk->sleep);
-	spin_unlock_irqrestore(&atmtcp_dev->lock, flags);
+	}
+	read_unlock(&vcc_sklist_lock);
 }
 
 
 static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
 {
-	unsigned long flags;
 	struct atm_dev *dev;
 	struct atmtcp_hdr *hdr;
-	struct atm_vcc *out_vcc;
+	struct sock *s;
+	struct hlist_node *node;
+	struct atm_vcc *out_vcc = NULL;
 	struct sk_buff *new_skb;
 	int result = 0;
 
@@ -270,13 +281,17 @@
 		    (struct atmtcp_control *) skb->data);
 		goto done;
 	}
-	spin_lock_irqsave(&dev->lock, flags);
-	for (out_vcc = dev->vccs; out_vcc; out_vcc = out_vcc->next)
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		out_vcc = atm_sk(s);
+		if (out_vcc->dev != dev)
+			continue;
 		if (out_vcc->vpi == ntohs(hdr->vpi) &&
 		    out_vcc->vci == ntohs(hdr->vci) &&
 		    out_vcc->qos.rxtp.traffic_class != ATM_NONE)
 			break;
-	spin_unlock_irqrestore(&dev->lock, flags);
+	}
+	read_unlock(&vcc_sklist_lock);
 	if (!out_vcc) {
 		atomic_inc(&vcc->stats->tx_err);
 		goto done;
@@ -366,7 +381,7 @@
 	if (itf != -1) dev = atm_dev_lookup(itf);
 	if (dev) {
 		if (dev->ops != &atmtcp_v_dev_ops) {
-			atm_dev_release(dev);
+			atm_dev_put(dev);
 			return -EMEDIUMTYPE;
 		}
 		if (PRIV(dev)->vcc) return -EBUSY;
@@ -378,7 +393,8 @@
 		if (error) return error;
 	}
 	PRIV(dev)->vcc = vcc;
-	bind_vcc(vcc,&atmtcp_control_dev);
+	vcc->dev = &atmtcp_control_dev;
+	vcc_insert_socket(vcc->sk);
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 	vcc->dev_data = dev;
@@ -402,7 +418,7 @@
 	dev = atm_dev_lookup(itf);
 	if (!dev) return -ENODEV;
 	if (dev->ops != &atmtcp_v_dev_ops) {
-		atm_dev_release(dev);
+		atm_dev_put(dev);
 		return -EMEDIUMTYPE;
 	}
 	dev_data = PRIV(dev);
@@ -410,7 +426,7 @@
 	dev_data->persist = 0;
 	if (PRIV(dev)->vcc) return 0;
 	kfree(dev_data);
-	atm_dev_release(dev);
+	atm_dev_put(dev);
 	shutdown_atm_dev(dev);
 	return 0;
 }
diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	Fri Jun 20 17:33:36 2003
+++ b/drivers/atm/eni.c	Fri Jun 20 17:33:36 2003
@@ -1887,10 +1887,11 @@
 
 static int get_ci(struct atm_vcc *vcc,short *vpi,int *vci)
 {
-	unsigned long flags;
+	struct sock *s;
+	struct hlist_node *node;
 	struct atm_vcc *walk;
 
-	spin_lock_irqsave(&vcc->dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
 	if (*vpi == ATM_VPI_ANY) *vpi = 0;
 	if (*vci == ATM_VCI_ANY) {
 		for (*vci = ATM_NOT_RSV_VCI; *vci < NR_VCI; (*vci)++) {
@@ -1898,40 +1899,48 @@
 			    ENI_DEV(vcc->dev)->rx_map[*vci])
 				continue;
 			if (vcc->qos.txtp.traffic_class != ATM_NONE) {
-				for (walk = vcc->dev->vccs; walk;
-				    walk = walk->next)
+				sk_for_each(s, node, &vcc_sklist) {
+					walk = atm_sk(s);
+					if (walk->dev != vcc->dev)
+						continue;
 					if (test_bit(ATM_VF_ADDR,&walk->flags)
 					    && walk->vci == *vci &&
 					    walk->qos.txtp.traffic_class !=
 					    ATM_NONE)
 						break;
-				if (walk) continue;
+				}
+				if (node)
+					continue;
 			}
 			break;
 		}
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return *vci == NR_VCI ? -EADDRINUSE : 0;
 	}
 	if (*vci == ATM_VCI_UNSPEC) {
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return 0;
 	}
 	if (vcc->qos.rxtp.traffic_class != ATM_NONE &&
 	    ENI_DEV(vcc->dev)->rx_map[*vci]) {
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return -EADDRINUSE;
 	}
 	if (vcc->qos.txtp.traffic_class == ATM_NONE) {
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return 0;
 	}
-	for (walk = vcc->dev->vccs; walk; walk = walk->next)
+	sk_for_each(s, node, &vcc_sklist) {
+		walk = atm_sk(s);
+		if (walk->dev != vcc->dev)
+			continue;
 		if (test_bit(ATM_VF_ADDR,&walk->flags) && walk->vci == *vci &&
 		    walk->qos.txtp.traffic_class != ATM_NONE) {
-			spin_unlock_irqrestore(&vcc->dev->lock, flags);
+			read_unlock(&vcc_sklist_lock);
 			return -EADDRINUSE;
 		}
-	spin_unlock_irqrestore(&vcc->dev->lock, flags);
+	}
+	read_unlock(&vcc_sklist_lock);
 	return 0;
 }
 
@@ -2139,7 +2148,8 @@
 
 static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
 {
-	unsigned long flags;
+	struct hlist_node *node;
+	struct sock *s;
 	static const char *signal[] = { "LOST","unknown","okay" };
 	struct eni_dev *eni_dev = ENI_DEV(dev);
 	struct atm_vcc *vcc;
@@ -2212,11 +2222,15 @@
 		return sprintf(page,"%10sbacklog %u packets\n","",
 		    skb_queue_len(&tx->backlog));
 	}
-	spin_lock_irqsave(&dev->lock, flags);
-	for (vcc = dev->vccs; vcc; vcc = vcc->next) {
-		struct eni_vcc *eni_vcc = ENI_VCC(vcc);
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		struct eni_vcc *eni_vcc;
 		int length;
 
+		vcc = atm_sk(s);
+		if (vcc->dev != dev)
+			continue;
+		eni_vcc = ENI_VCC(vcc);
 		if (--left) continue;
 		length = sprintf(page,"vcc %4d: ",vcc->vci);
 		if (eni_vcc->rx) {
@@ -2231,10 +2245,10 @@
 			length += sprintf(page+length,"tx[%d], txing %d bytes",
 			    eni_vcc->tx->index,eni_vcc->txing);
 		page[length] = '\n';
-		spin_unlock_irqrestore(&dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return length+1;
 	}
-	spin_unlock_irqrestore(&dev->lock, flags);
+	read_unlock(&vcc_sklist_lock);
 	for (i = 0; i < eni_dev->free_len; i++) {
 		struct eni_free *fe = eni_dev->free_list+i;
 		unsigned long offset;
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Fri Jun 20 17:33:36 2003
+++ b/drivers/atm/fore200e.c	Fri Jun 20 17:33:36 2003
@@ -1069,18 +1069,23 @@
 static struct atm_vcc* 
 fore200e_find_vcc(struct fore200e* fore200e, struct rpd* rpd)
 {
-    unsigned long flags;
+    struct sock *s;
     struct atm_vcc* vcc;
+    struct hlist_node *node;
 
-    spin_lock_irqsave(&fore200e->atm_dev->lock, flags);
-    for (vcc = fore200e->atm_dev->vccs; vcc; vcc = vcc->next) {
-
-	if (vcc->vpi == rpd->atm_header.vpi && vcc->vci == rpd->atm_header.vci)
-	    break;
+    read_lock(&vcc_sklist_lock);
+    sk_for_each(s, node, &vcc_sklist) {
+	vcc = atm_sk(s);
+	if (vcc->dev != fore200e->atm_dev)
+		continue;
+	if (vcc->vpi == rpd->atm_header.vpi && vcc->vci == rpd->atm_header.vci) {
+            read_unlock(&vcc_sklist_lock);
+	    return vcc;
+	}
     }
-    spin_unlock_irqrestore(&fore200e->atm_dev->lock, flags);
-    
-    return vcc;
+    read_unlock(&vcc_sklist_lock);
+
+    return NULL;
 }
 
 
@@ -1350,20 +1355,26 @@
 static int
 fore200e_walk_vccs(struct atm_vcc *vcc, short *vpi, int *vci)
 {
-    unsigned long flags;
     struct atm_vcc* walk;
+    struct sock *s;
+    struct hlist_node *node;
 
     /* find a free VPI */
 
-    spin_lock_irqsave(&vcc->dev->lock, flags);
+    read_lock(&vcc_sklist_lock);
 
     if (*vpi == ATM_VPI_ANY) {
 
-	for (*vpi = 0, walk = vcc->dev->vccs; walk; walk = walk->next) {
+	*vpi = 0;
+restart_vpi_search:
+	sk_for_each(s, node, &vcc_sklist) {
+	    walk = atm_sk(s);
+	    if (walk->dev != vcc->dev)
+		continue;
 
 	    if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
 		(*vpi)++;
-		walk = vcc->dev->vccs;
+		goto restart_vpi_search;
 	    }
 	}
     }
@@ -1371,16 +1382,21 @@
     /* find a free VCI */
     if (*vci == ATM_VCI_ANY) {
 	
-	for (*vci = ATM_NOT_RSV_VCI, walk = vcc->dev->vccs; walk; walk = walk->next) {
+	*vci = ATM_NOT_RSV_VCI;
+restart_vci_search:
+	sk_for_each(s, node, &vcc_sklist) {
+	    walk = atm_sk(s);
+	    if (walk->dev != vcc->dev)
+		continue;
 
 	    if ((walk->vpi = *vpi) && (walk->vci == *vci)) {
 		*vci = walk->vci + 1;
-		walk = vcc->dev->vccs;
+		goto restart_vci_search;
 	    }
 	}
     }
 
-    spin_unlock_irqrestore(&vcc->dev->lock, flags);
+    read_unlock(&vcc_sklist_lock);
 
     return 0;
 }
@@ -2642,7 +2658,8 @@
 static int
 fore200e_proc_read(struct atm_dev *dev,loff_t* pos,char* page)
 {
-    unsigned long flags;
+    struct sock *s;
+    struct hlist_node *node;
     struct fore200e* fore200e  = FORE200E_DEV(dev);
     int              len, left = *pos;
 
@@ -2889,8 +2906,12 @@
 	len = sprintf(page,"\n"    
 		      " VCCs:\n  address\tVPI.VCI:AAL\t(min/max tx PDU size) (min/max rx PDU size)\n");
 	
-	spin_lock_irqsave(&fore200e->atm_dev->lock, flags);
-	for (vcc = fore200e->atm_dev->vccs; vcc; vcc = vcc->next) {
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+	    vcc = atm_sk(s);
+
+	    if (vcc->dev != fore200e->atm_dev)
+		    continue;
 
 	    fore200e_vcc = FORE200E_VCC(vcc);
 	    
@@ -2904,7 +2925,7 @@
 			   fore200e_vcc->rx_max_pdu
 		);
 	}
-	spin_unlock_irqrestore(&fore200e->atm_dev->lock, flags);
+	read_unlock(&vcc_sklist_lock);
 
 	return len;
     }
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Fri Jun 20 17:33:36 2003
+++ b/drivers/atm/he.c	Fri Jun 20 17:33:36 2003
@@ -79,7 +79,6 @@
 #include <linux/sonet.h>
 
 #define USE_TASKLET
-#define USE_HE_FIND_VCC
 #undef USE_SCATTERGATHER
 #undef USE_CHECKSUM_HW			/* still confused about this */
 #define USE_RBPS
@@ -328,25 +327,25 @@
 		he_writel_rcm(dev, val, 0x00000 | (cid << 3) | 7)
 
 static __inline__ struct atm_vcc*
-he_find_vcc(struct he_dev *he_dev, unsigned cid)
+__find_vcc(struct he_dev *he_dev, unsigned cid)
 {
-	unsigned long flags;
 	struct atm_vcc *vcc;
+	struct hlist_node *node;
+	struct sock *s;
 	short vpi;
 	int vci;
 
 	vpi = cid >> he_dev->vcibits;
 	vci = cid & ((1 << he_dev->vcibits) - 1);
 
-	spin_lock_irqsave(&he_dev->atm_dev->lock, flags);
-	for (vcc = he_dev->atm_dev->vccs; vcc; vcc = vcc->next)
-		if (vcc->vci == vci && vcc->vpi == vpi
-			&& vcc->qos.rxtp.traffic_class != ATM_NONE) {
-				spin_unlock_irqrestore(&he_dev->atm_dev->lock, flags);
+	sk_for_each(s, node, &vcc_sklist) {
+		vcc = atm_sk(s);
+		if (vcc->dev == he_dev->atm_dev &&
+		    vcc->vci == vci && vcc->vpi == vpi &&
+		    vcc->qos.rxtp.traffic_class != ATM_NONE) {
 				return vcc;
-			}
-
-	spin_unlock_irqrestore(&he_dev->atm_dev->lock, flags);
+		}
+	}
 	return NULL;
 }
 
@@ -1566,17 +1565,6 @@
 	reg |= RX_ENABLE;
 	he_writel(he_dev, reg, RC_CONFIG);
 
-#ifndef USE_HE_FIND_VCC
-	he_dev->he_vcc_table = kmalloc(sizeof(struct he_vcc_table) * 
-			(1 << (he_dev->vcibits + he_dev->vpibits)), GFP_KERNEL);
-	if (he_dev->he_vcc_table == NULL) {
-		hprintk("failed to alloc he_vcc_table\n");
-		return -ENOMEM;
-	}
-	memset(he_dev->he_vcc_table, 0, sizeof(struct he_vcc_table) *
-				(1 << (he_dev->vcibits + he_dev->vpibits)));
-#endif
-
 	for (i = 0; i < HE_NUM_CS_STPER; ++i) {
 		he_dev->cs_stper[i].inuse = 0;
 		he_dev->cs_stper[i].pcr = -1;
@@ -1712,11 +1700,6 @@
 							he_dev->tpd_base, he_dev->tpd_base_phys);
 #endif
 
-#ifndef USE_HE_FIND_VCC
-	if (he_dev->he_vcc_table)
-		kfree(he_dev->he_vcc_table);
-#endif
-
 	if (he_dev->pci_dev) {
 		pci_read_config_word(he_dev->pci_dev, PCI_COMMAND, &command);
 		command &= ~(PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
@@ -1798,6 +1781,7 @@
 	int pdus_assembled = 0;
 	int updated = 0;
 
+	read_lock(&vcc_sklist_lock);
 	while (he_dev->rbrq_head != rbrq_tail) {
 		++updated;
 
@@ -1823,13 +1807,10 @@
 		buf_len = RBRQ_BUFLEN(he_dev->rbrq_head) * 4;
 		cid = RBRQ_CID(he_dev->rbrq_head);
 
-#ifdef USE_HE_FIND_VCC
 		if (cid != lastcid)
-			vcc = he_find_vcc(he_dev, cid);
+			vcc = __find_vcc(he_dev, cid);
 		lastcid = cid;
-#else
-		vcc = HE_LOOKUP_VCC(he_dev, cid);
-#endif
+
 		if (vcc == NULL) {
 			hprintk("vcc == NULL  (cid 0x%x)\n", cid);
 			if (!RBRQ_HBUF_ERR(he_dev->rbrq_head))
@@ -1966,6 +1947,7 @@
 					RBRQ_MASK(++he_dev->rbrq_head));
 
 	}
+	read_unlock(&vcc_sklist_lock);
 
 	if (updated) {
 		if (updated > he_dev->rbrq_peak)
@@ -2565,10 +2547,6 @@
 #endif
 
 		spin_unlock_irqrestore(&he_dev->global_lock, flags);
-
-#ifndef USE_HE_FIND_VCC
-		HE_LOOKUP_VCC(he_dev, cid) = vcc;
-#endif
 	}
 
 open_failed:
@@ -2634,9 +2612,6 @@
 		if (timeout == 0)
 			hprintk("close rx timeout cid 0x%x\n", cid);
 
-#ifndef USE_HE_FIND_VCC
-		HE_LOOKUP_VCC(he_dev, cid) = NULL;
-#endif
 		HPRINTK("close rx cid 0x%x complete\n", cid);
 
 	}
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	Fri Jun 20 17:33:36 2003
+++ b/drivers/atm/idt77252.c	Fri Jun 20 17:33:36 2003
@@ -2403,37 +2403,43 @@
 static int
 idt77252_find_vcc(struct atm_vcc *vcc, short *vpi, int *vci)
 {
-	unsigned long flags;
+	struct sock *s;
 	struct atm_vcc *walk;
 
-	spin_lock_irqsave(&vcc->dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
 	if (*vpi == ATM_VPI_ANY) {
 		*vpi = 0;
-		walk = vcc->dev->vccs;
-		while (walk) {
+		s = sk_head(&vcc_sklist);
+		while (s) {
+			walk = atm_sk(s);
+			if (walk->dev != vcc->dev)
+				continue;
 			if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
 				(*vpi)++;
-				walk = vcc->dev->vccs;
+				s = sk_head(&vcc_sklist);
 				continue;
 			}
-			walk = walk->next;
+			s = sk_next(s);
 		}
 	}
 
 	if (*vci == ATM_VCI_ANY) {
 		*vci = ATM_NOT_RSV_VCI;
-		walk = vcc->dev->vccs;
-		while (walk) {
+		s = sk_head(&vcc_sklist);
+		while (s) {
+			walk = atm_sk(s);
+			if (walk->dev != vcc->dev)
+				continue;
 			if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
 				(*vci)++;
-				walk = vcc->dev->vccs;
+				s = sk_head(&vcc_sklist);
 				continue;
 			}
-			walk = walk->next;
+			s = sk_next(s);
 		}
 	}
 
-	spin_unlock_irqrestore(&vcc->dev->lock, flags);
+	read_unlock(&vcc_sklist_lock);
 	return 0;
 }
 
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Fri Jun 20 17:33:36 2003
+++ b/include/linux/atmdev.h	Fri Jun 20 17:33:36 2003
@@ -293,7 +293,6 @@
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
 	wait_queue_head_t sleep;	/* if socket is busy */
 	struct sock	*sk;		/* socket backpointer */
-	struct atm_vcc	*prev,*next;
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
@@ -320,8 +319,6 @@
 					/* (NULL) */
 	const char	*type;		/* device type name */
 	int		number;		/* device index */
-	struct atm_vcc	*vccs;		/* VCC table (or NULL) */
-	struct atm_vcc	*last;		/* last VCC (or undefined) */
 	void		*dev_data;	/* per-device data */
 	void		*phy_data;	/* private PHY date */
 	unsigned long	flags;		/* device flags (ATM_DF_*) */
@@ -390,6 +387,9 @@
 	unsigned long	atm_options;	/* ATM layer options */
 };
 
+extern struct hlist_head vcc_sklist;
+extern rwlock_t vcc_sklist_lock;
+
 #define ATM_SKB(skb) (((struct atm_skb_data *) (skb)->cb))
 
 struct atm_dev *atm_dev_register(const char *type,const struct atmdev_ops *ops,
@@ -397,7 +397,8 @@
 struct atm_dev *atm_dev_lookup(int number);
 void atm_dev_deregister(struct atm_dev *dev);
 void shutdown_atm_dev(struct atm_dev *dev);
-void bind_vcc(struct atm_vcc *vcc,struct atm_dev *dev);
+void vcc_insert_socket(struct sock *sk);
+void vcc_remove_socket(struct sock *sk);
 
 
 /*
@@ -436,7 +437,7 @@
 }
 
 
-static inline void atm_dev_release(struct atm_dev *dev)
+static inline void atm_dev_put(struct atm_dev *dev)
 {
 	atomic_dec(&dev->refcnt);
 
diff -Nru a/net/atm/atm_misc.c b/net/atm/atm_misc.c
--- a/net/atm/atm_misc.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/atm_misc.c	Fri Jun 20 17:33:36 2003
@@ -47,15 +47,21 @@
 
 static int check_ci(struct atm_vcc *vcc,short vpi,int vci)
 {
+	struct hlist_node *node;
+	struct sock *s;
 	struct atm_vcc *walk;
 
-	for (walk = vcc->dev->vccs; walk; walk = walk->next)
+	sk_for_each(s, node, &vcc_sklist) {
+		walk = atm_sk(s);
+		if (walk->dev != vcc->dev)
+			continue;
 		if (test_bit(ATM_VF_ADDR,&walk->flags) && walk->vpi == vpi &&
 		    walk->vci == vci && ((walk->qos.txtp.traffic_class !=
 		    ATM_NONE && vcc->qos.txtp.traffic_class != ATM_NONE) ||
 		    (walk->qos.rxtp.traffic_class != ATM_NONE &&
 		    vcc->qos.rxtp.traffic_class != ATM_NONE)))
 			return -EADDRINUSE;
+	}
 		/* allow VCCs with same VPI/VCI iff they don't collide on
 		   TX/RX (but we may refuse such sharing for other reasons,
 		   e.g. if protocol requires to have both channels) */
@@ -65,17 +71,16 @@
 
 int atm_find_ci(struct atm_vcc *vcc,short *vpi,int *vci)
 {
-	unsigned long flags;
 	static short p = 0; /* poor man's per-device cache */
 	static int c = 0;
 	short old_p;
 	int old_c;
 	int err;
 
-	spin_lock_irqsave(&vcc->dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
 	if (*vpi != ATM_VPI_ANY && *vci != ATM_VCI_ANY) {
 		err = check_ci(vcc,*vpi,*vci);
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
+		read_unlock(&vcc_sklist_lock);
 		return err;
 	}
 	/* last scan may have left values out of bounds for current device */
@@ -90,7 +95,7 @@
 		if (!check_ci(vcc,p,c)) {
 			*vpi = p;
 			*vci = c;
-			spin_unlock_irqrestore(&vcc->dev->lock, flags);
+			read_unlock(&vcc_sklist_lock);
 			return 0;
 		}
 		if (*vci == ATM_VCI_ANY) {
@@ -105,7 +110,7 @@
 		}
 	}
 	while (old_p != p || old_c != c);
-	spin_unlock_irqrestore(&vcc->dev->lock, flags);
+	read_unlock(&vcc_sklist_lock);
 	return -EADDRINUSE;
 }
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/clip.c	Fri Jun 20 17:33:36 2003
@@ -737,7 +737,8 @@
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 	    /* allow replies and avoid getting closed if signaling dies */
-	bind_vcc(vcc,&atmarpd_dev);
+	vcc->dev = &atmarpd_dev;
+	vcc_insert_socket(vcc->sk);
 	vcc->push = NULL;
 	vcc->pop = NULL; /* crash */
 	vcc->push_oam = NULL; /* crash */
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/common.c	Fri Jun 20 17:33:36 2003
@@ -157,6 +157,29 @@
 #endif
 
 
+HLIST_HEAD(vcc_sklist);
+rwlock_t vcc_sklist_lock = RW_LOCK_UNLOCKED;
+
+void __vcc_insert_socket(struct sock *sk)
+{
+	sk_add_node(sk, &vcc_sklist);
+}
+
+void vcc_insert_socket(struct sock *sk)
+{
+	write_lock_irq(&vcc_sklist_lock);
+	__vcc_insert_socket(sk);
+	write_unlock_irq(&vcc_sklist_lock);
+}
+
+void vcc_remove_socket(struct sock *sk)
+{
+	write_lock_irq(&vcc_sklist_lock);
+	sk_del_node_init(sk);
+	write_unlock_irq(&vcc_sklist_lock);
+}
+
+
 static struct sk_buff *alloc_tx(struct atm_vcc *vcc,unsigned int size)
 {
 	struct sk_buff *skb;
@@ -175,16 +198,45 @@
 }
 
 
-int atm_create(struct socket *sock,int protocol,int family)
+EXPORT_SYMBOL(vcc_sklist);
+EXPORT_SYMBOL(vcc_sklist_lock);
+EXPORT_SYMBOL(vcc_insert_socket);
+EXPORT_SYMBOL(vcc_remove_socket);
+
+static void vcc_sock_destruct(struct sock *sk)
+{
+	struct atm_vcc *vcc = atm_sk(sk);
+
+	if (atomic_read(&vcc->sk->sk_rmem_alloc))
+		printk(KERN_DEBUG "vcc_sock_destruct: rmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_rmem_alloc));
+
+	if (atomic_read(&vcc->sk->sk_wmem_alloc))
+		printk(KERN_DEBUG "vcc_sock_destruct: wmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_wmem_alloc));
+
+	kfree(sk->sk_protinfo);
+}
+ 
+int vcc_create(struct socket *sock, int protocol, int family)
 {
 	struct sock *sk;
 	struct atm_vcc *vcc;
 
 	sock->sk = NULL;
-	if (sock->type == SOCK_STREAM) return -EINVAL;
-	if (!(sk = alloc_atm_vcc_sk(family))) return -ENOMEM;
-	vcc = atm_sk(sk);
-	memset(&vcc->flags,0,sizeof(vcc->flags));
+	if (sock->type == SOCK_STREAM)
+		return -EINVAL;
+	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
+	if (!sk)
+		return -ENOMEM;
+	sock_init_data(NULL, sk);
+
+	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
+	if (!vcc) {
+		sk_free(sk);
+		return -ENOMEM;
+	}
+
+	memset(vcc, 0, sizeof(*vcc));
+	vcc->sk = sk;
 	vcc->dev = NULL;
 	vcc->callback = NULL;
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
@@ -199,42 +251,48 @@
 	vcc->atm_options = vcc->aal_options = 0;
 	init_waitqueue_head(&vcc->sleep);
 	sk->sk_sleep = &vcc->sleep;
+	sk->sk_destruct = vcc_sock_destruct;
 	sock->sk = sk;
 	return 0;
 }
 
 
-void atm_release_vcc_sk(struct sock *sk,int free_sk)
+static void vcc_destroy_socket(struct sock *sk)
 {
 	struct atm_vcc *vcc = atm_sk(sk);
 	struct sk_buff *skb;
 
-	clear_bit(ATM_VF_READY,&vcc->flags);
+	clear_bit(ATM_VF_READY, &vcc->flags);
 	if (vcc->dev) {
-		if (vcc->dev->ops->close) vcc->dev->ops->close(vcc);
-		if (vcc->push) vcc->push(vcc,NULL); /* atmarpd has no push */
+		if (vcc->dev->ops->close)
+			vcc->dev->ops->close(vcc);
+		if (vcc->push)
+			vcc->push(vcc, NULL); /* atmarpd has no push */
+
+		vcc_remove_socket(sk);	/* no more receive */
+
 		while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
 			atm_return(vcc,skb->truesize);
 			kfree_skb(skb);
 		}
 
 		module_put(vcc->dev->ops->owner);
-		atm_dev_release(vcc->dev);
-		if (atomic_read(&vcc->sk->sk_rmem_alloc))
-			printk(KERN_WARNING "atm_release_vcc: strange ... "
-			    "rmem_alloc == %d after closing\n",
-			    atomic_read(&vcc->sk->sk_rmem_alloc));
-		bind_vcc(vcc,NULL);
+		atm_dev_put(vcc->dev);
 	}
-
-	if (free_sk) free_atm_vcc_sk(sk);
 }
 
 
-int atm_release(struct socket *sock)
+int vcc_release(struct socket *sock)
 {
-	if (sock->sk)
-		atm_release_vcc_sk(sock->sk,1);
+	struct sock *sk = sock->sk;
+
+	if (sk) {
+		lock_sock(sk);
+		vcc_destroy_socket(sock->sk);
+		release_sock(sk);
+		sock_put(sk);
+	}
+
 	return 0;
 }
 
@@ -289,7 +347,8 @@
 	if (vci > 0 && vci < ATM_NOT_RSV_VCI && !capable(CAP_NET_BIND_SERVICE))
 		return -EPERM;
 	error = 0;
-	bind_vcc(vcc,dev);
+	vcc->dev = dev;
+	vcc_insert_socket(vcc->sk);
 	switch (vcc->qos.aal) {
 		case ATM_AAL0:
 			error = atm_init_aal0(vcc);
@@ -313,7 +372,7 @@
 	if (!error) error = adjust_tp(&vcc->qos.txtp,vcc->qos.aal);
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
 	if (error) {
-		bind_vcc(vcc,NULL);
+		vcc_remove_socket(vcc->sk);
 		return error;
 	}
 	DPRINTK("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
@@ -327,7 +386,7 @@
 		error = dev->ops->open(vcc,vpi,vci);
 		if (error) {
 			module_put(dev->ops->owner);
-			bind_vcc(vcc,NULL);
+			vcc_remove_socket(vcc->sk);
 			return error;
 		}
 	}
@@ -371,7 +430,7 @@
 		dev = atm_dev_lookup(itf);
 		error = __vcc_connect(vcc, dev, vpi, vci);
 		if (error) {
-			atm_dev_release(dev);
+			atm_dev_put(dev);
 			return error;
 		}
 	} else {
@@ -385,7 +444,7 @@
 			spin_unlock(&atm_dev_lock);
 			if (!__vcc_connect(vcc, dev, vpi, vci))
 				break;
-			atm_dev_release(dev);
+			atm_dev_put(dev);
 			dev = NULL;
 			spin_lock(&atm_dev_lock);
 		}
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Fri Jun 20 17:33:36 2003
+++ b/net/atm/common.h	Fri Jun 20 17:33:36 2003
@@ -10,8 +10,8 @@
 #include <linux/poll.h> /* for poll_table */
 
 
-int atm_create(struct socket *sock,int protocol,int family);
-int atm_release(struct socket *sock);
+int vcc_create(struct socket *sock, int protocol, int family);
+int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		int size, int flags);
@@ -24,7 +24,6 @@
 int vcc_getsockopt(struct socket *sock, int level, int optname, char *optval,
 		   int *optlen);
 
-void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
 int atmpvc_init(void);
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/lec.c	Fri Jun 20 17:33:36 2003
@@ -48,7 +48,7 @@
 
 #include "lec.h"
 #include "lec_arpc.h"
-#include "resources.h"  /* for bind_vcc() */
+#include "resources.h"
 
 #if 0
 #define DPRINTK printk
@@ -810,7 +810,8 @@
         lec_arp_init(priv);
 	priv->itfnum = i;  /* LANE2 addition */
         priv->lecd = vcc;
-        bind_vcc(vcc, &lecatm_dev);
+        vcc->dev = &lecatm_dev;
+        vcc_insert_socket(vcc->sk);
         
         vcc->proto_data = dev_lec[i];
 	set_bit(ATM_VF_META,&vcc->flags);
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/mpc.c	Fri Jun 20 17:33:36 2003
@@ -28,7 +28,7 @@
 
 #include "lec.h"
 #include "mpc.h"
-#include "resources.h"  /* for bind_vcc() */
+#include "resources.h"
 
 /*
  * mpc.c: Implementation of MPOA client kernel part 
@@ -789,7 +789,8 @@
 	}
 
 	mpc->mpoad_vcc = vcc;
-	bind_vcc(vcc, &mpc_dev);
+	vcc->dev = &mpc_dev;
+	vcc_insert_socket(vcc->sk);
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/proc.c	Fri Jun 20 17:33:36 2003
@@ -334,9 +334,8 @@
 
 static int atm_pvc_info(loff_t pos,char *buf)
 {
-	unsigned long flags;
-	struct atm_dev *dev;
-	struct list_head *p;
+	struct hlist_node *node;
+	struct sock *s;
 	struct atm_vcc *vcc;
 	int left, clip_info = 0;
 
@@ -349,25 +348,20 @@
 	if (try_atm_clip_ops())
 		clip_info = 1;
 #endif
-	spin_lock(&atm_dev_lock);
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
-		spin_lock_irqsave(&dev->lock, flags);
-		for (vcc = dev->vccs; vcc; vcc = vcc->next)
-			if (vcc->sk->sk_family == PF_ATMPVC &&
-			    vcc->dev && !left--) {
-				pvc_info(vcc,buf,clip_info);
-				spin_unlock_irqrestore(&dev->lock, flags);
-				spin_unlock(&atm_dev_lock);
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		vcc = atm_sk(s);
+		if (vcc->sk->sk_family == PF_ATMPVC && vcc->dev && !left--) {
+			pvc_info(vcc,buf,clip_info);
+			read_unlock(&vcc_sklist_lock);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-				if (clip_info)
-					module_put(atm_clip_ops->owner);
+			if (clip_info)
+				module_put(atm_clip_ops->owner);
 #endif
-				return strlen(buf);
-			}
-		spin_unlock_irqrestore(&dev->lock, flags);
+			return strlen(buf);
+		}
 	}
-	spin_unlock(&atm_dev_lock);
+	read_unlock(&vcc_sklist_lock);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 	if (clip_info)
 		module_put(atm_clip_ops->owner);
@@ -378,10 +372,9 @@
 
 static int atm_vc_info(loff_t pos,char *buf)
 {
-	unsigned long flags;
-	struct atm_dev *dev;
-	struct list_head *p;
 	struct atm_vcc *vcc;
+	struct hlist_node *node;
+	struct sock *s;
 	int left;
 
 	if (!pos)
@@ -389,20 +382,16 @@
 		    "Address"," Itf VPI VCI   Fam Flags Reply Send buffer"
 		    "     Recv buffer\n");
 	left = pos-1;
-	spin_lock(&atm_dev_lock);
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
-		spin_lock_irqsave(&dev->lock, flags);
-		for (vcc = dev->vccs; vcc; vcc = vcc->next)
-			if (!left--) {
-				vc_info(vcc,buf);
-				spin_unlock_irqrestore(&dev->lock, flags);
-				spin_unlock(&atm_dev_lock);
-				return strlen(buf);
-			}
-		spin_unlock_irqrestore(&dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		vcc = atm_sk(s);
+		if (!left--) {
+			vc_info(vcc,buf);
+			read_unlock(&vcc_sklist_lock);
+			return strlen(buf);
+		}
 	}
-	spin_unlock(&atm_dev_lock);
+	read_unlock(&vcc_sklist_lock);
 
 	return 0;
 }
@@ -410,29 +399,24 @@
 
 static int atm_svc_info(loff_t pos,char *buf)
 {
-	unsigned long flags;
-	struct atm_dev *dev;
-	struct list_head *p;
+	struct hlist_node *node;
+	struct sock *s;
 	struct atm_vcc *vcc;
 	int left;
 
 	if (!pos)
 		return sprintf(buf,"Itf VPI VCI           State      Remote\n");
 	left = pos-1;
-	spin_lock(&atm_dev_lock);
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
-		spin_lock_irqsave(&dev->lock, flags);
-		for (vcc = dev->vccs; vcc; vcc = vcc->next)
-			if (vcc->sk->sk_family == PF_ATMSVC && !left--) {
-				svc_info(vcc,buf);
-				spin_unlock_irqrestore(&dev->lock, flags);
-				spin_unlock(&atm_dev_lock);
-				return strlen(buf);
-			}
-		spin_unlock_irqrestore(&dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		vcc = atm_sk(s);
+		if (vcc->sk->sk_family == PF_ATMSVC && !left--) {
+			svc_info(vcc,buf);
+			read_unlock(&vcc_sklist_lock);
+			return strlen(buf);
+		}
 	}
-	spin_unlock(&atm_dev_lock);
+	read_unlock(&vcc_sklist_lock);
 
 	return 0;
 }
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/pvc.c	Fri Jun 20 17:33:36 2003
@@ -17,10 +17,6 @@
 #include "resources.h"		/* devs and vccs */
 #include "common.h"		/* common for PVCs and SVCs */
 
-#ifndef NULL
-#define NULL 0
-#endif
-
 
 static int pvc_shutdown(struct socket *sock,int how)
 {
@@ -109,7 +105,7 @@
 static struct proto_ops pvc_proto_ops = {
 	.family =	PF_ATMPVC,
 
-	.release =	atm_release,
+	.release =	vcc_release,
 	.bind =		pvc_bind,
 	.connect =	pvc_connect,
 	.socketpair =	sock_no_socketpair,
@@ -131,7 +127,7 @@
 static int pvc_create(struct socket *sock,int protocol)
 {
 	sock->ops = &pvc_proto_ops;
-	return atm_create(sock,protocol,PF_ATMPVC);
+	return vcc_create(sock, protocol, PF_ATMPVC);
 }
 
 
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/resources.c	Fri Jun 20 17:33:36 2003
@@ -23,11 +23,6 @@
 #include "addr.h"
 
 
-#ifndef NULL
-#define NULL 0
-#endif
-
-
 LIST_HEAD(atm_devs);
 spinlock_t atm_dev_lock = SPIN_LOCK_UNLOCKED;
 
@@ -91,7 +86,7 @@
 	spin_lock(&atm_dev_lock);
 	if (number != -1) {
 		if ((inuse = __atm_dev_lookup(number))) {
-			atm_dev_release(inuse);
+			atm_dev_put(inuse);
 			spin_unlock(&atm_dev_lock);
 			__free_atm_dev(dev);
 			return NULL;
@@ -100,7 +95,7 @@
 	} else {
 		dev->number = 0;
 		while ((inuse = __atm_dev_lookup(dev->number))) {
-			atm_dev_release(inuse);
+			atm_dev_put(inuse);
 			dev->number++;
 		}
 	}
@@ -402,78 +397,12 @@
 	else
 		error = 0;
 done:
-	atm_dev_release(dev);
+	atm_dev_put(dev);
 	return error;
 }
 
 
-struct sock *alloc_atm_vcc_sk(int family)
-{
-	struct sock *sk;
-	struct atm_vcc *vcc;
-
-	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
-	if (!sk)
-		return NULL;
-	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
-	if (!vcc) {
-		sk_free(sk);
-		return NULL;
-	}
-	sock_init_data(NULL, sk);
-	memset(vcc, 0, sizeof(*vcc));
-	vcc->sk = sk;
-
-	return sk;
-}
-
-
-static void unlink_vcc(struct atm_vcc *vcc)
-{
-	unsigned long flags;
-	if (vcc->dev) {
-		spin_lock_irqsave(&vcc->dev->lock, flags);
-		if (vcc->prev)
-			vcc->prev->next = vcc->next;
-		else
-			vcc->dev->vccs = vcc->next;
-
-		if (vcc->next)
-			vcc->next->prev = vcc->prev;
-		else
-			vcc->dev->last = vcc->prev;
-		spin_unlock_irqrestore(&vcc->dev->lock, flags);
-	}
-}
-
-
-void free_atm_vcc_sk(struct sock *sk)
-{
-	unlink_vcc(atm_sk(sk));
-	sk_free(sk);
-}
-
-void bind_vcc(struct atm_vcc *vcc,struct atm_dev *dev)
-{
-	unsigned long flags;
-
-	unlink_vcc(vcc);
-	vcc->dev = dev;
-	if (dev) {
-		spin_lock_irqsave(&dev->lock, flags);
-		vcc->next = NULL;
-		vcc->prev = dev->last;
-		if (dev->vccs)
-			dev->last->next = vcc;
-		else
-			dev->vccs = vcc;
-		dev->last = vcc;
-		spin_unlock_irqrestore(&dev->lock, flags);
-	}
-}
-
 EXPORT_SYMBOL(atm_dev_register);
 EXPORT_SYMBOL(atm_dev_deregister);
 EXPORT_SYMBOL(atm_dev_lookup);
 EXPORT_SYMBOL(shutdown_atm_dev);
-EXPORT_SYMBOL(bind_vcc);
diff -Nru a/net/atm/resources.h b/net/atm/resources.h
--- a/net/atm/resources.h	Fri Jun 20 17:33:36 2003
+++ b/net/atm/resources.h	Fri Jun 20 17:33:36 2003
@@ -14,8 +14,6 @@
 extern spinlock_t atm_dev_lock;
 
 
-struct sock *alloc_atm_vcc_sk(int family);
-void free_atm_vcc_sk(struct sock *sk);
 int atm_dev_ioctl(unsigned int cmd, unsigned long arg);
 
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/signaling.c	Fri Jun 20 17:33:36 2003
@@ -200,26 +200,22 @@
 }
 
 
-static void purge_vccs(struct atm_vcc *vcc)
+static void purge_vcc(struct atm_vcc *vcc)
 {
-	while (vcc) {
-		if (vcc->sk->sk_family == PF_ATMSVC &&
-		    !test_bit(ATM_VF_META,&vcc->flags)) {
-			set_bit(ATM_VF_RELEASED,&vcc->flags);
-			vcc->reply = -EUNATCH;
-			vcc->sk->sk_err = EUNATCH;
-			wake_up(&vcc->sleep);
-		}
-		vcc = vcc->next;
+	if (vcc->sk->sk_family == PF_ATMSVC &&
+	    !test_bit(ATM_VF_META,&vcc->flags)) {
+		set_bit(ATM_VF_RELEASED,&vcc->flags);
+		vcc->reply = -EUNATCH;
+		vcc->sk->sk_err = EUNATCH;
+		wake_up(&vcc->sleep);
 	}
 }
 
 
 static void sigd_close(struct atm_vcc *vcc)
 {
-	unsigned long flags;
-	struct atm_dev *dev;
-	struct list_head *p;
+	struct hlist_node *node;
+	struct sock *s;
 
 	DPRINTK("sigd_close\n");
 	sigd = NULL;
@@ -227,14 +223,14 @@
 		printk(KERN_ERR "sigd_close: closing with requests pending\n");
 	skb_queue_purge(&vcc->sk->sk_receive_queue);
 
-	spin_lock(&atm_dev_lock);
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
-		spin_lock_irqsave(&dev->lock, flags);
-		purge_vccs(dev->vccs);
-		spin_unlock_irqrestore(&dev->lock, flags);
+	read_lock(&vcc_sklist_lock);
+	sk_for_each(s, node, &vcc_sklist) {
+		struct atm_vcc *vcc = atm_sk(s);
+
+		if (vcc->dev)
+			purge_vcc(vcc);
 	}
-	spin_unlock(&atm_dev_lock);
+	read_unlock(&vcc_sklist_lock);
 }
 
 
@@ -257,7 +253,8 @@
 	if (sigd) return -EADDRINUSE;
 	DPRINTK("sigd_attach\n");
 	sigd = vcc;
-	bind_vcc(vcc,&sigd_dev);
+	vcc->dev = &sigd_dev;
+	vcc_insert_socket(vcc->sk);
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 	wake_up(&sigd_sleep);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Fri Jun 20 17:33:36 2003
+++ b/net/atm/svc.c	Fri Jun 20 17:33:36 2003
@@ -88,18 +88,21 @@
 
 static int svc_release(struct socket *sock)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 
-	if (!sock->sk) return 0;
-	vcc = ATM_SD(sock);
-	DPRINTK("svc_release %p\n",vcc);
-	clear_bit(ATM_VF_READY,&vcc->flags);
-	atm_release_vcc_sk(sock->sk,0);
-	svc_disconnect(vcc);
-	    /* VCC pointer is used as a reference, so we must not free it
-	       (thereby subjecting it to re-use) before all pending connections
-	        are closed */
-	free_atm_vcc_sk(sock->sk);
+	if (sk)  {
+		vcc = ATM_SD(sock);
+		DPRINTK("svc_release %p\n", vcc);
+		clear_bit(ATM_VF_READY, &vcc->flags);
+		/* VCC pointer is used as a reference, so we must not free it
+		   (thereby subjecting it to re-use) before all pending connections
+	           are closed */
+		sock_hold(sk);
+		vcc_release(sock);
+		svc_disconnect(vcc);
+		sock_put(sk);
+	}
 	return 0;
 }
 
@@ -542,7 +545,7 @@
 	int error;
 
 	sock->ops = &svc_proto_ops;
-	error = atm_create(sock,protocol,AF_ATMSVC);
+	error = vcc_create(sock, protocol, AF_ATMSVC);
 	if (error) return error;
 	ATM_SD(sock)->callback = svc_callback;
 	ATM_SD(sock)->local.sas_family = AF_ATMSVC;

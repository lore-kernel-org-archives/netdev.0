From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC][1/2] remove atm_find_ci(); convert vcc_sklist to hash
Date: Wed, 08 Oct 2003 08:46:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310081246.h98CkvkT028983@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1435  -> 1.1436 
#	    drivers/atm/he.c	1.28    -> 1.29   
#	   drivers/atm/eni.c	1.29    -> 1.30   
#	      net/atm/proc.c	1.34    -> 1.35   
#	drivers/atm/atmtcp.c	1.25    -> 1.26   
#	 net/atm/signaling.c	1.24    -> 1.25   
#	include/linux/atmdev.h	1.37    -> 1.38   
#	drivers/atm/fore200e.c	1.26    -> 1.27   
#	    net/atm/common.c	1.59    -> 1.60   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/08	chas@relax.cmf.nrl.navy.mil	1.1436
# [ATM]: convert vcc list to hash
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Wed Oct  8 08:29:48 2003
+++ b/drivers/atm/atmtcp.c	Wed Oct  8 08:29:48 2003
@@ -158,6 +158,7 @@
 	struct atm_vcc *vcc;
 	struct hlist_node *node;
 	struct sock *s;
+	int i;
 
 	if (cmd != ATM_SETCIRANGE) return -ENOIOCTLCMD;
 	if (copy_from_user(&ci,(void *) arg,sizeof(ci))) return -EFAULT;
@@ -166,14 +167,18 @@
 	if (ci.vpi_bits > MAX_VPI_BITS || ci.vpi_bits < 0 ||
 	    ci.vci_bits > MAX_VCI_BITS || ci.vci_bits < 0) return -EINVAL;
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		vcc = atm_sk(s);
-		if (vcc->dev != dev)
-			continue;
-		if ((vcc->vpi >> ci.vpi_bits) ||
-		    (vcc->vci >> ci.vci_bits)) {
-			read_unlock(&vcc_sklist_lock);
-			return -EBUSY;
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+		struct hlist_head *head = &vcc_hash[i];
+
+		sk_for_each(s, node, head) {
+			vcc = atm_sk(s);
+			if (vcc->dev != dev)
+				continue;
+			if ((vcc->vpi >> ci.vpi_bits) ||
+			    (vcc->vci >> ci.vci_bits)) {
+				read_unlock(&vcc_sklist_lock);
+				return -EBUSY;
+			}
 		}
 	}
 	read_unlock(&vcc_sklist_lock);
@@ -244,6 +249,7 @@
 	struct sock *s;
 	struct hlist_node *node;
 	struct atm_vcc *walk;
+	int i;
 
 	atmtcp_dev = (struct atm_dev *) vcc->dev_data;
 	dev_data = PRIV(atmtcp_dev);
@@ -254,11 +260,15 @@
 	shutdown_atm_dev(atmtcp_dev);
 	vcc->dev_data = NULL;
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		walk = atm_sk(s);
-		if (walk->dev != atmtcp_dev)
-			continue;
-		wake_up(walk->sk->sk_sleep);
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+		struct hlist_head *head = &vcc_hash[i];
+
+		sk_for_each(s, node, head) {
+			walk = atm_sk(s);
+			if (walk->dev != atmtcp_dev)
+				continue;
+			wake_up(walk->sk->sk_sleep);
+		}
 	}
 	read_unlock(&vcc_sklist_lock);
 }
@@ -272,7 +282,7 @@
 	struct hlist_node *node;
 	struct atm_vcc *out_vcc = NULL;
 	struct sk_buff *new_skb;
-	int result = 0;
+	int i, result = 0;
 
 	if (!skb->len) return 0;
 	dev = vcc->dev_data;
@@ -283,14 +293,18 @@
 		goto done;
 	}
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		out_vcc = atm_sk(s);
-		if (out_vcc->dev != dev)
-			continue;
-		if (out_vcc->vpi == ntohs(hdr->vpi) &&
-		    out_vcc->vci == ntohs(hdr->vci) &&
-		    out_vcc->qos.rxtp.traffic_class != ATM_NONE)
-			break;
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+		struct hlist_head *head = &vcc_hash[i];
+
+		sk_for_each(s, node, head) {
+			out_vcc = atm_sk(s);
+			if (out_vcc->dev != dev)
+				continue;
+			if (out_vcc->vpi == ntohs(hdr->vpi) &&
+			    out_vcc->vci == ntohs(hdr->vci) &&
+			    out_vcc->qos.rxtp.traffic_class != ATM_NONE)
+				break;
+		}
 	}
 	read_unlock(&vcc_sklist_lock);
 	if (!out_vcc) {
diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	Wed Oct  8 08:29:48 2003
+++ b/drivers/atm/eni.c	Wed Oct  8 08:29:48 2003
@@ -2147,30 +2147,34 @@
 		    skb_queue_len(&tx->backlog));
 	}
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		struct eni_vcc *eni_vcc;
-		int length;
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+		struct hlist_head *head = &vcc_hash[i];
 
-		vcc = atm_sk(s);
-		if (vcc->dev != dev)
-			continue;
-		eni_vcc = ENI_VCC(vcc);
-		if (--left) continue;
-		length = sprintf(page,"vcc %4d: ",vcc->vci);
-		if (eni_vcc->rx) {
-			length += sprintf(page+length,"0x%06lx-0x%06lx "
-			    "(%6ld bytes)",
-			    eni_vcc->recv-eni_dev->ram,
-			    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
-			    eni_vcc->words*4);
-			if (eni_vcc->tx) length += sprintf(page+length,", ");
+		sk_for_each(s, node, head) {
+			struct eni_vcc *eni_vcc;
+			int length;
+
+			vcc = atm_sk(s);
+			if (vcc->dev != dev)
+				continue;
+			eni_vcc = ENI_VCC(vcc);
+			if (--left) continue;
+			length = sprintf(page,"vcc %4d: ",vcc->vci);
+			if (eni_vcc->rx) {
+				length += sprintf(page+length,"0x%06lx-0x%06lx "
+				    "(%6ld bytes)",
+				    eni_vcc->recv-eni_dev->ram,
+				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
+				    eni_vcc->words*4);
+				if (eni_vcc->tx) length += sprintf(page+length,", ");
+			}
+			if (eni_vcc->tx)
+				length += sprintf(page+length,"tx[%d], txing %d bytes",
+				    eni_vcc->tx->index,eni_vcc->txing);
+			page[length] = '\n';
+			read_unlock(&vcc_sklist_lock);
+			return length+1;
 		}
-		if (eni_vcc->tx)
-			length += sprintf(page+length,"tx[%d], txing %d bytes",
-			    eni_vcc->tx->index,eni_vcc->txing);
-		page[length] = '\n';
-		read_unlock(&vcc_sklist_lock);
-		return length+1;
 	}
 	read_unlock(&vcc_sklist_lock);
 	for (i = 0; i < eni_dev->free_len; i++) {
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Wed Oct  8 08:29:48 2003
+++ b/drivers/atm/fore200e.c	Wed Oct  8 08:29:48 2003
@@ -1071,14 +1071,16 @@
     struct sock *s;
     struct atm_vcc* vcc;
     struct hlist_node *node;
+    int i;
 
     read_lock(&vcc_sklist_lock);
-    sk_for_each(s, node, &vcc_sklist) {
+
+    sk_for_each(s, node, &vcc_hash[rpd->atm_header.vci & (VCC_HTABLE_SIZE-1)]) {
 	vcc = atm_sk(s);
 	if (vcc->dev != fore200e->atm_dev)
-		continue;
+	    continue;
 	if (vcc->vpi == rpd->atm_header.vpi && vcc->vci == rpd->atm_header.vci) {
-            read_unlock(&vcc_sklist_lock);
+	    read_unlock(&vcc_sklist_lock);
 	    return vcc;
 	}
     }
@@ -2606,7 +2608,7 @@
     struct sock *s;
     struct hlist_node *node;
     struct fore200e* fore200e  = FORE200E_DEV(dev);
-    int              len, left = *pos;
+    int              i, len, left = *pos;
 
     if (!left--) {
 
@@ -2852,15 +2854,18 @@
 		      " VCCs:\n  address\tVPI.VCI:AAL\t(min/max tx PDU size) (min/max rx PDU size)\n");
 	
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-	    vcc = atm_sk(s);
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+	    struct hlist_head *head = &vcc_hash[i];
 
-	    if (vcc->dev != fore200e->atm_dev)
+	    sk_for_each(s, node, head) {
+		vcc = atm_sk(s);
+
+		if (vcc->dev != fore200e->atm_dev)
 		    continue;
 
-	    fore200e_vcc = FORE200E_VCC(vcc);
+		fore200e_vcc = FORE200E_VCC(vcc);
 	    
-	    len += sprintf(page + len,
+		len += sprintf(page + len,
 			   "  %x\t%d.%d:%d\t\t(%d/%d)\t(%d/%d)\n",
 			   (u32)(unsigned long)vcc,
 			   vcc->vpi, vcc->vci, fore200e_atm2fore_aal(vcc->qos.aal),
@@ -2869,6 +2874,7 @@
 			   fore200e_vcc->rx_min_pdu > 0xFFFF ? 0 : fore200e_vcc->rx_min_pdu,
 			   fore200e_vcc->rx_max_pdu
 		);
+	    }
 	}
 	read_unlock(&vcc_sklist_lock);
 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Wed Oct  8 08:29:48 2003
+++ b/drivers/atm/he.c	Wed Oct  8 08:29:48 2003
@@ -328,6 +328,7 @@
 static __inline__ struct atm_vcc*
 __find_vcc(struct he_dev *he_dev, unsigned cid)
 {
+	struct hlist_head *head;
 	struct atm_vcc *vcc;
 	struct hlist_node *node;
 	struct sock *s;
@@ -336,8 +337,9 @@
 
 	vpi = cid >> he_dev->vcibits;
 	vci = cid & ((1 << he_dev->vcibits) - 1);
+	head = &vcc_hash[vci & (VCC_HTABLE_SIZE -1)];
 
-	sk_for_each(s, node, &vcc_sklist) {
+	sk_for_each(s, node, head) {
 		vcc = atm_sk(s);
 		if (vcc->dev == he_dev->atm_dev &&
 		    vcc->vci == vci && vcc->vpi == vpi &&
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Wed Oct  8 08:29:48 2003
+++ b/include/linux/atmdev.h	Wed Oct  8 08:29:48 2003
@@ -380,7 +380,9 @@
 	unsigned long	atm_options;	/* ATM layer options */
 };
 
-extern struct hlist_head vcc_sklist;
+#define VCC_HTABLE_SIZE 32
+
+extern struct hlist_head vcc_hash[VCC_HTABLE_SIZE];
 extern rwlock_t vcc_sklist_lock;
 
 #define ATM_SKB(skb) (((struct atm_skb_data *) (skb)->cb))
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Wed Oct  8 08:29:48 2003
+++ b/net/atm/common.c	Wed Oct  8 08:29:48 2003
@@ -38,13 +38,16 @@
 #define DPRINTK(format,args...)
 #endif
 
-
-HLIST_HEAD(vcc_sklist);
+struct hlist_head vcc_hash[VCC_HTABLE_SIZE];
 rwlock_t vcc_sklist_lock = RW_LOCK_UNLOCKED;
 
 void __vcc_insert_socket(struct sock *sk)
 {
-	sk_add_node(sk, &vcc_sklist);
+	struct atm_vcc *vcc = atm_sk(sk);
+	struct hlist_head *head = &vcc_hash[vcc->vci &
+					(VCC_HTABLE_SIZE - 1)];
+	sk->sk_hashent = vcc->vci & (VCC_HTABLE_SIZE - 1);
+	sk_add_node(sk, head);
 }
 
 void vcc_insert_socket(struct sock *sk)
@@ -80,7 +83,7 @@
 }
 
 
-EXPORT_SYMBOL(vcc_sklist);
+EXPORT_SYMBOL(vcc_hash);
 EXPORT_SYMBOL(vcc_sklist_lock);
 EXPORT_SYMBOL(vcc_insert_socket);
 EXPORT_SYMBOL(vcc_remove_socket);
@@ -250,11 +253,13 @@
 
 static int check_ci(struct atm_vcc *vcc, short vpi, int vci)
 {
+	struct hlist_head *head = &vcc_hash[vci &
+					(VCC_HTABLE_SIZE - 1)];
 	struct hlist_node *node;
 	struct sock *s;
 	struct atm_vcc *walk;
 
-	sk_for_each(s, node, &vcc_sklist) {
+	sk_for_each(s, node, head) {
 		walk = atm_sk(s);
 		if (walk->dev != vcc->dev)
 			continue;
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Wed Oct  8 08:29:48 2003
+++ b/net/atm/proc.c	Wed Oct  8 08:29:48 2003
@@ -64,6 +64,7 @@
 }
 
 struct vcc_state {
+	int bucket;
 	struct sock *sk;
 	int family;
 };
@@ -75,19 +76,30 @@
 	return !family || (vcc->sk->sk_family == family);
 }
 
-static int __vcc_walk(struct sock **sock, int family, loff_t l)
+static int __vcc_walk(struct sock **sock, int family, int *bucket, loff_t l)
 {
 	struct sock *sk = *sock;
 
 	if (sk == (void *)1) {
-		sk = hlist_empty(&vcc_sklist) ? NULL : __sk_head(&vcc_sklist);
+		for (*bucket = 0; *bucket < VCC_HTABLE_SIZE; ++*bucket) {
+			struct hlist_head *head = &vcc_hash[*bucket];
+
+			sk = hlist_empty(head) ? NULL : __sk_head(head);
+			if (sk)
+				break;
+		}
 		l--;
 	} 
+try_again:
 	for (; sk; sk = sk_next(sk)) {
 		l -= compare_family(sk, family);
 		if (l < 0)
 			goto out;
 	}
+	if (!sk && ++*bucket < VCC_HTABLE_SIZE) {
+		sk = sk_head(&vcc_hash[*bucket]);
+		goto try_again;
+	}
 	sk = (void *)1;
 out:
 	*sock = sk;
@@ -96,7 +108,7 @@
 
 static inline void *vcc_walk(struct vcc_state *state, loff_t l)
 {
-	return __vcc_walk(&state->sk, state->family, l) ?
+	return __vcc_walk(&state->sk, state->family, &state->bucket, l) ?
 	       state : NULL;
 }
 
@@ -207,9 +219,10 @@
 		default:
 			seq_printf(seq, "%3d", vcc->sk->sk_family);
 	}
-	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d\n", vcc->flags, vcc->sk->sk_err,
+	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d] 0x%x\n", vcc->flags, vcc->sk->sk_err,
 		atomic_read(&vcc->sk->sk_wmem_alloc),vcc->sk->sk_sndbuf,
-		atomic_read(&vcc->sk->sk_rmem_alloc),vcc->sk->sk_rcvbuf);
+		atomic_read(&vcc->sk->sk_rmem_alloc),vcc->sk->sk_rcvbuf,
+		atomic_read(&vcc->sk->sk_refcnt), vcc->sk->sk_hashent);
 }
 
 static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Wed Oct  8 08:29:48 2003
+++ b/net/atm/signaling.c	Wed Oct  8 08:29:48 2003
@@ -216,6 +216,7 @@
 {
 	struct hlist_node *node;
 	struct sock *s;
+	int i;
 
 	DPRINTK("sigd_close\n");
 	sigd = NULL;
@@ -224,11 +225,15 @@
 	skb_queue_purge(&vcc->sk->sk_receive_queue);
 
 	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		struct atm_vcc *vcc = atm_sk(s);
+	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+		struct hlist_head *head = &vcc_hash[i];
 
-		if (vcc->dev)
-			purge_vcc(vcc);
+		sk_for_each(s, node, head) {
+			struct atm_vcc *vcc = atm_sk(s);
+
+			if (vcc->dev)
+				purge_vcc(vcc);
+		}
 	}
 	read_unlock(&vcc_sklist_lock);
 }

From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC][2/2] remove atm_find_ci(); convert vcc_sklist to hash
Date: Wed, 08 Oct 2003 08:50:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310081250.h98CoHkT029036@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[please note i got parts 1 and 2 out of order just like me]

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1434  -> 1.1435 
#	drivers/atm/horizon.c	1.17    -> 1.18   
#	drivers/atm/ambassador.c	1.19    -> 1.20   
#	drivers/atm/firestream.c	1.28    -> 1.29   
#	    drivers/atm/he.c	1.27    -> 1.28   
#	drivers/atm/nicstar.c	1.22    -> 1.23   
#	  net/atm/atm_misc.c	1.14    -> 1.15   
#	   drivers/atm/eni.c	1.28    -> 1.29   
#	  drivers/atm/zatm.c	1.23    -> 1.24   
#	 drivers/atm/lanai.c	1.30    -> 1.31   
#	drivers/atm/idt77252.c	1.28    -> 1.29   
#	drivers/atm/atmtcp.c	1.24    -> 1.25   
#	include/linux/atmdev.h	1.36    -> 1.37   
#	drivers/atm/iphase.c	1.30    -> 1.31   
#	drivers/atm/fore200e.c	1.25    -> 1.26   
#	drivers/usb/misc/speedtch.c	1.97    -> 1.98   
#	    net/atm/common.c	1.58    -> 1.59   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/07	chas@relax.cmf.nrl.navy.mil	1.1435
# [ATM]: eliminate atm_find_ci()
# --------------------------------------------
#
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/ambassador.c	Wed Oct  8 08:48:46 2003
@@ -1064,7 +1064,8 @@
 
 /********** Open a VC **********/
 
-static int amb_open (struct atm_vcc * atm_vcc, short vpi, int vci) {
+static int amb_open (struct atm_vcc * atm_vcc)
+{
   int error;
   
   struct atm_qos * qos;
@@ -1077,6 +1078,8 @@
   amb_dev * dev = AMB_DEV(atm_vcc->dev);
   amb_vcc * vcc;
   unsigned char pool = -1; // hush gcc
+  short vpi = atm_vcc->vpi;
+  int vci = atm_vcc->vci;
   
   PRINTD (DBG_FLOW|DBG_VCC, "amb_open %x %x", vpi, vci);
   
@@ -1088,14 +1091,6 @@
   }
 #endif
   
-  // deal with possibly wildcarded VCs
-  error = atm_find_ci (atm_vcc, &vpi, &vci);
-  if (error) {
-    PRINTD (DBG_WARN|DBG_VCC, "atm_find_ci failed!");
-    return error;
-  }
-  PRINTD (DBG_VCC, "atm_find_ci gives %x %x", vpi, vci);
-  
   if (!(0 <= vpi && vpi < (1<<NUM_VPI_BITS) &&
 	0 <= vci && vci < (1<<NUM_VCI_BITS))) {
     PRINTD (DBG_WARN|DBG_VCC, "VPI/VCI out of range: %hd/%d", vpi, vci);
@@ -1273,10 +1268,6 @@
     dev->rxer[vci] = atm_vcc;
     up (&dev->vcc_sf);
   }
-  
-  // set elements of vcc
-  atm_vcc->vpi = vpi; // 0
-  atm_vcc->vci = vci;
   
   // indicate readiness
   set_bit(ATM_VF_READY,&atm_vcc->flags);
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/atmtcp.c	Wed Oct  8 08:48:46 2003
@@ -115,10 +115,12 @@
 }
 
 
-static int atmtcp_v_open(struct atm_vcc *vcc,short vpi,int vci)
+static int atmtcp_v_open(struct atm_vcc *vcc)
 {
 	struct atmtcp_control msg;
 	int error;
+	short vpi = vcc->vpi;
+	int vci = vcc->vci;
 
 	memset(&msg,0,sizeof(msg));
 	msg.addr.sap_family = AF_ATMPVC;
@@ -126,8 +128,6 @@
 	msg.addr.sap_addr.vpi = vpi;
 	msg.hdr.vci = htons(vci);
 	msg.addr.sap_addr.vci = vci;
-	error = atm_find_ci(vcc,&msg.addr.sap_addr.vpi,&msg.addr.sap_addr.vci);
-	if (error) return error;
 	if (vpi == ATM_VPI_UNSPEC || vci == ATM_VCI_UNSPEC) return 0;
 	msg.type = ATMTCP_CTRL_OPEN;
 	msg.qos = vcc->qos;
diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/eni.c	Wed Oct  8 08:48:46 2003
@@ -1881,80 +1881,18 @@
 }
 
 
-static int get_ci(struct atm_vcc *vcc,short *vpi,int *vci)
-{
-	struct sock *s;
-	struct hlist_node *node;
-	struct atm_vcc *walk;
-
-	read_lock(&vcc_sklist_lock);
-	if (*vpi == ATM_VPI_ANY) *vpi = 0;
-	if (*vci == ATM_VCI_ANY) {
-		for (*vci = ATM_NOT_RSV_VCI; *vci < NR_VCI; (*vci)++) {
-			if (vcc->qos.rxtp.traffic_class != ATM_NONE &&
-			    ENI_DEV(vcc->dev)->rx_map[*vci])
-				continue;
-			if (vcc->qos.txtp.traffic_class != ATM_NONE) {
-				sk_for_each(s, node, &vcc_sklist) {
-					walk = atm_sk(s);
-					if (walk->dev != vcc->dev)
-						continue;
-					if (test_bit(ATM_VF_ADDR,&walk->flags)
-					    && walk->vci == *vci &&
-					    walk->qos.txtp.traffic_class !=
-					    ATM_NONE)
-						break;
-				}
-				if (node)
-					continue;
-			}
-			break;
-		}
-		read_unlock(&vcc_sklist_lock);
-		return *vci == NR_VCI ? -EADDRINUSE : 0;
-	}
-	if (*vci == ATM_VCI_UNSPEC) {
-		read_unlock(&vcc_sklist_lock);
-		return 0;
-	}
-	if (vcc->qos.rxtp.traffic_class != ATM_NONE &&
-	    ENI_DEV(vcc->dev)->rx_map[*vci]) {
-		read_unlock(&vcc_sklist_lock);
-		return -EADDRINUSE;
-	}
-	if (vcc->qos.txtp.traffic_class == ATM_NONE) {
-		read_unlock(&vcc_sklist_lock);
-		return 0;
-	}
-	sk_for_each(s, node, &vcc_sklist) {
-		walk = atm_sk(s);
-		if (walk->dev != vcc->dev)
-			continue;
-		if (test_bit(ATM_VF_ADDR,&walk->flags) && walk->vci == *vci &&
-		    walk->qos.txtp.traffic_class != ATM_NONE) {
-			read_unlock(&vcc_sklist_lock);
-			return -EADDRINUSE;
-		}
-	}
-	read_unlock(&vcc_sklist_lock);
-	return 0;
-}
-
-
-static int eni_open(struct atm_vcc *vcc,short vpi,int vci)
+static int eni_open(struct atm_vcc *vcc)
 {
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
 	int error;
+	short vpi = vcc->vpi;
+	int vci = vcc->vci;
 
 	DPRINTK(">eni_open\n");
 	EVENT("eni_open\n",0,0);
 	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags)) ENI_VCC(vcc) = NULL;
 	eni_dev = ENI_DEV(vcc->dev);
-	error = get_ci(vcc,&vpi,&vci);
-	if (error) return error;
-	vcc->vpi = vpi;
-	vcc->vci = vci;
 	if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_ADDR,&vcc->flags);
 	if (vcc->qos.aal != ATM_AAL0 && vcc->qos.aal != ATM_AAL5)
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/firestream.c	Wed Oct  8 08:48:46 2003
@@ -854,7 +854,7 @@
 
 #define DO_DIRECTION(tp) ((tp)->traffic_class != ATM_NONE)
 
-static int fs_open(struct atm_vcc *atm_vcc, short vpi, int vci)
+static int fs_open(struct atm_vcc *atm_vcc)
 {
 	struct fs_dev *dev;
 	struct fs_vcc *vcc;
@@ -867,6 +867,8 @@
 	int bfp;
 	int to;
 	unsigned short tmc0;
+	short vpi = atm_vcc->vpi;
+	int vci = atm_vcc->vci;
 
 	func_enter ();
 
@@ -874,14 +876,6 @@
 	fs_dprintk (FS_DEBUG_OPEN, "fs: open on dev: %p, vcc at %p\n", 
 		    dev, atm_vcc);
 
-	error = atm_find_ci(atm_vcc, &vpi, &vci);
-	if (error) {
-		fs_dprintk (FS_DEBUG_OPEN, "fs: find_ci failed.\n");
-		return error;
-	}
-
-	atm_vcc->vpi = vpi;
-	atm_vcc->vci = vci;
 	if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_ADDR, &atm_vcc->flags);
 
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/fore200e.c	Wed Oct  8 08:48:46 2003
@@ -1351,56 +1351,6 @@
 }
 
 
-static int
-fore200e_walk_vccs(struct atm_vcc *vcc, short *vpi, int *vci)
-{
-    struct atm_vcc* walk;
-    struct sock *s;
-    struct hlist_node *node;
-
-    /* find a free VPI */
-
-    read_lock(&vcc_sklist_lock);
-
-    if (*vpi == ATM_VPI_ANY) {
-
-	*vpi = 0;
-restart_vpi_search:
-	sk_for_each(s, node, &vcc_sklist) {
-	    walk = atm_sk(s);
-	    if (walk->dev != vcc->dev)
-		continue;
-
-	    if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
-		(*vpi)++;
-		goto restart_vpi_search;
-	    }
-	}
-    }
-
-    /* find a free VCI */
-    if (*vci == ATM_VCI_ANY) {
-	
-	*vci = ATM_NOT_RSV_VCI;
-restart_vci_search:
-	sk_for_each(s, node, &vcc_sklist) {
-	    walk = atm_sk(s);
-	    if (walk->dev != vcc->dev)
-		continue;
-
-	    if ((walk->vpi = *vpi) && (walk->vci == *vci)) {
-		*vci = walk->vci + 1;
-		goto restart_vci_search;
-	    }
-	}
-    }
-
-    read_unlock(&vcc_sklist_lock);
-
-    return 0;
-}
-
-
 #define FORE200E_MAX_BACK2BACK_CELLS 255    /* XXX depends on CDVT */
 
 static void
@@ -1420,17 +1370,13 @@
 
 
 static int
-fore200e_open(struct atm_vcc *vcc, short vpi, int vci)
+fore200e_open(struct atm_vcc *vcc)
 {
     struct fore200e*     fore200e = FORE200E_DEV(vcc->dev);
     struct fore200e_vcc* fore200e_vcc;
+    short vpi = vcc->vpi;
+    int vci = vcc->vci;
     
-    /* find a free VPI/VCI */
-    fore200e_walk_vccs(vcc, &vpi, &vci);
-
-    vcc->vpi = vpi;
-    vcc->vci = vci;
-
     /* ressource checking only? */
     if (vci == ATM_VCI_UNSPEC || vpi == ATM_VPI_UNSPEC)
 	return 0;
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/he.c	Wed Oct  8 08:48:46 2003
@@ -135,7 +135,7 @@
 
 /* declarations */
 
-static int he_open(struct atm_vcc *vcc, short vpi, int vci);
+static int he_open(struct atm_vcc *vcc);
 static void he_close(struct atm_vcc *vcc);
 static int he_send(struct atm_vcc *vcc, struct sk_buff *skb);
 static int he_ioctl(struct atm_dev *dev, unsigned int cmd, void *arg);
@@ -2342,23 +2342,18 @@
 }
 
 static int
-he_open(struct atm_vcc *vcc, short vpi, int vci)
+he_open(struct atm_vcc *vcc)
 {
 	unsigned long flags;
 	struct he_dev *he_dev = HE_DEV(vcc->dev);
 	struct he_vcc *he_vcc;
 	int err = 0;
 	unsigned cid, rsr0, rsr1, rsr4, tsr0, tsr0_aal, tsr4, period, reg, clock;
+	short vpi = vcc->vpi;
+	int vci = vcc->vci;
 
-	
-	if ((err = atm_find_ci(vcc, &vpi, &vci))) {
-		HPRINTK("atm_find_ci err = %d\n", err);
-		return err;
-	}
 	if (vci == ATM_VCI_UNSPEC || vpi == ATM_VPI_UNSPEC)
 		return 0;
-	vcc->vpi = vpi;
-	vcc->vci = vci;
 
 	HPRINTK("open vcc %p %d.%d\n", vcc, vpi, vci);
 
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/horizon.c	Wed Oct  8 08:48:46 2003
@@ -2174,7 +2174,8 @@
 
 /********** open VC **********/
 
-static int hrz_open (struct atm_vcc * atm_vcc, short vpi, int vci) {
+static int hrz_open (struct atm_vcc *atm_vcc)
+{
   int error;
   u16 channel;
   
@@ -2185,6 +2186,8 @@
   hrz_dev * dev = HRZ_DEV(atm_vcc->dev);
   hrz_vcc vcc;
   hrz_vcc * vccp; // allocated late
+  short vpi = atm_vcc->vpi;
+  int vci = atm_vcc->vci;
   PRINTD (DBG_FLOW|DBG_VCC, "hrz_open %x %x", vpi, vci);
   
 #ifdef ATM_VPI_UNSPEC
@@ -2195,14 +2198,6 @@
   }
 #endif
   
-  // deal with possibly wildcarded VCs
-  error = atm_find_ci (atm_vcc, &vpi, &vci);
-  if (error) {
-    PRINTD (DBG_WARN|DBG_VCC, "atm_find_ci failed!");
-    return error;
-  }
-  PRINTD (DBG_VCC, "atm_find_ci gives %x %x", vpi, vci);
-  
   error = vpivci_to_channel (&channel, vpi, vci);
   if (error) {
     PRINTD (DBG_WARN|DBG_VCC, "VPI/VCI out of range: %hd/%d", vpi, vci);
@@ -2557,8 +2552,6 @@
   }
   
   // success, set elements of atm_vcc
-  atm_vcc->vpi = vpi;
-  atm_vcc->vci = vci;
   atm_vcc->dev_data = (void *) vccp;
   
   // indicate readiness
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/idt77252.c	Wed Oct  8 08:48:46 2003
@@ -122,7 +122,7 @@
  * ATM Interface.
  */
 static void idt77252_dev_close(struct atm_dev *dev);
-static int idt77252_open(struct atm_vcc *vcc, short vpi, int vci);
+static int idt77252_open(struct atm_vcc *vcc);
 static void idt77252_close(struct atm_vcc *vcc);
 static int idt77252_send(struct atm_vcc *vcc, struct sk_buff *skb);
 static int idt77252_send_oam(struct atm_vcc *vcc, void *cell,
@@ -2402,50 +2402,7 @@
 }
 
 static int
-idt77252_find_vcc(struct atm_vcc *vcc, short *vpi, int *vci)
-{
-	struct sock *s;
-	struct atm_vcc *walk;
-
-	read_lock(&vcc_sklist_lock);
-	if (*vpi == ATM_VPI_ANY) {
-		*vpi = 0;
-		s = sk_head(&vcc_sklist);
-		while (s) {
-			walk = atm_sk(s);
-			if (walk->dev != vcc->dev)
-				continue;
-			if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
-				(*vpi)++;
-				s = sk_head(&vcc_sklist);
-				continue;
-			}
-			s = sk_next(s);
-		}
-	}
-
-	if (*vci == ATM_VCI_ANY) {
-		*vci = ATM_NOT_RSV_VCI;
-		s = sk_head(&vcc_sklist);
-		while (s) {
-			walk = atm_sk(s);
-			if (walk->dev != vcc->dev)
-				continue;
-			if ((walk->vci == *vci) && (walk->vpi == *vpi)) {
-				(*vci)++;
-				s = sk_head(&vcc_sklist);
-				continue;
-			}
-			s = sk_next(s);
-		}
-	}
-
-	read_unlock(&vcc_sklist_lock);
-	return 0;
-}
-
-static int
-idt77252_open(struct atm_vcc *vcc, short vpi, int vci)
+idt77252_open(struct atm_vcc *vcc)
 {
 	struct atm_dev *dev = vcc->dev;
 	struct idt77252_dev *card = dev->dev_data;
@@ -2453,8 +2410,8 @@
 	unsigned int index;
 	unsigned int inuse;
 	int error;
-
-	idt77252_find_vcc(vcc, &vpi, &vci);
+	int vci = vcc->vci;
+	short vpi = vcc->vpi;
 
 	if (vpi == ATM_VPI_UNSPEC || vci == ATM_VCI_UNSPEC)
 		return 0;
@@ -2469,8 +2426,6 @@
 		return -EINVAL;
 	}
 
-	vcc->vpi = vpi;
-	vcc->vci = vci;
 	set_bit(ATM_VF_ADDR, &vcc->flags);
 
 	down(&card->mutex);
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/iphase.c	Wed Oct  8 08:48:46 2003
@@ -2676,7 +2676,7 @@
         return;        
 }  
   
-static int ia_open(struct atm_vcc *vcc, short vpi, int vci)  
+static int ia_open(struct atm_vcc *vcc)
 {  
 	IADEV *iadev;  
 	struct ia_vcc *ia_vcc;  
@@ -2687,15 +2687,7 @@
 		INPH_IA_VCC(vcc) = NULL;  
 	}  
 	iadev = INPH_IA_DEV(vcc->dev);  
-	error = atm_find_ci(vcc, &vpi, &vci);  
-	if (error)   
-	{  
-	    printk("iadev: atm_find_ci returned error %d\n", error);  
-	    return error;  
-	}  
-	vcc->vpi = vpi;  
-	vcc->vci = vci;  
-	if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)  
+	if (vcc->vci != ATM_VPI_UNSPEC && vcc->vpi != ATM_VCI_UNSPEC)  
 	{  
 		IF_EVENT(printk("iphase open: unspec part\n");)  
 		set_bit(ATM_VF_ADDR,&vcc->flags);
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/lanai.c	Wed Oct  8 08:48:46 2003
@@ -2350,11 +2350,13 @@
 }
 
 /* open a vcc on the card to vpi/vci */
-static int lanai_open(struct atm_vcc *atmvcc, short vpi, int vci)
+static int lanai_open(struct atm_vcc *atmvcc)
 {
 	struct lanai_dev *lanai;
 	struct lanai_vcc *lvcc;
 	int result = 0;
+	int vci = atmvcc->vci;
+	short vpi = atmvcc->vpi;
 	/* we don't support partial open - it's not really useful anyway */
 	if ((test_bit(ATM_VF_PARTIAL, &atmvcc->flags)) ||
 	    (vpi == ATM_VPI_UNSPEC) || (vci == ATM_VCI_UNSPEC))
@@ -2363,8 +2365,6 @@
 	result = lanai_normalize_ci(lanai, atmvcc, &vpi, &vci);
 	if (unlikely(result != 0))
 		goto out;
-	atmvcc->vpi = vpi;
-	atmvcc->vci = vci;
 	set_bit(ATM_VF_ADDR, &atmvcc->flags);
 	if (atmvcc->qos.aal != ATM_AAL0 && atmvcc->qos.aal != ATM_AAL5)
 		return -EINVAL;
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/nicstar.c	Wed Oct  8 08:48:46 2003
@@ -221,7 +221,7 @@
 static void push_rxbufs(ns_dev *card, u32 type, u32 handle1, u32 addr1,
                        u32 handle2, u32 addr2);
 static irqreturn_t ns_irq_handler(int irq, void *dev_id, struct pt_regs *regs);
-static int ns_open(struct atm_vcc *vcc, short vpi, int vci);
+static int ns_open(struct atm_vcc *vcc);
 static void ns_close(struct atm_vcc *vcc);
 static void fill_tst(ns_dev *card, int n, vc_map *vc);
 static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb);
@@ -1371,11 +1371,10 @@
 
 
 
-static int ns_open(struct atm_vcc *vcc, short vpi, int vci)
+static int ns_open(struct atm_vcc *vcc)
 {
    ns_dev *card;
    vc_map *vc;
-   int error;
    unsigned long tmpl, modl;
    int tcr, tcra;	/* target cell rate, and absolute value */
    int n = 0;		/* Number of entries in the TST. Initialized to remove
@@ -1386,6 +1385,8 @@
 			   tell which variables can truly be used
 			   uninitialized... */
    int inuse;		/* tx or rx vc already in use by another vcc */
+   short vpi = vcc->vpi;
+   int vci = vcc->vci;
 
    card = (ns_dev *) vcc->dev->dev_data;
    PRINTK("nicstar%d: opening vpi.vci %d.%d \n", card->index, (int) vpi, vci);
@@ -1395,14 +1396,7 @@
       return -EINVAL;
    }
 
-   if ((error = atm_find_ci(vcc, &vpi, &vci)))
-   {
-      PRINTK("nicstar%d: error in atm_find_ci().\n", card->index);
-      return error;
-   }
    vc = &(card->vcmap[vpi << card->vcibits | vci]);
-   vcc->vpi = vpi;
-   vcc->vci = vci;
    vcc->dev_data = vc;
 
    inuse = 0;
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/atm/zatm.c	Wed Oct  8 08:48:46 2003
@@ -1373,19 +1373,17 @@
 }
 
 
-static int zatm_open(struct atm_vcc *vcc,short vpi,int vci)
+static int zatm_open(struct atm_vcc *vcc)
 {
 	struct zatm_dev *zatm_dev;
 	struct zatm_vcc *zatm_vcc;
+	short vpi = vcc->vpi;
+	int vci = vcc->vci;
 	int error;
 
 	DPRINTK(">zatm_open\n");
 	zatm_dev = ZATM_DEV(vcc->dev);
 	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags)) ZATM_VCC(vcc) = NULL;
-	error = atm_find_ci(vcc,&vpi,&vci);
-	if (error) return error;
-	vcc->vpi = vpi;
-	vcc->vci = vci;
 	if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_ADDR,&vcc->flags);
 	if (vcc->qos.aal != ATM_AAL5) return -EINVAL; /* @@@ AAL0 */
diff -Nru a/drivers/usb/misc/speedtch.c b/drivers/usb/misc/speedtch.c
--- a/drivers/usb/misc/speedtch.c	Wed Oct  8 08:48:46 2003
+++ b/drivers/usb/misc/speedtch.c	Wed Oct  8 08:48:46 2003
@@ -264,7 +264,7 @@
 /* ATM */
 
 static void udsl_atm_dev_close (struct atm_dev *dev);
-static int udsl_atm_open (struct atm_vcc *vcc, short vpi, int vci);
+static int udsl_atm_open (struct atm_vcc *vcc);
 static void udsl_atm_close (struct atm_vcc *vcc);
 static int udsl_atm_ioctl (struct atm_dev *dev, unsigned int cmd, void *arg);
 static int udsl_atm_send (struct atm_vcc *vcc, struct sk_buff *skb);
@@ -867,10 +867,12 @@
 	return 0;
 }
 
-static int udsl_atm_open (struct atm_vcc *vcc, short vpi, int vci)
+static int udsl_atm_open (struct atm_vcc *vcc)
 {
 	struct udsl_instance_data *instance = vcc->dev->dev_data;
 	struct udsl_vcc_data *new;
+	int vci = vcc->vci;
+	short vpi = vcc->vpi;
 
 	dbg ("udsl_atm_open: vpi %hd, vci %d", vpi, vci);
 
@@ -879,9 +881,6 @@
 		return -ENODEV;
 	}
 
-	if ((vpi == ATM_VPI_ANY) || (vci == ATM_VCI_ANY))
-		return -EINVAL;
-
 	/* only support AAL5 */
 	if ((vcc->qos.aal != ATM_AAL5) || (vcc->qos.rxtp.max_sdu < 0) || (vcc->qos.rxtp.max_sdu > ATM_MAX_AAL5_PDU))
 		return -EINVAL;
@@ -910,8 +909,6 @@
 	new->max_pdu = max (1, UDSL_NUM_CELLS (vcc->qos.rxtp.max_sdu)) * ATM_CELL_PAYLOAD;
 
 	vcc->dev_data = new;
-	vcc->vpi = vpi;
-	vcc->vci = vci;
 
 	tasklet_disable (&instance->receive_tasklet);
 	list_add (&new->list, &instance->vcc_list);
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Wed Oct  8 08:48:46 2003
+++ b/include/linux/atmdev.h	Wed Oct  8 08:48:46 2003
@@ -351,7 +351,7 @@
 
 struct atmdev_ops { /* only send is required */
 	void (*dev_close)(struct atm_dev *dev);
-	int (*open)(struct atm_vcc *vcc,short vpi,int vci);
+	int (*open)(struct atm_vcc *vcc);
 	void (*close)(struct atm_vcc *vcc);
 	int (*ioctl)(struct atm_dev *dev,unsigned int cmd,void *arg);
 	int (*getsockopt)(struct atm_vcc *vcc,int level,int optname,
@@ -443,7 +443,6 @@
 int atm_charge(struct atm_vcc *vcc,int truesize);
 struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
     int gfp_flags);
-int atm_find_ci(struct atm_vcc *vcc,short *vpi,int *vci);
 int atm_pcr_goal(struct atm_trafprm *tp);
 
 void vcc_release_async(struct atm_vcc *vcc, int reply);
diff -Nru a/net/atm/atm_misc.c b/net/atm/atm_misc.c
--- a/net/atm/atm_misc.c	Wed Oct  8 08:48:46 2003
+++ b/net/atm/atm_misc.c	Wed Oct  8 08:48:46 2003
@@ -45,76 +45,6 @@
 }
 
 
-static int check_ci(struct atm_vcc *vcc,short vpi,int vci)
-{
-	struct hlist_node *node;
-	struct sock *s;
-	struct atm_vcc *walk;
-
-	sk_for_each(s, node, &vcc_sklist) {
-		walk = atm_sk(s);
-		if (walk->dev != vcc->dev)
-			continue;
-		if (test_bit(ATM_VF_ADDR,&walk->flags) && walk->vpi == vpi &&
-		    walk->vci == vci && ((walk->qos.txtp.traffic_class !=
-		    ATM_NONE && vcc->qos.txtp.traffic_class != ATM_NONE) ||
-		    (walk->qos.rxtp.traffic_class != ATM_NONE &&
-		    vcc->qos.rxtp.traffic_class != ATM_NONE)))
-			return -EADDRINUSE;
-	}
-		/* allow VCCs with same VPI/VCI iff they don't collide on
-		   TX/RX (but we may refuse such sharing for other reasons,
-		   e.g. if protocol requires to have both channels) */
-	return 0;
-}
-
-
-int atm_find_ci(struct atm_vcc *vcc,short *vpi,int *vci)
-{
-	static short p;        /* poor man's per-device cache */
-	static int c;
-	short old_p;
-	int old_c;
-	int err;
-
-	read_lock(&vcc_sklist_lock);
-	if (*vpi != ATM_VPI_ANY && *vci != ATM_VCI_ANY) {
-		err = check_ci(vcc,*vpi,*vci);
-		read_unlock(&vcc_sklist_lock);
-		return err;
-	}
-	/* last scan may have left values out of bounds for current device */
-	if (*vpi != ATM_VPI_ANY) p = *vpi;
-	else if (p >= 1 << vcc->dev->ci_range.vpi_bits) p = 0;
-	if (*vci != ATM_VCI_ANY) c = *vci;
-	else if (c < ATM_NOT_RSV_VCI || c >= 1 << vcc->dev->ci_range.vci_bits)
-			c = ATM_NOT_RSV_VCI;
-	old_p = p;
-	old_c = c;
-	do {
-		if (!check_ci(vcc,p,c)) {
-			*vpi = p;
-			*vci = c;
-			read_unlock(&vcc_sklist_lock);
-			return 0;
-		}
-		if (*vci == ATM_VCI_ANY) {
-			c++;
-			if (c >= 1 << vcc->dev->ci_range.vci_bits)
-				c = ATM_NOT_RSV_VCI;
-		}
-		if ((c == ATM_NOT_RSV_VCI || *vci != ATM_VCI_ANY) &&
-		    *vpi == ATM_VPI_ANY) {
-			p++;
-			if (p >= 1 << vcc->dev->ci_range.vpi_bits) p = 0;
-		}
-	}
-	while (old_p != p || old_c != c);
-	read_unlock(&vcc_sklist_lock);
-	return -EADDRINUSE;
-}
-
-
 /*
  * atm_pcr_goal returns the positive PCR if it should be rounded up, the
  * negative PCR if it should be rounded down, and zero if the maximum available
@@ -170,7 +100,6 @@
 
 EXPORT_SYMBOL(atm_charge);
 EXPORT_SYMBOL(atm_alloc_charge);
-EXPORT_SYMBOL(atm_find_ci);
 EXPORT_SYMBOL(atm_pcr_goal);
 EXPORT_SYMBOL(sonet_copy_stats);
 EXPORT_SYMBOL(sonet_subtract_stats);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Wed Oct  8 08:48:46 2003
+++ b/net/atm/common.c	Wed Oct  8 08:48:46 2003
@@ -248,7 +248,78 @@
 }
 
 
-static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, int vpi,
+static int check_ci(struct atm_vcc *vcc, short vpi, int vci)
+{
+	struct hlist_node *node;
+	struct sock *s;
+	struct atm_vcc *walk;
+
+	sk_for_each(s, node, &vcc_sklist) {
+		walk = atm_sk(s);
+		if (walk->dev != vcc->dev)
+			continue;
+		if (test_bit(ATM_VF_ADDR, &walk->flags) && walk->vpi == vpi &&
+		    walk->vci == vci && ((walk->qos.txtp.traffic_class !=
+		    ATM_NONE && vcc->qos.txtp.traffic_class != ATM_NONE) ||
+		    (walk->qos.rxtp.traffic_class != ATM_NONE &&
+		    vcc->qos.rxtp.traffic_class != ATM_NONE)))
+			return -EADDRINUSE;
+	}
+
+	/* allow VCCs with same VPI/VCI iff they don't collide on
+	   TX/RX (but we may refuse such sharing for other reasons,
+	   e.g. if protocol requires to have both channels) */
+
+	return 0;
+}
+
+
+static int find_ci(struct atm_vcc *vcc, short *vpi, int *vci)
+{
+	static short p;        /* poor man's per-device cache */
+	static int c;
+	short old_p;
+	int old_c;
+	int err;
+
+	if (*vpi != ATM_VPI_ANY && *vci != ATM_VCI_ANY) {
+		err = check_ci(vcc, *vpi, *vci);
+		return err;
+	}
+	/* last scan may have left values out of bounds for current device */
+	if (*vpi != ATM_VPI_ANY)
+		p = *vpi;
+	else if (p >= 1 << vcc->dev->ci_range.vpi_bits)
+		p = 0;
+	if (*vci != ATM_VCI_ANY)
+		c = *vci;
+	else if (c < ATM_NOT_RSV_VCI || c >= 1 << vcc->dev->ci_range.vci_bits)
+			c = ATM_NOT_RSV_VCI;
+	old_p = p;
+	old_c = c;
+	do {
+		if (!check_ci(vcc, p, c)) {
+			*vpi = p;
+			*vci = c;
+			return 0;
+		}
+		if (*vci == ATM_VCI_ANY) {
+			c++;
+			if (c >= 1 << vcc->dev->ci_range.vci_bits)
+				c = ATM_NOT_RSV_VCI;
+		}
+		if ((c == ATM_NOT_RSV_VCI || *vci != ATM_VCI_ANY) &&
+		    *vpi == ATM_VPI_ANY) {
+			p++;
+			if (p >= 1 << vcc->dev->ci_range.vpi_bits) p = 0;
+		}
+	}
+	while (old_p != p || old_c != c);
+	return -EADDRINUSE;
+}
+
+
+static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 			 int vci)
 {
 	int error;
@@ -260,8 +331,18 @@
 	if (vci > 0 && vci < ATM_NOT_RSV_VCI && !capable(CAP_NET_BIND_SERVICE))
 		return -EPERM;
 	error = 0;
+	if (!try_module_get(dev->ops->owner))
+		return -ENODEV;
 	vcc->dev = dev;
-	vcc_insert_socket(vcc->sk);
+	write_lock_irq(&vcc_sklist_lock);
+	if ((error = find_ci(vcc, &vpi, &vci))) {
+		write_unlock_irq(&vcc_sklist_lock);
+		goto fail_module_put;
+	}
+	vcc->vpi = vpi;
+	vcc->vci = vci;
+	__vcc_insert_socket(vcc->sk);
+	write_unlock_irq(&vcc_sklist_lock);
 	switch (vcc->qos.aal) {
 		case ATM_AAL0:
 			error = atm_init_aal0(vcc);
@@ -291,21 +372,17 @@
 	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
 	DPRINTK("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
 	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
-	if (!try_module_get(dev->ops->owner)) {
-		error = -ENODEV;
-		goto fail;
-	}
 
 	if (dev->ops->open) {
-		if ((error = dev->ops->open(vcc,vpi,vci)))
-			goto put_module_fail;
+		if ((error = dev->ops->open(vcc)))
+			goto fail;
 	}
 	return 0;
 
-put_module_fail:
-	module_put(dev->ops->owner);
 fail:
 	vcc_remove_socket(vcc->sk);
+fail_module_put:
+	module_put(dev->ops->owner);
 	/* ensure we get dev module ref count correct */
 	vcc->dev = NULL;
 	return error;

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-next-2.6 2/6] atm: [suni] add support for setting loopback and framing modes
Date: Tue, 17 Jun 2008 09:57:23 -0400
Message-ID: <200806171357.m5HDvNZF032196@cmf.nrl.navy.mil>
References: <200806171316.m5HDGFpt005872@cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:32790 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758459AbYFQN53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:57:29 -0400
In-reply-to: <200806171316.m5HDGFpt005872@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <200806171316.m5HDGFpt005872@cmf.nrl.navy.mil>,"chas williams - CONT
RACTOR" writes:
>commit 77203e01be64419bcdfa7f70ea70d39eecb2eb3b
>Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
>Date:   Sat Jun 14 17:31:20 2008 -0400
>
>    atm: [suni] add support for setting loopback and framing modes
>    
>    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

missed part of the patch for this.  correct below:

commit 77203e01be64419bcdfa7f70ea70d39eecb2eb3b
Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jun 14 17:31:20 2008 -0400

    atm: [suni] add support for setting loopback and framing modes
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index 6097f68..7872977 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -1,8 +1,14 @@
-/* drivers/atm/suni.c - PMC PM5346 SUNI (PHY) driver */
+/*
+ * drivers/atm/suni.c - S/UNI PHY driver
+ *
+ * Supports the following:
+ * 	PMC PM5346 S/UNI LITE
+ * 	PMC PM5350 S/UNI 155 ULTRA
+ * 	PMC PM5355 S/UNI 622
+ */
  
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
-
 #include <linux/module.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
@@ -146,25 +152,105 @@ static int get_diag(struct atm_dev *dev,void __user *arg)
 static int set_loopback(struct atm_dev *dev,int mode)
 {
 	unsigned char control;
+	int reg, dle, lle;
+
+	if (PRIV(dev)->type == SUNI_MRI_TYPE_PM5355) {
+		reg = SUNI_MCM;
+		dle = SUNI_MCM_DLE;
+		lle = SUNI_MCM_LLE;
+	} else {
+		reg = SUNI_MCT;
+		dle = SUNI_MCT_DLE;
+		lle = SUNI_MCT_LLE;
+	}
 
-	control = GET(MCT) & ~(SUNI_MCT_DLE | SUNI_MCT_LLE);
+	control = dev->ops->phy_get(dev, reg) & ~(dle | lle);
 	switch (mode) {
 		case ATM_LM_NONE:
 			break;
 		case ATM_LM_LOC_PHY:
-			control |= SUNI_MCT_DLE;
+			control |= dle;
 			break;
 		case ATM_LM_RMT_PHY:
-			control |= SUNI_MCT_LLE;
+			control |= lle;
 			break;
 		default:
 			return -EINVAL;
 	}
-	PUT(control,MCT);
+	 dev->ops->phy_put(dev, control, reg);
 	PRIV(dev)->loop_mode = mode;
 	return 0;
 }
 
+/*
+ * SONET vs. SDH Configuration
+ *
+ * Z0INS (register 0x06): 0 for SONET, 1 for SDH
+ * ENSS (register 0x3D): 0 for SONET, 1 for SDH
+ * LEN16 (register 0x28): 0 for SONET, 1 for SDH (n/a for S/UNI 155 QUAD)
+ * LEN16 (register 0x50): 0 for SONET, 1 for SDH (n/a for S/UNI 155 QUAD)
+ * S[1:0] (register 0x46): 00 for SONET, 10 for SDH
+ */
+
+static int set_sonet(struct atm_dev *dev)
+{
+	if (PRIV(dev)->type == SUNI_MRI_TYPE_PM5355) {
+		PUT(GET(RPOP_RC) & ~SUNI_RPOP_RC_ENSS, RPOP_RC);
+		PUT(GET(SSTB_CTRL) & ~SUNI_SSTB_CTRL_LEN16, SSTB_CTRL);
+		PUT(GET(SPTB_CTRL) & ~SUNI_SPTB_CTRL_LEN16, SPTB_CTRL);
+	}
+
+	REG_CHANGE(SUNI_TPOP_APM_S, SUNI_TPOP_APM_S_SHIFT,
+		   SUNI_TPOP_S_SONET, TPOP_APM);
+
+	return 0;
+}
+
+static int set_sdh(struct atm_dev *dev)
+{
+	if (PRIV(dev)->type == SUNI_MRI_TYPE_PM5355) {
+		PUT(GET(RPOP_RC) | SUNI_RPOP_RC_ENSS, RPOP_RC);
+		PUT(GET(SSTB_CTRL) | SUNI_SSTB_CTRL_LEN16, SSTB_CTRL);
+		PUT(GET(SPTB_CTRL) | SUNI_SPTB_CTRL_LEN16, SPTB_CTRL);
+	}
+
+	REG_CHANGE(SUNI_TPOP_APM_S, SUNI_TPOP_APM_S_SHIFT,
+		   SUNI_TPOP_S_SDH, TPOP_APM);
+
+	return 0;
+}
+
+
+static int get_framing(struct atm_dev *dev, void __user *arg)
+{
+	int framing;
+	unsigned char s;
+
+
+	s = (GET(TPOP_APM) & SUNI_TPOP_APM_S) >> SUNI_TPOP_APM_S_SHIFT;
+	if (s == SUNI_TPOP_S_SONET)
+		framing = SONET_FRAME_SONET;
+	else
+		framing = SONET_FRAME_SDH;
+
+	return put_user(framing, (int __user *) arg) ? -EFAULT : 0;
+}
+
+static int set_framing(struct atm_dev *dev, void __user *arg)
+{
+	int mode;
+
+	if (get_user(mode, (int __user *) arg))
+		return -EFAULT;
+
+	if (mode == SONET_FRAME_SONET)
+		return set_sonet(dev);
+	else if (mode == SONET_FRAME_SDH)
+		return set_sdh(dev);
+
+	return -EINVAL;
+}
+
 
 static int suni_ioctl(struct atm_dev *dev,unsigned int cmd,void __user *arg)
 {
@@ -179,14 +265,16 @@ static int suni_ioctl(struct atm_dev *dev,unsigned int cmd,void __user *arg)
 		case SONET_GETDIAG:
 			return get_diag(dev,arg);
 		case SONET_SETFRAMING:
-			if ((int)(unsigned long)arg != SONET_FRAME_SONET) return -EINVAL;
-			return 0;
+			if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
+			return set_framing(dev, arg);
 		case SONET_GETFRAMING:
-			return put_user(SONET_FRAME_SONET,(int __user *)arg) ?
-			    -EFAULT : 0;
+			return get_framing(dev, arg);
 		case SONET_GETFRSENSE:
 			return -EINVAL;
 		case ATM_SETLOOP:
+			if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
 			return set_loopback(dev,(int)(unsigned long)arg);
 		case ATM_GETLOOP:
 			return put_user(PRIV(dev)->loop_mode,(int __user *)arg) ?
@@ -220,10 +308,6 @@ static int suni_start(struct atm_dev *dev)
 	unsigned long flags;
 	int first;
 
-	if (!(dev->phy_data = kmalloc(sizeof(struct suni_priv),GFP_KERNEL)))
-		return -ENOMEM;
-
-	PRIV(dev)->dev = dev;
 	spin_lock_irqsave(&sunis_lock,flags);
 	first = !sunis;
 	PRIV(dev)->next = sunis;
@@ -284,16 +368,21 @@ int suni_init(struct atm_dev *dev)
 {
 	unsigned char mri;
 
+	if (!(dev->phy_data = kmalloc(sizeof(struct suni_priv),GFP_KERNEL)))
+		return -ENOMEM;
+	PRIV(dev)->dev = dev;
+
 	mri = GET(MRI); /* reset SUNI */
+	PRIV(dev)->type = (mri & SUNI_MRI_TYPE) >> SUNI_MRI_TYPE_SHIFT;
 	PUT(mri | SUNI_MRI_RESET,MRI);
 	PUT(mri,MRI);
 	PUT((GET(MT) & SUNI_MT_DS27_53),MT); /* disable all tests */
-	REG_CHANGE(SUNI_TPOP_APM_S,SUNI_TPOP_APM_S_SHIFT,SUNI_TPOP_S_SONET,
-	    TPOP_APM); /* use SONET */
+        set_sonet(dev);
 	REG_CHANGE(SUNI_TACP_IUCHP_CLP,0,SUNI_TACP_IUCHP_CLP,
 	    TACP_IUCHP); /* idle cells */
 	PUT(SUNI_IDLE_PATTERN,TACP_IUCPOP);
 	dev->phy = &suni_ops;
+
 	return 0;
 }
 
diff --git a/drivers/atm/suni.h b/drivers/atm/suni.h
index efa79bf..7e3e656 100644
--- a/drivers/atm/suni.h
+++ b/drivers/atm/suni.h
@@ -1,7 +1,8 @@
-/* drivers/atm/suni.h - PMC PM5346 SUNI (PHY) declarations */
+/*
+ * drivers/atm/suni.h - S/UNI PHY driver
+ */
  
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
- 
 
 #ifndef DRIVER_ATM_SUNI_H
 #define DRIVER_ATM_SUNI_H
@@ -39,7 +40,8 @@
 #define SUNI_RLOP_LFM		0x1F	/* RLOP Line FEBE MSB */
 #define SUNI_TLOP_CTRL		0x20	/* TLOP Control */
 #define SUNI_TLOP_DIAG		0x21	/* TLOP Diagnostic */
-			     /* 0x22-0x2F reserved */
+			     /* 0x22-0x27 reserved */
+#define SUNI_SSTB_CTRL		0x28
 #define SUNI_RPOP_SC		0x30	/* RPOP Status/Control */
 #define SUNI_RPOP_IS		0x31	/* RPOP Interrupt Status */
 			     /* 0x32 reserved */
@@ -52,6 +54,7 @@
 #define SUNI_RPOP_PFM		0x3B	/* RPOP Path FEBE MSB */
 			     /* 0x3C reserved */
 #define SUNI_RPOP_PBC		0x3D	/* RPOP Path BIP-8 Configuration */
+#define SUNI_RPOP_RC		0x3D	/* RPOP Ring Control (PM5355) */
 			     /* 0x3E-0x3F reserved */
 #define SUNI_TPOP_CD		0x40	/* TPOP Control/Diagnostic */
 #define SUNI_TPOP_PC		0x41	/* TPOP Pointer Control */
@@ -82,7 +85,8 @@
 #define SUNI_TACP_TCC		0x65	/* TACP Transmit Cell Counter */
 #define SUNI_TACP_TCCM		0x66	/* TACP Transmit Cell Counter MSB */
 #define SUNI_TACP_CFG		0x67	/* TACP Configuration */
-			     /* 0x68-0x7F reserved */
+#define SUNI_SPTB_CTRL		0x68	/* SPTB Control */
+			     /* 0x69-0x7F reserved */
 #define	SUNI_MT			0x80	/* Master Test */
 			     /* 0x81-0xFF reserved */
 
@@ -94,9 +98,18 @@
 #define SUNI_MRI_ID_SHIFT 	0
 #define SUNI_MRI_TYPE		0x70	/* R, SUNI type (lite is 011) */
 #define SUNI_MRI_TYPE_SHIFT 	4
+#define SUNI_MRI_TYPE_PM5346	0x3	/* S/UNI 155 LITE */
+#define SUNI_MRI_TYPE_PM5347	0x4	/* S/UNI 155 PLUS */
+#define SUNI_MRI_TYPE_PM5350	0x7	/* S/UNI 155 ULTRA */
+#define SUNI_MRI_TYPE_PM5355	0x1	/* S/UNI 622 */
 #define SUNI_MRI_RESET		0x80	/* RW, reset & power down chip
 					   0: normal operation
 					   1: reset & low power */
+
+/* MCM is reg 0x4 */
+#define SUNI_MCM_LLE		0x20	/* line loopback (PM5355) */
+#define SUNI_MCM_DLE		0x10	/* diagnostic loopback (PM5355) */
+
 /* MCT is reg 5 */
 #define SUNI_MCT_LOOPT		0x01	/* RW, timing source, 0: from
 					   TRCLK+/- */
@@ -144,6 +157,12 @@
 /* TLOP_DIAG is reg 0x21 */
 #define SUNI_TLOP_DIAG_DBIP	0x01	/* insert line BIP err (continuously) */
 
+/* SSTB_CTRL is reg 0x28 */
+#define SUNI_SSTB_CTRL_LEN16	0x01	/* path trace message length bit */
+
+/* RPOP_RC is reg 0x3D (PM5355) */
+#define SUNI_RPOP_RC_ENSS	0x40	/* enable size bit */
+
 /* TPOP_DIAG is reg 0x40 */
 #define SUNI_TPOP_DIAG_PAIS	0x01	/* insert STS path alarm ind (cont) */
 #define SUNI_TPOP_DIAG_DB3	0x02	/* insert path BIP err (continuously) */
@@ -191,6 +210,9 @@
 					   pattern */
 #define SUNI_TACP_IUCHP_GFC_SHIFT 4
 
+/* SPTB_CTRL is reg 0x68 */
+#define SUNI_SPTB_CTRL_LEN16	0x01	/* path trace message length */
+
 /* MT is reg 0x80 */
 #define SUNI_MT_HIZIO		0x01	/* RW, all but data bus & MP interface
 					   tri-state */
@@ -208,6 +230,7 @@
 struct suni_priv {
 	struct k_sonet_stats sonet_stats;	/* link diagnostics */
 	int loop_mode;				/* loopback mode */
+	int type;				/* phy type */
 	struct atm_dev *dev;			/* device back-pointer */
 	struct suni_priv *next;			/* next SUNI */
 };
diff --git a/include/linux/sonet.h b/include/linux/sonet.h
index 7536802..67ad11f 100644
--- a/include/linux/sonet.h
+++ b/include/linux/sonet.h
@@ -34,7 +34,7 @@ struct sonet_stats {
 					/* clear error insertion */
 #define SONET_GETDIAG	_IOR('a',ATMIOC_PHYTYP+4,int)
 					/* query error insertion */
-#define SONET_SETFRAMING _IO('a',ATMIOC_PHYTYP+5)
+#define SONET_SETFRAMING _IOW('a',ATMIOC_PHYTYP+5,int)
 					/* set framing mode (SONET/SDH) */
 #define SONET_GETFRAMING _IOR('a',ATMIOC_PHYTYP+6,int)
 					/* get framing mode */

From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [he] unconditionalize extra pci reads to flush posted writes
Date: Wed, 11 Feb 2004 09:29:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402111429.i1BETlRr005845@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

since its difficult to tell which pci bus is using
posted writes, remove the ifdef's for the sgi sn2
(and remove the extra flushes that would be flushed
by other reads just slightly later).  the extra reads
shouldnt impact performance.

please apply to 2.6 and 2.4

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1170  -> 1.1171 
#	    drivers/atm/he.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/04	chas@relax.cmf.nrl.navy.mil	1.1171
# [ATM]: [he] unconditionalize extra pci reads to flush posted writes
# --------------------------------------------
#
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Wed Feb 11 09:13:28 2004
+++ b/drivers/atm/he.c	Wed Feb 11 09:13:28 2004
@@ -177,9 +177,7 @@
 								unsigned flags)
 {
 	he_writel(he_dev, val, CON_DAT);
-#ifdef CONFIG_IA64_SGI_SN2
-	(void) he_readl(he_dev, CON_DAT);
-#endif
+	(void) he_readl(he_dev, CON_DAT);		/* flush posted writes */
 	he_writel(he_dev, flags | CON_CTL_WRITE | CON_CTL_ADDR(addr), CON_CTL);
 	while (he_readl(he_dev, CON_CTL) & CON_CTL_BUSY);
 }
@@ -2011,9 +2009,6 @@
 
 		he_writel(he_dev, RBRQ_MASK(he_dev->rbrq_head),
 						G0_RBRQ_H + (group * 16));
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl(he_dev, G0_RBRQ_H + (group * 16));
-#endif
 	}
 
 	return pdus_assembled;
@@ -2107,9 +2102,6 @@
 
 		he_writel(he_dev, TBRQ_MASK(he_dev->tbrq_head),
 						G0_TBRQ_H + (group * 16));
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl(he_dev, G0_TBRQ_H + (group * 16));
-#endif
 	}
 }
 
@@ -2137,12 +2129,8 @@
 		++moved;
 	} 
 
-	if (moved) {
+	if (moved)
 		he_writel(he_dev, RBPL_MASK(he_dev->rbpl_tail), G0_RBPL_T);
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl(he_dev, G0_RBPL_T);
-#endif
-	}
 }
 
 #ifdef CONFIG_ATM_HE_RBPS
@@ -2169,12 +2157,8 @@
 		++moved;
 	} 
 
-	if (moved) {
+	if (moved)
 		he_writel(he_dev, RBPS_MASK(he_dev->rbps_tail), G0_RBPS_T);
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl(he_dev, G0_RBPS_T);
-#endif
-	}
 }
 #endif /* CONFIG_ATM_HE_RBPS */
 
@@ -2271,7 +2255,7 @@
 			IRQ_SIZE(CONFIG_IRQ_SIZE) |
 			IRQ_THRESH(CONFIG_IRQ_THRESH) |
 			IRQ_TAIL(he_dev->irq_tail), IRQ0_HEAD);
-		(void) he_readl(he_dev, INT_FIFO); /* 8.1.2 controller errata */
+		(void) he_readl(he_dev, INT_FIFO); /* 8.1.2 controller errata; flush posted writes */
 	}
 #ifdef USE_TASKLET
 	spin_unlock_irqrestore(&he_dev->global_lock, flags);
@@ -2312,11 +2296,8 @@
 #else
 		he_tasklet((unsigned long) he_dev);
 #endif
-		he_writel(he_dev, INT_CLEAR_A, INT_FIFO);
-							/* clear interrupt */
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl(he_dev, INT_FIFO);
-#endif
+		he_writel(he_dev, INT_CLEAR_A, INT_FIFO);	/* clear interrupt */
+		(void) he_readl(he_dev, INT_FIFO);		/* flush posted writes */
 	}
 	spin_unlock_irqrestore(&he_dev->global_lock, flags);
 	return IRQ_RETVAL(handled);
@@ -2385,9 +2366,7 @@
 	he_dev->tpdrq_tail = new_tail;
 
 	he_writel(he_dev, TPDRQ_MASK(he_dev->tpdrq_tail), TPDRQ_T);
-#ifdef CONFIG_IA64_SGI_SN2
-	(void) he_readl(he_dev, TPDRQ_T);
-#endif
+	(void) he_readl(he_dev, TPDRQ_T);		/* flush posted writes */
 }
 
 static int
@@ -2537,9 +2516,7 @@
 		he_writel_tsr12(he_dev, 0x0, cid);
 		he_writel_tsr13(he_dev, 0x0, cid);
 		he_writel_tsr14(he_dev, 0x0, cid);
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl_tsr0(he_dev, cid);
-#endif
+		(void) he_readl_tsr0(he_dev, cid);		/* flush posted writes */
 		spin_unlock_irqrestore(&he_dev->global_lock, flags);
 	}
 
@@ -2593,9 +2570,7 @@
 			  the open/closed indication in rsr0 */
 		he_writel_rsr0(he_dev,
 			rsr0 | RSR0_START_PDU | RSR0_OPEN_CONN | aal, cid);
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl_rsr0(he_dev, cid);
-#endif
+		(void) he_readl_rsr0(he_dev, cid);		/* flush posted writes */
 
 		spin_unlock_irqrestore(&he_dev->global_lock, flags);
 	}
@@ -2649,9 +2624,7 @@
 		set_current_state(TASK_UNINTERRUPTIBLE);
 
 		he_writel_rsr0(he_dev, RSR0_CLOSE_CONN, cid);
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl_rsr0(he_dev, cid);
-#endif
+		(void) he_readl_rsr0(he_dev, cid);		/* flush posted writes */
 		he_writel_mbox(he_dev, cid, RXCON_CLOSE);
 		spin_unlock_irqrestore(&he_dev->global_lock, flags);
 
@@ -2701,9 +2674,6 @@
 		spin_lock_irqsave(&he_dev->global_lock, flags);
 		he_writel_tsr4_upper(he_dev, TSR4_FLUSH_CONN, cid);
 					/* also clears TSR4_SESSION_ENDED */
-#ifdef CONFIG_IA64_SGI_SN2
-		(void) he_readl_tsr4(he_dev, cid);
-#endif
 
 		switch (vcc->qos.txtp.traffic_class) {
 			case ATM_UBR:
@@ -2715,6 +2685,7 @@
 				he_writel_tsr14_upper(he_dev, TSR14_DELETE, cid);
 				break;
 		}
+		(void) he_readl_tsr4(he_dev, cid);		/* flush posted writes */
 
 		tpd = __alloc_tpd(he_dev);
 		if (tpd == NULL) {
@@ -2977,9 +2948,7 @@
 
 	spin_lock_irqsave(&he_dev->global_lock, flags);
 	he_writel(he_dev, val, FRAMER + (addr*4));
-#ifdef CONFIG_IA64_SGI_SN2
-	(void) he_readl(he_dev, FRAMER + (addr*4));
-#endif
+	(void) he_readl(he_dev, FRAMER + (addr*4));		/* flush posted writes */
 	spin_unlock_irqrestore(&he_dev->global_lock, flags);
 }
  

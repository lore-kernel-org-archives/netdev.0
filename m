From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: [PATCH] #1: cleanup, add reset debug message
Date: Tue, 10 Aug 2004 18:23:15 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408101823.15792.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jhOGBNeYz2x2FIT"
Cc: prism54-devel@prism54.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_jhOGBNeYz2x2FIT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Luis,

This is a mostly trivial patch on top of today's prism54 CVS.

* Move assignment out of if()
* Remove trailing space from printk
* Eliminate not needed local 'u32 reg'
* Add a comment about undoc bits
* Add #define VEC_SIZE, use it as appropriate
* Add a pair of printks to reset error code path (our current area of trouble)
* Make printk text less confusing

Please apply.
--
vda

--Boundary-00=_jhOGBNeYz2x2FIT
Content-Type: text/x-diff;
  charset="us-ascii";
  name="prism54-20040810.1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prism54-20040810.1.patch"

* Move assignment out of if()
* Remove trailing space from printk
* Eliminate not needed local 'u32 reg'
* Add a comment about undoc bits
* Add #define VEC_SIZE, use it as appropriate
* Add a pair of printks to reset error code path (our current area of trouble)
* Make printk text less confusing

diff -urpN prism54-20040810.orig/isl_38xx.c prism54-20040810.1/isl_38xx.c
--- prism54-20040810.orig/isl_38xx.c	Sat May 29 18:06:49 2004
+++ prism54-20040810.1/isl_38xx.c	Tue Aug 10 17:18:37 2004
@@ -135,8 +135,8 @@ isl38xx_trigger_device(int asleep, void 
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
 
-		if (reg = readl(device_base + ISL38XX_INT_IDENT_REG),
-		    reg == 0xabadface) {
+		reg = readl(device_base + ISL38XX_INT_IDENT_REG);
+		if (reg == 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
@@ -194,10 +194,8 @@ isl38xx_trigger_device(int asleep, void 
 void
 isl38xx_interface_reset(void *device_base, dma_addr_t host_address)
 {
-	u32 reg;
-
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset\n");
 #endif
 
 	/* load the address of the control block in the device */
@@ -205,8 +203,7 @@ isl38xx_interface_reset(void *device_bas
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* set the reset bit in the Device Interrupt Register */
-	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET,
-			  ISL38XX_DEV_INT_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET, ISL38XX_DEV_INT_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* enable the interrupt for detecting initialization */
@@ -214,9 +211,7 @@ isl38xx_interface_reset(void *device_bas
 	/* Note: Do not enable other interrupts here. We want the
 	 * device to have come up first 100% before allowing any other 
 	 * interrupts. */
-	reg = ISL38XX_INT_IDENT_INIT;
-
-	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
 
diff -urpN prism54-20040810.orig/isl_38xx.h prism54-20040810.1/isl_38xx.h
--- prism54-20040810.orig/isl_38xx.h	Sat May 29 18:06:49 2004
+++ prism54-20040810.1/isl_38xx.h	Tue Aug 10 17:18:37 2004
@@ -95,6 +95,10 @@ isl38xx_w32_flush(void *base, u32 val, u
 #define ISL38XX_INT_SOURCES                     0x001E
 
 /* Control/Status register bits */
+/* Looks like there are other meaningful bits
+    0x20004400 seen in normal operation,
+    0x200044db at 'timeout waiting for mgmt response'
+*/
 #define ISL38XX_CTRL_STAT_SLEEPMODE             0x00000200
 #define	ISL38XX_CTRL_STAT_CLKRUN		0x00800000
 #define ISL38XX_CTRL_STAT_RESET                 0x10000000
diff -urpN prism54-20040810.orig/oid_mgt.c prism54-20040810.1/oid_mgt.c
--- prism54-20040810.orig/oid_mgt.c	Fri Aug  6 13:50:47 2004
+++ prism54-20040810.1/oid_mgt.c	Tue Aug 10 17:18:37 2004
@@ -638,9 +638,13 @@ mgt_update_addr(islpci_private *priv)
 	if (res)
 		islpci_mgt_release(res);
 
+	if (ret)
+		printk(KERN_ERR "%s: mgt_update_addr: failure\n", priv->ndev->name);
 	return ret;
 }
 
+#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
+
 void
 mgt_commit(islpci_private *priv)
 {
@@ -650,14 +654,10 @@ mgt_commit(islpci_private *priv)
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return;
 
-	rvalue = mgt_commit_list(priv, commit_part1,
-				 sizeof (commit_part1) /
-				 sizeof (commit_part1[0]));
+	rvalue = mgt_commit_list(priv, commit_part1, VEC_SIZE(commit_part1));
 
 	if (priv->iw_mode != IW_MODE_MONITOR)
-		rvalue |= mgt_commit_list(priv, commit_part2,
-					  sizeof (commit_part2) /
-					  sizeof (commit_part2[0]));
+		rvalue |= mgt_commit_list(priv, commit_part2, VEC_SIZE(commit_part2));
 
 	u = OID_INL_MODE;
 	rvalue |= mgt_commit_list(priv, &u, 1);
@@ -666,8 +666,7 @@ mgt_commit(islpci_private *priv)
 	if (rvalue) {
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
-		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
-		       "device \n", priv->ndev->name);
+		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
 	}
 }
 

--Boundary-00=_jhOGBNeYz2x2FIT--

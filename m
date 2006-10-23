From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18] defxx: Big-endian hosts support
Date: Mon, 23 Oct 2006 13:53:17 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:34058 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1751942AbWJWMxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 08:53:20 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The PDQ DMA engine requires a different byte-swapping mode for big-endian 
hosts; also the MAC address which is read from a register through PIO has 
to be byte-swapped.  These changes have been verified with DEFPA-DC (PCI) 
boards and a Broadcom BCM91250A (MIPS CPU based) host.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-defxx-eb-3
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/defxx.c linux-mips-2.6.18-20060920/drivers/net/defxx.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/defxx.c	2006-09-20 20:50:22.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/defxx.c	2006-10-23 00:43:03.000000000 +0000
@@ -192,6 +192,7 @@
  *		04 Aug 2003	macro		Converted to the DMA API.
  *		14 Aug 2004	macro		Fix device names reported.
  *		14 Jun 2005	macro		Use irqreturn_t.
+ *		23 Oct 2006	macro		Big-endian host support.
  */
 
 /* Include files */
@@ -218,8 +219,8 @@
 
 /* Version information string should be updated prior to each new release!  */
 #define DRV_NAME "defxx"
-#define DRV_VERSION "v1.08"
-#define DRV_RELDATE "2005/06/14"
+#define DRV_VERSION "v1.09"
+#define DRV_RELDATE "2006/10/23"
 
 static char version[] __devinitdata =
 	DRV_NAME ": " DRV_VERSION " " DRV_RELDATE
@@ -860,6 +861,7 @@ static int __devinit dfx_driver_init(str
 		       print_name);
 		return(DFX_K_FAILURE);
 	}
+	data = cpu_to_le32(data);
 	memcpy(&bp->factory_mac_addr[0], &data, sizeof(u32));
 
 	if (dfx_hw_port_ctrl_req(bp, PI_PCTRL_M_MLA, PI_PDATA_A_MLA_K_HI, 0,
@@ -868,6 +870,7 @@ static int __devinit dfx_driver_init(str
 		       print_name);
 		return(DFX_K_FAILURE);
 	}
+	data = cpu_to_le32(data);
 	memcpy(&bp->factory_mac_addr[4], &data, sizeof(u16));
 
 	/*
@@ -1086,27 +1089,23 @@ static int dfx_adap_init(DFX_board_t *bp
 		}
 
 	/*
-	 * Set base address of Descriptor Block and bring adapter to DMA_AVAILABLE state
+	 * Set the base address of Descriptor Block and bring adapter
+	 * to DMA_AVAILABLE state.
 	 *
-	 * Note: We also set the literal and data swapping requirements in this
-	 *	     command.  Since this driver presently runs on Intel platforms
-	 *		 which are Little Endian, we'll tell the adapter to byte swap
-	 *		 data only.  This code will need to change when we support
-	 *		 Big Endian systems (eg. PowerPC).
+	 * Note: We also set the literal and data swapping requirements
+	 *       in this command.
 	 *
-	 * Assumption: 32-bit physical address of descriptor block is 8Kbyte
-	 *             aligned.  That is, bits 0-12 of the address must be zero.
+	 * Assumption: 32-bit physical address of descriptor block
+	 *       is 8Kbyte aligned.
 	 */
-
-	if (dfx_hw_port_ctrl_req(bp,
-							PI_PCTRL_M_INIT,
-							(u32) (bp->descr_block_phys | PI_PDATA_A_INIT_M_BSWAP_DATA),
-							0,
-							NULL) != DFX_K_SUCCESS)
-		{
-		printk("%s: Could not set descriptor block address!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
-		}
+	if (dfx_hw_port_ctrl_req(bp, PI_PCTRL_M_INIT,
+				 (u32)(bp->descr_block_phys |
+				       PI_PDATA_A_INIT_M_BSWAP_INIT),
+				 0, NULL) != DFX_K_SUCCESS) {
+		printk("%s: Could not set descriptor block address!\n",
+		       bp->dev->name);
+		return DFX_K_FAILURE;
+	}
 
 	/* Set transmit flush timeout value */
 
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/defxx.h linux-mips-2.6.18-20060920/drivers/net/defxx.h
--- linux-mips-2.6.18-20060920.macro/drivers/net/defxx.h	2004-11-16 05:57:00.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/defxx.h	2006-10-23 00:27:28.000000000 +0000
@@ -25,6 +25,7 @@
  *							macros to DEFXX.C.
  *		12-Sep-96	LVS		Removed packet request header pointers.
  *		04 Aug 2003	macro		Converted to the DMA API.
+ *		23 Oct 2006	macro		Big-endian host support.
  */
 
 #ifndef _DEFXX_H_
@@ -1344,7 +1345,7 @@ typedef struct
 
 /* Register definition structures are defined for both big and little endian systems */
 
-#ifndef  BIG_ENDIAN
+#ifndef __BIG_ENDIAN
 
 /* Little endian format of Type 1 Producer register */
 
@@ -1402,7 +1403,11 @@ typedef union
 		} index;
 	} PI_TYPE_2_CONSUMER;
 
-#else
+/* Define swapping required by DMA transfers.  */
+#define PI_PDATA_A_INIT_M_BSWAP_INIT	\
+	(PI_PDATA_A_INIT_M_BSWAP_DATA)
+
+#else /* __BIG_ENDIAN */
 
 /* Big endian format of Type 1 Producer register */
 
@@ -1460,7 +1465,11 @@ typedef union
 		} index;
 	} PI_TYPE_2_CONSUMER;
 
-#endif	/* #ifndef BIG_ENDIAN */
+/* Define swapping required by DMA transfers.  */
+#define PI_PDATA_A_INIT_M_BSWAP_INIT	\
+	(PI_PDATA_A_INIT_M_BSWAP_DATA | PI_PDATA_A_INIT_M_BSWAP_LITERAL)
+
+#endif /* __BIG_ENDIAN */
 
 /* Define EISA controller register offsets */
 

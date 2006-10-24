From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18] defxx: Big-endian hosts support
Date: Tue, 24 Oct 2006 12:57:56 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610241058420.1955@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
 <20061023144844.GA30864@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:19730 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1030343AbWJXL57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 07:57:59 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061023144844.GA30864@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The PDQ DMA engine requires a different byte-swapping mode for big-endian
hosts; also the MAC address which is read from a register through PIO has
to be byte-swapped.  These changes have been verified with DEFPA-DC (PCI)
boards and a Broadcom BCM91250A (MIPS CPU based) host.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

On Mon, 23 Oct 2006, Christoph Hellwig wrote:

> On Mon, Oct 23, 2006 at 01:53:17PM +0100, Maciej W. Rozycki wrote:
> > +	data = cpu_to_le32(data);
> 
> This is rather ugly and not provable by static typechecking.  Please
> always use spearate variables/structs for device and host endian values,
> and run the resulting driver through sparse to make sure everything is
> correct.

 Hmm, I'm not sure why this would matter, but as it does not change the 
generated code, then I see no problem either.

 [Note that there is no such notion as the device and host endian value 
here -- the contents of the register are just a string of bytes which has 
to have its byte addresses preserved when transferring to memory and hence 
the swapping already done by inl() has to be undone.]

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-defxx-eb-4
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/defxx.c linux-mips-2.6.18-20060920/drivers/net/defxx.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/defxx.c	2006-09-20 20:50:22.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/defxx.c	2006-10-23 22:58:19.000000000 +0000
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
@@ -808,10 +809,10 @@ static int __devinit dfx_driver_init(str
 				     const char *print_name)
 {
 	DFX_board_t *bp = dev->priv;
-	int			alloc_size;			/* total buffer size needed */
-	char		*top_v, *curr_v;	/* virtual addrs into memory block */
-	dma_addr_t		top_p, curr_p;		/* physical addrs into memory block */
-	u32			data;				/* host data register value */
+	int alloc_size;			/* total buffer size needed */
+	char *top_v, *curr_v;		/* virtual addrs into memory block */
+	dma_addr_t top_p, curr_p;	/* physical addrs into memory block */
+	u32 data, le32;			/* host data register value */
 
 	DBG_printk("In dfx_driver_init...\n");
 
@@ -860,7 +861,8 @@ static int __devinit dfx_driver_init(str
 		       print_name);
 		return(DFX_K_FAILURE);
 	}
-	memcpy(&bp->factory_mac_addr[0], &data, sizeof(u32));
+	le32 = cpu_to_le32(data);
+	memcpy(&bp->factory_mac_addr[0], &le32, sizeof(u32));
 
 	if (dfx_hw_port_ctrl_req(bp, PI_PCTRL_M_MLA, PI_PDATA_A_MLA_K_HI, 0,
 				 &data) != DFX_K_SUCCESS) {
@@ -868,7 +870,8 @@ static int __devinit dfx_driver_init(str
 		       print_name);
 		return(DFX_K_FAILURE);
 	}
-	memcpy(&bp->factory_mac_addr[4], &data, sizeof(u16));
+	le32 = cpu_to_le32(data);
+	memcpy(&bp->factory_mac_addr[4], &le32, sizeof(u16));
 
 	/*
 	 * Set current address to factory address
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
 

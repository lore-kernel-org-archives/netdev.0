From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 3/3] defxx: DEFEA's ESIC port I/O decoding cleanup
Date: Thu, 25 Sep 2014 11:06:55 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1409251038120.6148@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:51423 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaIYK3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 06:29:42 -0400
Received: from localhost.localdomain ([127.0.0.1]:35309 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27009735AbaIYKGzvu2DN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:06:55 +0200
In-Reply-To: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the slot-specific I/O range for decoding accesses to PDQ ASIC 
registers (IOCS0) and the discrete Burst Holdoff register (IOCS1) as per 
the "HD64981F EISA Slave Interface Controller (ESIC)" datasheet.  Use 
disjoint decode ranges now that the assignment of chip selects is known.  
Update the span of the port I/O resource requested accordingly.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Dave, please apply.

  Maciej

linux-defea-esic-decode.patch
Index: linux-20140924-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140924-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20140924-dolch/drivers/net/fddi/defxx.c
@@ -466,7 +466,8 @@ static void dfx_get_bars(struct device *
 			*bar_len = (bar | PI_MEM_ADD_MASK_M) + 1;
 		} else {
 			*bar_start = base_addr;
-			*bar_len = PI_ESIC_K_CSR_IO_LEN;
+			*bar_len = PI_ESIC_K_CSR_IO_LEN +
+				   PI_ESIC_K_BURST_HOLDOFF_LEN;
 		}
 	}
 	if (dfx_bus_tc) {
@@ -683,6 +684,9 @@ static void dfx_bus_init(struct net_devi
 	if (dfx_bus_eisa) {
 		unsigned long base_addr = to_eisa_device(bdev)->base_addr;
 
+		/* Disable the board before fiddling with the decoders.  */
+		outb(0, base_addr + PI_ESIC_K_SLOT_CNTRL);
+
 		/* Get the interrupt level from the ESIC chip.  */
 		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 		val &= PI_CONFIG_STAT_0_M_IRQ;
@@ -709,25 +713,33 @@ static void dfx_bus_init(struct net_devi
 		/*
 		 * Enable memory decoding (MEMCS0) and/or port decoding
 		 * (IOCS1/IOCS0) as appropriate in Function Control
-		 * Register.  One of the port chip selects seems to be
-		 * used for the Burst Holdoff register, but this bit of
-		 * documentation is missing and as yet it has not been
-		 * determined which of the two.  This is also the reason
-		 * the size of the decoded port range is twice as large
-		 * as one required by the PDQ.
+		 * Register.  IOCS0 is used for PDQ registers, taking 16
+		 * 32-bit words, while IOCS1 is used for the Burst Holdoff
+		 * register, taking a single 32-bit word only.  We use the
+		 * slot-specific I/O range as per the ESIC spec, that is
+		 * set bits 15:12 in the mask registers to mask them out.
 		 */
 
 		/* Set the decode range of the board.  */
-		val = ((bp->base.port >> 12) << PI_IO_CMP_V_SLOT);
+		val = 0;
 		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_0_1);
-		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_0_0);
-		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_1_1);
-		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_1_0);
-		val = PI_ESIC_K_CSR_IO_LEN - 1;
+		val = PI_DEFEA_K_CSR_IO;
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_0_0);
+
+		val = PI_IO_CMP_M_SLOT;
 		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_0_1);
-		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_0_0);
+		val = (PI_ESIC_K_CSR_IO_LEN - 1) & ~3;
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_0_0);
+
+		val = 0;
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_1_1);
+		val = PI_DEFEA_K_BURST_HOLDOFF;
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_1_0);
+
+		val = PI_IO_CMP_M_SLOT;
 		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_1_1);
-		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_1_0);
+		val = (PI_ESIC_K_BURST_HOLDOFF_LEN - 1) & ~3;
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_1_0);
 
 		/* Enable the decoders.  */
 		val = PI_FUNCTION_CNTRL_M_IOCS1 | PI_FUNCTION_CNTRL_M_IOCS0;
Index: linux-20140924-dolch/drivers/net/fddi/defxx.h
===================================================================
--- linux-20140924-dolch.orig/drivers/net/fddi/defxx.h
+++ linux-20140924-dolch/drivers/net/fddi/defxx.h
@@ -1479,8 +1479,10 @@ typedef union
 
 /* Define EISA controller register offsets */
 
-#define PI_ESIC_K_CSR_IO_LEN		0x80		/* 128 bytes */
+#define PI_ESIC_K_CSR_IO_LEN		0x40		/* 64 bytes */
+#define PI_ESIC_K_BURST_HOLDOFF_LEN	0x04		/* 4 bytes */
 
+#define PI_DEFEA_K_CSR_IO		0x000
 #define PI_DEFEA_K_BURST_HOLDOFF	0x040
 
 #define PI_ESIC_K_SLOT_ID            	0xC80
@@ -1558,11 +1560,9 @@ typedef union
 
 #define PI_MEM_ADD_MASK_M		0x3ff
 
-/*
- * Define the fields in the IO Compare registers.
- * The driver must initialize the slot field with the slot ID shifted by the
- * amount shown below.
- */
+/* Define the fields in the I/O Address Compare and Mask registers.  */
+
+#define PI_IO_CMP_M_SLOT		0xf0
 
 #define PI_IO_CMP_V_SLOT		4
 

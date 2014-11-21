From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2/4] defxx: Correct DEFEA's ESIC MMIO decoding
Date: Fri, 21 Nov 2014 14:09:57 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1411211131260.4773@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59728 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbaKUOJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:09:58 -0500
Received: from localhost.localdomain ([127.0.0.1]:49959 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27006519AbaKUOJ5L0oDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:09:57 +0100
In-Reply-To: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ESIC's memory area 1 (MEMCS1) and its Memory Address High Compare
and Memory Address Low Compare registers to set up the MMIO range for
decoding accesses to PDQ ASIC registers.  Previously the PDQ ASIC was
thought to be addressable with the memory area 0 (MEMCS0) and its Memory
Address Compare and Memory Address Mask registers.

The MMIO range allocated for the option card is preset via ECU (EISA
Configuration Utility) and can be disabled, so handle such a case
gracefully too.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
linux-defea-mmio.patch
Index: linux-20141025-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20141025-dolch/drivers/net/fddi/defxx.c
@@ -447,23 +447,24 @@ static void dfx_get_bars(struct device *
 	}
 	if (dfx_bus_eisa) {
 		unsigned long base_addr = to_eisa_device(bdev)->base_addr;
-		resource_size_t bar;
+		resource_size_t bar_lo;
+		resource_size_t bar_hi;
 
 		if (dfx_use_mmio) {
-			bar = inb(base_addr + PI_ESIC_K_MEM_ADD_CMP_2);
-			bar <<= 8;
-			bar |= inb(base_addr + PI_ESIC_K_MEM_ADD_CMP_1);
-			bar <<= 8;
-			bar |= inb(base_addr + PI_ESIC_K_MEM_ADD_CMP_0);
-			bar <<= 16;
-			*bar_start = bar;
-			bar = inb(base_addr + PI_ESIC_K_MEM_ADD_MASK_2);
-			bar <<= 8;
-			bar |= inb(base_addr + PI_ESIC_K_MEM_ADD_MASK_1);
-			bar <<= 8;
-			bar |= inb(base_addr + PI_ESIC_K_MEM_ADD_MASK_0);
-			bar <<= 16;
-			*bar_len = (bar | PI_MEM_ADD_MASK_M) + 1;
+			bar_lo = inb(base_addr + PI_ESIC_K_MEM_ADD_LO_CMP_2);
+			bar_lo <<= 8;
+			bar_lo |= inb(base_addr + PI_ESIC_K_MEM_ADD_LO_CMP_1);
+			bar_lo <<= 8;
+			bar_lo |= inb(base_addr + PI_ESIC_K_MEM_ADD_LO_CMP_0);
+			bar_lo <<= 8;
+			*bar_start = bar_lo;
+			bar_hi = inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_2);
+			bar_hi <<= 8;
+			bar_hi |= inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_1);
+			bar_hi <<= 8;
+			bar_hi |= inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_0);
+			bar_hi <<= 8;
+			*bar_len = ((bar_hi - bar_lo) | PI_MEM_ADD_MASK_M) + 1;
 		} else {
 			*bar_start = base_addr;
 			*bar_len = PI_ESIC_K_CSR_IO_LEN +
@@ -518,6 +519,7 @@ static int dfx_register(struct device *b
 {
 	static int version_disp;
 	int dfx_bus_pci = dev_is_pci(bdev);
+	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 	const char *print_name = dev_name(bdev);
@@ -558,6 +560,16 @@ static int dfx_register(struct device *b
 	dev_set_drvdata(bdev, dev);
 
 	dfx_get_bars(bdev, &bar_start, &bar_len);
+	if (dfx_bus_eisa && dfx_use_mmio && bar_start == 0) {
+		pr_err("%s: Cannot use MMIO, no address set, aborting\n",
+		       print_name);
+		pr_err("%s: Run ECU and set adapter's MMIO location\n",
+		       print_name);
+		pr_err("%s: Or recompile driver with \"CONFIG_DEFXX_MMIO=n\""
+		       "\n", print_name);
+		err = -ENXIO;
+		goto err_out;
+	}
 
 	if (dfx_use_mmio)
 		region = request_mem_region(bar_start, bar_len, print_name);
@@ -714,13 +726,14 @@ static void dfx_bus_init(struct net_devi
 		}
 
 		/*
-		 * Enable memory decoding (MEMCS0) and/or port decoding
+		 * Enable memory decoding (MEMCS1) and/or port decoding
 		 * (IOCS1/IOCS0) as appropriate in Function Control
-		 * Register.  IOCS0 is used for PDQ registers, taking 16
-		 * 32-bit words, while IOCS1 is used for the Burst Holdoff
-		 * register, taking a single 32-bit word only.  We use the
-		 * slot-specific I/O range as per the ESIC spec, that is
-		 * set bits 15:12 in the mask registers to mask them out.
+		 * Register.  MEMCS1 or IOCS0 is used for PDQ registers,
+		 * taking 16 32-bit words, while IOCS1 is used for the
+		 * Burst Holdoff register, taking a single 32-bit word
+		 * only.  We use the slot-specific I/O range as per the
+		 * ESIC spec, that is set bits 15:12 in the mask registers
+		 * to mask them out.
 		 */
 
 		/* Set the decode range of the board.  */
@@ -745,9 +758,11 @@ static void dfx_bus_init(struct net_devi
 		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_1_0);
 
 		/* Enable the decoders.  */
-		val = PI_FUNCTION_CNTRL_M_IOCS1 | PI_FUNCTION_CNTRL_M_IOCS0;
+		val = PI_FUNCTION_CNTRL_M_IOCS1;
 		if (dfx_use_mmio)
-			val |= PI_FUNCTION_CNTRL_M_MEMCS0;
+			val |= PI_FUNCTION_CNTRL_M_MEMCS1;
+		else
+			val |= PI_FUNCTION_CNTRL_M_IOCS0;
 		outb(val, base_addr + PI_ESIC_K_FUNCTION_CNTRL);
 
 		/*
Index: linux-20141025-dolch/drivers/net/fddi/defxx.h
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.h
+++ linux-20141025-dolch/drivers/net/fddi/defxx.h
@@ -1556,7 +1556,7 @@ typedef union
 #define PI_BURST_HOLDOFF_V_RESERVED	1
 #define PI_BURST_HOLDOFF_V_MEM_MAP	0
 
-/* Define the implicit mask of the Memory Address Mask Register.  */
+/* Define the implicit mask of the Memory Address Compare registers.  */
 
 #define PI_MEM_ADD_MASK_M		0x3ff
 

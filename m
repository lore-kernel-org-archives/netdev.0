From: Olof Johansson <olof@lixom.net>
Subject: [patch 2/6] [POWERPC] pasemi: Add flag management functions to dma_lib
Date: Wed, 20 Feb 2008 20:57:55 -0600
Message-ID: <20080221025929.381241000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44446 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbYBUDPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:09 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-add-flag-alloc
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions to manage the channel syncronization flags to dma_lib
    
Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/arch/powerpc/platforms/pasemi/dma_lib.c
===================================================================
--- k.org.orig/arch/powerpc/platforms/pasemi/dma_lib.c
+++ k.org/arch/powerpc/platforms/pasemi/dma_lib.c
@@ -26,6 +26,7 @@
 
 #define MAX_TXCH 64
 #define MAX_RXCH 64
+#define MAX_FLAGS 64
 
 static struct pasdma_status *dma_status;
 
@@ -43,6 +44,7 @@ static struct pci_dev *dma_pdev;
 
 static DECLARE_BITMAP(txch_free, MAX_TXCH);
 static DECLARE_BITMAP(rxch_free, MAX_RXCH);
+static DECLARE_BITMAP(flags_free, MAX_FLAGS);
 
 /* pasemi_read_iob_reg - read IOB register
  * @reg: Register to read (offset into PCI CFG space)
@@ -373,6 +375,71 @@ void pasemi_dma_free_buf(struct pasemi_d
 }
 EXPORT_SYMBOL(pasemi_dma_free_buf);
 
+/* pasemi_dma_alloc_flag - Allocate a flag (event) for channel syncronization
+ *
+ * Allocates a flag for use with channel syncronization (event descriptors).
+ * Returns allocated flag (0-63), < 0 on error.
+ */
+int pasemi_dma_alloc_flag(void)
+{
+	int bit;
+
+retry:
+	bit = find_next_bit(flags_free, MAX_FLAGS, 0);
+	if (bit >= MAX_FLAGS)
+		return -ENOSPC;
+	if (!test_and_clear_bit(bit, flags_free))
+		goto retry;
+
+	return bit;
+}
+EXPORT_SYMBOL(pasemi_dma_alloc_flag);
+
+
+/* pasemi_dma_free_flag - Deallocates a flag (event)
+ * @flag: Flag number to deallocate
+ *
+ * Frees up a flag so it can be reused for other purposes.
+ */
+void pasemi_dma_free_flag(int flag)
+{
+	BUG_ON(test_bit(flag, flags_free));
+	BUG_ON(flag >= MAX_FLAGS);
+	set_bit(flag, flags_free);
+}
+EXPORT_SYMBOL(pasemi_dma_free_flag);
+
+
+/* pasemi_dma_set_flag - Sets a flag (event) to 1
+ * @flag: Flag number to set active
+ *
+ * Sets the flag provided to 1.
+ */
+void pasemi_dma_set_flag(int flag)
+{
+	BUG_ON(flag >= MAX_FLAGS);
+	if (flag < 32)
+		pasemi_write_dma_reg(PAS_DMA_TXF_SFLG0, 1 << flag);
+	else
+		pasemi_write_dma_reg(PAS_DMA_TXF_SFLG1, 1 << flag);
+}
+EXPORT_SYMBOL(pasemi_dma_set_flag);
+
+/* pasemi_dma_clear_flag - Sets a flag (event) to 0
+ * @flag: Flag number to set inactive
+ *
+ * Sets the flag provided to 0.
+ */
+void pasemi_dma_clear_flag(int flag)
+{
+	BUG_ON(flag >= MAX_FLAGS);
+	if (flag < 32)
+		pasemi_write_dma_reg(PAS_DMA_TXF_CFLG0, 1 << flag);
+	else
+		pasemi_write_dma_reg(PAS_DMA_TXF_CFLG1, 1 << flag);
+}
+EXPORT_SYMBOL(pasemi_dma_clear_flag);
+
 static void *map_onedev(struct pci_dev *p, int index)
 {
 	struct device_node *dn;
@@ -502,6 +569,13 @@ int pasemi_dma_init(void)
 	/* enable rx section */
 	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
 
+	for (i = 0; i < MAX_FLAGS; i++)
+		__set_bit(i, flags_free);
+
+	/* clear all status flags */
+	pasemi_write_dma_reg(PAS_DMA_TXF_CFLG0, 0xffffffff);
+	pasemi_write_dma_reg(PAS_DMA_TXF_CFLG1, 0xffffffff);
+
 	printk(KERN_INFO "PA Semi PWRficient DMA library initialized "
 		"(%d tx, %d rx channels)\n", num_txch, num_rxch);
 
Index: k.org/include/asm-powerpc/pasemi_dma.h
===================================================================
--- k.org.orig/include/asm-powerpc/pasemi_dma.h
+++ k.org/include/asm-powerpc/pasemi_dma.h
@@ -466,6 +466,12 @@ extern void *pasemi_dma_alloc_buf(struct
 extern void pasemi_dma_free_buf(struct pasemi_dmachan *chan, int size,
 				dma_addr_t *handle);
 
+/* Routines to allocate flags (events) for channel syncronization */
+extern int  pasemi_dma_alloc_flag(void);
+extern void pasemi_dma_free_flag(int flag);
+extern void pasemi_dma_set_flag(int flag);
+extern void pasemi_dma_clear_flag(int flag);
+
 /* Initialize the library, must be called before any other functions */
 extern int pasemi_dma_init(void);
 

-- 


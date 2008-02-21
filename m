From: Olof Johansson <olof@lixom.net>
Subject: [patch 3/6] [POWERPC] pasemi: Add function engine management functions to dma_lib
Date: Wed, 20 Feb 2008 20:57:56 -0600
Message-ID: <20080221025929.670289000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44452 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbYBUDPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:09 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-add-fun-alloc
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used to allocate functions for crypto/checksum offload.
    
Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/arch/powerpc/platforms/pasemi/dma_lib.c
===================================================================
--- k.org.orig/arch/powerpc/platforms/pasemi/dma_lib.c
+++ k.org/arch/powerpc/platforms/pasemi/dma_lib.c
@@ -27,6 +27,7 @@
 #define MAX_TXCH 64
 #define MAX_RXCH 64
 #define MAX_FLAGS 64
+#define MAX_FUN 8
 
 static struct pasdma_status *dma_status;
 
@@ -45,6 +46,7 @@ static struct pci_dev *dma_pdev;
 static DECLARE_BITMAP(txch_free, MAX_TXCH);
 static DECLARE_BITMAP(rxch_free, MAX_RXCH);
 static DECLARE_BITMAP(flags_free, MAX_FLAGS);
+static DECLARE_BITMAP(fun_free, MAX_FUN);
 
 /* pasemi_read_iob_reg - read IOB register
  * @reg: Register to read (offset into PCI CFG space)
@@ -440,6 +442,41 @@ void pasemi_dma_clear_flag(int flag)
 }
 EXPORT_SYMBOL(pasemi_dma_clear_flag);
 
+/* pasemi_dma_alloc_fun - Allocate a function engine
+ *
+ * Allocates a function engine to use for crypto/checksum offload
+ * Returns allocated engine (0-8), < 0 on error.
+ */
+int pasemi_dma_alloc_fun(void)
+{
+	int bit;
+
+retry:
+	bit = find_next_bit(fun_free, MAX_FLAGS, 0);
+	if (bit >= MAX_FLAGS)
+		return -ENOSPC;
+	if (!test_and_clear_bit(bit, fun_free))
+		goto retry;
+
+	return bit;
+}
+EXPORT_SYMBOL(pasemi_dma_alloc_fun);
+
+
+/* pasemi_dma_free_fun - Deallocates a function engine
+ * @flag: Engine number to deallocate
+ *
+ * Frees up a function engine so it can be used for other purposes.
+ */
+void pasemi_dma_free_fun(int fun)
+{
+	BUG_ON(test_bit(fun, fun_free));
+	BUG_ON(fun >= MAX_FLAGS);
+	set_bit(fun, fun_free);
+}
+EXPORT_SYMBOL(pasemi_dma_free_fun);
+
+
 static void *map_onedev(struct pci_dev *p, int index)
 {
 	struct device_node *dn;
@@ -572,6 +609,9 @@ int pasemi_dma_init(void)
 	for (i = 0; i < MAX_FLAGS; i++)
 		__set_bit(i, flags_free);
 
+	for (i = 0; i < MAX_FUN; i++)
+		__set_bit(i, fun_free);
+
 	/* clear all status flags */
 	pasemi_write_dma_reg(PAS_DMA_TXF_CFLG0, 0xffffffff);
 	pasemi_write_dma_reg(PAS_DMA_TXF_CFLG1, 0xffffffff);
Index: k.org/include/asm-powerpc/pasemi_dma.h
===================================================================
--- k.org.orig/include/asm-powerpc/pasemi_dma.h
+++ k.org/include/asm-powerpc/pasemi_dma.h
@@ -472,6 +472,10 @@ extern void pasemi_dma_free_flag(int fla
 extern void pasemi_dma_set_flag(int flag);
 extern void pasemi_dma_clear_flag(int flag);
 
+/* Routines to allocate function engines */
+extern int  pasemi_dma_alloc_fun(void);
+extern void pasemi_dma_free_fun(int fun);
+
 /* Initialize the library, must be called before any other functions */
 extern int pasemi_dma_init(void);
 

-- 


From: Olof Johansson <olof@lixom.net>
Subject: [patch 1/6] pasemi_mac: Move RX/TX section enablement to dma_lib
Date: Wed, 20 Feb 2008 20:57:54 -0600
Message-ID: <20080221025929.082348000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44445 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbYBUDPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:09 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-move-rx-tx-enable
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also stop both rx and tx sections before changing the configuration of
the dma device during init.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/arch/powerpc/platforms/pasemi/dma_lib.c
===================================================================
--- k.org.orig/arch/powerpc/platforms/pasemi/dma_lib.c
+++ k.org/arch/powerpc/platforms/pasemi/dma_lib.c
@@ -478,6 +478,30 @@ int pasemi_dma_init(void)
 	for (i = 0; i < MAX_RXCH; i++)
 		__set_bit(i, rxch_free);
 
+	i = 1000;
+	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
+	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1))
+		i--;
+	if (i < 0)
+		printk(KERN_INFO "Warning: Could not disable RX section\n");
+
+	i = 1000;
+	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
+	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1))
+		i--;
+	if (i < 0)
+		printk(KERN_INFO "Warning: Could not disable TX section\n");
+
+	/* setup resource allocations for the different DMA sections */
+	tmp = pasemi_read_dma_reg(PAS_DMA_COM_CFG);
+	pasemi_write_dma_reg(PAS_DMA_COM_CFG, tmp | 0x18000000);
+
+	/* enable tx section */
+	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, PAS_DMA_COM_TXCMD_EN);
+
+	/* enable rx section */
+	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
+
 	printk(KERN_INFO "PA Semi PWRficient DMA library initialized "
 		"(%d tx, %d rx channels)\n", num_txch, num_rxch);
 
Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -1043,12 +1043,6 @@ static int pasemi_mac_open(struct net_de
 	unsigned int flags;
 	int ret;
 
-	/* enable rx section */
-	write_dma_reg(PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
-
-	/* enable tx section */
-	write_dma_reg(PAS_DMA_COM_TXCMD, PAS_DMA_COM_TXCMD_EN);
-
 	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
 		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
 		PAS_MAC_CFG_TXP_TIFT(8) | PAS_MAC_CFG_TXP_TIFG(12);
Index: k.org/include/asm-powerpc/pasemi_dma.h
===================================================================
--- k.org.orig/include/asm-powerpc/pasemi_dma.h
+++ k.org/include/asm-powerpc/pasemi_dma.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006 PA Semi, Inc
+ * Copyright (C) 2006-2008 PA Semi, Inc
  *
  * Hardware register layout and descriptor formats for the on-board
  * DMA engine on PA Semi PWRficient. Used by ethernet, function and security
@@ -40,6 +40,11 @@ enum {
 	PAS_DMA_COM_TXSTA = 0x104,	/* Transmit Status Register   */
 	PAS_DMA_COM_RXCMD = 0x108,	/* Receive Command Register   */
 	PAS_DMA_COM_RXSTA = 0x10c,	/* Receive Status Register    */
+	PAS_DMA_COM_CFG   = 0x114,	/* Common config reg	      */
+	PAS_DMA_TXF_SFLG0 = 0x140,	/* Set flags                  */
+	PAS_DMA_TXF_SFLG1 = 0x144,	/* Set flags                  */
+	PAS_DMA_TXF_CFLG0 = 0x148,	/* Set flags                  */
+	PAS_DMA_TXF_CFLG1 = 0x14c,	/* Set flags                  */
 };
 
 

-- 


From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Sun, 29 Jun 2014 03:10:47 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:34260 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbaF2CKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 22:10:49 -0400
Received: from localhost.localdomain ([127.0.0.1]:50951 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6815784AbaF2CKrRa2mT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 04:10:47 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes compiler warnings:

drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
drivers/net/ethernet/amd/declance.c:478: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
drivers/net/ethernet/amd/declance.c:487: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
drivers/net/ethernet/amd/declance.c:503: warning: cast from pointer to integer of different size
drivers/net/ethernet/amd/declance.c:520: warning: cast from pointer to integer of different size

in 64-bit compilation.  Where the value printed is an offset (whose range 
will always fit) the cast uses a 32-bit type, otherwise, where it is a 
host memory address, the `long' type is used and the width of the number 
printed adjusted according to the size of this type.

Tested with both 32-bit and 64-bit compilation, as well as at the run time 
(with the debug messages affected enabled).

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Update from v1 fixes issues with the field width requested observed by 
Joe (thanks!) and myself.  Please apply.

  Maciej

linux-declance-desc-printk.patch
Index: linux-20140623-4maxp64/drivers/net/ethernet/amd/declance.c
===================================================================
--- linux-20140623-4maxp64.orig/drivers/net/ethernet/amd/declance.c
+++ linux-20140623-4maxp64/drivers/net/ethernet/amd/declance.c
@@ -475,7 +475,7 @@ static void lance_init_ring(struct net_d
 	*lib_ptr(ib, rx_ptr, lp->type) = leptr;
 	if (ZERO)
 		printk("RX ptr: %8.8x(%8.8x)\n",
-		       leptr, lib_off(brx_ring, lp->type));
+		       leptr, (uint)lib_off(brx_ring, lp->type));
 
 	/* Setup tx descriptor pointer */
 	leptr = offsetof(struct lance_init_block, btx_ring);
@@ -484,7 +484,7 @@ static void lance_init_ring(struct net_d
 	*lib_ptr(ib, tx_ptr, lp->type) = leptr;
 	if (ZERO)
 		printk("TX ptr: %8.8x(%8.8x)\n",
-		       leptr, lib_off(btx_ring, lp->type));
+		       leptr, (uint)lib_off(btx_ring, lp->type));
 
 	if (ZERO)
 		printk("TX rings:\n");
@@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
 						/* The ones required by tmd2 */
 		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
 		if (i < 3 && ZERO)
-			printk("%d: 0x%8.8x(0x%8.8x)\n",
-			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
+			printk("%d: 0x%8.8x(%#0*lx)\n",
+			       i, leptr, 2 * (int)sizeof(long) + 2,
+			       (long)lp->tx_buf_ptr_cpu[i]);
 	}
 
 	/* Setup the Rx ring entries */
@@ -516,8 +517,9 @@ static void lance_init_ring(struct net_d
 							     0xf000;
 		*lib_ptr(ib, brx_ring[i].mblength, lp->type) = 0;
 		if (i < 3 && ZERO)
-			printk("%d: 0x%8.8x(0x%8.8x)\n",
-			       i, leptr, (uint)lp->rx_buf_ptr_cpu[i]);
+			printk("%d: 0x%8.8x(%#0*lx)\n",
+			       i, leptr, 2 * (int)sizeof(long) + 2,
+			       (long)lp->rx_buf_ptr_cpu[i]);
 	}
 	iob();
 }

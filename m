From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] defxx: Fix issues with debug printk calls
Date: Sat, 5 Jul 2014 15:28:22 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59894 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbaGEO2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:28:24 -0400
Received: from localhost.localdomain ([127.0.0.1]:48352 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859932AbaGEO2WkxUiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:28:22 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes issues with debug printk calls across the driver, normally 
disabled; first compilation errors:

drivers/net/fddi/defxx.c:676:1: error: pasting "(" and ""In dfx_bus_init...\n"" does not give a valid preprocessing token
drivers/net/fddi/defxx.c:820:1: error: pasting "(" and ""In dfx_bus_uninit...\n"" does not give a valid preprocessing token

and so on, and then warnings:

drivers/net/fddi/defxx.c: In function 'dfx_driver_init':
drivers/net/fddi/defxx.c:1132: warning: format '%0X' expects type 'unsigned int', but argument 4 has type 'dma_addr_t'
drivers/net/fddi/defxx.c:1132: warning: format '%0X' expects type 'unsigned int', but argument 4 has type 'dma_addr_t'

etc.  Additionally casts are removed from virtual addresses and %p used.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-dbg-printk.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -1127,17 +1127,16 @@ static int dfx_driver_init(struct net_de
 
 	/* Display virtual and physical addresses if debug driver */
 
-	DBG_printk("%s: Descriptor block virt = %0lX, phys = %0X\n",
-		   print_name,
-		   (long)bp->descr_block_virt, bp->descr_block_phys);
-	DBG_printk("%s: Command Request buffer virt = %0lX, phys = %0X\n",
-		   print_name, (long)bp->cmd_req_virt, bp->cmd_req_phys);
-	DBG_printk("%s: Command Response buffer virt = %0lX, phys = %0X\n",
-		   print_name, (long)bp->cmd_rsp_virt, bp->cmd_rsp_phys);
-	DBG_printk("%s: Receive buffer block virt = %0lX, phys = %0X\n",
-		   print_name, (long)bp->rcv_block_virt, bp->rcv_block_phys);
-	DBG_printk("%s: Consumer block virt = %0lX, phys = %0X\n",
-		   print_name, (long)bp->cons_block_virt, bp->cons_block_phys);
+	DBG_printk("%s: Descriptor block virt = %p, phys = %pad\n",
+		   print_name, bp->descr_block_virt, &bp->descr_block_phys);
+	DBG_printk("%s: Command Request buffer virt = %p, phys = %pad\n",
+		   print_name, bp->cmd_req_virt, &bp->cmd_req_phys);
+	DBG_printk("%s: Command Response buffer virt = %p, phys = %pad\n",
+		   print_name, bp->cmd_rsp_virt, &bp->cmd_rsp_phys);
+	DBG_printk("%s: Receive buffer block virt = %p, phys = %pad\n",
+		   print_name, bp->rcv_block_virt, &bp->rcv_block_phys);
+	DBG_printk("%s: Consumer block virt = %p, phys = %pad\n",
+		   print_name, bp->cons_block_virt, &bp->cons_block_phys);
 
 	return DFX_K_SUCCESS;
 }
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.h
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.h
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.h
@@ -1693,7 +1693,7 @@ typedef union
 /* Only execute special print call when debug driver was built */
 
 #ifdef DEFXX_DEBUG
-#define DBG_printk(args...) printk(## args)
+#define DBG_printk(args...) printk(args)
 #else
 #define DBG_printk(args...)
 #endif

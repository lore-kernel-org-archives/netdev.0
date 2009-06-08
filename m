From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] declance: Restore tx descriptor ring locking
Date: Mon, 8 Jun 2009 02:47:05 +0100 (WEST)
Message-ID: <alpine.LFD.1.10.0906080219360.6360@ftp.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([213.58.128.207]:39747 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbZFHBrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 21:47:07 -0400
Received: from localhost.localdomain ([127.0.0.1]:54551 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-OK) by ftp.linux-mips.org
	with ESMTP id S20023541AbZFHBrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 02:47:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 A driver overhaul on 29 Feb 2000 (!) broke locking around fiddling with 
the tx descriptor ring in start_xmit(); a follow-on "fix" removed the 
broken remnants altogether.  Here's a patch to restore proper locking in 
the function -- the complement in the interrupt handler has been correct 
all the time.

 This *may* have been the reason for the occasional confusion of the chip 
-- triggering a tx timeout followed by a chip reset sequence -- seen on 
R4k-based DECstations with the onboard Ethernet interface.  Another theory 
is the confusion is due to an unindentified problem -- perhaps a silicon 
erratum -- associated with the variation of the MT ASIC used to interface 
the R4k CPU to the rest of the system on these computers; with its 
aggressive write-back buffering the design is particularly weakly ordered 
when it comes to MMIO (in the absence of ordering barriers uncached reads 
are allowed to bypass earlier uncached writes, even if to the same 
location), which may trigger all kinds of corner cases in peripheral 
hardware as well as software.

 Either way this piece of code is buggy.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Works for me.  Dave, please apply.

  Maciej

patch-mips-2.6.27-rc8-20081004-declance-lock-2
Index: linux-mips-2.6.27-rc8-20081004-3maxp/drivers/net/declance.c
===================================================================
--- linux-mips-2.6.27-rc8-20081004-3maxp.orig/drivers/net/declance.c
+++ linux-mips-2.6.27-rc8-20081004-3maxp/drivers/net/declance.c
@@ -906,6 +906,7 @@ static int lance_start_xmit(struct sk_bu
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
+	unsigned long flags;
 	int entry, len;
 
 	len = skb->len;
@@ -918,6 +919,8 @@ static int lance_start_xmit(struct sk_bu
 
 	dev->stats.tx_bytes += len;
 
+	spin_lock_irqsave(&lp->lock, flags);
+
 	entry = lp->tx_new;
 	*lib_ptr(ib, btx_ring[entry].length, lp->type) = (-len);
 	*lib_ptr(ib, btx_ring[entry].misc, lp->type) = 0;
@@ -936,6 +939,8 @@ static int lance_start_xmit(struct sk_bu
 	/* Kick the lance: transmit now */
 	writereg(&ll->rdp, LE_C0_INEA | LE_C0_TDMD);
 
+	spin_unlock_irqrestore(&lp->lock, flags);
+
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 

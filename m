From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/42] atm: idt77252: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:32:40 -0700 (PDT)
Message-ID: <20110417.173240.104058805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752439Ab1DRAdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:15 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0A7F624C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two cases here:

1) idt77252_rx_raw() really does not make any use of the
   extracted PTI field of the atm header.

2) idt77252_collect_stat() only uses the register values
   in code which has been compiled out by a "NOTDEF" cpp
   test for more than 10 years.  Just kill this NOTDEF
   code entirely, but keep the register reads in case
   they have side effects.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/idt77252.c |   52 +++--------------------------------------------
 1 files changed, 4 insertions(+), 48 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 048f99f..1f8d724 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1261,14 +1261,13 @@ idt77252_rx_raw(struct idt77252_dev *card)
 				    PCI_DMA_FROMDEVICE);
 
 	while (head != tail) {
-		unsigned int vpi, vci, pti;
+		unsigned int vpi, vci;
 		u32 header;
 
 		header = le32_to_cpu(*(u32 *) &queue->data[0]);
 
 		vpi = (header & ATM_HDR_VPI_MASK) >> ATM_HDR_VPI_SHIFT;
 		vci = (header & ATM_HDR_VCI_MASK) >> ATM_HDR_VCI_SHIFT;
-		pti = (header & ATM_HDR_PTI_MASK) >> ATM_HDR_PTI_SHIFT;
 
 #ifdef CONFIG_ATM_IDT77252_DEBUG
 		if (debug & DBG_RAW_CELL) {
@@ -2709,53 +2708,10 @@ idt77252_proc_read(struct atm_dev *dev, loff_t * pos, char *page)
 static void
 idt77252_collect_stat(struct idt77252_dev *card)
 {
-	u32 cdc, vpec, icc;
+	(void) readl(SAR_REG_CDC);
+	(void) readl(SAR_REG_VPEC);
+	(void) readl(SAR_REG_ICC);
 
-	cdc = readl(SAR_REG_CDC);
-	vpec = readl(SAR_REG_VPEC);
-	icc = readl(SAR_REG_ICC);
-
-#ifdef	NOTDEF
-	printk("%s:", card->name);
-
-	if (cdc & 0x7f0000) {
-		char *s = "";
-
-		printk(" [");
-		if (cdc & (1 << 22)) {
-			printk("%sRM ID", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 21)) {
-			printk("%sCON TAB", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 20)) {
-			printk("%sNO FB", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 19)) {
-			printk("%sOAM CRC", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 18)) {
-			printk("%sRM CRC", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 17)) {
-			printk("%sRM FIFO", s);
-			s = " | ";
-		}
-		if (cdc & (1 << 16)) {
-			printk("%sRX FIFO", s);
-			s = " | ";
-		}
-		printk("]");
-	}
-
-	printk(" CDC %04x, VPEC %04x, ICC: %04x\n",
-	       cdc & 0xffff, vpec & 0xffff, icc & 0xffff);
-#endif
 }
 
 static irqreturn_t
-- 
1.7.4.3


From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 4/5] spidernet: fix error interrupt handling
Date: Fri, 11 Apr 2008 12:32:30 +0900 (JST)
Message-ID: <20080411.123230.-345474303.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:49851 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636AbYDKDiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 23:38:51 -0400
Received: from imx2.toshiba.co.jp (imx2 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id m3B3coqq021081
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 12:38:50 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to the value of GHIINT0STS, spidernet interrupt handler
should check the values of GHIINT1STS/GHIINT2STS registers at the
beginning of spider_net_interrupt() so as not to drop error
interrupts.

GHIINT1STS/GHIINT2STS registers indicates some of erroneous conditions
in spidernet, and a few bits of GHIINT0STS register reflects these
conditions. But GHIINT0MSK masks these bits, so you should check these
conditions by reading GHIINT1STS/GHIINT2STS registers directly.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Acked-by: Jens Osterkamp <jens@de.ibm.com>
---

Index: linux-powerpc-git/drivers/net/spider_net.c
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.c
+++ linux-powerpc-git/drivers/net/spider_net.c
@@ -1415,18 +1415,12 @@ spider_net_link_reset(struct net_device 
  * found when an interrupt is presented
  */
 static void
-spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
+spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
+			    u32 error_reg1, u32 error_reg2)
 {
-	u32 error_reg1, error_reg2;
 	u32 i;
 	int show_error = 1;
 
-	error_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
-	error_reg2 = spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
-
-	error_reg1 &= SPIDER_NET_INT1_MASK_VALUE;
-	error_reg2 &= SPIDER_NET_INT2_MASK_VALUE;
-
 	/* check GHIINT0STS ************************************/
 	if (status_reg)
 		for (i = 0; i < 32; i++)
@@ -1656,12 +1650,15 @@ spider_net_interrupt(int irq, void *ptr)
 {
 	struct net_device *netdev = ptr;
 	struct spider_net_card *card = netdev_priv(netdev);
-	u32 status_reg;
+	u32 status_reg, error_reg1, error_reg2;
 
 	status_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
-	status_reg &= SPIDER_NET_INT0_MASK_VALUE;
+	error_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
+	error_reg2 = spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
 
-	if (!status_reg)
+	if (!(status_reg & SPIDER_NET_INT0_MASK_VALUE) &&
+	    !(error_reg1 & SPIDER_NET_INT1_MASK_VALUE) &&
+	    !(error_reg2 & SPIDER_NET_INT2_MASK_VALUE))
 		return IRQ_NONE;
 
 	if (status_reg & SPIDER_NET_RXINT ) {
@@ -1676,7 +1673,8 @@ spider_net_interrupt(int irq, void *ptr)
 		spider_net_link_reset(netdev);
 
 	if (status_reg & SPIDER_NET_ERRINT )
-		spider_net_handle_error_irq(card, status_reg);
+		spider_net_handle_error_irq(card, status_reg,
+					    error_reg1, error_reg2);
 
 	/* clear interrupt sources */
 	spider_net_write_reg(card, SPIDER_NET_GHIINT0STS, status_reg);

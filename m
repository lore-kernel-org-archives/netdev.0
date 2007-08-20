From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] spidernet: fix interrupt reason recognition
Date: Mon, 20 Aug 2007 22:13:27 +0900 (JST)
Message-ID: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:62798 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbXHTNVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:21:46 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id l7KDLdOe008267
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 22:21:40 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch solves a problem that the spidernet driver sometimes fails
to handle IRQ.

The problem happens because,
- In Cell architecture, interrupts may arrive at an interrupt
  controller, even if they are masked by the setting on registers of
  devices. It happens when interrupt packets are sent just before 
  the interrupts are masked.
- spidernet interrupt handler compares interrupt reasons with
  interrupt masks, so when such interrupts occurs, spidernet interrupt
  handler returns IRQ_NONE.
- When all of interrupt handler return IRQ_NONE, linux kernel disables
  the IRQ and it no longer delivers interrupts to the interrupt handlers.

spidernet doesn't work after above sequence, because it can't receive
interrupts.
 
This patch changes spidernet interrupt handler that it compares
interrupt reason with SPIDER_NET_INTX_MASK_VALUE.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Linas-san,

Please apply this to 2.6.23. Because this problem is sometimes happens
and we cannot use the ethernet port any more.

And also, please apply the following Arnd-san's patch to fix a problem
that spidernet driver sometimes causes a BUG_ON at open.

 http://patchwork.ozlabs.org/cbe-oss-dev/patch?id=12211


Index: linux-powerpc-git/drivers/net/spider_net.c
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.c	2007-07-19 18:42:02.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-08-20 20:52:23.000000000 +0900
@@ -1441,17 +1441,14 @@ static void
 spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 {
 	u32 error_reg1, error_reg2;
-	u32 mask_reg1, mask_reg2;
 	u32 i;
 	int show_error = 1;
 
 	error_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
 	error_reg2 = spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
-	mask_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1MSK);
-	mask_reg2 = spider_net_read_reg(card,SPIDER_NET_GHIINT2MSK);
 
-	error_reg1 &= mask_reg1;
-	error_reg2 &= mask_reg2;
+	error_reg1 &= SPIDER_NET_INT1_MASK_VALUE;
+	error_reg2 &= SPIDER_NET_INT2_MASK_VALUE;
 
 	/* check GHIINT0STS ************************************/
 	if (status_reg)
@@ -1679,11 +1676,10 @@ spider_net_interrupt(int irq, void *ptr)
 {
 	struct net_device *netdev = ptr;
 	struct spider_net_card *card = netdev_priv(netdev);
-	u32 status_reg, mask_reg;
+	u32 status_reg;
 
 	status_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
-	mask_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
-	status_reg &= mask_reg;
+	status_reg &= SPIDER_NET_INT0_MASK_VALUE;
 
 	if (!status_reg)
 		return IRQ_NONE;

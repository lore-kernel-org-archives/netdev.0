From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] spidernet: improve interrupt handling
Date: Mon, 09 Jul 2007 17:48:08 +0900 (JST)
Message-ID: <20070709.174808.-1350520249.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:59532 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbXGIJSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 05:18:31 -0400
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id l699ITa2021789
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 18:18:29 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We intend this patch to improve spidernet interrupt handling to be
more strict.  We had following problem and this patch solves it.

 -when CONFIG_DEBUG_SHIRQ=y, request_irq() calls handler().
 -when spider_net_open() is called, it calls request_irq() which calls
  spider_net_interrupt().
 -if some specific interrupt bit is set at this timing, it calls
  netif_rx_schedule() and spider_net_poll() is scheduled.
 -spider_net_open() calls netif_poll_enable() which clears the bit 
  __LINK_STATE_RX_SCHED.
 -when spider_net_poll() is called, it calls netif_rx_complete() which
  causes BUG_ON() because __LINK_STATE_RX_SCHED is not set.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.c
diff -u linux-powerpc-git/drivers/net/spider_net.c:1.1.1.13 linux-powerpc-git/drivers/net/spider_net.c:1.18
--- linux-powerpc-git/drivers/net/spider_net.c:1.1.1.13	Tue Jul  3 15:43:29 2007
+++ linux-powerpc-git/drivers/net/spider_net.c	Fri Jul  6 14:31:38 2007
@@ -1376,11 +1376,17 @@
 spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 {
 	u32 error_reg1, error_reg2;
+	u32 mask_reg1, mask_reg2;
 	u32 i;
 	int show_error = 1;
 
 	error_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
 	error_reg2 = spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
+	mask_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1MSK);
+	mask_reg2 = spider_net_read_reg(card,SPIDER_NET_GHIINT2MSK);
+
+	error_reg1 &= mask_reg1;
+	error_reg2 &= mask_reg2;
 
 	/* check GHIINT0STS ************************************/
 	if (status_reg)
@@ -1609,9 +1615,11 @@
 {
 	struct net_device *netdev = ptr;
 	struct spider_net_card *card = netdev_priv(netdev);
-	u32 status_reg;
+	u32 status_reg, mask_reg;
 
 	status_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
+	mask_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
+	status_reg &= mask_reg;
 
 	if (!status_reg)
 		return IRQ_NONE;
@@ -1653,6 +1661,38 @@
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
 /**
+ * spider_net_enable_interrupts - enable interrupts
+ * @card: card structure
+ *
+ * spider_net_enable_interrupt enables several interrupts
+ */
+static void 
+spider_net_enable_interrupts(struct spider_net_card *card)
+{
+	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK,
+			     SPIDER_NET_INT0_MASK_VALUE);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK,
+			     SPIDER_NET_INT1_MASK_VALUE);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK,
+			     SPIDER_NET_INT2_MASK_VALUE);
+}
+
+/**
+ * spider_net_disable_interrupts - disable interrupts
+ * @card: card structure
+ *
+ * spider_net_disable_interrupts disables all the interrupts
+ */
+static void 
+spider_net_disable_interrupts(struct spider_net_card *card)
+{
+	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+}
+
+/**
  * spider_net_init_card - initializes the card
  * @card: card structure
  *
@@ -1672,6 +1712,7 @@
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
 
+	spider_net_disable_interrupts(card);
 }
 
 /**
@@ -1759,14 +1800,6 @@
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 			     SPIDER_NET_OPMODE_VALUE);
 
-	/* set interrupt mask registers */
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK,
-			     SPIDER_NET_INT0_MASK_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK,
-			     SPIDER_NET_INT1_MASK_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK,
-			     SPIDER_NET_INT2_MASK_VALUE);
-
 	spider_net_write_reg(card, SPIDER_NET_GDTDMACCNTR,
 			     SPIDER_NET_GDTBSTA);
 }
@@ -1941,6 +1974,8 @@
 	netif_carrier_on(netdev);
 	netif_poll_enable(netdev);
 
+	spider_net_enable_interrupts(card);
+
 	return 0;
 
 register_int_failed:
@@ -2113,11 +2148,7 @@
 	del_timer_sync(&card->tx_timer);
 	del_timer_sync(&card->aneg_timer);
 
-	/* disable/mask all interrupts */
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+	spider_net_disable_interrupts(card);
 
 	free_irq(netdev->irq, netdev);
 

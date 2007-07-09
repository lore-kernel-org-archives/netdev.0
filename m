From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] spidernet: improve interrupt handling
Date: Mon, 9 Jul 2007 18:17:42 -0500
Message-ID: <20070709231742.GQ4457@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53737 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997AbXGIXRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 19:17:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69NHkoc030237
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 19:17:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69NHhbO392520
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 19:17:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69NHhjZ023103
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 19:17:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>

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
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
Jeff, please apply for 2.6.23

Linas.

 drivers/net/spider_net.c |   59 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 45 insertions(+), 14 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-14 17:23:32.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-07-09 14:10:04.000000000 -0500
@@ -1478,11 +1478,17 @@ static void
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
@@ -1710,9 +1716,11 @@ spider_net_interrupt(int irq, void *ptr)
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
@@ -1754,6 +1762,38 @@ spider_net_poll_controller(struct net_de
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
@@ -1773,6 +1813,7 @@ spider_net_init_card(struct spider_net_c
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
 
+	spider_net_disable_interrupts(card);
 }
 
 /**
@@ -1860,14 +1901,6 @@ spider_net_enable_card(struct spider_net
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
@@ -2044,6 +2077,8 @@ spider_net_open(struct net_device *netde
 	netif_carrier_on(netdev);
 	netif_poll_enable(netdev);
 
+	spider_net_enable_interrupts(card);
+
 	return 0;
 
 register_int_failed:
@@ -2216,11 +2251,7 @@ spider_net_stop(struct net_device *netde
 	del_timer_sync(&card->tx_timer);
 	del_timer_sync(&card->aneg_timer);
 
-	/* disable/mask all interrupts */
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+	spider_net_disable_interrupts(card);
 
 	free_irq(netdev->irq, netdev);
 

From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Tue, 26 Feb 2008 21:46:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802262144300.12927@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: romieu@fr.zoriel.com, sorbica@icplus.com.tw, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35215 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbYBZTqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 14:46:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Convert the internal JUMBO_FRAME #ifdef to CONFIG_IP1000_JUMBO_FRAME proper and
fix compilation errors.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/Kconfig |    8 ++++++++
 drivers/net/ipg.c   |   21 ++++++++++-----------
 drivers/net/ipg.h   |   11 ++++++-----
 3 files changed, 24 insertions(+), 16 deletions(-)

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -2029,6 +2029,14 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
+config IP1000_JUMBO_FRAME
+	bool "Support for jumbo frames (EXPERIMENTAL)"
+	depends on IP1000 && EXPERIMENTAL
+	help
+	  This option enables jumbo frame support for the IP1000 driver.
+
+	  If in doubt, say N.
+
 config IGB
        tristate "Intel(R) 82575 PCI-Express Gigabit Ethernet support"
        depends on PCI
Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -42,7 +42,6 @@
 #define ipg_r16(reg)		ioread16(ioaddr + (reg))
 #define ipg_r8(reg)		ioread8(ioaddr + (reg))
 
-#define JUMBO_FRAME_4k_ONLY
 enum {
 	netdev_io_size = 128
 };
@@ -1079,7 +1078,7 @@ static int ipg_nic_rxrestore(struct net_
 	return 0;
 }
 
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 
 /* use jumboindex and jumbosize to control jumbo frame status
  * initial status is jumboindex=-1 and jumbosize=0
@@ -1274,7 +1273,7 @@ static void ipg_nic_rx_with_end(struct n
 
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
-			endframeLen = framelen - jumbo->current_size;
+			endframelen = framelen - jumbo->current_size;
 			/*
 			if (framelen > IPG_RXFRAG_SIZE)
 				framelen=IPG_RXFRAG_SIZE;
@@ -1282,8 +1281,8 @@ static void ipg_nic_rx_with_end(struct n
 			if (framelen > IPG_RXSUPPORT_SIZE)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
-				memcpy(skb_put(jumbo->skb, endframeLen),
-				       skb->data, endframeLen);
+				memcpy(skb_put(jumbo->skb, endframelen),
+				       skb->data, endframelen);
 
 				jumbo->skb->protocol =
 				    eth_type_trans(jumbo->skb, dev);
@@ -1355,16 +1354,16 @@ static int ipg_nic_rx(struct net_device 
 
 		switch (ipg_nic_rx_check_frame_type(dev)) {
 		case FRAME_WITH_START_WITH_END:
-			ipg_nic_rx_with_start_and_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start_and_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_START:
-			ipg_nic_rx_with_start(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_END:
-			ipg_nic_rx_with_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_NO_START_NO_END:
-			ipg_nic_rx_no_start_no_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_no_start_no_end(dev, sp, rxfd, entry);
 			break;
 		}
 	}
@@ -1595,7 +1594,7 @@ static irqreturn_t ipg_interrupt_handler
 
 	IPG_DEBUG_MSG("_interrupt_handler\n");
 
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 	ipg_nic_rxrestore(dev);
 #endif
 	spin_lock(&sp->lock);
@@ -1807,7 +1806,7 @@ static int ipg_nic_open(struct net_devic
 	if (ipg_config_autoneg(dev) < 0)
 		printk(KERN_INFO "%s: Auto-negotiation error.\n", dev->name);
 
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -536,7 +536,7 @@ enum ipg_regs {
  */
 #define		IPG_FRAMESBETWEENTXDMACOMPLETES 0x1
 
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 
 # ifdef JUMBO_FRAME_SIZE_2K
 # define JUMBO_FRAME_SIZE 2048
@@ -575,6 +575,7 @@ enum ipg_regs {
 #         define __IPG_RXFRAG_SIZE 4088
 #         else
 #         define JUMBO_FRAME_SIZE 4096
+#         define __IPG_RXFRAG_SIZE 4088
 #         endif
 #        endif
 #       endif
@@ -589,7 +590,7 @@ enum ipg_regs {
 /* Size of allocated received buffers. Nominally 0x0600.
  * Define larger if expecting jumbo frames.
  */
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 /* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
 #define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
 #endif
@@ -597,7 +598,7 @@ enum ipg_regs {
 /* Size of allocated received buffers. Nominally 0x0600.
  * Define larger if expecting jumbo frames.
  */
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 /* 4088 = 4096 - 8 */
 #define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
 #define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
@@ -607,7 +608,7 @@ enum ipg_regs {
 #endif
 
 /* IPG_MAX_RXFRAME_SIZE <= IPG_RXFRAG_SIZE */
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 #define		IPG_MAX_RXFRAME_SIZE		JUMBO_FRAME_SIZE
 #else
 #define		IPG_MAX_RXFRAME_SIZE		0x0600
@@ -786,7 +787,7 @@ struct ipg_nic_private {
 	unsigned int tx_dirty;
 	unsigned int rx_current;
 	unsigned int rx_dirty;
-#ifdef JUMBO_FRAME
+#ifdef CONFIG_IP1000_JUMBO_FRAME
 	struct ipg_jumbo jumbo;
 #endif
 	unsigned int rx_buf_sz;

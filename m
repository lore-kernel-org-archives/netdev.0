From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 03/08] ipg: always compile in jumbo frame support
Date: Mon, 23 Jun 2008 14:35:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231434510.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbYFWLfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:35:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Add a ->is_jumbo boolean to struct ipg_nic_private and fix up
ipg_interrupt_handler() to call the jumbo frame version of ipg_nic_rx() if the
boolean is set to true. Also remove the JUMBO_FRAME #ifdefs so we can always
compile in support for jumbo frames.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   27 ++++++++++++++-------------
 drivers/net/ipg.h |    9 +++++++--
 2 files changed, 21 insertions(+), 15 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -1076,8 +1076,6 @@ static int ipg_nic_rxrestore(struct net_
 	return 0;
 }
 
-#ifdef JUMBO_FRAME
-
 /* use jumboindex and jumbosize to control jumbo frame status
  * initial status is jumboindex=-1 and jumbosize=0
  * 1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
@@ -1097,7 +1095,7 @@ enum {
 	FRAME_WITH_START_WITH_END = 11
 };
 
-inline void ipg_nic_rx_free_skb(struct net_device *dev)
+static void ipg_nic_rx_free_skb(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
@@ -1113,7 +1111,7 @@ inline void ipg_nic_rx_free_skb(struct n
 	}
 }
 
-inline int ipg_nic_rx_check_frame_type(struct net_device *dev)
+static int ipg_nic_rx_check_frame_type(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	struct ipg_rx *rxfd = sp->rxd + (sp->rx_current % IPG_RFDLIST_LENGTH);
@@ -1126,7 +1124,7 @@ inline int ipg_nic_rx_check_frame_type(s
 	return type;
 }
 
-inline int ipg_nic_rx_check_error(struct net_device *dev)
+static int ipg_nic_rx_check_error(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
@@ -1334,7 +1332,7 @@ static void ipg_nic_rx_no_start_no_end(s
 	}
 }
 
-static int ipg_nic_rx(struct net_device *dev)
+static int ipg_nic_rx_jumbo(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int curr = sp->rx_current;
@@ -1382,7 +1380,6 @@ static int ipg_nic_rx(struct net_device 
 	return 0;
 }
 
-#else
 static int ipg_nic_rx(struct net_device *dev)
 {
 	/* Transfer received Ethernet frames to higher network layers. */
@@ -1556,7 +1553,6 @@ static int ipg_nic_rx(struct net_device 
 
 	return 0;
 }
-#endif
 
 static void ipg_reset_after_host_error(struct work_struct *work)
 {
@@ -1592,9 +1588,9 @@ static irqreturn_t ipg_interrupt_handler
 
 	IPG_DEBUG_MSG("_interrupt_handler\n");
 
-#ifdef JUMBO_FRAME
-	ipg_nic_rxrestore(dev);
-#endif
+	if (sp->is_jumbo)
+		ipg_nic_rxrestore(dev);
+
 	spin_lock(&sp->lock);
 
 	/* Get interrupt source information, and acknowledge
@@ -1650,7 +1646,10 @@ static irqreturn_t ipg_interrupt_handler
 			sp->RFDListCheckedCount++;
 #endif
 
-		ipg_nic_rx(dev);
+		if (sp->is_jumbo)
+			ipg_nic_rx_jumbo(dev);
+		else
+			ipg_nic_rx(dev);
 	}
 
 	/* If TxDMAComplete interrupt, free used TFDs. */
@@ -1804,11 +1803,11 @@ static int ipg_nic_open(struct net_devic
 	if (ipg_config_autoneg(dev) < 0)
 		printk(KERN_INFO "%s: Auto-negotiation error.\n", dev->name);
 
-#ifdef JUMBO_FRAME
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
 	sp->jumbo.skb = NULL;
+#ifdef JUMBO_FRAME
 	dev->mtu = IPG_TXFRAG_SIZE;
 #endif
 
@@ -2240,6 +2239,8 @@ static int __devinit ipg_probe(struct pc
 	spin_lock_init(&sp->lock);
 	mutex_init(&sp->mii_mutex);
 
+	sp->is_jumbo = IPG_JUMBO;
+
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
 	dev->open = &ipg_nic_open;
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -537,6 +537,12 @@ enum ipg_regs {
 #define		IPG_FRAMESBETWEENTXDMACOMPLETES 0x1
 
 #ifdef JUMBO_FRAME
+# define IPG_JUMBO true
+#else
+# define IPG_JUMBO false
+#endif
+
+#ifdef JUMBO_FRAME
 
 # ifdef JUMBO_FRAME_SIZE_2K
 # define JUMBO_FRAME_SIZE 2048
@@ -786,9 +792,8 @@ struct ipg_nic_private {
 	unsigned int tx_dirty;
 	unsigned int rx_current;
 	unsigned int rx_dirty;
-#ifdef JUMBO_FRAME
+	bool is_jumbo;
 	struct ipg_jumbo jumbo;
-#endif
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
 	struct net_device *dev;

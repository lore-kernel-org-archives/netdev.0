From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 05/08] ipg: per-device rxfrag_size
Date: Mon, 23 Jun 2008 14:36:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231435380.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbYFWLgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:36:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Add a ->max_rxframe member to struct ipg_nic_private and convert the users of
IPG_RXFRAG_SIZE to use it instead to enable per-device jumbo frame
configuration.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   25 +++++++++++--------------
 drivers/net/ipg.h |    1 +
 2 files changed, 12 insertions(+), 14 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -751,7 +751,7 @@ static int ipg_get_rxbuff(struct net_dev
 		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
 
 	/* Set the RFD fragment length. */
-	rxfragsize = IPG_RXFRAG_SIZE;
+	rxfragsize = sp->rxfrag_size;
 	rxfd->frag_info |= cpu_to_le64((rxfragsize << 48) & IPG_RFI_FRAGLEN);
 
 	return 0;
@@ -1207,8 +1207,8 @@ static void ipg_nic_rx_with_start_and_en
 
 	/* accept this frame and send to upper layer */
 	framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
-	if (framelen > IPG_RXFRAG_SIZE)
-		framelen = IPG_RXFRAG_SIZE;
+	if (framelen > sp->rxfrag_size)
+		framelen = sp->rxfrag_size;
 
 	skb_put(skb, framelen);
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1241,10 +1241,10 @@ static void ipg_nic_rx_with_start(struct
 	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-	skb_put(skb, IPG_RXFRAG_SIZE);
+	skb_put(skb, sp->rxfrag_size);
 
 	jumbo->found_start = 1;
-	jumbo->current_size = IPG_RXFRAG_SIZE;
+	jumbo->current_size = sp->rxfrag_size;
 	jumbo->skb = skb;
 
 	sp->rx_buff[entry] = NULL;
@@ -1270,10 +1270,6 @@ static void ipg_nic_rx_with_end(struct n
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
 			endframelen = framelen - jumbo->current_size;
-			/*
-			if (framelen > IPG_RXFRAG_SIZE)
-				framelen=IPG_RXFRAG_SIZE;
-			 */
 			if (framelen > IPG_RXSUPPORT_SIZE)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
@@ -1314,11 +1310,11 @@ static void ipg_nic_rx_no_start_no_end(s
 
 		if (skb) {
 			if (jumbo->found_start) {
-				jumbo->current_size += IPG_RXFRAG_SIZE;
+				jumbo->current_size += sp->rxfrag_size;
 				if (jumbo->current_size <= IPG_RXSUPPORT_SIZE) {
 					memcpy(skb_put(jumbo->skb,
-						       IPG_RXFRAG_SIZE),
-					       skb->data, IPG_RXFRAG_SIZE);
+						       sp->rxfrag_size),
+					       skb->data, sp->rxfrag_size);
 				}
 			}
 			dev->last_rx = jiffies;
@@ -1410,11 +1406,11 @@ static int ipg_nic_rx(struct net_device 
 		/* Check for jumbo frame arrival with too small
 		 * RXFRAG_SIZE.
 		 */
-		if (framelen > IPG_RXFRAG_SIZE) {
+		if (framelen > sp->rxfrag_size) {
 			IPG_DEBUG_MSG
 			    ("RFS FrameLen > allocated fragment size.\n");
 
-			framelen = IPG_RXFRAG_SIZE;
+			framelen = sp->rxfrag_size;
 		}
 
 		if ((IPG_DROP_ON_RX_ETH_ERRORS && (le64_to_cpu(rxfd->rfs) &
@@ -2240,6 +2236,7 @@ static int __devinit ipg_probe(struct pc
 	mutex_init(&sp->mii_mutex);
 
 	sp->is_jumbo = IPG_JUMBO;
+	sp->rxfrag_size = IPG_RXFRAG_SIZE;
 
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -796,6 +796,7 @@ struct ipg_nic_private {
 	unsigned int rx_dirty;
 	bool is_jumbo;
 	struct ipg_jumbo jumbo;
+	unsigned long rxfrag_size;
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
 	struct net_device *dev;

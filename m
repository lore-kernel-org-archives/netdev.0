From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 06/08] ipg: per-device rxsupport_size
Date: Mon, 23 Jun 2008 14:36:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231436010.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbYFWLgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Add a ->max_rxframe member to struct ipg_nic_private and convert the users of
IPG_RXSUPPORT_SIZE to use it instead to enable per-device jumbo frame
configuration.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |    9 +++++----
 drivers/net/ipg.h |    1 +
 2 files changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -730,7 +730,7 @@ static int ipg_get_rxbuff(struct net_dev
 
 	IPG_DEBUG_MSG("_get_rxbuff\n");
 
-	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(dev, sp->rxsupport_size + NET_IP_ALIGN);
 	if (!skb) {
 		sp->rx_buff[entry] = NULL;
 		return -ENOMEM;
@@ -1270,7 +1270,7 @@ static void ipg_nic_rx_with_end(struct n
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
 			endframelen = framelen - jumbo->current_size;
-			if (framelen > IPG_RXSUPPORT_SIZE)
+			if (framelen > sp->rxsupport_size)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
 				memcpy(skb_put(jumbo->skb, endframelen),
@@ -1311,7 +1311,7 @@ static void ipg_nic_rx_no_start_no_end(s
 		if (skb) {
 			if (jumbo->found_start) {
 				jumbo->current_size += sp->rxfrag_size;
-				if (jumbo->current_size <= IPG_RXSUPPORT_SIZE) {
+				if (jumbo->current_size <= sp->rxsupport_size) {
 					memcpy(skb_put(jumbo->skb,
 						       sp->rxfrag_size),
 					       skb->data, sp->rxfrag_size);
@@ -1744,7 +1744,7 @@ static int ipg_nic_open(struct net_devic
 
 	IPG_DEBUG_MSG("_nic_open\n");
 
-	sp->rx_buf_sz = IPG_RXSUPPORT_SIZE;
+	sp->rx_buf_sz = sp->rxsupport_size;
 
 	/* Check for interrupt line conflicts, and request interrupt
 	 * line for IPG.
@@ -2237,6 +2237,7 @@ static int __devinit ipg_probe(struct pc
 
 	sp->is_jumbo = IPG_JUMBO;
 	sp->rxfrag_size = IPG_RXFRAG_SIZE;
+	sp->rxsupport_size = IPG_RXSUPPORT_SIZE;
 
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -797,6 +797,7 @@ struct ipg_nic_private {
 	bool is_jumbo;
 	struct ipg_jumbo jumbo;
 	unsigned long rxfrag_size;
+	unsigned long rxsupport_size;
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
 	struct net_device *dev;

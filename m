From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 07/08] ipg: per-device max_rxframe_size
Date: Mon, 23 Jun 2008 14:36:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231436190.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbYFWLgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Add a ->max_rxframe member to struct ipg_nic_private and convert the users of
IPG_MAX_RXFRAME_SIZE to use it instead to enable per-device jumbo frame
configuration.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |    8 ++++++--
 drivers/net/ipg.h |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -631,6 +631,7 @@ static void ipg_nic_set_multicast_list(s
 
 static int ipg_io_config(struct net_device *dev)
 {
+	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	u32 origmacctrl;
 	u32 restoremacctrl;
@@ -670,7 +671,7 @@ static int ipg_io_config(struct net_devi
 	/* Set RECEIVEMODE register. */
 	ipg_nic_set_multicast_list(dev);
 
-	ipg_w16(IPG_MAX_RXFRAME_SIZE, MAX_FRAME_SIZE);
+	ipg_w16(sp->max_rxframe_size, MAX_FRAME_SIZE);
 
 	ipg_w8(IPG_RXDMAPOLLPERIOD_VALUE,   RX_DMA_POLL_PERIOD);
 	ipg_w8(IPG_RXDMAURGENTTHRESH_VALUE, RX_DMA_URGENT_THRESH);
@@ -2114,6 +2115,8 @@ static int ipg_ioctl(struct net_device *
 
 static int ipg_nic_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct ipg_nic_private *sp = netdev_priv(dev);
+
 	/* Function to accomodate changes to Maximum Transfer Unit
 	 * (or MTU) of IPG NIC. Cannot use default function since
 	 * the default will not allow for MTU > 1500 bytes.
@@ -2125,7 +2128,7 @@ static int ipg_nic_change_mtu(struct net
 	 * byte payload, 4 byte FCS) and IPG_MAX_RXFRAME_SIZE, which
 	 * corresponds to the MAXFRAMESIZE register in the IPG.
 	 */
-	if ((new_mtu < 68) || (new_mtu > IPG_MAX_RXFRAME_SIZE))
+	if ((new_mtu < 68) || (new_mtu > sp->max_rxframe_size))
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
@@ -2238,6 +2241,7 @@ static int __devinit ipg_probe(struct pc
 	sp->is_jumbo = IPG_JUMBO;
 	sp->rxfrag_size = IPG_RXFRAG_SIZE;
 	sp->rxsupport_size = IPG_RXSUPPORT_SIZE;
+	sp->max_rxframe_size = IPG_MAX_RXFRAME_SIZE;
 
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -798,6 +798,7 @@ struct ipg_nic_private {
 	struct ipg_jumbo jumbo;
 	unsigned long rxfrag_size;
 	unsigned long rxsupport_size;
+	unsigned long max_rxframe_size;
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
 	struct net_device *dev;

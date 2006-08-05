From: Jim Lewis <jim@jklewis.com>
Subject: Patch to add ethtool -g to Spidernet network driver
Date: Sat, 05 Aug 2006 10:36:25 -0500
Message-ID: <1154792185.3692.68.camel@localhost.localdomain>
Reply-To: jim@jklewis.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centrmmtao01.cox.net ([70.168.83.83]:23012 "EHLO
	centrmmtao01.cox.net") by vger.kernel.org with ESMTP
	id S1161137AbWHEPg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 11:36:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



This patch adds ethtool -g (show ring sizes) support to the Spidernet
network driver.

Signed-off-by: James K Lewis <jklewis@us.ibm.com>
---
 drivers/net/spider_net.c         |   12 +++++++-----
 drivers/net/spider_net.h         |    3 +++
 drivers/net/spider_net_ethtool.c |   13 +++++++++++++
 3 files changed, 23 insertions(+), 5 deletions(-)

Index: linux-2.6.18-rc2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net.c	2006-08-03
12:03:01.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net.c	2006-08-04
14:48:28.000000000 -0500
@@ -1612,13 +1612,12 @@ spider_net_open(struct net_device *netde
 	int result;
 
 	result = -ENOMEM;
-	if (spider_net_init_chain(card, &card->tx_chain,
-			card->descr,
-			PCI_DMA_TODEVICE, tx_descriptors))
+	if (spider_net_init_chain(card, &card->tx_chain, card->descr,
+			PCI_DMA_TODEVICE, card->tx_desc))
 		goto alloc_tx_failed;
 	if (spider_net_init_chain(card, &card->rx_chain,
-			card->descr + tx_descriptors,
-			PCI_DMA_FROMDEVICE, rx_descriptors))
+			card->descr + card->rx_desc,
+			PCI_DMA_FROMDEVICE, card->rx_desc))
 		goto alloc_rx_failed;
 
 	/* allocate rx skbs */
@@ -2006,6 +2005,9 @@ spider_net_setup_netdev(struct spider_ne
 
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
+	card->tx_desc = tx_descriptors;
+	card->rx_desc = rx_descriptors;
+
 	spider_net_setup_netdev_ops(netdev);
 
 	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
Index: linux-2.6.18-rc2/drivers/net/spider_net.h
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net.h	2006-08-03
12:03:01.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net.h	2006-08-04
14:48:26.000000000 -0500
@@ -441,6 +441,9 @@ struct spider_net_card {
 	/* for ethtool */
 	int msg_enable;
 
+	int rx_desc;
+	int tx_desc;
+
 	struct spider_net_descr descr[0];
 };
 
Index: linux-2.6.18-rc2/drivers/net/spider_net_ethtool.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net_ethtool.c	2006-08-03
12:03:01.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net_ethtool.c	2006-08-04
15:00:22.000000000 -0500
@@ -130,6 +130,18 @@ spider_net_ethtool_set_tx_csum(struct ne
         return 0;
 }
 
+static void
+spider_net_ethtool_get_ringparam(struct net_device *netdev,
+				 struct ethtool_ringparam *ering)
+{
+	struct spider_net_card *card = netdev->priv;
+
+	ering->tx_max_pending = SPIDER_NET_TX_DESCRIPTORS_MAX;
+	ering->tx_pending = card->tx_desc;
+	ering->rx_max_pending = SPIDER_NET_RX_DESCRIPTORS_MAX;
+	ering->rx_pending = card->rx_desc;
+}
+
 struct ethtool_ops spider_net_ethtool_ops = {
 	.get_settings		= spider_net_ethtool_get_settings,
 	.get_drvinfo		= spider_net_ethtool_get_drvinfo,
@@ -141,5 +153,6 @@ struct ethtool_ops spider_net_ethtool_op
 	.set_rx_csum		= spider_net_ethtool_set_rx_csum,
 	.get_tx_csum		= spider_net_ethtool_get_tx_csum,
 	.set_tx_csum		= spider_net_ethtool_set_tx_csum,
+	.get_ringparam          = spider_net_ethtool_get_ringparam,
 };
 








-- 
Jim Lewis



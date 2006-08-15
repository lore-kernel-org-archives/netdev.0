From: akpm@osdl.org
Subject: [patch 35/41] Add ethtool -g support to Spidernet network driver
Date: Mon, 14 Aug 2006 23:00:23 -0700
Message-ID: <200608150600.k7F60NET012727@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jim@jklewis.com,
	jklewis@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34200 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965207AbWHOGRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:17:16 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Lewis <jim@jklewis.com>

Add ethtool -g (show ring sizes) support to the Spidernet network driver.

Signed-off-by: James K Lewis <jklewis@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/spider_net.c         |   12 +++++++-----
 drivers/net/spider_net.h         |    3 +++
 drivers/net/spider_net_ethtool.c |   13 +++++++++++++
 3 files changed, 23 insertions(+), 5 deletions(-)

diff -puN drivers/net/spider_net.c~add-ethtool-g-support-to-spidernet-network-driver drivers/net/spider_net.c
--- a/drivers/net/spider_net.c~add-ethtool-g-support-to-spidernet-network-driver
+++ a/drivers/net/spider_net.c
@@ -1611,13 +1611,12 @@ spider_net_open(struct net_device *netde
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
@@ -2005,6 +2004,9 @@ spider_net_setup_netdev(struct spider_ne
 
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
+	card->tx_desc = tx_descriptors;
+	card->rx_desc = rx_descriptors;
+
 	spider_net_setup_netdev_ops(netdev);
 
 	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
diff -puN drivers/net/spider_net.h~add-ethtool-g-support-to-spidernet-network-driver drivers/net/spider_net.h
--- a/drivers/net/spider_net.h~add-ethtool-g-support-to-spidernet-network-driver
+++ a/drivers/net/spider_net.h
@@ -440,6 +440,9 @@ struct spider_net_card {
 	/* for ethtool */
 	int msg_enable;
 
+	int rx_desc;
+	int tx_desc;
+
 	struct spider_net_descr descr[0];
 };
 
diff -puN drivers/net/spider_net_ethtool.c~add-ethtool-g-support-to-spidernet-network-driver drivers/net/spider_net_ethtool.c
--- a/drivers/net/spider_net_ethtool.c~add-ethtool-g-support-to-spidernet-network-driver
+++ a/drivers/net/spider_net_ethtool.c
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
 
_

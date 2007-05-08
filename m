From: Olof Johansson <olof@lixom.net>
Subject: [PATCH v4 7/9] pasemi_mac: Add msglevel support and "debug" module param
Date: Tue, 8 May 2007 00:47:49 -0500
Message-ID: <20070508054749.GH14321@lixom.net>
References: <20070508053500.358169000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:32959 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754666AbXEHGIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 02:08:43 -0400
Content-Disposition: inline; filename=n-8
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add msglevel support for pasemi_mac. Move the MODULE_* defines to the
top to go together with the variable (similar to tg3).

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -53,6 +53,16 @@
 #define RX_RING_SIZE 512
 #define TX_RING_SIZE 512
 
+#define DEFAULT_MSG_ENABLE	  \
+	(NETIF_MSG_DRV		| \
+	 NETIF_MSG_PROBE	| \
+	 NETIF_MSG_LINK		| \
+	 NETIF_MSG_TIMER	| \
+	 NETIF_MSG_IFDOWN	| \
+	 NETIF_MSG_IFUP		| \
+	 NETIF_MSG_RX_ERR	| \
+	 NETIF_MSG_TX_ERR)
+
 #define TX_DESC(mac, num)	((mac)->tx->desc[(num) & (TX_RING_SIZE-1)])
 #define TX_DESC_INFO(mac, num)	((mac)->tx->desc_info[(num) & (TX_RING_SIZE-1)])
 #define RX_DESC(mac, num)	((mac)->rx->desc[(num) & (RX_RING_SIZE-1)])
@@ -61,6 +71,14 @@
 
 #define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
+MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
+
+static int debug = -1;	/* -1 == use DEFAULT_MSG_ENABLE as value */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
+
 static struct pasdma_status *dma_status;
 
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
@@ -873,6 +891,7 @@ static struct net_device_stats *pasemi_m
 	return &mac->stats;
 }
 
+
 static void pasemi_mac_set_rx_mode(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -1007,6 +1026,8 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
 	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
 
+	mac->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+
 	err = register_netdev(dev);
 
 	if (err) {
@@ -1081,9 +1102,5 @@ int pasemi_mac_init_module(void)
 	return pci_register_driver(&pasemi_mac_driver);
 }
 
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
-MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
-
 module_init(pasemi_mac_init_module);
 module_exit(pasemi_mac_cleanup_module);
Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -75,6 +75,8 @@ struct pasemi_mac {
 	struct pasemi_mac_rxring *rx;
 	unsigned long	tx_irq;
 	unsigned long	rx_irq;
+
+	unsigned int	msg_enable;
 };
 
 /* Software status descriptor (desc_info) */

--

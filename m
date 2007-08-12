From: Michael Trimarchi <trimarchi@gandalf.sssup.it>
Subject: dm9000: add set_mac_address()
Date: Sun, 12 Aug 2007 21:27:41 +0200
Message-ID: <20070812192741.GB27490@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, trimarchi@gandalf.sssup.it
To: jgarzi@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:33830 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758605AbXHLVeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 17:34:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement set_mac_address() for the dm9000 driver.  This allows changing
the mac address of the interface.

Signed-off-by: Michael Trimarchi <trimarchi@gandalf.sssup.it>
---

--- linux-2.6.22/drivers/net/dm9000.c.orig	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22/drivers/net/dm9000.c	2007-08-12 21:42:50.000000000 +0200
@@ -161,6 +161,8 @@ static irqreturn_t dm9000_interrupt(int,
 static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused, int reg);
 static void dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg,
 			   int value);
+static int dm9000_eth_set_mac_address(struct net_device *dev, void *p);
+
 static u16 read_srom_word(board_info_t *, int);
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
@@ -546,6 +548,7 @@ dm9000_probe(struct platform_device *pde
 	ndev->stop		 = &dm9000_stop;
 	ndev->get_stats		 = &dm9000_get_stats;
 	ndev->set_multicast_list = &dm9000_hash_table;
+	ndev->set_mac_address	 = &dm9000_eth_set_mac_address;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;
 #endif
@@ -986,7 +989,6 @@ read_srom_word(board_info_t * db, int of
 	return (ior(db, DM9000_EPDRL) + (ior(db, DM9000_EPDRH) << 8));
 }
 
-#ifdef DM9000_PROGRAM_EEPROM
 /*
  * Write a word data to SROM
  */
@@ -1002,6 +1004,34 @@ write_srom_word(board_info_t * db, int o
 }
 
 /*
+ * dm9000_eth_set_mac_address
+ *
+ * Change the interface's mac address.
+ *
+ */
+static int 
+dm9000_eth_set_mac_address(struct net_device *dev, void *p)
+{
+	board_info_t *db = (board_info_t *) dev->priv;
+	struct sockaddr *addr = p;
+	int i;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	for (i = 0; i < 3; i++)
+		write_srom_word(db, i, ((u16 *)(addr->sa_data))[i]);
+
+	return 0;
+}
+
+#ifdef DM9000_PROGRAM_EEPROM
+/*
  * Only for development:
  * Here we write static data to the eeprom in case
  * we don't have valid content on a new board

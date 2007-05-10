From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.21 1/3]S2IO: getringparam ethtool option
Date: Thu, 10 May 2007 04:06:28 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10705100351060.23138-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alicia.Pena@neterion.com, Leonid.Grossman@neterion.com,
	ramkrishna.vep@neterion.com, santosh.rastapur@neterion.com,
	Sivakumar.Subramani@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47783 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371AbXEJITT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 04:19:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding get_ringparam ethtool option.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -pNur netdev-2.6-org/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- netdev-2.6-org/drivers/net/s2io.c	2007-04-09 12:24:33.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-04-17 10:45:23.000000000 +0530
@@ -4775,6 +4775,40 @@ static int s2io_ethtool_idnic(struct net
 	return 0;
 }
 
+static void s2io_ethtool_gringparam(struct net_device *dev,
+                                    struct ethtool_ringparam *ering)
+{
+	struct s2io_nic *sp = dev->priv;
+	int i,tx_desc_count=0,rx_desc_count=0;
+
+	if (sp->rxd_mode == RXD_MODE_1)
+		ering->rx_max_pending = MAX_RX_DESC_1;
+	else if (sp->rxd_mode == RXD_MODE_3B)
+		ering->rx_max_pending = MAX_RX_DESC_2;
+	else if (sp->rxd_mode == RXD_MODE_3A)
+		ering->rx_max_pending = MAX_RX_DESC_3;
+
+	ering->tx_max_pending = MAX_TX_DESC;
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
+	}
+	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
+	ering->tx_pending = tx_desc_count;
+	rx_desc_count = 0;
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
+	}
+	ering->rx_pending = rx_desc_count;
+
+	ering->rx_mini_max_pending = 0;
+	ering->rx_mini_pending = 0;
+	if(sp->rxd_mode == RXD_MODE_1)
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_1;
+	else if (sp->rxd_mode == RXD_MODE_3B)
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
+	ering->rx_jumbo_pending = rx_desc_count;
+}
+
 /**
  * s2io_ethtool_getpause_data -Pause frame frame generation and reception.
  * @sp : private member of the device structure, which is a pointer to the
@@ -5854,6 +5888,7 @@ static const struct ethtool_ops netdev_e
 	.get_eeprom_len = s2io_get_eeprom_len,
 	.get_eeprom = s2io_ethtool_geeprom,
 	.set_eeprom = s2io_ethtool_seeprom,
+	.get_ringparam = s2io_ethtool_gringparam,
 	.get_pauseparam = s2io_ethtool_getpause_data,
 	.set_pauseparam = s2io_ethtool_setpause_data,
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
diff -pNur netdev-2.6-org/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- netdev-2.6-org/drivers/net/s2io.h	2007-04-09 12:24:33.000000000 +0530
+++ patch1/drivers/net/s2io.h	2007-04-17 10:45:32.000000000 +0530
@@ -308,6 +308,11 @@ struct stat_block {
 #define MAX_TX_FIFOS 8
 #define MAX_RX_RINGS 8
 
+#define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 127 )
+#define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
+#define MAX_RX_DESC_3  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
+#define MAX_TX_DESC    (MAX_AVAILABLE_TXDS)
+
 /* FIFO mappings for all possible number of fifos configured */
 static int fifo_map[][MAX_TX_FIFOS] = {
 	{0, 0, 0, 0, 0, 0, 0, 0},


From: tzungder@cobra.ee.ntu.edu.tw (User Tzungder)
Subject: [PATCH 2.6.29.1 1/1]8139too:fix HW initial flow
Date: Tue, 21 Apr 2009 18:13:41 +0800 (CST)
Message-ID: <20090421101341.3ECFD1380B4@cobra.ee.ntu.edu.tw>
Cc: dada1@cosmosbay.com, jon.lin@vatics.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tzungder@cobra.ee.ntu.edu.tw
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cobra.ee.ntu.edu.tw ([140.112.42.65]:50144 "EHLO
	cobra.ee.ntu.edu.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbZDUKZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:25:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:Jonathan Lin <jon.lin@vatics.com>

While ifconfig eth0 up kernel call open() of 8139 driver(8139too.c).
In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before setting up the DMA buffer address. In this interval where RX was enabled and DMA buffer address is not yet set up, any incoming broadcast packet would be send to a strange physical address: 0x003e8800 which is the default value of DMA buffer address.
Unfortunately, this address is used by Linux kernel. So kernel panics.
This patch fix it by setting up DMA buffer address before RX enabled and everything is fine even under broadcast packets attack.

Signed-off-by:Jonathan Lin <jon.lin@vatics.com>

--- linux-2.6.29.1/drivers/net/8139too.c.orig	2009-04-20 20:46:21.000000000 +0800
+++ linux-2.6.29.1/drivers/net/8139too.c	2009-04-20 20:58:39.000000000 +0800
@@ -1382,6 +1382,10 @@ static void rtl8139_hw_start (struct net
 	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
 	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
 
+	tp->cur_rx = 0;
+	/* init Rx ring buffer DMA address BEFORE Rx enabled*/
+	RTL_W32_F (RxBuf, tp->rx_ring_dma);
+	
 	/* Must enable Tx/Rx before setting transfer thresholds! */
 	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
 
@@ -1389,8 +1393,6 @@ static void rtl8139_hw_start (struct net
 	RTL_W32 (RxConfig, tp->rx_config);
 	RTL_W32 (TxConfig, rtl8139_tx_config);
 
-	tp->cur_rx = 0;
-
 	rtl_check_media (dev, 1);
 
 	if (tp->chipset >= CH_8139B) {
@@ -1405,9 +1407,6 @@ static void rtl8139_hw_start (struct net
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
 
-	/* init Rx ring buffer DMA address */
-	RTL_W32_F (RxBuf, tp->rx_ring_dma);
-
 	/* init Tx buffer DMA addresses */
 	for (i = 0; i < NUM_TX_DESC; i++)
 		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));

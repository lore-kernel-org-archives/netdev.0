From: Tzungder Lin <tzungder@gmail.com>
Subject: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Mon, 20 Apr 2009 09:54:10 +0800
Message-ID: <528f811a0904191854o3a354e8fif6a8d65f8da94965@mail.gmail.com>
References: <528f811a0904190316v22621684o3047e37bf8e78bda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:53730 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbZDTByL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 21:54:11 -0400
In-Reply-To: <528f811a0904190316v22621684o3047e37bf8e78bda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Lin <tzungder@gmail.com>

While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before
setting up the DMA buffer address. In this interval where RX was
enabled and DMA buffer address is not yet set up, any incoming
broadcast packet would be send to a strange physical address:
0x003e8800 which is the default value of DMA buffer address.
Unfortunately, this address is used by Linux kernel. So kernel panics.
This patch fix it by setting up DMA buffer address before RX enabled
and everything is fine even under broadcast packets attack.

Signed-off-by: Jonathan Lin <tzungder@gmail.com>

--- linux-2.6.29.1/drivers/net/8139too.c.orig   2009-04-19
17:50:38.000000000 +0800
+++ linux-2.6.29.1/drivers/net/8139too.c        2009-04-19
17:52:51.000000000 +0800
@@ -1382,6 +1382,10 @@ static void rtl8139_hw_start (struct net
       RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
       RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));

+       tp->cur_rx = 0;
+       /* init Rx ring buffer DMA address BEFORE Rx enabled*/
+       RTL_W32_F (RxBuf, tp->rx_ring_dma);
+
       /* Must enable Tx/Rx before setting transfer thresholds! */
       RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);

@@ -1389,8 +1393,6 @@ static void rtl8139_hw_start (struct net
       RTL_W32 (RxConfig, tp->rx_config);
       RTL_W32 (TxConfig, rtl8139_tx_config);

-       tp->cur_rx = 0;
-
       rtl_check_media (dev, 1);

       if (tp->chipset >= CH_8139B) {
@@ -1405,9 +1407,6 @@ static void rtl8139_hw_start (struct net
       /* Lock Config[01234] and BMCR register writes */
       RTL_W8 (Cfg9346, Cfg9346_Lock);

-       /* init Rx ring buffer DMA address */
-       RTL_W32_F (RxBuf, tp->rx_ring_dma);
-
       /* init Tx buffer DMA addresses */
       for (i = 0; i < NUM_TX_DESC; i++)
               RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] -
tp->tx_bufs));

From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 06/10] mv643xx_eth: also check TX_IN_PROGRESS when disabling transmit path
Date: Wed, 16 Jul 2008 12:32:37 +0200
Message-ID: <20080716103237.GG8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44736 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756540AbYGPKcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recommended sequence for waiting for the transmit path to clear
after disabling all of the transmit queues is to wait for the
TX_FIFO_EMPTY bit in the Port Status register to become set as well
as the TX_IN_PROGRESS bit to clear.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 207d439..c700c1f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -90,6 +90,7 @@ static char mv643xx_eth_driver_version[] = "1.1";
 #define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
 #define  TX_FIFO_EMPTY			0x00000400
+#define  TX_IN_PROGRESS			0x00000080
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
 #define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
@@ -2039,8 +2040,14 @@ static void port_reset(struct mv643xx_eth_private *mp)
 		if (mp->txq_mask & (1 << i))
 			txq_disable(mp->txq + i);
 	}
-	while (!(rdl(mp, PORT_STATUS(mp->port_num)) & TX_FIFO_EMPTY))
+
+	while (1) {
+		u32 ps = rdl(mp, PORT_STATUS(mp->port_num));
+
+		if ((ps & (TX_IN_PROGRESS | TX_FIFO_EMPTY)) == TX_FIFO_EMPTY)
+			break;
 		udelay(10);
+	}
 
 	/* Reset the Enable bit in the Configuration Register */
 	data = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
-- 
1.5.3.4

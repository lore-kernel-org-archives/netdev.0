From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 28/39] mv643xx_eth: remove write-only interrupt coalescing variables
Date: Tue,  3 Jun 2008 13:02:43 +0200
Message-ID: <1212490974-23719-29-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48761 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755776AbYFCMAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:38 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the write-only ->[rt]x_int_coal members from struct
mv643xx_eth_private.  In the process, tweak the RX/TX interrupt
mitigation code so that it is compiled by default, and set the
default coalescing delays to 0 usec.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   29 ++++-------------------------
 1 files changed, 4 insertions(+), 25 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index beeadcf..ef1c461 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -52,12 +52,6 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_NAPI
 #define MV643XX_ETH_TX_FAST_REFILL
-#undef	MV643XX_ETH_COAL
-
-#define MV643XX_ETH_TX_COAL 100
-#ifdef MV643XX_ETH_COAL
-#define MV643XX_ETH_RX_COAL 100
-#endif
 
 #ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
@@ -313,8 +307,6 @@ struct mv643xx_eth_private {
 	struct mib_counters mib_counters;
 	spinlock_t lock;
 
-	u32 rx_int_coal;
-	u32 tx_int_coal;
 	struct mii_if_info mii;
 
 	/*
@@ -1672,9 +1664,7 @@ static void port_start(struct net_device *dev)
 	}
 }
 
-#ifdef MV643XX_ETH_COAL
-static unsigned int set_rx_coal(struct mv643xx_eth_private *mep,
-					unsigned int delay)
+static void set_rx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
 {
 	unsigned int port_num = mep->port_num;
 	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
@@ -1684,20 +1674,14 @@ static unsigned int set_rx_coal(struct mv643xx_eth_private *mep,
 		((coal & 0x3fff) << 8) |
 		(rdl(mep, SDMA_CONFIG(port_num))
 			& 0xffc000ff));
-
-	return coal;
 }
-#endif
 
-static unsigned int set_tx_coal(struct mv643xx_eth_private *mep,
-					unsigned int delay)
+static void set_tx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
 {
 	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
 	wrl(mep, TX_FIFO_URGENT_THRESHOLD(mep->port_num), coal << 4);
-
-	return coal;
 }
 
 static void port_init(struct mv643xx_eth_private *mep)
@@ -1743,13 +1727,8 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	port_start(dev);
 
-	/* Interrupt Coalescing */
-
-#ifdef MV643XX_ETH_COAL
-	mep->rx_int_coal = set_rx_coal(mep, MV643XX_ETH_RX_COAL);
-#endif
-
-	mep->tx_int_coal = set_tx_coal(mep, MV643XX_ETH_TX_COAL);
+	set_rx_coal(mep, 0);
+	set_tx_coal(mep, 0);
 
 	/* Unmask phy and link status changes interrupts */
 	wrl(mep, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-- 
1.5.3.4


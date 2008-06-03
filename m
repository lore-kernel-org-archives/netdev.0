From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 10/39] mv643xx_eth: clarify irq masking and unmasking
Date: Tue,  3 Jun 2008 13:02:25 +0200
Message-ID: <1212490974-23719-11-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48748 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756347AbYFCMAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:43 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the nondescriptive names ETH_INT_UNMASK_ALL and
ETH_INT_UNMASK_ALL_EXT by names of the actual fields being masked
and unmasked in the various writes to the interrupt mask registers.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   61 +++++++++++++++++---------------------------
 1 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index bdb03f3..ffdd3fc 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -97,7 +97,14 @@ static char mv643xx_driver_version[] = "1.0";
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define  INT_RX				0x00000804
+#define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
+#define  INT_EXT_LINK			0x00100000
+#define  INT_EXT_PHY			0x00010000
+#define  INT_EXT_TX_ERROR_0		0x00000100
+#define  INT_EXT_TX_0			0x00000001
+#define  INT_EXT_TX			0x00000101
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
@@ -153,26 +160,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-#define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
-#define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
-
-#define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 2)
-#define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 9)
-#define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR)
-#define ETH_INT_CAUSE_EXT	0x00000002
-#define ETH_INT_UNMASK_ALL	(ETH_INT_CAUSE_RX | ETH_INT_CAUSE_EXT)
-
-#define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 0)
-#define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
-#define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR)
-#define ETH_INT_CAUSE_PHY	0x00010000
-#define ETH_INT_CAUSE_STATE	0x00100000
-#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY | \
-					ETH_INT_CAUSE_STATE)
-
-#define ETH_INT_MASK_ALL	0x00000000
-#define ETH_INT_MASK_ALL_EXT	0x00000000
-
 #define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
 #define PHY_WAIT_MICRO_SECONDS	10
 
@@ -832,7 +819,7 @@ static int mv643xx_poll(struct napi_struct *napi, int budget)
 		netif_rx_complete(dev, napi);
 		wrl(mp, INT_CAUSE(port_num), 0);
 		wrl(mp, INT_CAUSE_EXT(port_num), 0);
-		wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
+		wrl(mp, INT_MASK(port_num), INT_RX | INT_EXT);
 	}
 
 	return work_done;
@@ -988,7 +975,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
-	mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
+	mv643xx_eth_port_enable_tx(mp, 1);
 
 	mp->tx_desc_count += nr_frags + 1;
 }
@@ -1971,21 +1958,21 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = rdl(mp, INT_CAUSE(port_num)) & ETH_INT_UNMASK_ALL;
-	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
+	eth_int_cause = rdl(mp, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
+	if (eth_int_cause & INT_EXT) {
 		eth_int_cause_ext = rdl(mp, INT_CAUSE_EXT(port_num))
-						& ETH_INT_UNMASK_ALL_EXT;
+				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 		wrl(mp, INT_CAUSE_EXT(port_num), ~eth_int_cause_ext);
 	}
 
 	/* PHY status changed */
-	if (eth_int_cause_ext & (ETH_INT_CAUSE_PHY | ETH_INT_CAUSE_STATE)) {
+	if (eth_int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
 		struct ethtool_cmd cmd;
 
 		if (mii_link_ok(&mp->mii)) {
 			mii_ethtool_gset(&mp->mii, &cmd);
 			mv643xx_eth_update_pscr(dev, &cmd);
-			mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
+			mv643xx_eth_port_enable_tx(mp, 1);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
 				if (mp->tx_ring_size - mp->tx_desc_count >=
@@ -1999,9 +1986,9 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	}
 
 #ifdef MV643XX_NAPI
-	if (eth_int_cause & ETH_INT_CAUSE_RX) {
+	if (eth_int_cause & INT_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
+		wrl(mp, INT_MASK(port_num), 0x00000000);
 
 		/* wait for previous write to complete */
 		rdl(mp, INT_MASK(port_num));
@@ -2009,10 +1996,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 		netif_rx_schedule(dev, &mp->napi);
 	}
 #else
-	if (eth_int_cause & ETH_INT_CAUSE_RX)
+	if (eth_int_cause & INT_RX)
 		mv643xx_eth_receive_queue(dev, INT_MAX);
 #endif
-	if (eth_int_cause_ext & ETH_INT_CAUSE_TX)
+	if (eth_int_cause_ext & INT_EXT_TX)
 		mv643xx_eth_free_completed_tx_descs(dev);
 
 	/*
@@ -2136,7 +2123,7 @@ static void eth_port_start(struct net_device *dev)
 	wrl(mp, SDMA_CONFIG(port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
+	mv643xx_eth_port_enable_rx(mp, 1);
 
 	/* Disable port bandwidth limits by clearing MTU register */
 	wrl(mp, TX_BW_MTU(port_num), 0);
@@ -2383,10 +2370,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	wrl(mp, INT_MASK_EXT(port_num), ETH_INT_UNMASK_ALL_EXT);
+	wrl(mp, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 
 	/* Unmask RX buffer and TX end interrupt */
-	wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INT_MASK(port_num), INT_RX | INT_EXT);
 
 	return 0;
 
@@ -2453,7 +2440,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INT_MASK(port_num), 0x00000000);
 	/* wait for previous write to complete */
 	rdl(mp, INT_MASK(port_num));
 
@@ -2558,13 +2545,13 @@ static void mv643xx_netpoll(struct net_device *netdev)
 	struct mv643xx_private *mp = netdev_priv(netdev);
 	int port_num = mp->port_num;
 
-	wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INT_MASK(port_num), 0x00000000);
 	/* wait for previous write to complete */
 	rdl(mp, INT_MASK(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INT_MASK(port_num), INT_RX | INT_CAUSE_EXT);
 }
 #endif
 
-- 
1.5.3.4


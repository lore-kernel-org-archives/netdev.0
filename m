From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/5] mv643xx_eth: only unmask RX and TX_END interrupts for available queues
Date: Wed, 6 May 2009 15:02:01 +0200
Message-ID: <20090506130201.GJ24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: saeed@marvell.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40439 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936AbZEFMzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:55:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Bishara <saeed@marvell.com>

It is not a good idea to blindly unmask the RX and TX_END interrupts
for all eight queues on all mv643xx_eth hardware, since some variations
of the hardware have less than eight transmit/receive queues, and the
RX/TX_END interrupts for the queues they don't have can be in use by
other interrupt sources.

Signed-off-by: Saeed Bishara <saeed@marvell.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 05bb1c5..d583852 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -123,7 +123,9 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define TX_BW_BURST			0x005c
 #define INT_CAUSE			0x0060
 #define  INT_TX_END			0x07f80000
+#define  INT_TX_END_0			0x00080000
 #define  INT_RX				0x000003fc
+#define  INT_RX_0			0x00000004
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT			0x0064
 #define  INT_EXT_LINK_PHY		0x00110000
@@ -392,6 +394,7 @@ struct mv643xx_eth_private {
 	struct work_struct tx_timeout_task;
 
 	struct napi_struct napi;
+	u32 int_mask;
 	u8 oom;
 	u8 work_link;
 	u8 work_tx;
@@ -2058,15 +2061,16 @@ static int mv643xx_eth_collect_events(struct mv643xx_eth_private *mp)
 	u32 int_cause;
 	u32 int_cause_ext;
 
-	int_cause = rdlp(mp, INT_CAUSE) & (INT_TX_END | INT_RX | INT_EXT);
+	int_cause = rdlp(mp, INT_CAUSE) & mp->int_mask;
 	if (int_cause == 0)
 		return 0;
 
 	int_cause_ext = 0;
-	if (int_cause & INT_EXT)
+	if (int_cause & INT_EXT) {
+		int_cause &= ~INT_EXT;
 		int_cause_ext = rdlp(mp, INT_CAUSE_EXT);
+	}
 
-	int_cause &= INT_TX_END | INT_RX;
 	if (int_cause) {
 		wrlp(mp, INT_CAUSE, ~int_cause);
 		mp->work_tx_end |= ((int_cause & INT_TX_END) >> 19) &
@@ -2212,7 +2216,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		if (mp->oom)
 			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
 		napi_complete(napi);
-		wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
+		wrlp(mp, INT_MASK, mp->int_mask);
 	}
 
 	return work_done;
@@ -2366,6 +2370,8 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	skb_queue_head_init(&mp->rx_recycle);
 
+	mp->int_mask = INT_EXT;
+
 	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
@@ -2375,6 +2381,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 		}
 
 		rxq_refill(mp->rxq + i, INT_MAX);
+		mp->int_mask |= INT_RX_0 << i;
 	}
 
 	if (mp->oom) {
@@ -2389,12 +2396,13 @@ static int mv643xx_eth_open(struct net_device *dev)
 				txq_deinit(mp->txq + i);
 			goto out_free;
 		}
+		mp->int_mask |= INT_TX_END_0 << i;
 	}
 
 	port_start(mp);
 
 	wrlp(mp, INT_MASK_EXT, INT_EXT_LINK_PHY | INT_EXT_TX);
-	wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
+	wrlp(mp, INT_MASK, mp->int_mask);
 
 	return 0;
 
@@ -2538,7 +2546,7 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
+	wrlp(mp, INT_MASK, mp->int_mask);
 }
 #endif
 
-- 
1.5.6.4

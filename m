From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] arc_emac: Use net_device_stats from struct net_device
Date: Wed,  9 Jul 2014 11:07:37 +0200
Message-ID: <1404896857-29248-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:39105 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294AbaGIJHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 05:07:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a privatge copy of struct net_device_stats in struct
arc_emac_priv, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/arc/emac.h      |  2 --
 drivers/net/ethernet/arc/emac_main.c | 10 +++++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 53f85bf..8e7c1a1 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -110,7 +110,6 @@ struct buffer_state {
  * @bus:	Pointer to the current MII bus.
  * @regs:	Base address of EMAC memory-mapped control registers.
  * @napi:	Structure for NAPI.
- * @stats:	Network device statistics.
  * @rxbd:	Pointer to Rx BD ring.
  * @txbd:	Pointer to Tx BD ring.
  * @rxbd_dma:	DMA handle for Rx BD ring.
@@ -135,7 +134,6 @@ struct arc_emac_priv {
 	struct clk *clk;
 
 	struct napi_struct napi;
-	struct net_device_stats stats;
 
 	struct arc_emac_bd *rxbd;
 	struct arc_emac_bd *txbd;
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 18e2fac..6cfcd38 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -140,7 +140,7 @@ static const struct ethtool_ops arc_emac_ethtool_ops = {
 static void arc_emac_tx_clean(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &ndev->stats;
 	unsigned int i;
 
 	for (i = 0; i < TX_BD_NUM; i++) {
@@ -202,7 +202,7 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 
 	for (work_done = 0; work_done < budget; work_done++) {
 		unsigned int *last_rx_bd = &priv->last_rx_bd;
-		struct net_device_stats *stats = &priv->stats;
+		struct net_device_stats *stats = &ndev->stats;
 		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
 		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
 		unsigned int pktlen, info = le32_to_cpu(rxbd->info);
@@ -318,7 +318,7 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
 	struct arc_emac_priv *priv = netdev_priv(ndev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &ndev->stats;
 	unsigned int status;
 
 	status = arc_reg_get(priv, R_STATUS);
@@ -529,7 +529,7 @@ static int arc_emac_stop(struct net_device *ndev)
 static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &ndev->stats;
 	unsigned long miss, rxerr;
 	u8 rxcrc, rxfram, rxoflow;
 
@@ -565,7 +565,7 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	unsigned int len, *txbd_curr = &priv->txbd_curr;
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &ndev->stats;
 	__le32 *info = &priv->txbd[*txbd_curr].info;
 	dma_addr_t addr;
 
-- 
2.0.1

From: Shuyu Wei <wsy2220@gmail.com>
Subject: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Tue, 17 May 2016 23:25:20 +0800
Message-ID: <20160517152520.GA2750@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org
To: wxt@rock-chips.com, davem@davemloft.net, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34353 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcEQP0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 11:26:05 -0400
Received: by mail-pa0-f66.google.com with SMTP id yl2so2178294pac.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 08:26:04 -0700 (PDT)
Content-Disposition: inline; filename="mail2.txt"
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting the FOR_EMAC flag should be the last step of modifying the buffer
descriptor, or possible racing will occur.

The loop counter i in tx_clean() is not needed, and we need to make sure
it does not clear the finished txbds.

Signed-off-by: Shuyu Wei <sy.w@outlook.com>
---
Changes in v2:
- Remove loop counter in tx_clean and check for unfinished txbds (Ueimor)
- Use dma_wmb() to sync writes (Ueimor)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..df3dfef 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -153,9 +153,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &ndev->stats;
-	unsigned int i;
 
-	for (i = 0; i < TX_BD_NUM; i++) {
+	while (priv->txbd_dirty != priv->txbd_curr) {
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
 		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
@@ -685,13 +684,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	wmb();
 
 	skb_tx_timestamp(skb);
+	priv->tx_buff[*txbd_curr].skb = skb;
+
+	dma_wmb();
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
 	/* Make sure info word is set */
 	wmb();
 
-	priv->tx_buff[*txbd_curr].skb = skb;
 
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;

From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] moxa: fix missing unlock on error in moxart_mac_start_xmit()
Date: Sun, 18 Aug 2013 16:09:30 +0800
Message-ID: <CAPgLHd_pVD1wsDmL+bON35fif14xE5A6WsJjf+b1mywgrme-+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:46439 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192Ab3HRIJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 04:09:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing unlock before return from function moxart_mac_start_xmit()
in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index abd2c54..6eee686 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -314,6 +314,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	unsigned int len;
 	unsigned int tx_head = priv->tx_head;
 	u32 txdes1;
+	int ret = NETDEV_TX_BUSY;
 
 	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
 
@@ -321,7 +322,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (readl(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
 		priv->stats.tx_dropped++;
-		return NETDEV_TX_BUSY;
+		goto out_unlock;
 	}
 
 	len = skb->len > TX_BUF_SIZE ? TX_BUF_SIZE : skb->len;
@@ -330,7 +331,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 						   len, DMA_TO_DEVICE);
 	if (dma_mapping_error(&ndev->dev, priv->tx_mapping[tx_head])) {
 		netdev_err(ndev, "DMA mapping error\n");
-		return NETDEV_TX_BUSY;
+		goto out_unlock;
 	}
 
 	priv->tx_len[tx_head] = len;
@@ -360,10 +361,11 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	priv->tx_head = TX_NEXT(tx_head);
 
 	ndev->trans_start = jiffies;
-
+	ret = NETDEV_TX_OK;
+out_unlock:
 	spin_unlock_irq(&priv->txlock);
 
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 static struct net_device_stats *moxart_mac_get_stats(struct net_device *ndev)

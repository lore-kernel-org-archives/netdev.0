From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bcmgenet: log RX buffer allocation and RX/TX dma failures
Date: Wed, 19 Nov 2014 10:29:56 -0800
Message-ID: <1416421796-27657-3-git-send-email-f.fainelli@gmail.com>
References: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:40976 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332AbaKSSaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:30:12 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so764375pac.11
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:30:11 -0800 (PST)
In-Reply-To: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help troubleshoot heavy memory pressure conditions, add a bunch of
statistics counter to log RX buffer allocation and RX/TX DMA mapping
failures. These are reported like any other counters through the ethtool
stats interface.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 +++++++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  3 +++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index da1a2500c91c..fcbf1255ae5a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -613,6 +613,9 @@ static const struct bcmgenet_stats bcmgenet_gstrings_stats[] = {
 			UMAC_RBUF_OVFL_CNT),
 	STAT_GENET_MISC("rbuf_err_cnt", mib.rbuf_err_cnt, UMAC_RBUF_ERR_CNT),
 	STAT_GENET_MISC("mdf_err_cnt", mib.mdf_err_cnt, UMAC_MDF_ERR_CNT),
+	STAT_GENET_MIB_RX("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
+	STAT_GENET_MIB_RX("rx_dma_failed", mib.rx_dma_failed),
+	STAT_GENET_MIB_TX("tx_dma_failed", mib.tx_dma_failed),
 };
 
 #define BCMGENET_STATS_LEN	ARRAY_SIZE(bcmgenet_gstrings_stats)
@@ -989,6 +992,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
+		priv->mib.tx_dma_failed++;
 		netif_err(priv, tx_err, dev, "Tx DMA map failed\n");
 		dev_kfree_skb(skb);
 		return ret;
@@ -1035,6 +1039,7 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 				   skb_frag_size(frag), DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
+		priv->mib.tx_dma_failed++;
 		netif_err(priv, tx_err, dev, "%s: Tx DMA map failed\n",
 			  __func__);
 		return ret;
@@ -1231,6 +1236,7 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
 				 priv->rx_buf_len, DMA_FROM_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
+		priv->mib.rx_dma_failed++;
 		bcmgenet_free_cb(cb);
 		netif_err(priv, rx_err, priv->dev,
 			  "%s DMA map failed\n", __func__);
@@ -1397,8 +1403,10 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		/* refill RX path on the current control block */
 refill:
 		err = bcmgenet_rx_refill(priv, cb);
-		if (err)
+		if (err) {
+			priv->mib.alloc_rx_buff_failed++;
 			netif_err(priv, rx_err, dev, "Rx refill failed\n");
+		}
 
 		rxpktprocessed++;
 		priv->rx_read_ptr++;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 31b2da5f9b82..c4ca7282a601 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -143,6 +143,9 @@ struct bcmgenet_mib_counters {
 	u32	rbuf_ovflow_cnt;
 	u32	rbuf_err_cnt;
 	u32	mdf_err_cnt;
+	u32	alloc_rx_buff_failed;
+	u32	rx_dma_failed;
+	u32	tx_dma_failed;
 };
 
 #define UMAC_HD_BKP_CTRL		0x004
-- 
1.9.1

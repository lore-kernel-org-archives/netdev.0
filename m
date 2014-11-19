From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: systemport: log RX buffer allocation and RX/TX DMA failures
Date: Wed, 19 Nov 2014 10:29:55 -0800
Message-ID: <1416421796-27657-2-git-send-email-f.fainelli@gmail.com>
References: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42469 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328AbaKSSaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:30:11 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so753156pad.38
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:30:10 -0800 (PST)
In-Reply-To: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help troubleshoot heavy memory pressure conditions, add a bunch of
statistics counter to log RX buffer allocation and RX/TX DMA mapping
failures. These are reported like any other counters through the ethtool
stats interface.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 10 +++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h |  3 +++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 3cb241155dac..c1d255972dae 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -274,6 +274,9 @@ static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 	/* RBUF misc statistics */
 	STAT_RBUF("rbuf_ovflow_cnt", mib.rbuf_ovflow_cnt, RBUF_OVFL_DISC_CNTR),
 	STAT_RBUF("rbuf_err_cnt", mib.rbuf_err_cnt, RBUF_ERR_PKT_CNTR),
+	STAT_MIB_RX("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
+	STAT_MIB_RX("rx_dma_failed", mib.rx_dma_failed),
+	STAT_MIB_TX("tx_dma_failed", mib.tx_dma_failed),
 };
 
 #define BCM_SYSPORT_STATS_LEN	ARRAY_SIZE(bcm_sysport_gstrings_stats)
@@ -477,6 +480,7 @@ static int bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
 				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
+		priv->mib.rx_dma_failed++;
 		bcm_sysport_free_cb(cb);
 		netif_err(priv, rx_err, ndev, "DMA mapping failure\n");
 		return ret;
@@ -526,6 +530,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	unsigned int p_index;
 	u16 len, status;
 	struct bcm_rsb *rsb;
+	int ret;
 
 	/* Determine how much we should process since last call */
 	p_index = rdma_readl(priv, RDMA_PROD_INDEX);
@@ -620,7 +625,9 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 
 		napi_gro_receive(&priv->napi, skb);
 refill:
-		bcm_sysport_rx_refill(priv, cb);
+		ret = bcm_sysport_rx_refill(priv, cb);
+		if (ret)
+			priv->mib.alloc_rx_buff_failed++;
 	}
 
 	return processed;
@@ -973,6 +980,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
+		priv->mib.tx_dma_failed++;
 		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
 			  skb->data, skb_len);
 		ret = NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index b08dab828101..fc19417d82a5 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -557,6 +557,9 @@ struct bcm_sysport_mib {
 	u32 rxchk_other_pkt_disc;
 	u32 rbuf_ovflow_cnt;
 	u32 rbuf_err_cnt;
+	u32 alloc_rx_buff_failed;
+	u32 rx_dma_failed;
+	u32 tx_dma_failed;
 };
 
 /* HW maintains a large list of counters */
-- 
1.9.1

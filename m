From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 15/17] stmmac: do not perform zero-copy for rx frames
Date: Mon, 29 Feb 2016 14:27:41 +0100
Message-ID: <1456752463-27128-16-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45938 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753144AbcB2N3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:29:03 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDS8pe019736
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:01 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqg8-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:01 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 18D4C23
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:58 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id AB43AF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:56 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch is to allow this driver to copy tiny frames during the reception
process. This is giving more stability while stressing the driver on STi
embedded systems.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 0d01f3e..221f5cd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -74,6 +74,7 @@ struct stmmac_priv {
 	unsigned int cur_rx;
 	unsigned int dirty_rx;
 	unsigned int dma_buf_sz;
+	unsigned int rx_copybreak;
 	u32 rx_riwt;
 	int hwts_rx_en;
 	dma_addr_t *rx_skbuff_dma;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index c803d4c..3c7928e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -781,6 +781,43 @@ static int stmmac_get_ts_info(struct net_device *dev,
 		return ethtool_op_get_ts_info(dev, info);
 }
 
+static int stmmac_get_tunable(struct net_device *dev,
+			      const struct ethtool_tunable *tuna, void *data)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = priv->rx_copybreak;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int stmmac_set_tunable(struct net_device *dev,
+			      const struct ethtool_tunable *tuna,
+			      const void *data)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		priv->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
@@ -803,6 +840,8 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.get_ts_info = stmmac_get_ts_info,
 	.get_coalesce = stmmac_get_coalesce,
 	.set_coalesce = stmmac_set_coalesce,
+	.get_tunable = stmmac_get_tunable,
+	.set_tunable = stmmac_set_tunable,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3cc1355..2ffe8dd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -91,6 +91,8 @@ static int buf_sz = DEFAULT_BUFSIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
+#define	STMMAC_RX_COPYBREAK	256
+
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
@@ -1808,6 +1810,7 @@ static int stmmac_open(struct net_device *dev)
 	priv->xstats.threshold = tc;
 
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
+	priv->rx_copybreak = STMMAC_RX_COPYBREAK;
 
 	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
@@ -2159,8 +2162,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
-
-			if (unlikely(skb == NULL))
+			if (unlikely(!skb))
 				break;
 
 			priv->rx_skbuff[entry] = skb;
@@ -2282,23 +2284,52 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 					pr_debug("\tframe size %d, COE: %d\n",
 						 frame_len, status);
 			}
-			skb = priv->rx_skbuff[entry];
-			if (unlikely(!skb)) {
-				pr_err("%s: Inconsistent Rx descriptor chain\n",
-				       priv->dev->name);
-				priv->dev->stats.rx_dropped++;
-				break;
+
+			if (unlikely(frame_len < priv->rx_copybreak)) {
+				skb = netdev_alloc_skb_ip_align(priv->dev,
+								frame_len);
+				if (unlikely(!skb)) {
+					if (net_ratelimit())
+						dev_warn(priv->device,
+							 "packet dropped\n");
+					priv->dev->stats.rx_dropped++;
+					break;
+				}
+
+				dma_sync_single_for_cpu(priv->device,
+							priv->rx_skbuff_dma
+							[entry], frame_len,
+							DMA_FROM_DEVICE);
+				skb_copy_to_linear_data(skb,
+							priv->
+							rx_skbuff[entry]->data,
+							frame_len);
+
+				skb_put(skb, frame_len);
+				dma_sync_single_for_device(priv->device,
+							   priv->rx_skbuff_dma
+							   [entry], frame_len,
+							   DMA_FROM_DEVICE);
+			} else {
+				skb = priv->rx_skbuff[entry];
+				if (unlikely(!skb)) {
+					pr_err("%s: Inconsistent Rx chain\n",
+					       priv->dev->name);
+					priv->dev->stats.rx_dropped++;
+					break;
+				}
+				prefetch(skb->data - NET_IP_ALIGN);
+				priv->rx_skbuff[entry] = NULL;
+
+				skb_put(skb, frame_len);
+				dma_unmap_single(priv->device,
+						 priv->rx_skbuff_dma[entry],
+						 priv->dma_buf_sz,
+						 DMA_FROM_DEVICE);
 			}
-			prefetch(skb->data - NET_IP_ALIGN);
-			priv->rx_skbuff[entry] = NULL;
 
 			stmmac_get_rx_hwtstamp(priv, entry, skb);
 
-			skb_put(skb, frame_len);
-			dma_unmap_single(priv->device,
-					 priv->rx_skbuff_dma[entry],
-					 priv->dma_buf_sz, DMA_FROM_DEVICE);
-
 			if (netif_msg_pktdata(priv)) {
 				pr_debug("frame received (%dbytes)", frame_len);
 				print_pkt(skb->data, frame_len);
-- 
1.9.1

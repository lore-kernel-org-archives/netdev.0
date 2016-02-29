From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 16/17] stmmac: tune rx copy via threshold.
Date: Mon, 29 Feb 2016 14:27:42 +0100
Message-ID: <1456752463-27128-17-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:2296 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753852AbcB2N3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:29:06 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDOqBF027994
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:05 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b1t8k349-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:05 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 6118E22
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:29:01 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 0886AF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:29:00 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

There is a threshold now used to also limit the skb allocation
when use zero-copy. This is to avoid that there are incoherence
in the ring due to a failure on skb allocation under very
aggressive testing and under low memory conditions.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 221f5cd..d6c244f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -75,6 +75,7 @@ struct stmmac_priv {
 	unsigned int dirty_rx;
 	unsigned int dma_buf_sz;
 	unsigned int rx_copybreak;
+	unsigned int rx_zeroc_thresh;
 	u32 rx_riwt;
 	int hwts_rx_en;
 	dma_addr_t *rx_skbuff_dma;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2ffe8dd..4c5ce98 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -72,6 +72,7 @@ module_param(phyaddr, int, S_IRUGO);
 MODULE_PARM_DESC(phyaddr, "Physical device address");
 
 #define STMMAC_TX_THRESH	(DMA_TX_SIZE / 4)
+#define STMMAC_RX_THRESH	(DMA_RX_SIZE / 4)
 
 static int flow_ctrl = FLOW_OFF;
 module_param(flow_ctrl, int, S_IRUGO | S_IWUSR);
@@ -2138,6 +2139,14 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
 }
 
 
+static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
+{
+	if (priv->rx_zeroc_thresh < STMMAC_RX_THRESH)
+		return 0;
+
+	return 1;
+}
+
 /**
  * stmmac_rx_refill - refill used skb preallocated buffers
  * @priv: driver private structure
@@ -2162,8 +2171,15 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
-			if (unlikely(!skb))
+			if (unlikely(!skb)) {
+				/* so for a while no zero-copy! */
+				priv->rx_zeroc_thresh = STMMAC_RX_THRESH;
+				if (unlikely(net_ratelimit()))
+					dev_err(priv->device,
+						"fail to alloc skb entry %d\n",
+						entry);
 				break;
+			}
 
 			priv->rx_skbuff[entry] = skb;
 			priv->rx_skbuff_dma[entry] =
@@ -2179,9 +2195,13 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			priv->hw->mode->refill_desc3(priv, p);
 
+			if (priv->rx_zeroc_thresh > 0)
+				priv->rx_zeroc_thresh--;
+
 			if (netif_msg_rx_status(priv))
 				pr_debug("\trefill entry #%d\n", entry);
 		}
+
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
 		wmb();
@@ -2285,7 +2305,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 						 frame_len, status);
 			}
 
-			if (unlikely(frame_len < priv->rx_copybreak)) {
+			if (unlikely((frame_len < priv->rx_copybreak) ||
+				     stmmac_rx_threshold_count(priv))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -2320,6 +2341,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				}
 				prefetch(skb->data - NET_IP_ALIGN);
 				priv->rx_skbuff[entry] = NULL;
+				priv->rx_zeroc_thresh++;
 
 				skb_put(skb, frame_len);
 				dma_unmap_single(priv->device,
-- 
1.9.1

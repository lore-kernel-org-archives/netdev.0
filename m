From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 17/18] stmmac: tune rx copy via threshold.
Date: Mon, 4 Jan 2016 14:07:02 +0100
Message-ID: <1451912823-5245-18-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:44353 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753829AbcADMyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:35 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CrFsJ022688
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:33 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 2034vyx79t-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:33 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 21BCA34
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:49 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 533F250FC
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:31 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a threshold now used to also limit the skb allocation
when use zero-copy. This is to avoid that there are incoherence
in the ring due to a failure on skb allocation under very
aggressive testing and under low memory conditions.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   26 +++++++++++++++++++-
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c94ae65..9c62b86 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -77,6 +77,7 @@ struct stmmac_priv {
 	unsigned int dma_rx_size;
 	unsigned int dma_buf_sz;
 	unsigned int rx_copybreak;
+	unsigned int rx_zeroc_thresh;
 	u32 rx_riwt;
 	int hwts_rx_en;
 	dma_addr_t *rx_skbuff_dma;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b431046..71bda4e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -201,6 +201,7 @@ static void print_pkt(unsigned char *buf, int len)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define STMMAC_TX_THRESH(x)	(x->dma_tx_size/4)
+#define STMMAC_RX_THRESH(x)	(x->dma_rx_size / 4)
 
 static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 {
@@ -2173,6 +2174,14 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
 }
 
 
+static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
+{
+	if (priv->rx_zeroc_thresh < STMMAC_RX_THRESH(priv))
+		return 0;
+
+	return 1;
+}
+
 /**
  * stmmac_rx_refill - refill used skb preallocated buffers
  * @priv: driver private structure
@@ -2198,8 +2207,15 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
-			if (unlikely(!skb))
+			if (unlikely(!skb)) {
+				/* so for a while no zero-copy! */
+				priv->rx_zeroc_thresh = STMMAC_RX_THRESH(priv);
+				if (unlikely(net_ratelimit()))
+					dev_err(priv->device,
+						"fail to alloc skb entry %d\n",
+						entry);
 				break;
+			}
 
 			priv->rx_skbuff[entry] = skb;
 			priv->rx_skbuff_dma[entry] =
@@ -2215,9 +2231,13 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
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
@@ -2322,7 +2342,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 						 frame_len, status);
 			}
 
-			if (unlikely(frame_len < priv->rx_copybreak)) {
+			if (unlikely((frame_len < priv->rx_copybreak) ||
+				     stmmac_rx_threshold_count(priv))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -2357,6 +2378,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				}
 				prefetch(skb->data - NET_IP_ALIGN);
 				priv->rx_skbuff[entry] = NULL;
+				priv->rx_zeroc_thresh++;
 
 				skb_put(skb, frame_len);
 				dma_unmap_single(priv->device,
-- 
1.7.4.4

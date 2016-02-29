From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 05/17] stmmac: add length field to dma data
Date: Mon, 29 Feb 2016 14:27:31 +0100
Message-ID: <1456752463-27128-6-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:61192 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755279AbcB2N2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:31 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDQNGC032766
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:30 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx07-00178001.pphosted.com with ESMTP id 21b254tvcv-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:29 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 8BA7C23
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:20 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 31D7CF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:19 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Currently, the code pulls out the length field when
unmapping a buffer directly from the descriptor. This will result
in an uncached read to a dma_alloc_coherent() region. There is no
need to do this, so this patch simply puts the value directly into
a data structure which will hit the cache.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 2763772..7fa7ab0d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -49,6 +49,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	if (dma_mapping_error(priv->device, desc->des2))
 		return -1;
 	priv->tx_skbuff_dma[entry].buf = desc->des2;
+	priv->tx_skbuff_dma[entry].len = bmax;
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
 
 	while (len != 0) {
@@ -63,6 +64,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			if (dma_mapping_error(priv->device, desc->des2))
 				return -1;
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
+			priv->tx_skbuff_dma[entry].len = bmax;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
@@ -75,6 +77,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			if (dma_mapping_error(priv->device, desc->des2))
 				return -1;
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
+			priv->tx_skbuff_dma[entry].len = len;
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 4358a87..cfc2f24 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -56,6 +56,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = bmax;
+
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE);
@@ -73,6 +75,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		if (dma_mapping_error(priv->device, desc->des2))
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = len;
+
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 						STMMAC_RING_MODE);
@@ -84,6 +88,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		if (dma_mapping_error(priv->device, desc->des2))
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = nopaged_len;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 7ae7c64..c497460 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -45,6 +45,7 @@ struct stmmac_resources {
 struct stmmac_tx_info {
 	dma_addr_t buf;
 	bool map_as_page;
+	unsigned len;
 };
 
 struct stmmac_priv {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index eb555f0..90a946f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1093,6 +1093,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		p->des2 = 0;
 		priv->tx_skbuff_dma[i].buf = 0;
 		priv->tx_skbuff_dma[i].map_as_page = false;
+		priv->tx_skbuff_dma[i].len = 0;
 		priv->tx_skbuff[i] = NULL;
 	}
 
@@ -1136,12 +1137,12 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 			if (priv->tx_skbuff_dma[i].map_as_page)
 				dma_unmap_page(priv->device,
 					       priv->tx_skbuff_dma[i].buf,
-					       priv->hw->desc->get_tx_len(p),
+					       priv->tx_skbuff_dma[i].len,
 					       DMA_TO_DEVICE);
 			else
 				dma_unmap_single(priv->device,
 						 priv->tx_skbuff_dma[i].buf,
-						 priv->hw->desc->get_tx_len(p),
+						 priv->tx_skbuff_dma[i].len,
 						 DMA_TO_DEVICE);
 		}
 
@@ -1347,12 +1348,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			if (priv->tx_skbuff_dma[entry].map_as_page)
 				dma_unmap_page(priv->device,
 					       priv->tx_skbuff_dma[entry].buf,
-					       priv->hw->desc->get_tx_len(p),
+					       priv->tx_skbuff_dma[entry].len,
 					       DMA_TO_DEVICE);
 			else
 				dma_unmap_single(priv->device,
 						 priv->tx_skbuff_dma[entry].buf,
-						 priv->hw->desc->get_tx_len(p),
+						 priv->tx_skbuff_dma[entry].len,
 						 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry].buf = 0;
 			priv->tx_skbuff_dma[entry].map_as_page = false;
@@ -1986,6 +1987,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (dma_mapping_error(priv->device, desc->des2))
 			goto dma_map_err;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = nopaged_len;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
 	} else {
@@ -2014,6 +2016,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].map_as_page = true;
+		priv->tx_skbuff_dma[entry].len = len;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode);
 		wmb();
-- 
1.9.1

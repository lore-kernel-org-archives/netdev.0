From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 05/18] stmmac: add length field to dma data
Date: Wed, 9 Dec 2015 09:37:41 +0100
Message-ID: <1449650274-14896-6-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:10401 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753352AbbLII2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:13 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tB98BppX031185
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:11 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ynn3af6yn-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:11 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E0E443F
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:34 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5559D4F06
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:10 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the code pulls out the length field when
unmapping a buffer directly from the descriptor. This will result
in an uncached read to a dma_alloc_coherent() region. There is no
need to do this, so this patch simply puts the value directly into
a data structure which will hit the cache.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 +++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   11 +++++++----
 4 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 399a7ed..688795e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -50,6 +50,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	if (dma_mapping_error(priv->device, desc->des2))
 		return -1;
 	priv->tx_skbuff_dma[entry].buf = desc->des2;
+	priv->tx_skbuff_dma[entry].len = bmax;
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
 
 	while (len != 0) {
@@ -65,6 +66,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			if (dma_mapping_error(priv->device, desc->des2))
 				return -1;
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
+			priv->tx_skbuff_dma[entry].len = bmax;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
@@ -77,6 +79,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			if (dma_mapping_error(priv->device, desc->des2))
 				return -1;
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
+			priv->tx_skbuff_dma[entry].len = len;
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 2560855..3300029 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -57,6 +57,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = bmax;
+
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE);
@@ -75,6 +77,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		if (dma_mapping_error(priv->device, desc->des2))
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = len;
+
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 						STMMAC_RING_MODE);
@@ -86,6 +90,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		if (dma_mapping_error(priv->device, desc->des2))
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = nopaged_len;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 1f3b33a..8517a04 100644
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
index 366da1f..f9baf5d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1110,6 +1110,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		p->des2 = 0;
 		priv->tx_skbuff_dma[i].buf = 0;
 		priv->tx_skbuff_dma[i].map_as_page = false;
+		priv->tx_skbuff_dma[i].len = 0;
 		priv->tx_skbuff[i] = NULL;
 	}
 
@@ -1153,12 +1154,12 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
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
 
@@ -1367,12 +1368,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
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
@@ -2012,6 +2013,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (dma_mapping_error(priv->device, desc->des2))
 			goto dma_map_err;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
+		priv->tx_skbuff_dma[entry].len = nopaged_len;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
 	} else {
@@ -2041,6 +2043,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].map_as_page = true;
+		priv->tx_skbuff_dma[entry].len = len;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode);
 		wmb();
-- 
1.7.4.4

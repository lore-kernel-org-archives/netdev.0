From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 13/18] stmmac: perf, remove modulo in stmmac_rx()
Date: Mon, 4 Jan 2016 14:06:58 +0100
Message-ID: <1451912823-5245-14-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:18837 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753766AbcADMyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:20 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CrGRT022844
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:19 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 2034vyx78p-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:19 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6844431
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:35 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A1A3250F6
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:17 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indexes into the ring buffer are always incremented, and
the entry is accessed via doing a modulo to find the "real" index.
Modulo is an expensive operation.

This patch replaces the modulo with a simple if clamp.
It helps improve stmmac RX path as it's being called inside RX loop.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   28 ++++++++++++++++++---
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5bb2804..4a75f79 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -212,6 +212,18 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 	return avail;
 }
 
+static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
+{
+	unsigned dirty;
+
+	if (priv->dirty_rx <= priv->cur_rx)
+		dirty = priv->cur_rx - priv->dirty_rx;
+	else
+		dirty = priv->dma_rx_size - priv->dirty_rx + priv->cur_rx;
+
+	return dirty;
+}
+
 /**
  * stmmac_hw_fix_mac_speed - callback for speed selection
  * @priv: driver private structure
@@ -2162,9 +2174,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 {
 	unsigned int rxsize = priv->dma_rx_size;
 	int bfsize = priv->dma_buf_sz;
+	unsigned int entry = priv->dirty_rx;
+	int dirty = stmmac_rx_dirty(priv);
 
-	for (; priv->cur_rx - priv->dirty_rx > 0; priv->dirty_rx++) {
-		unsigned int entry = priv->dirty_rx % rxsize;
+	while (dirty-- > 0) {
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
@@ -2200,6 +2213,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
 		wmb();
+
+		if (unlikely(++priv->dirty_rx >= rxsize))
+			priv->dirty_rx = 0;
+		entry = priv->dirty_rx;
 	}
 }
 
@@ -2213,7 +2230,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 static int stmmac_rx(struct stmmac_priv *priv, int limit)
 {
 	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int entry = priv->cur_rx % rxsize;
+	unsigned int entry = priv->cur_rx;
 	unsigned int next_entry;
 	unsigned int count = 0;
 	int coe = priv->hw->rx_csum;
@@ -2243,7 +2260,10 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		count++;
 
-		next_entry = (++priv->cur_rx) % rxsize;
+		if (unlikely(++priv->cur_rx >= rxsize))
+			priv->cur_rx = 0;
+		next_entry = priv->cur_rx;
+
 		if (priv->extend_desc)
 			prefetch(priv->dma_erx + next_entry);
 		else
-- 
1.7.4.4

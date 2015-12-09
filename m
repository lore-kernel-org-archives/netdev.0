From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 13/18] stmmac: perf, remove modulo in stmmac_rx()
Date: Wed, 9 Dec 2015 09:37:49 +0100
Message-ID: <1449650274-14896-14-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:23359 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753355AbbLII2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:38 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tB98DXSs023467
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:37 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1yndrgrxrq-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:37 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0FD2731
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:00 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 795924F61
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:35 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
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
index 0a39331..52ac648 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -211,6 +211,18 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
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
@@ -2165,9 +2177,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
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
@@ -2203,6 +2216,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
 		wmb();
+
+		if (unlikely(++priv->dirty_rx >= rxsize))
+			priv->dirty_rx = 0;
+		entry = priv->dirty_rx;
 	}
 }
 
@@ -2216,7 +2233,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 static int stmmac_rx(struct stmmac_priv *priv, int limit)
 {
 	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int entry = priv->cur_rx % rxsize;
+	unsigned int entry = priv->cur_rx;
 	unsigned int next_entry;
 	unsigned int count = 0;
 	int coe = priv->hw->rx_csum;
@@ -2246,7 +2263,10 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
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

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 04/18] stmmac: remove modulo in stmmac_xmit()
Date: Mon, 4 Jan 2016 14:06:49 +0100
Message-ID: <1451912823-5245-5-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David McKay <david.mckay@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:9152 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753608AbcADMyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:09 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CrGNL022850
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:08 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 2034vyx77s-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:07 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3F1B83D
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:24 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 75AC350F5
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:06 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indexes into the ring buffer are always incremented, and
the entry is accessed via doing a modulo to find the "real" index.

I have changed this for 3 reasons:

* It is inefficient, modulo is an expensive operation.
* It is also broken when the counter wraps.
* It makes my head hurt trying to cope with huge numbers

This patch replaces the modulo with a simple if clamp.

Signed-off-by: David McKay <david.mckay@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   15 ++++++----
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    7 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   31 +++++++++++++++-----
 3 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index cf28dab..399a7ed 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -32,7 +32,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
 	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
+	unsigned int entry = priv->cur_tx;
 	struct dma_desc *desc = priv->dma_tx + entry;
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int bmax;
@@ -54,7 +54,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 	while (len != 0) {
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		if (++entry >= txsize)
+			entry = 0;
 		desc = priv->dma_tx + entry;
 
 		if (len > bmax) {
@@ -82,6 +83,9 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			len = 0;
 		}
 	}
+
+	priv->cur_tx = entry;
+
 	return entry;
 }
 
@@ -151,10 +155,9 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
 		 */
-		p->des3 = (unsigned int)(priv->dma_tx_phy +
-					 (((priv->dirty_tx + 1) %
-					   priv->dma_tx_size) *
-					  sizeof(struct dma_desc)));
+		p->des3 = (unsigned int)((priv->dma_tx_phy +
+					  priv->dirty_tx + 1) *
+					  sizeof(struct dma_desc));
 }
 
 const struct stmmac_mode_ops chain_mode_ops = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 5dd50c6..2560855 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -32,7 +32,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
 	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
+	unsigned int entry = priv->cur_tx;
 	struct dma_desc *desc;
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int bmax, len;
@@ -62,7 +62,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 		wmb();
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		if (++entry >= txsize)
+			entry = 0;
 
 		if (priv->extend_desc)
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
@@ -90,6 +91,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 	}
 
+	priv->cur_tx = entry;
+
 	return entry;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 89c2626..4c73c09 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -202,7 +202,14 @@ static void print_pkt(unsigned char *buf, int len)
 
 static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 {
-	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
+	unsigned avail;
+
+	if (priv->dirty_tx > priv->cur_tx)
+		avail = priv->dirty_tx - priv->cur_tx - 1;
+	else
+		avail = priv->dma_tx_size - priv->cur_tx + priv->dirty_tx - 1;
+
+	return avail;
 }
 
 /**
@@ -1312,16 +1319,16 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
  */
 static void stmmac_tx_clean(struct stmmac_priv *priv)
 {
-	unsigned int txsize = priv->dma_tx_size;
 	unsigned int bytes_compl = 0, pkts_compl = 0;
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int entry = priv->dirty_tx;
 
 	spin_lock(&priv->tx_lock);
 
 	priv->xstats.tx_clean++;
 
-	while (priv->dirty_tx != priv->cur_tx) {
+	while (entry != priv->cur_tx) {
 		int last;
-		unsigned int entry = priv->dirty_tx % txsize;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
 		struct dma_desc *p;
 
@@ -1378,7 +1385,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 		priv->hw->desc->release_tx_desc(p, priv->mode);
 
-		priv->dirty_tx++;
+		if (++entry >= txsize)
+			entry = 0;
+		priv->dirty_tx = entry;
 	}
 
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
@@ -1978,7 +1987,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
 
-	entry = priv->cur_tx % txsize;
+	entry = priv->cur_tx;
+
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
@@ -2013,7 +2023,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		int len = skb_frag_size(frag);
 
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		if (++entry >= txsize)
+			entry = 0;
+
 		if (priv->extend_desc)
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
 		else
@@ -2056,7 +2068,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->hw->desc->set_tx_owner(first);
 	wmb();
 
-	priv->cur_tx++;
+	if (++entry >= txsize)
+		entry = 0;
+
+	priv->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
 		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-- 
1.7.4.4

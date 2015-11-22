From: Shunqian Zheng <zhengsq@rock-chips.com>
Subject: [PATCH v1] net: stmmac: Free rx_skbufs before realloc
Date: Sun, 22 Nov 2015 16:44:18 +0800
Message-ID: <1448181858-5935-2-git-send-email-zhengsq@rock-chips.com>
References: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
Cc: linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, dianders@google.com,
	ZhengShunQian <zhengsq@rock-chips.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ZhengShunQian <zhengsq@rock-chips.com>

The init_dma_desc_rings() may realloc the rx_skbuff[] when
suspend and resume. This patch free the rx_skbuff[] before
reallocing memory.

Signed-off-by: ZhengShunQian <zhengsq@rock-chips.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 64d8aa4..2af1ed9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1022,6 +1022,14 @@ static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
 	priv->rx_skbuff[i] = NULL;
 }
 
+static void dma_free_rx_skbufs(struct stmmac_priv *priv)
+{
+	int i;
+
+	for (i = 0; i < priv->dma_rx_size; i++)
+		stmmac_free_rx_buffers(priv, i);
+}
+
 /**
  * init_dma_desc_rings - init the RX/TX descriptor rings
  * @dev: net device structure
@@ -1058,6 +1066,8 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		/* RX INITIALIZATION */
 		pr_debug("\tSKB addresses:\nskb\t\tskb data\tdma data\n");
 	}
+
+	dma_free_rx_skbufs(priv);
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p;
 		if (priv->extend_desc)
@@ -1122,14 +1132,6 @@ err_init_rx_buffers:
 	return ret;
 }
 
-static void dma_free_rx_skbufs(struct stmmac_priv *priv)
-{
-	int i;
-
-	for (i = 0; i < priv->dma_rx_size; i++)
-		stmmac_free_rx_buffers(priv, i);
-}
-
 static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 {
 	int i;
-- 
1.9.1

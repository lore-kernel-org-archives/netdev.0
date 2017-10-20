From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 2/3] net: stmmac: Fix stmmac_get_rx_hwtstamp()
Date: Fri, 20 Oct 2017 14:37:35 +0100
Message-ID: <7de5fdcba82b9196be8ffd5e38fe93bdf20a98e8.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using GMAC4 the valid timestamp is from CTX next desc but
we are passing the previous desc to get_rx_timestamp_status()
callback.

Fix this and while at it rework a little bit the function logic.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f7b7906..0d3fd3b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -473,19 +473,18 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 				   struct dma_desc *np, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamp = NULL;
+	struct dma_desc *desc = p;
 	u64 ns;
 
 	if (!priv->hwts_rx_en)
 		return;
+	/* For GMAC4, the valid timestamp is from CTX next desc. */
+	if (priv->plat->has_gmac4)
+		desc = np;
 
 	/* Check if timestamp is available */
-	if (priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
-		/* For GMAC4, the valid timestamp is from CTX next desc. */
-		if (priv->plat->has_gmac4)
-			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
-		else
-			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
-
+	if (priv->hw->desc->get_rx_timestamp_status(desc, priv->adv_ts)) {
+		ns = priv->hw->desc->get_timestamp(desc, priv->adv_ts);
 		netdev_dbg(priv->dev, "get valid RX hw timestamp %llu\n", ns);
 		shhwtstamp = skb_hwtstamps(skb);
 		memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
-- 
1.9.1

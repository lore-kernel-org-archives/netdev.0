From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/3] net: ethernet: ti: cpsw: simplify submit routine
Date: Fri,  5 Aug 2016 00:14:30 +0300
Message-ID: <1470345272-874-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As second net dev is created only in case of dual_emac mode, port
number can be figured out in simpler way. Also no need to pass
redundant ndev struct.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c51f346..8972bf6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1065,19 +1065,11 @@ static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
 	return usage_count;
 }
 
-static inline int cpsw_tx_packet_submit(struct net_device *ndev,
-			struct cpsw_priv *priv, struct sk_buff *skb)
+static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
+					struct sk_buff *skb)
 {
-	if (!priv->data.dual_emac)
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 0);
-
-	if (ndev == cpsw_get_slave_ndev(priv, 0))
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 1);
-	else
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 2);
+	return cpdma_chan_submit(priv->txch, skb, skb->data, skb->len,
+				 priv->emac_port + priv->data.dual_emac);
 }
 
 static inline void cpsw_add_dual_emac_def_ale_entries(
@@ -1406,7 +1398,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	ret = cpsw_tx_packet_submit(ndev, priv, skb);
+	ret = cpsw_tx_packet_submit(priv, skb);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
 		goto fail;
-- 
1.9.1

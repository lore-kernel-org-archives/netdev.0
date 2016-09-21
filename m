From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 3/6] net/faraday: Adapt for Aspeed SoCs
Date: Thu, 22 Sep 2016 08:35:00 +0930
Message-ID: <20160921230503.23309-4-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RXDES and TXDES registers bits in the ftgmac100 indicates EDO{R,T}R
at bit position 15 for the Faraday Tech IP. However, the version of this
IP present in the Aspeed SoCs has these bits at position 30 in the
registers.

It appers that ast2400 SoCs support both positions, with the 15th bit
marked as reserved but still functional. In the ast2500 this bit is
reused for another function, so we need a work around.

This was confirmed with engineers from Aspeed that using bit 30 is
correct for both the ast2400 and ast2500 SoCs.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 62a88d1a1f99..47f512224b57 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1345,9 +1345,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv->netdev = netdev;
 	priv->dev = &pdev->dev;
 
-	priv->rxdes0_edorr_mask = BIT(15);
-	priv->txdes0_edotr_mask = BIT(15);
-
 	spin_lock_init(&priv->tx_lock);
 
 	/* initialize NAPI */
@@ -1381,6 +1378,16 @@ static int ftgmac100_probe(struct platform_device *pdev)
 			      FTGMAC100_INT_PHYSTS_CHG |
 			      FTGMAC100_INT_RPKT_BUF |
 			      FTGMAC100_INT_NO_RXBUF);
+
+	if (of_machine_is_compatible("aspeed,ast2400") ||
+	    of_machine_is_compatible("aspeed,ast2500")) {
+		priv->rxdes0_edorr_mask = BIT(30);
+		priv->txdes0_edotr_mask = BIT(30);
+	} else {
+		priv->rxdes0_edorr_mask = BIT(15);
+		priv->txdes0_edotr_mask = BIT(15);
+	}
+
 	if (pdev->dev.of_node &&
 	    of_get_property(pdev->dev.of_node, "use-ncsi", NULL)) {
 		if (!IS_ENABLED(CONFIG_NET_NCSI)) {
-- 
2.9.3

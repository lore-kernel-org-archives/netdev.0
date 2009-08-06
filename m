From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/8] sky2: Move tx reset functionality to sky2_tx_reset()
Date: Thu, 06 Aug 2009 09:12:16 -0700
Message-ID: <20090806161232.680332333@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756237AbZHFQos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:48 -0400
Content-Disposition: inline; filename=sky2-tx2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is refactoring and should not affect functionality.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   44 ++++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 16a359d..a9bb3fa 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1804,6 +1804,31 @@ static void sky2_tx_clean(struct net_device *dev)
 	netif_tx_unlock_bh(dev);
 }

+static void sky2_tx_reset(struct sky2_port* sky2)
+{
+	unsigned port = sky2->port;
+	struct sky2_hw *hw = sky2->hw;
+
+	/* Disable Force Sync bit and Enable Alloc bit */
+	sky2_write8(hw, SK_REG(port, TXA_CTRL),
+		    TXA_DIS_FSYNC | TXA_DIS_ALLOC | TXA_STOP_RC);
+
+	/* Stop Interval Timer and Limit Counter of Tx Arbiter */
+	sky2_write32(hw, SK_REG(port, TXA_ITI_INI), 0L);
+	sky2_write32(hw, SK_REG(port, TXA_LIM_INI), 0L);
+
+	/* Reset the PCI FIFO of the async Tx queue */
+	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR),
+		     BMU_RST_SET | BMU_FIFO_RST);
+
+	/* Reset the Tx prefetch units */
+	sky2_write32(hw, Y2_QADDR(txqaddr[port], PREF_UNIT_CTRL),
+		     PREF_UNIT_RST_SET);
+
+	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);
+	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
+}
+
 /* Network shutdown */
 static int sky2_down(struct net_device *dev)
 {
@@ -1841,26 +1866,9 @@ static int sky2_down(struct net_device *dev)
 	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);

-	/* Disable Force Sync bit and Enable Alloc bit */
-	sky2_write8(hw, SK_REG(port, TXA_CTRL),
-		    TXA_DIS_FSYNC | TXA_DIS_ALLOC | TXA_STOP_RC);
-
-	/* Stop Interval Timer and Limit Counter of Tx Arbiter */
-	sky2_write32(hw, SK_REG(port, TXA_ITI_INI), 0L);
-	sky2_write32(hw, SK_REG(port, TXA_LIM_INI), 0L);
-
-	/* Reset the PCI FIFO of the async Tx queue */
-	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR),
-		     BMU_RST_SET | BMU_FIFO_RST);
-
-	/* Reset the Tx prefetch units */
-	sky2_write32(hw, Y2_QADDR(txqaddr[port], PREF_UNIT_CTRL),
-		     PREF_UNIT_RST_SET);
-
-	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);
+	sky2_tx_reset(sky2);

 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
-	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);

 	/* Force any delayed status interrrupt and NAPI */
 	sky2_write32(hw, STAT_LEV_TIMER_CNT, 0);
-- 
1.5.6.5

-- 


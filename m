From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/5] sky2: Move tx reset functionality to sky2_tx_reset()
Date: Mon, 3 Aug 2009 20:08:10 +0900
Message-ID: <392fb48f0908030408o71ad6af4i26c0ba90e963ffd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:64469 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbZHCLIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:08:09 -0400
Received: by fg-out-1718.google.com with SMTP id e21so985886fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 04:08:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike McCormack <mikem@ring3k.org>
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

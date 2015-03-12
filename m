From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH] net/macb: Only adjust tx_clk on link change
Date: Thu, 12 Mar 2015 18:07:54 -0500
Message-ID: <1426201674-824-1-git-send-email-jaeden.amero@ni.com>
Cc: Jaeden Amero <jaeden.amero@ni.com>, Josh Cartwright <joshc@ni.com>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY state machine (in drivers/net/phy/phy.c) will unconditionally
call phydev->adjust_link (macb_handle_link_change) when polling in the
PHY_CHANGELINK state. As currently written, macb always ends up
requesting a new tx_clk frequency in macb_handle_link_change. It is a
waste of time to request a new tx_clk frequency if the link state hasn't
changed, as the tx_clk will already be configured properly.

Let's only request a new tx_clk clock frequency when necessary.

Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
Cc: Josh Cartwright <joshc@ni.com>
Cc: Soren Brinkmann <soren.brinkmann@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index f00be58..a0a04b3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -293,10 +293,13 @@ static void macb_handle_link_change(struct net_device *dev)
 
 	spin_unlock_irqrestore(&bp->lock, flags);
 
-	macb_set_tx_clk(bp->tx_clk, phydev->speed, dev);
-
 	if (status_change) {
 		if (phydev->link) {
+			/* Update the TX clock rate if and only if the link is
+			 * up and there has been a link change.
+			 */
+			macb_set_tx_clk(bp->tx_clk, phydev->speed, dev);
+
 			netif_carrier_on(dev);
 			netdev_info(dev, "link up (%d/%s)\n",
 				    phydev->speed,
-- 
2.1.4

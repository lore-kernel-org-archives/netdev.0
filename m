From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] sky2: Reset tx train after interrupts disabled.
Date: Fri, 14 Aug 2009 08:15:14 -0700
Message-ID: <20090814151608.115603088@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44126 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932567AbZHNPUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:20:06 -0400
Content-Disposition: inline; filename=sky2-tx3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:	Mike McCormack <mikem@ring3k.org>

Reseting the tx chain too soon results in invalid tx queue positions
being delivered in the status queue.  This also makes sure there's no
overlap between the cleanup done by sky2_tx_clean() and
sky2_tx_done().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/net/sky2.c	2009-08-14 07:58:44.833439109 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:45.736296852 -0700
@@ -1804,11 +1804,8 @@ static void sky2_tx_clean(struct net_dev
 	netif_tx_unlock_bh(dev);
 }
 
-static void sky2_tx_reset(struct sky2_port* sky2)
+static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
 {
-	unsigned port = sky2->port;
-	struct sky2_hw *hw = sky2->hw;
-
 	/* Disable Force Sync bit and Enable Alloc bit */
 	sky2_write8(hw, SK_REG(port, TXA_CTRL),
 		    TXA_DIS_FSYNC | TXA_DIS_ALLOC | TXA_STOP_RC);
@@ -1866,8 +1863,6 @@ static int sky2_down(struct net_device *
 	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);
 
-	sky2_tx_reset(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 
 	/* Force any delayed status interrrupt and NAPI */
@@ -1892,6 +1887,8 @@ static int sky2_down(struct net_device *
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
+	sky2_tx_reset(hw, port);
+
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 

-- 


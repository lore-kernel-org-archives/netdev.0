From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 6/8] bnx2x: Do not call load/unload functionality
 from DCC
Date: Thu, 15 Oct 2009 08:48:42 +0200
Message-ID: <1255589322.25030.76.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3744 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934752AbZJOGtf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:49:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is really no need to clear the MAC or the FW filtering rules - it was
added for completion, but caused race conditions with load/unload. Removing this
redundant code

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 7c5c300..42cd957 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2565,21 +2565,12 @@ static void bnx2x_set_rx_mode(struct net_device *dev);
 static void bnx2x_e1h_disable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
-	int i;
-
-	bp->rx_mode = BNX2X_RX_MODE_NONE;
-	bnx2x_set_storm_rx_mode(bp);
 
 	netif_tx_disable(bp->dev);
 	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 
 	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
-	bnx2x_set_eth_mac_addr_e1h(bp, 0);
-
-	for (i = 0; i < MC_HASH_SIZE; i++)
-		REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
-
 	netif_carrier_off(bp->dev);
 }
 
@@ -2589,13 +2580,13 @@ static void bnx2x_e1h_enable(struct bnx2x *bp)
 
 	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
 
-	bnx2x_set_eth_mac_addr_e1h(bp, 1);
-
 	/* Tx queue should be only reenabled */
 	netif_tx_wake_all_queues(bp->dev);
 
-	/* Initialize the receive filter. */
-	bnx2x_set_rx_mode(bp->dev);
+	/*
+	 * Should not call netif_carrier_on since it will be called if the link
+	 * is up when checking for link state
+	 */
 }
 
 static void bnx2x_update_min_max(struct bnx2x *bp)
@@ -10538,7 +10529,7 @@ static void bnx2x_self_test(struct net_device *dev,
 		/* disable input for TX port IF */
 		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, 0);
 
-		link_up = bp->link_vars.link_up;
+		link_up = (bnx2x_link_test(bp) == 0);
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 		bnx2x_nic_load(bp, LOAD_DIAG);
 		/* wait until link state is restored */
-- 
1.5.4.3





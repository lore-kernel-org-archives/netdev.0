From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: Duplication in promisc mode
Date: Sun, 6 Feb 2011 15:14:13 +0200
Message-ID: <1296998053.16759.25.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1233 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab1BFNOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Feb 2011 08:14:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent packets duplication for frames targeting FCoE L2 ring:
packets were arriving to stack from both L2 RSS and from FCoE
L2 in a promiscuous mode.

Configure FCoE L2 ring to DROP_ALL rx mode, when interface is
configured to PROMISC, and to accept only unicast frames, when
interface is configured to ALL_MULTI.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index ae8d20a..84608c8 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4281,9 +4281,12 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		def_q_filters |= BNX2X_ACCEPT_UNICAST | BNX2X_ACCEPT_BROADCAST |
 				BNX2X_ACCEPT_MULTICAST;
 #ifdef BCM_CNIC
-		cl_id = bnx2x_fcoe(bp, cl_id);
-		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
-					  BNX2X_ACCEPT_MULTICAST);
+		if (!NO_FCOE(bp)) {
+			cl_id = bnx2x_fcoe(bp, cl_id);
+			bnx2x_rxq_set_mac_filters(bp, cl_id,
+						  BNX2X_ACCEPT_UNICAST |
+						  BNX2X_ACCEPT_MULTICAST);
+		}
 #endif
 		break;
 
@@ -4291,18 +4294,29 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		def_q_filters |= BNX2X_ACCEPT_UNICAST | BNX2X_ACCEPT_BROADCAST |
 				BNX2X_ACCEPT_ALL_MULTICAST;
 #ifdef BCM_CNIC
-		cl_id = bnx2x_fcoe(bp, cl_id);
-		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
-					  BNX2X_ACCEPT_MULTICAST);
+		/*
+		 *  Prevent duplication of multicast packets by configuring FCoE
+		 *  L2 Client to receive only matched unicast frames.
+		 */
+		if (!NO_FCOE(bp)) {
+			cl_id = bnx2x_fcoe(bp, cl_id);
+			bnx2x_rxq_set_mac_filters(bp, cl_id,
+						  BNX2X_ACCEPT_UNICAST);
+		}
 #endif
 		break;
 
 	case BNX2X_RX_MODE_PROMISC:
 		def_q_filters |= BNX2X_PROMISCUOUS_MODE;
 #ifdef BCM_CNIC
-		cl_id = bnx2x_fcoe(bp, cl_id);
-		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
-					  BNX2X_ACCEPT_MULTICAST);
+		/*
+		 *  Prevent packets duplication by configuring DROP_ALL for FCoE
+		 *  L2 Client.
+		 */
+		if (!NO_FCOE(bp)) {
+			cl_id = bnx2x_fcoe(bp, cl_id);
+			bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_NONE);
+		}
 #endif
 		/* pass management unicast packets as well */
 		llh_mask |= NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST;
-- 
1.7.0.4





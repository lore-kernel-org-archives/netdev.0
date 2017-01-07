From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ibm: ibmvnic: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  7 Jan 2017 22:37:29 +0100
Message-ID: <1483825049-7501-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35433 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdAGVhh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 16:37:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c125966..3c2526b 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1025,21 +1025,26 @@ static void ibmvnic_netpoll_controller(struct net_device *dev)
 
 /* ethtool functions */
 
-static int ibmvnic_get_settings(struct net_device *netdev,
-				struct ethtool_cmd *cmd)
+static int ibmvnic_get_link_ksettings(struct net_device *netdev,
+				      struct ethtool_link_ksettings *cmd)
 {
-	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+	u32 supported, advertising;
+
+	supported = (SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
 			  SUPPORTED_FIBRE);
-	cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg |
+	advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg |
 			    ADVERTISED_FIBRE);
-	ethtool_cmd_speed_set(cmd, SPEED_1000);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->port = PORT_FIBRE;
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = AUTONEG_ENABLE;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 1;
+	cmd->base.speed = SPEED_1000;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.port = PORT_FIBRE;
+	cmd->base.phy_address = 0;
+	cmd->base.autoneg = AUTONEG_ENABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
@@ -1132,7 +1137,6 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops ibmvnic_ethtool_ops = {
-	.get_settings		= ibmvnic_get_settings,
 	.get_drvinfo		= ibmvnic_get_drvinfo,
 	.get_msglevel		= ibmvnic_get_msglevel,
 	.set_msglevel		= ibmvnic_set_msglevel,
@@ -1141,6 +1145,7 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 	.get_strings            = ibmvnic_get_strings,
 	.get_sset_count         = ibmvnic_get_sset_count,
 	.get_ethtool_stats	= ibmvnic_get_ethtool_stats,
+	.get_link_ksettings	= ibmvnic_get_link_ksettings,
 };
 
 /* Routines for managing CRQs/sCRQs  */
-- 
1.7.4.4

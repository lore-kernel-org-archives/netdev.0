From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/6] ixgbe: ethtool support to change advertised link
	modes of 82599 adapters
Date: Thu, 04 Jun 2009 14:11:34 -0700
Message-ID: <20090604211134.5011.74067.stgit@localhost.localdomain>
References: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:42804
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbZFDVLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:11:51 -0400
In-Reply-To: <20090604210941.5011.31995.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Add ethtool support to change advertised link modes/autoneg settings of
82599 multispeed fiber adapters.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c   |    9 ++++++++
 drivers/net/ixgbe/ixgbe_ethtool.c |   42 +++++++++++++++++++++----------------
 2 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 4d83e59..3f36d83 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -464,6 +464,15 @@ s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 	hw->mac.ops.get_link_capabilities(hw, &phy_link_speed, &negotiation);
 	speed &= phy_link_speed;
 
+	 /* Set autoneg_advertised value based on input link speed */
+	hw->phy.autoneg_advertised = 0;
+
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
+
 	/*
 	 * When the driver changes the link speeds that it can support,
 	 * it sets autotry_restart to true to indicate that we need to
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 1c11045..e0feaf5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -136,11 +136,12 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	ecmd->supported = SUPPORTED_10000baseT_Full;
 	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
-	if (hw->phy.media_type == ixgbe_media_type_copper) {
+	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
+	    (hw->mac.type == ixgbe_mac_82599EB)) {
 		ecmd->supported |= (SUPPORTED_1000baseT_Full |
-		                    SUPPORTED_TP | SUPPORTED_Autoneg);
+		                    SUPPORTED_Autoneg);
 
-		ecmd->advertising = (ADVERTISED_TP | ADVERTISED_Autoneg);
+		ecmd->advertising = ADVERTISED_Autoneg;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
@@ -155,7 +156,15 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= (ADVERTISED_10000baseT_Full |
 					      ADVERTISED_1000baseT_Full);
 
-		ecmd->port = PORT_TP;
+		if (hw->phy.media_type == ixgbe_media_type_copper) {
+			ecmd->supported |= SUPPORTED_TP;
+			ecmd->advertising |= ADVERTISED_TP;
+			ecmd->port = PORT_TP;
+		} else {
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
+			ecmd->port = PORT_FIBRE;
+		}
 	} else if (hw->phy.media_type == ixgbe_media_type_backplane) {
 		/* Set as FIBRE until SERDES defined in kernel */
 		switch (hw->device_id) {
@@ -203,16 +212,10 @@ static int ixgbe_set_settings(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 advertised, old;
-	s32 err;
+	s32 err = 0;
 
-	switch (hw->phy.media_type) {
-	case ixgbe_media_type_fiber:
-		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
-		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
-			return -EINVAL;
-		/* in this case we currently only support 10Gb/FULL */
-		break;
-	case ixgbe_media_type_copper:
+	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
+	    (hw->mac.type == ixgbe_mac_82599EB)) {
 		/* 10000/copper and 1000/copper must autoneg
 		 * this function does not support any duplex forcing, but can
 		 * limit the advertising of the adapter to only 10000 or 1000 */
@@ -228,20 +231,23 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
 		if (old == advertised)
-			break;
+			return err;
 		/* this sets the link speed and restarts auto-neg */
+		hw->mac.autotry_restart = true;
 		err = hw->mac.ops.setup_link_speed(hw, advertised, true, true);
 		if (err) {
 			DPRINTK(PROBE, INFO,
 			        "setup link failed with code %d\n", err);
 			hw->mac.ops.setup_link_speed(hw, old, true, true);
 		}
-		break;
-	default:
-		break;
+	} else {
+		/* in this case we currently only support 10Gb/FULL */
+		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
+		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+			return -EINVAL;
 	}
 
-	return 0;
+	return err;
 }
 
 static void ixgbe_get_pauseparam(struct net_device *netdev,


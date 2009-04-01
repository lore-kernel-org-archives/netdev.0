From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 8/9] ixgbe: fix ethtool -A|a behavior
Date: Wed, 01 Apr 2009 00:35:05 -0700
Message-ID: <20090401073505.3749.61750.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:46026
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759153AbZDAHfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:35:24 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We were basicly ignoring ethtool users request for FC autoneg
and replying to queries with a "best guess".  This patch
enables the driver to store if we want to enable/disable
autoneg FC and do the correct behavior.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c   |    3 ++-
 drivers/net/ixgbe/ixgbe_common.c  |    3 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c |   19 ++++++++++++++++---
 drivers/net/ixgbe/ixgbe_main.c    |    2 ++
 drivers/net/ixgbe/ixgbe_type.h    |    1 +
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index ed265a7..de4db0d 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -411,7 +411,8 @@ static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 
 	/* Decide whether to use autoneg or not. */
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	if (hw->phy.multispeed_fiber && (speed == IXGBE_LINK_SPEED_1GB_FULL))
+	if (!hw->fc.disable_fc_autoneg && hw->phy.multispeed_fiber &&
+	    (speed == IXGBE_LINK_SPEED_1GB_FULL))
 		ret_val = ixgbe_fc_autoneg(hw);
 
 	if (ret_val)
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 8cfd3fd..63ab667 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1937,7 +1937,8 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 
 	/* Decide whether to use autoneg or not. */
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	if (hw->phy.multispeed_fiber && (speed == IXGBE_LINK_SPEED_1GB_FULL))
+	if (!hw->fc.disable_fc_autoneg && hw->phy.multispeed_fiber &&
+	    (speed == IXGBE_LINK_SPEED_1GB_FULL))
 		ret_val = ixgbe_fc_autoneg(hw);
 
 	if (ret_val)
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 34b4a84..55970ec 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -234,7 +234,16 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	pause->autoneg = (hw->fc.current_mode == ixgbe_fc_full ? 1 : 0);
+	/*
+	 * Flow Control Autoneg isn't on if
+	 *  - we didn't ask for it OR
+	 *  - it failed, we know this by tx & rx being off
+	 */
+	if (hw->fc.disable_fc_autoneg ||
+	    (hw->fc.current_mode == ixgbe_fc_none))
+		pause->autoneg = 0;
+	else
+		pause->autoneg = 1;
 
 	if (hw->fc.current_mode == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
@@ -252,8 +261,12 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if ((pause->autoneg == AUTONEG_ENABLE) ||
-	    (pause->rx_pause && pause->tx_pause))
+	if (pause->autoneg != AUTONEG_ENABLE)
+		hw->fc.disable_fc_autoneg = true;
+	else
+		hw->fc.disable_fc_autoneg = false;
+
+	if (pause->rx_pause && pause->tx_pause)
 		hw->fc.requested_mode = ixgbe_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.requested_mode = ixgbe_fc_rx_pause;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ae2af45..286ecc0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3167,10 +3167,12 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 	/* default flow control settings */
 	hw->fc.requested_mode = ixgbe_fc_full;
+	hw->fc.current_mode = ixgbe_fc_full;	/* init for ethtool output */
 	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
 	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 	hw->fc.send_xon = true;
+	hw->fc.disable_fc_autoneg = false;
 
 	/* enable itr by default in dynamic mode */
 	adapter->itr_setting = 1;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 2b2ecba..030ff0a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2005,6 +2005,7 @@ struct ixgbe_fc_info {
 	u16 pause_time; /* Flow Control Pause timer */
 	bool send_xon; /* Flow control send XON */
 	bool strict_ieee; /* Strict IEEE mode */
+	bool disable_fc_autoneg; /* Turn off autoneg FC mode */
 	enum ixgbe_fc_mode current_mode; /* FC mode in effect */
 	enum ixgbe_fc_mode requested_mode; /* FC mode requested by caller */
 };


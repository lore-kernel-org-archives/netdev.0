From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] ixgbe: fix slow load times on 82598 nics
Date: Fri, 23 Jan 2009 00:37:33 -0800
Message-ID: <20090123083733.20920.86146.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:51793
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751215AbZAWIh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 03:37:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Load times for NICs that use i2c to communicate with the phy were taking
~4.5 sec per port.  This fix first checks to see if the link is already
up before calling get_link_capabilities, since if it is we don't need
query the phy for link state.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f7b592e..18d4353 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3901,16 +3901,27 @@ static void ixgbe_netpoll(struct net_device *netdev)
  **/
 static int ixgbe_link_config(struct ixgbe_hw *hw)
 {
-	u32 autoneg = IXGBE_LINK_SPEED_10GB_FULL;
+	u32 autoneg;
+	bool link_up = false;
+	u32 ret = IXGBE_ERR_LINK_SETUP;
 
-	/* must always autoneg for both 1G and 10G link */
-	hw->mac.autoneg = true;
+	if (hw->mac.ops.check_link)
+		ret = hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
 
-	if ((hw->mac.type == ixgbe_mac_82598EB) &&
-	    (hw->phy.media_type == ixgbe_media_type_copper))
-		autoneg = IXGBE_LINK_SPEED_82598_AUTONEG;
+	if (ret || !link_up)
+		goto link_cfg_out;
 
-	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
+	if (hw->mac.ops.get_link_capabilities)
+		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg,
+		                                        &hw->mac.autoneg);
+	if (ret)
+		goto link_cfg_out;
+
+	if (hw->mac.ops.setup_link_speed)
+		ret = hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
+
+link_cfg_out:
+	return ret;
 }
 
 static const struct net_device_ops ixgbe_netdev_ops = {


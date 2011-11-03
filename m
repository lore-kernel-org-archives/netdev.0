From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 04/10] ixgbe: Fix link issues caused by a reset while interface is down
Date: Wed,  2 Nov 2011 17:19:55 -0700
Message-ID: <1320279601-1276-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414Ab1KCAUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:06 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Interface fails to obtain link on 82599 SFP in the following scenario:

1. Set advertised speed to GB:
ethtool -s eth0 advertise 0x20

2. Bring interface down
ip link set eth0 down

3. Issue any command that leads to a reset:
ethtool -t eth0

4. Bring link back up:
ip link set eth0 up

Following patch makes sure that the driver flaps the Tx laser every time
ixgbe_start_hw() is called, and not only when the speed is set.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 09b8e88..b7abf43 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6125,7 +6125,6 @@ static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 	autoneg = hw->phy.autoneg_advertised;
 	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
 		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
-	hw->mac.autotry_restart = false;
 	if (hw->mac.ops.setup_link)
 		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
 
-- 
1.7.6.4

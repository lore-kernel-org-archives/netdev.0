From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] ixgbe: fix race when setting advertised speed
Date: Thu, 30 Oct 2014 05:33:56 -0700
Message-ID: <1414672436-20616-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19001 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932975AbaJ3Md7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 08:33:59 -0400
In-Reply-To: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Following commands:

modprobe ixgbe
ifconfig ethX up
ethtool -s ethX advertise 0x020

can lead to "setup link failed with code -14" error due to the setup_link
call racing with the SFP detection routine in the watchdog.

This patch resolves this issue by protecting the setup_link call with check
for __IXGBE_IN_SFP_INIT.

Reported-by: Scott Harrison <scoharr2@cisco.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 3ce4a25..0ae038b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -342,12 +342,16 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		if (old == advertised)
 			return err;
 		/* this sets the link speed and restarts auto-neg */
+		while (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
+			usleep_range(1000, 2000);
+
 		hw->mac.autotry_restart = true;
 		err = hw->mac.ops.setup_link(hw, advertised, true);
 		if (err) {
 			e_info(probe, "setup link failed with code %d\n", err);
 			hw->mac.ops.setup_link(hw, old, true);
 		}
+		clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
 	} else {
 		/* in this case we currently only support 10Gb/FULL */
 		u32 speed = ethtool_cmd_speed(ecmd);
-- 
1.9.3

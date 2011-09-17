From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgb: eliminate checkstack warnings
Date: Sat, 17 Sep 2011 01:04:25 -0700
Message-ID: <1316246677-8830-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26662 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817Ab1IQIEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 04:04:41 -0400
In-Reply-To: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Really trivial fix, use kzalloc/kree instead of stack space.

before:
[jbrandeb@jbrandeb-mobl2 linux-2.6]$ make checkstack|grep ixgb_
0x0210 ixgb_set_multi [ixgb]:				768
0x04f8 ixgb_check_options [ixgb]:			220
0x04334 ixgb_set_ringparam [ixgb]:			124
0x04516 ixgb_set_ringparam [ixgb]:			124

after:
0x04f8 ixgb_check_options [ixgb]:			220
0x04354 ixgb_set_ringparam [ixgb]:			124
0x04536 ixgb_set_ringparam [ixgb]:			124

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index b8fb163..500823b 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1120,8 +1120,12 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
-			    IXGB_ETH_LENGTH_OF_ADDRESS];
+		u8 *mta = kzalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+			      IXGB_ETH_LENGTH_OF_ADDRESS, GFP_KERNEL);
+		if (!mta) {
+			pr_err("allocation of multicast memory failed\n");
+			goto alloc_failed;
+		}
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
@@ -1131,8 +1135,10 @@ ixgb_set_multi(struct net_device *netdev)
 			       ha->addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
+		kfree(mta);
 	}
 
+alloc_failed:
 	if (netdev->features & NETIF_F_HW_VLAN_RX)
 		ixgb_vlan_strip_enable(adapter);
 	else
-- 
1.7.6

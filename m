From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH net-next] ixgb: relax stack usage of 768 Byte
Date: Fri, 16 Sep 2011 23:34:57 +0200
Message-ID: <1316208897-4557-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:40523 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755201Ab1IPVfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 17:35:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ixgb_set_multi() will push (128 * 6) byte on the stack to set the
multicast filter. Fix this by allocate the scratch buffer on the heap.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index c8b9c90..4d23007 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1095,8 +1095,10 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
-			    IXGB_ETH_LENGTH_OF_ADDRESS];
+		u8 *mta = kmalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+				IXGB_ETH_LENGTH_OF_ADDRESS, GFP_ATOMIC);
+		if (!mta)
+			return;
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
@@ -1106,6 +1108,8 @@ ixgb_set_multi(struct net_device *netdev)
 			       ha->addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
+
+		kfree(mta);
 	}
 
 	if (netdev->features & NETIF_F_HW_VLAN_RX)
-- 
1.7.5.4

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 03/10] ixgbe: add rtnl locking in service task around vxlan_get_rx_port
Date: Mon, 11 Jan 2016 13:17:24 +0100
Message-ID: <1452514651-15445-4-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:59948 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759387AbcAKMRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:43 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id C57A920B1F
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:42 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protect IXGBE_FLAG2_VXLAN_REREG_NEEDED flag with rtnl_lock as it seems
it could be concurrently modified by ixgbe_set_features and
ixgbe_del_vxlan_port.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4003a88bbf6ea..85ec389bd46560 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7118,10 +7118,12 @@ static void ixgbe_service_task(struct work_struct *work)
 		return;
 	}
 #ifdef CONFIG_IXGBE_VXLAN
+	rtnl_lock();
 	if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
 		adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
 		vxlan_get_rx_port(adapter->netdev);
 	}
+	rtnl_unlock();
 #endif /* CONFIG_IXGBE_VXLAN */
 	ixgbe_reset_subtask(adapter);
 	ixgbe_phy_interrupt_subtask(adapter);
-- 
2.5.0

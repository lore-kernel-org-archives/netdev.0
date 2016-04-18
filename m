From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 4/7] ixgbe: protect vxlan_get_rx_port in ixgbe_service_task with rtnl_lock
Date: Mon, 18 Apr 2016 21:19:45 +0200
Message-ID: <1461007188-1603-5-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48820 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642AbcDRTUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:06 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 1210A20C5C
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:05 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_get_rx_port requires rtnl_lock to be held.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2976df77bf14f5..b2f2cf40f06a87 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7192,10 +7192,12 @@ static void ixgbe_service_task(struct work_struct *work)
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
2.5.5

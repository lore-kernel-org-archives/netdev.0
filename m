From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 5/7] ixgbe: limit VF access to network traffic
Date: Tue,  8 Feb 2011 01:44:37 -0800
Message-ID: <1297158279-20277-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297158279-20277-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21440 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab1BHJor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 04:44:47 -0500
In-Reply-To: <1297158279-20277-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes VM pool allocation issues based on MAC address filtering,
as well as limits the scope of VF access to promiscuous mode.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |    3 +++
 drivers/net/ixgbe/ixgbe_sriov.c  |    2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index d5ede2d..ebbda7d 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1370,6 +1370,9 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		hw_dbg(hw, " New MAC Addr =%pM\n", hw->mac.addr);
 
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+
+		/*  clear VMDq pool/queue selection for RAR 0 */
+		hw->mac.ops.clear_vmdq(hw, 0, IXGBE_CLEAR_VMDQ_ALL);
 	}
 	hw->addr_ctrl.overflow_promisc = 0;
 
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 47b1573..187b3a1 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -110,12 +110,10 @@ static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 
-
 static void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 {
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
 	vmolr |= (IXGBE_VMOLR_ROMPE |
-		  IXGBE_VMOLR_ROPE |
 		  IXGBE_VMOLR_BAM);
 	if (aupe)
 		vmolr |= IXGBE_VMOLR_AUPE;
-- 
1.7.4


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] ixgbe: Make the bridge mode setting sticky
Date: Wed, 28 Nov 2012 05:06:17 -0800
Message-ID: <1354107978-24731-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22755 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932092Ab2K1NG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:27 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The internal bridge mode setting needs to be sticky so that it can be
configured correctly after a device reset.  This change is required now
that the driver supports setting the bridge mode to VEB or VEPA.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <Sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 12 ++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  1 +
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7ff4c4f..8e78676 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -483,6 +483,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
 #define IXGBE_FLAG2_PTP_ENABLED			(u32)(1 << 10)
 #define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 11)
+#define IXGBE_FLAG2_BRIDGE_MODE_VEB		(u32)(1 << 12)
 
 	/* Tx fast path data */
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fc8cfad..fee0f8c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3247,6 +3247,8 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), reg_offset - 1);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (~0) << vf_shift);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), reg_offset - 1);
+	if (adapter->flags2 & IXGBE_FLAG2_BRIDGE_MODE_VEB)
+		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
 	hw->mac.ops.set_vmdq(hw, 0, VMDQ_P(0));
@@ -7039,11 +7041,13 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 			continue;
 
 		mode = nla_get_u16(attr);
-		if (mode == BRIDGE_MODE_VEPA)
+		if (mode == BRIDGE_MODE_VEPA) {
 			reg = 0;
-		else if (mode == BRIDGE_MODE_VEB)
+			adapter->flags2 &= ~IXGBE_FLAG2_BRIDGE_MODE_VEB;
+		} else if (mode == BRIDGE_MODE_VEB) {
 			reg = IXGBE_PFDTXGSWC_VT_LBEN;
-		else
+			adapter->flags2 |= IXGBE_FLAG2_BRIDGE_MODE_VEB;
+		} else
 			return -EINVAL;
 
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, reg);
@@ -7064,7 +7068,7 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return 0;
 
-	if (IXGBE_READ_REG(&adapter->hw, IXGBE_PFDTXGSWC) & 1)
+	if (adapter->flags2 & IXGBE_FLAG2_BRIDGE_MODE_VEB)
 		mode = BRIDGE_MODE_VEB;
 	else
 		mode = BRIDGE_MODE_VEPA;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 4993642..85cddac 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -119,6 +119,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 
 	/* Initialize default switching mode VEB */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+	adapter->flags2 |= IXGBE_FLAG2_BRIDGE_MODE_VEB;
 
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
-- 
1.7.11.7

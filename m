From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/10] ixgbe: cleanup move setting PFQDE.HIDE_VLAN to support function.
Date: Tue, 11 Nov 2014 06:44:44 -0800
Message-ID: <1415717086-3441-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12581 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbaKKOpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:19 -0500
In-Reply-To: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Move setting of drop enable to support function.  This not only makes the
code more readable but is also prep for following patches that add
additional MAC support.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 31 ++++++++++++++++++--------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 07d1c04..0c25df5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -618,6 +618,27 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 	return 0;
 }
 
+static inline void ixgbe_write_qde(struct ixgbe_adapter *adapter, u32 vf,
+				   u32 qde)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
+	u32 q_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
+	int i;
+
+	for (i = vf * q_per_pool; i < ((vf + 1) * q_per_pool); i++) {
+		u32 reg;
+
+		/* flush previous write */
+		IXGBE_WRITE_FLUSH(hw);
+
+		/* indicate to hardware that we want to set drop enable */
+		reg = IXGBE_QDE_WRITE | IXGBE_QDE_ENABLE;
+		reg |= i <<  IXGBE_QDE_IDX_SHIFT;
+		IXGBE_WRITE_REG(hw, IXGBE_QDE, reg);
+	}
+}
+
 static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
@@ -647,15 +668,7 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
 
 	/* force drop enable for all VF Rx queues */
-	for (i = vf * q_per_pool; i < ((vf + 1) * q_per_pool); i++) {
-		/* flush previous write */
-		IXGBE_WRITE_FLUSH(hw);
-
-		/* indicate to hardware that we want to set drop enable */
-		reg = IXGBE_QDE_WRITE | IXGBE_QDE_ENABLE;
-		reg |= i <<  IXGBE_QDE_IDX_SHIFT;
-		IXGBE_WRITE_REG(hw, IXGBE_QDE, reg);
-	}
+	ixgbe_write_qde(adapter, vf, IXGBE_QDE_ENABLE);
 
 	/* enable receive for vf */
 	reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
-- 
1.9.3

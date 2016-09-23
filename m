From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: simplify the logic for setting VLAN filtering
Date: Fri, 23 Sep 2016 00:51:34 -0700
Message-ID: <1474617103-59530-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27953 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752993AbcIWHvp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:45 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Simplify the logic for setting VLNCTRL.VFE by checking the  VMDQ flag
and 82598 MAC instead of having to maintain a list of MAC types.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 39 ++++++++-------------------
 1 file changed, 11 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d76bc1a..1c88858 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4105,23 +4105,20 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 
 	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 
-	switch (hw->mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-	case ixgbe_mac_X550:
-	case ixgbe_mac_X550EM_x:
-	case ixgbe_mac_x550em_a:
-	default:
-		if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED)
-			break;
-		/* fall through */
-	case ixgbe_mac_82598EB:
-		/* legacy case, we can just disable VLAN filtering */
+	if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED) {
+	/* For VMDq and SR-IOV we must leave VLAN filtering enabled */
+		vlnctrl |= IXGBE_VLNCTRL_VFE;
+		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+	} else {
 		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		return;
 	}
 
+	/* Nothing to do for 82598 */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
 	/* We are already in VLAN promisc, nothing to do */
 	if (adapter->flags2 & IXGBE_FLAG2_VLAN_PROMISC)
 		return;
@@ -4129,10 +4126,6 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 	/* Set flag so we don't redo unnecessary work */
 	adapter->flags2 |= IXGBE_FLAG2_VLAN_PROMISC;
 
-	/* For VMDq and SR-IOV we must leave VLAN filtering enabled */
-	vlnctrl |= IXGBE_VLNCTRL_VFE;
-	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
-
 	/* Add PF to all active pools */
 	for (i = IXGBE_VLVF_ENTRIES; --i;) {
 		u32 reg_offset = IXGBE_VLVFB(i * 2 + VMDQ_P(0) / 32);
@@ -4204,19 +4197,9 @@ static void ixgbe_vlan_promisc_disable(struct ixgbe_adapter *adapter)
 	vlnctrl |= IXGBE_VLNCTRL_VFE;
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
-	switch (hw->mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-	case ixgbe_mac_X550:
-	case ixgbe_mac_X550EM_x:
-	case ixgbe_mac_x550em_a:
-	default:
-		if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED)
-			break;
-		/* fall through */
-	case ixgbe_mac_82598EB:
+	if (!(adapter->flags & IXGBE_FLAG_VMDQ_ENABLED) ||
+	    hw->mac.type == ixgbe_mac_82598EB)
 		return;
-	}
 
 	/* We are not in VLAN promisc, nothing to do */
 	if (!(adapter->flags2 & IXGBE_FLAG2_VLAN_PROMISC))
-- 
2.7.4

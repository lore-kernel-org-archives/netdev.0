From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] ixgbevf: Adjust to handle unassigned MAC address from PF
Date: Thu, 28 Mar 2013 02:00:15 -0700
Message-ID: <1364461215-7793-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20438 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab3C1JA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:28 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the administrator has not assigned a MAC address to the VF via the
PF then handle it gracefully by generating a temporary MAC address.
This ensures that we always know when we have a random address and
udev won't get upset about it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 21 +++++++++++++++------
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  7 ++++++-
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 5563250..eeae934 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2052,6 +2052,7 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 	int err;
 
 	/* PCI config space info */
@@ -2071,18 +2072,26 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
-		         "PF still in reset state, assigning new address\n");
-		eth_hw_addr_random(adapter->netdev);
-		memcpy(adapter->hw.mac.addr, adapter->netdev->dev_addr,
-			adapter->netdev->addr_len);
+			 "PF still in reset state.  Is the PF interface up?\n");
 	} else {
 		err = hw->mac.ops.init_hw(hw);
 		if (err) {
 			pr_err("init_shared_code failed: %d\n", err);
 			goto out;
 		}
-		memcpy(adapter->netdev->dev_addr, adapter->hw.mac.addr,
-		       adapter->netdev->addr_len);
+		err = hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
+		if (err)
+			dev_info(&pdev->dev, "Error reading MAC address\n");
+		else if (is_zero_ether_addr(adapter->hw.mac.addr))
+			dev_info(&pdev->dev,
+				 "MAC address not assigned by administrator.\n");
+		memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
+	}
+
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
+		dev_info(&pdev->dev, "Assigning random MAC address\n");
+		eth_hw_addr_random(netdev);
+		memcpy(hw->mac.addr, netdev->dev_addr, netdev->addr_len);
 	}
 
 	/* lock to protect mailbox accesses */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 0c94557..387b526 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -109,7 +109,12 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	if (msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK))
+	/* New versions of the PF may NACK the reset return message
+	 * to indicate that no MAC address has yet been assigned for
+	 * the VF.
+	 */
+	if (msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK) &&
+	    msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_NACK))
 		return IXGBE_ERR_INVALID_MAC_ADDR;
 
 	memcpy(hw->mac.perm_addr, addr, ETH_ALEN);
-- 
1.7.11.7

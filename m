From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] ixgbe: Don't give VFs random MAC addresses
Date: Thu, 28 Mar 2013 02:00:14 -0700
Message-ID: <1364461215-7793-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61712 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424Ab3C1JA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:27 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the user has not assigned a MAC address to a VM, then don't give it a
random one. Instead, just give it zeros and let it figure out what to do
with them.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d44b4d2..b3e6530 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -661,13 +661,7 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 	bool enable = ((event_mask & 0x10000000U) != 0);
 
 	if (enable) {
-		eth_random_addr(vf_mac_addr);
-		e_info(probe, "IOV: VF %d is enabled MAC %pM\n",
-		       vfn, vf_mac_addr);
-		/*
-		 * Store away the VF "permananet" MAC address, it will ask
-		 * for it later.
-		 */
+		eth_zero_addr(vf_mac_addr);
 		memcpy(adapter->vfinfo[vfn].vf_mac_addresses, vf_mac_addr, 6);
 	}
 
@@ -688,7 +682,8 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	ixgbe_vf_reset_event(adapter, vf);
 
 	/* set vf mac address */
-	ixgbe_set_vf_mac(adapter, vf, vf_mac);
+	if (!is_zero_ether_addr(vf_mac))
+		ixgbe_set_vf_mac(adapter, vf, vf_mac);
 
 	vf_shift = vf % 32;
 	reg_offset = vf / 32;
@@ -729,8 +724,16 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
 
 	/* reply to reset with ack and vf mac address */
-	msgbuf[0] = IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK;
-	memcpy(addr, vf_mac, ETH_ALEN);
+	msgbuf[0] = IXGBE_VF_RESET;
+	if (!is_zero_ether_addr(vf_mac)) {
+		msgbuf[0] |= IXGBE_VT_MSGTYPE_ACK;
+		memcpy(addr, vf_mac, ETH_ALEN);
+	} else {
+		msgbuf[0] |= IXGBE_VT_MSGTYPE_NACK;
+		dev_warn(&adapter->pdev->dev,
+			 "VF %d has no MAC address assigned, you may have to assign one manually\n",
+			 vf);
+	}
 
 	/*
 	 * Piggyback the multicast filter type so VF can compute the
-- 
1.7.11.7

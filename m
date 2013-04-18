From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] ixgbe: Fix a bug in setting VF VLAN via PF
Date: Wed, 17 Apr 2013 23:41:35 -0700
Message-ID: <1366267295-18420-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38039 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab3DRGlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 02:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The PF driver does not check if the administrator has already set a VF
VLAN via the PF driver before setting the new VLAN.  This results in
the following scenario:

A) Administrator sets VF <n> to VLAN 100
B) Administrator sets VF <x> to VLAN 100
C) Administrator sets VF <n> to VLAN 200
D) The VF <n> driver continues to be able to receive traffic on VLAN
   100 because the VLVFB pool enable bit for that VF was left set
   instead of being cleared as it should be.

This fix ensures that the old VLAN filter for VF <n> is first removed
and the pool bit enable for VF <n> is cleared so that it no longer
receives traffic on VLAN 100.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d44b4d2..97e3366 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1049,6 +1049,12 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 	if (vlan || qos) {
+		if (adapter->vfinfo[vf].pf_vlan)
+			err = ixgbe_set_vf_vlan(adapter, false,
+						adapter->vfinfo[vf].pf_vlan,
+						vf);
+		if (err)
+			goto out;
 		err = ixgbe_set_vf_vlan(adapter, true, vlan, vf);
 		if (err)
 			goto out;
-- 
1.7.11.7

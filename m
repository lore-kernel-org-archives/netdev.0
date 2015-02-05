From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] ixgbe: fix setting port VLAN
Date: Thu,  5 Feb 2015 01:35:41 -0800
Message-ID: <1423128950-12388-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55155 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756728AbbBEJgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:05 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes couple of issues introduced by
commit 2b509c0cd292 ("ixgbe: cleanup ixgbe_ndo_set_vf_vlan")

- fix setting of the VLAN inside ixgbe_enable_port_vlan()
- disable the "hide VLAN" bit in PFQDE when port VLAN is disabled

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index a82a36b..7f37fe7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1094,14 +1094,12 @@ static int ixgbe_enable_port_vlan(struct ixgbe_adapter *adapter, int vf,
 				  u16 vlan, u8 qos)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err = 0;
+	int err;
 
-	if (adapter->vfinfo[vf].pf_vlan)
-		err = ixgbe_set_vf_vlan(adapter, false,
-					adapter->vfinfo[vf].pf_vlan,
-					vf);
+	err = ixgbe_set_vf_vlan(adapter, true, vlan, vf);
 	if (err)
 		goto out;
+
 	ixgbe_set_vmvir(adapter, vlan, qos, vf);
 	ixgbe_set_vmolr(hw, vf, false);
 	if (adapter->vfinfo[vf].spoofchk_enabled)
@@ -1140,6 +1138,11 @@ static int ixgbe_disable_port_vlan(struct ixgbe_adapter *adapter, int vf)
 	hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
 	if (adapter->vfinfo[vf].vlan_count)
 		adapter->vfinfo[vf].vlan_count--;
+
+	/* disable hide VLAN on X550 */
+	if (hw->mac.type >= ixgbe_mac_X550)
+		ixgbe_write_qde(adapter, vf, IXGBE_QDE_ENABLE);
+
 	adapter->vfinfo[vf].pf_vlan = 0;
 	adapter->vfinfo[vf].pf_qos = 0;
 
-- 
1.9.3

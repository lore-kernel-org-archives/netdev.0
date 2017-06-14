From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: Fix a sleep-in-atomic bug
Date: Wed, 14 Jun 2017 16:35:31 -0700
Message-ID: <20170614233531.40509-1-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:45426 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752661AbdFNXfh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 19:35:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

The driver may sleep under a spin lock, and the function call path is:
i40e_ndo_set_vf_port_vlan (acquire the lock by spin_lock_bh)
  i40e_vsi_remove_pvid
    i40e_vlan_stripping_disable
      i40e_aq_update_vsi_params
        i40e_asq_send_command
          mutex_lock --> may sleep

To fixed it, the spin lock is released before "i40e_vsi_remove_pvid", and
the lock is acquired again after this function.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 95c23fbaa211..0fb38ca78900 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -3017,10 +3017,12 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 					   VLAN_VID_MASK));
 	}
 
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	if (vlan_id || qos)
 		ret = i40e_vsi_add_pvid(vsi, vlanprio);
 	else
 		i40e_vsi_remove_pvid(vsi);
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
 
 	if (vlan_id) {
 		dev_info(&pf->pdev->dev, "Setting VLAN %d, QOS 0x%x on VF %d\n",
-- 
2.12.2

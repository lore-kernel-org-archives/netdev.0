From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Add support to program FDir SB rules for VF from PF through ethtool
Date: Tue, 14 Apr 2015 21:51:40 -0700
Message-ID: <1429073511-27664-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47805 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530AbbDOEv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:51:59 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With this patch we can now add Flow director Sideband rules for a VF from
it's PF. Here is an example on how it can be done when VF id = 5 and
queue = 2:

"ethtool -N ethx flow-type udp4 src-ip x.x.x.x dst-ip y.y.y.y src-port p1 dst-port p2 action 2 user-def 5"

User-def specifies VF id and action specifies queue.

Change-ID: Ib37d6dff3823a4d85caffde638473891c38c2b89
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c848b18..7d60587 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1914,6 +1914,16 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 	else
 		fsp->ring_cookie = rule->q_index;
 
+	if (rule->dest_vsi != pf->vsi[pf->lan_vsi]->id) {
+		struct i40e_vsi *vsi;
+
+		vsi = i40e_find_vsi_from_id(pf, rule->dest_vsi);
+		if (vsi && vsi->type == I40E_VSI_SRIOV) {
+			fsp->h_ext.data[1] = htonl(vsi->vf_id);
+			fsp->m_ext.data[1] = htonl(0x1);
+		}
+	}
+
 	return 0;
 }
 
@@ -2207,6 +2217,7 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	struct i40e_fdir_filter *input;
 	struct i40e_pf *pf;
 	int ret = -EINVAL;
+	u16 vf_id;
 
 	if (!vsi)
 		return -EINVAL;
@@ -2267,7 +2278,22 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	input->dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
 	input->src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
 
+	if (ntohl(fsp->m_ext.data[1])) {
+		if (ntohl(fsp->h_ext.data[1]) >= pf->num_alloc_vfs) {
+			netif_info(pf, drv, vsi->netdev, "Invalid VF id\n");
+			goto free_input;
+		}
+		vf_id = ntohl(fsp->h_ext.data[1]);
+		/* Find vsi id from vf id and override dest vsi */
+		input->dest_vsi = pf->vf[vf_id].lan_vsi_id;
+		if (input->q_index >= pf->vf[vf_id].num_queue_pairs) {
+			netif_info(pf, drv, vsi->netdev, "Invalid queue id\n");
+			goto free_input;
+		}
+	}
+
 	ret = i40e_add_del_fdir(vsi, input, true);
+free_input:
 	if (ret)
 		kfree(input);
 	else
-- 
1.9.3

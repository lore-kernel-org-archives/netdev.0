From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: fix deleting mac filters
Date: Sat, 24 Sep 2016 23:42:36 -0700
Message-ID: <1474785769-54665-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47187 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964845AbcIYGmw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:52 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

There exists a bug in which deleting a mac filter does not actually
occur.  The driver reports that the filter has been deleted with no
error.  The problem occurs because the wrong cmd_flag is passed to the
firmware when deleting the filter.  The firmware reports an error back
to the driver but it is expressly ignored.

This fixes the bug by using the correct flag when deleting a filter.
Without this patch, deleted filters remain in firmware and function as
if they had not been deleted.

Change-ID: I5f22b874f3b83f457702f18f0d5602ca21ac40c3
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 60f082e..0841379 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1315,7 +1315,7 @@ static void i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
 	element.vlan_tag = 0;
 	/* ...and some firmware does it this way. */
 	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH |
-			I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
+			I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
 	i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
 }
 
@@ -1908,7 +1908,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			ether_addr_copy(del_list[num_del].mac_addr, f->macaddr);
 			if (f->vlan == I40E_VLAN_ANY) {
 				del_list[num_del].vlan_tag = 0;
-				cmd_flags |= I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
+				cmd_flags |= I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
 			} else {
 				del_list[num_del].vlan_tag =
 					cpu_to_le16((u16)(f->vlan));
-- 
2.7.4

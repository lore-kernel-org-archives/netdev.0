From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/22] i40e: When searching all MAC/VLAN filters, ignore removed filters
Date: Mon, 31 Oct 2016 15:29:36 -0700
Message-ID: <1477952992-125662-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034489AbcJaW35 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:29:57 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When adding new MAC address filters, the driver determines if it should
behave in VLAN mode (where all MAC addresses get assigned to every
existing VLAN) or in non-VLAN mode where MAC addresses get assigned the
VLAN_ANY identifier. Under some circumstances it is possible that a VLAN
has been marked for removal (such that all filters of that VLAN are set
to I40E_FILTER_REMOVE), and a subsequent call to i40e_put_mac_in_vlan
may occur prior to the driver subtask that syncs filters to the
hardware.

In this case, we may add filters to the new removed VLAN, even though it
should have been removed. This is most obvious when first adding a new
VLAN. We will delete all filters which are in I40E_VLAN_ANY (-1) and
then re-add them as in VLAN 0 (untagged). Then before we sync filters,
we will add new MAC address filter, which will be added to every VLAN
that exists. Unfortunately, this will include I40E_VLAN_ANY, so we will
end up incorrectly adding filters to the -1 VLAN. This can be fixed by
simply skipping all filters which are marked for removal.

A similar check is not necessary in i40e_del_mac_all_vlan, since we are
deleting, and any filter which we find already marked for removal would
simply be deleted again, which doesn't cause any issues.

Change-Id: I7962154013ce02fe950584690aeeb3ed853d0086
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c096093..86ad953 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1328,6 +1328,8 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
 				       le16_to_cpu(vsi->info.pvid));
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		if (f->state == I40E_FILTER_REMOVE)
+			continue;
 		add = i40e_add_filter(vsi, macaddr, f->vlan);
 		if (!add)
 			return NULL;
@@ -2271,6 +2273,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	}
 
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
+		if (f->state == I40E_FILTER_REMOVE)
+			continue;
 		add_f = i40e_add_filter(vsi, f->macaddr, vid);
 		if (!add_f) {
 			dev_info(&vsi->back->pdev->dev,
@@ -2305,6 +2309,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	/* Do not assume that I40E_VLAN_ANY should be reset to VLAN 0 */
 	if (vid > 0 && !vsi->info.pvid) {
 		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
+			if (f->state == I40E_FILTER_REMOVE)
+				continue;
 			if (!i40e_find_filter(vsi, f->macaddr, I40E_VLAN_ANY))
 				continue;
 			i40e_del_filter(vsi, f->macaddr, I40E_VLAN_ANY);
-- 
2.7.4

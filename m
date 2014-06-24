From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: reapply LAA after reset
Date: Mon, 23 Jun 2014 17:47:35 -0700
Message-ID: <1403570858-13548-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58414 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbaFXArv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:51 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The LAA is lost on a reset, so be sure to replay it when rebuilding
the switch after any reset.

Change-ID: I6e643f9a59dfd899b6cbdf84d93b4bc9c37bb949
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 07811dd..2ec6e8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -362,6 +362,7 @@ struct i40e_mac_filter {
 	bool is_vf;		/* filter belongs to a VF */
 	bool is_netdev;		/* filter belongs to a netdev */
 	bool changed;		/* filter needs to be sync'd to the HW */
+	bool is_laa;		/* filter is a Locally Administered Address */
 };
 
 struct i40e_veb {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b83aac6..f7496a0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1344,8 +1344,8 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		}
 	}
 
-	if (!i40e_find_mac(vsi, addr->sa_data, false, true)) {
-
+	f = i40e_find_mac(vsi, addr->sa_data, false, true);
+	if (!f) {
 		/* In order to be sure to not drop any packets, add the
 		 * new address first then delete the old one.
 		 */
@@ -1360,6 +1360,7 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		i40e_sync_vsi_filters(vsi);
 	}
 
+	f->is_laa = true;
 	if (!ether_addr_equal(netdev->dev_addr, addr->sa_data))
 		ether_addr_copy(netdev->dev_addr, addr->sa_data);
 
@@ -7379,6 +7380,12 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
 		f->changed = true;
 		f_count++;
+
+		if (f->is_laa && vsi->type == I40E_VSI_MAIN) {
+			i40e_aq_mac_address_write(&vsi->back->hw,
+						  I40E_AQC_WRITE_TYPE_LAA_WOL,
+						  f->macaddr, NULL);
+		}
 	}
 	if (f_count) {
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
-- 
1.9.3

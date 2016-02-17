From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: allocate memory safer
Date: Wed, 17 Feb 2016 09:51:36 -0800
Message-ID: <1455731506-62165-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161411AbcBQRvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:50 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The sync_vsi_filter function was allocating memory in such
a way that it could sleep (GFP_KERNEL) which was causing a problem
when called by the team driver under rcu_read_lock(), which cannot
be held while sleeping.  Found with lockdep.

Change-ID: I4e59053cb5eedcf3d0ca151715be3dc42a94bdd5
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c4ad0f1..fe67b90 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1937,7 +1937,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
 		del_list_size = filter_list_len *
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
-		del_list = kzalloc(del_list_size, GFP_KERNEL);
+		del_list = kzalloc(del_list_size, GFP_ATOMIC);
 		if (!del_list) {
 			i40e_cleanup_add_list(&tmp_add_list);
 
@@ -2015,7 +2015,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			       sizeof(struct i40e_aqc_add_macvlan_element_data),
 		add_list_size = filter_list_len *
 			       sizeof(struct i40e_aqc_add_macvlan_element_data);
-		add_list = kzalloc(add_list_size, GFP_KERNEL);
+		add_list = kzalloc(add_list_size, GFP_ATOMIC);
 		if (!add_list) {
 			/* Purge element from temporary lists */
 			i40e_cleanup_add_list(&tmp_add_list);
-- 
2.5.0

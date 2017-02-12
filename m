From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: allow i40e_update_filter_state to skip broadcast filters
Date: Sat, 11 Feb 2017 21:30:26 -0800
Message-ID: <20170212053028.98581-13-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:18297 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751152AbdBLFae (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:34 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Fix a bug where we modified the mac_filter_hash while outside a lock,
when handling addition of broadcast filters.

Normally, we add filters to firmware by batching the additions into
lists and issuing 1 update for every few filters. Broadcast filters are
handled differently, by instead setting the broadcast promiscuous mode
flags. In order to make sure the 1<->1 mapping of filters in our
addition array lined up with filters in the hlist tmp_add_list, we had
to remove the filter and move it back to the main hash. However, we
didn't do this under lock, which could cause consistency problems for
the list.

Fix this by updating i40e_update_filter_state logic so that it knows to
avoid broadcast filters. This ensures that we don't have to remove the
filter separately, and can put it back using the normal flow.

Change-ID: Id288fade80b3e3a9a54b68cc249188cb95147518
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 37 ++++++++++++++++++++++-------
 1 file changed, 29 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fa4a04d..06c80d4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1843,6 +1843,31 @@ static void i40e_undo_filter_entries(struct i40e_vsi *vsi,
 }
 
 /**
+ * i40e_next_entry - Get the next non-broadcast filter from a list
+ * @f: pointer to filter in list
+ *
+ * Returns the next non-broadcast filter in the list. Required so that we
+ * ignore broadcast filters within the list, since these are not handled via
+ * the normal firmware update path.
+ */
+static struct i40e_mac_filter *i40e_next_filter(struct i40e_mac_filter *f)
+{
+	while (f) {
+		f = hlist_entry(f->hlist.next,
+				typeof(struct i40e_mac_filter),
+				hlist);
+
+		/* keep going if we found a broadcast filter */
+		if (f && is_broadcast_ether_addr(f->macaddr))
+			continue;
+
+		break;
+	}
+
+	return f;
+}
+
+/**
  * i40e_update_filter_state - Update filter state based on return data
  * from firmware
  * @count: Number of filters added
@@ -1874,9 +1899,9 @@ i40e_update_filter_state(int count,
 			retval++;
 		}
 
-		add_head = hlist_entry(add_head->hlist.next,
-				       typeof(struct i40e_mac_filter),
-				       hlist);
+		add_head = i40e_next_filter(add_head);
+		if (!add_head)
+			break;
 	}
 
 	return retval;
@@ -2095,7 +2120,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			cmd_flags = 0;
 
 			/* handle broadcast filters by updating the broadcast
-			 * promiscuous flag instead of deleting a MAC filter.
+			 * promiscuous flag and release filter list.
 			 */
 			if (is_broadcast_ether_addr(f->macaddr)) {
 				i40e_aqc_broadcast_filter(vsi, vsi_name, f);
@@ -2164,11 +2189,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			 * promiscuous flag instead of adding a MAC filter.
 			 */
 			if (is_broadcast_ether_addr(f->macaddr)) {
-				u64 key = i40e_addr_to_hkey(f->macaddr);
 				i40e_aqc_broadcast_filter(vsi, vsi_name, f);
-
-				hlist_del(&f->hlist);
-				hash_add(vsi->mac_filter_hash, &f->hlist, key);
 				continue;
 			}
 
-- 
2.10.2

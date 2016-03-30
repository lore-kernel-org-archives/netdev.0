From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 09/11] ixgbe: fix error handling in TC cls_u32 offload routines
Date: Wed, 30 Mar 2016 16:00:53 -0700
Message-ID: <1459378855-139837-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65047 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbcC3XBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:04 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Check for handle ids when adding/deleting hash nodes OR adding/deleting
filter entries and limit them to max number of links or header nodes
supported(IXGBE_MAX_LINK_HANDLE).

Start from bit 0 when setting hash table bit-map.(adapter->tables)

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 52 +++++++++++++++++----------
 1 file changed, 34 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f5736a3..ca9c543 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8192,10 +8192,17 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 static int ixgbe_delete_clsu32(struct ixgbe_adapter *adapter,
 			       struct tc_cls_u32_offload *cls)
 {
+	u32 uhtid = TC_U32_USERHTID(cls->knode.handle);
+	u32 loc;
 	int err;
 
+	if ((uhtid != 0x800) && (uhtid >= IXGBE_MAX_LINK_HANDLE))
+		return -EINVAL;
+
+	loc = cls->knode.handle & 0xfffff;
+
 	spin_lock(&adapter->fdir_perfect_lock);
-	err = ixgbe_update_ethtool_fdir_entry(adapter, NULL, cls->knode.handle);
+	err = ixgbe_update_ethtool_fdir_entry(adapter, NULL, loc);
 	spin_unlock(&adapter->fdir_perfect_lock);
 	return err;
 }
@@ -8204,20 +8211,30 @@ static int ixgbe_configure_clsu32_add_hnode(struct ixgbe_adapter *adapter,
 					    __be16 protocol,
 					    struct tc_cls_u32_offload *cls)
 {
+	u32 uhtid = TC_U32_USERHTID(cls->hnode.handle);
+
+	if (uhtid >= IXGBE_MAX_LINK_HANDLE)
+		return -EINVAL;
+
 	/* This ixgbe devices do not support hash tables at the moment
 	 * so abort when given hash tables.
 	 */
 	if (cls->hnode.divisor > 0)
 		return -EINVAL;
 
-	set_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
+	set_bit(uhtid - 1, &adapter->tables);
 	return 0;
 }
 
 static int ixgbe_configure_clsu32_del_hnode(struct ixgbe_adapter *adapter,
 					    struct tc_cls_u32_offload *cls)
 {
-	clear_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
+	u32 uhtid = TC_U32_USERHTID(cls->hnode.handle);
+
+	if (uhtid >= IXGBE_MAX_LINK_HANDLE)
+		return -EINVAL;
+
+	clear_bit(uhtid - 1, &adapter->tables);
 	return 0;
 }
 
@@ -8235,27 +8252,29 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 #endif
 	int i, err = 0;
 	u8 queue;
-	u32 handle;
+	u32 uhtid, link_uhtid;
 
 	memset(&mask, 0, sizeof(union ixgbe_atr_input));
-	handle = cls->knode.handle;
+	uhtid = TC_U32_USERHTID(cls->knode.handle);
+	link_uhtid = TC_U32_USERHTID(cls->knode.link_handle);
 
-	/* At the moment cls_u32 jumps to transport layer and skips past
+	/* At the moment cls_u32 jumps to network layer and skips past
 	 * L2 headers. The canonical method to match L2 frames is to use
 	 * negative values. However this is error prone at best but really
 	 * just broken because there is no way to "know" what sort of hdr
-	 * is in front of the transport layer. Fix cls_u32 to support L2
+	 * is in front of the network layer. Fix cls_u32 to support L2
 	 * headers when needed.
 	 */
 	if (protocol != htons(ETH_P_IP))
 		return -EINVAL;
 
-	if (cls->knode.link_handle ||
-	    cls->knode.link_handle >= IXGBE_MAX_LINK_HANDLE) {
+	if (link_uhtid) {
 		struct ixgbe_nexthdr *nexthdr = ixgbe_ipv4_jumps;
-		u32 uhtid = TC_U32_USERHTID(cls->knode.link_handle);
 
-		if (!test_bit(uhtid, &adapter->tables))
+		if (link_uhtid >= IXGBE_MAX_LINK_HANDLE)
+			return -EINVAL;
+
+		if (!test_bit(link_uhtid - 1, &adapter->tables))
 			return -EINVAL;
 
 		for (i = 0; nexthdr[i].jump; i++) {
@@ -8271,10 +8290,7 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 			    nexthdr->mask != cls->knode.sel->keys[0].mask)
 				return -EINVAL;
 
-			if (uhtid >= IXGBE_MAX_LINK_HANDLE)
-				return -EINVAL;
-
-			adapter->jump_tables[uhtid] = nexthdr->jump;
+			adapter->jump_tables[link_uhtid] = nexthdr->jump;
 		}
 		return 0;
 	}
@@ -8291,13 +8307,13 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	 * To add support for new nodes update ixgbe_model.h parse structures
 	 * this function _should_ be generic try not to hardcode values here.
 	 */
-	if (TC_U32_USERHTID(handle) == 0x800) {
+	if (uhtid == 0x800) {
 		field_ptr = adapter->jump_tables[0];
 	} else {
-		if (TC_U32_USERHTID(handle) >= ARRAY_SIZE(adapter->jump_tables))
+		if (uhtid >= IXGBE_MAX_LINK_HANDLE)
 			return -EINVAL;
 
-		field_ptr = adapter->jump_tables[TC_U32_USERHTID(handle)];
+		field_ptr = adapter->jump_tables[uhtid];
 	}
 
 	if (!field_ptr)
-- 
2.5.5

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 1/5] ixgbe: Ensure MAC filter was added before setting MACVLAN
Date: Tue, 18 Jul 2017 18:23:01 -0700
Message-ID: <20170719012305.76795-2-jeffrey.t.kirsher@intel.com>
References: <20170719012305.76795-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:31205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751906AbdGSBXN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 21:23:13 -0400
In-Reply-To: <20170719012305.76795-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

This patch adds a check to ensure that adding the MAC filter was
successful before setting the MACVLAN.  If it was unsuccessful, propagate
the error.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 0760bd7eeb01..ca492876bd3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -681,6 +681,7 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 {
 	struct list_head *pos;
 	struct vf_macvlans *entry;
+	s32 retval = 0;
 
 	if (index <= 1) {
 		list_for_each(pos, &adapter->vf_mvs.l) {
@@ -721,14 +722,15 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 	if (!entry || !entry->free)
 		return -ENOSPC;
 
-	entry->free = false;
-	entry->is_macvlan = true;
-	entry->vf = vf;
-	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
-
-	ixgbe_add_mac_filter(adapter, mac_addr, vf);
+	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
+	if (retval >= 0) {
+		entry->free = false;
+		entry->is_macvlan = true;
+		entry->vf = vf;
+		memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
+	}
 
-	return 0;
+	return retval;
 }
 
 static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
-- 
2.13.2

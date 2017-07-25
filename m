From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v4 1/5] ixgbe: Ensure MAC filter was added before setting MACVLAN
Date: Tue, 25 Jul 2017 16:41:34 -0700
Message-ID: <20170725234138.42283-2-jeffrey.t.kirsher@intel.com>
References: <20170725234138.42283-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19869 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751703AbdGYXlq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 19:41:46 -0400
In-Reply-To: <20170725234138.42283-1-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 0760bd7eeb01..112d24c6c9ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -679,8 +679,9 @@ static void ixgbe_clear_vf_vlans(struct ixgbe_adapter *adapter, u32 vf)
 static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 				int vf, int index, unsigned char *mac_addr)
 {
-	struct list_head *pos;
 	struct vf_macvlans *entry;
+	struct list_head *pos;
+	int retval = 0;
 
 	if (index <= 1) {
 		list_for_each(pos, &adapter->vf_mvs.l) {
@@ -721,13 +722,15 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 	if (!entry || !entry->free)
 		return -ENOSPC;
 
+	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
+	if (retval < 0)
+		return retval;
+
 	entry->free = false;
 	entry->is_macvlan = true;
 	entry->vf = vf;
 	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
 
-	ixgbe_add_mac_filter(adapter, mac_addr, vf);
-
 	return 0;
 }
 
-- 
2.13.3

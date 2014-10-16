From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] fm10k: Unlock mailbox on VLAN addition failures
Date: Thu, 16 Oct 2014 02:36:25 -0700
Message-ID: <1413452187-2950-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32154 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbaJPJgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 05:36:31 -0400
In-Reply-To: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

After grabbing the mailbox lock and detecting an error, the lock must be
released before the error code can be returned.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index bf44a8f..b57ea1c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -785,14 +785,14 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (!(netdev->flags & IFF_PROMISC)) {
 		err = hw->mac.ops.update_vlan(hw, vid, 0, set);
 		if (err)
-			return err;
+			goto err_out;
 	}
 
 	/* update our base MAC address */
 	err = hw->mac.ops.update_uc_addr(hw, interface->glort, hw->mac.addr,
 					 vid, set, 0);
 	if (err)
-		return err;
+		goto err_out;
 
 	/* set vid prior to syncing/unsyncing the VLAN */
 	interface->vid = vid + (set ? VLAN_N_VID : 0);
@@ -801,9 +801,10 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	__dev_uc_unsync(netdev, fm10k_uc_vlan_unsync);
 	__dev_mc_unsync(netdev, fm10k_mc_vlan_unsync);
 
+err_out:
 	fm10k_mbx_unlock(interface);
 
-	return 0;
+	return err;
 }
 
 static int fm10k_vlan_rx_add_vid(struct net_device *netdev,
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/8] igb: fix vf lookup
Date: Wed,  8 Feb 2012 01:36:32 -0800
Message-ID: <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45540 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab2BHJgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:36:45 -0500
In-Reply-To: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Recent addition of code to find already allocated VFs failed to take
account that systems with 2 or more multi-port SR-IOV capable controllers
might have already enabled VFs.  Make sure that the VFs the function is
finding are actually subordinate to the particular instance of the adapter
that is looking for them and not subordinate to some device that has
previously enabled SR-IOV.

This is applicable to 3.2+ kernels.

CC: stable@vger.kernel.org
Reported-by: David Ahern <daahern@cisco.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e91d73c..94be6c3 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct igb_adapter *adapter)
 	vf_devfn = pdev->devfn + 0x80;
 	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
 	while (pvfdev) {
-		if (pvfdev->devfn == vf_devfn)
+		if (pvfdev->devfn == vf_devfn &&
+		    (pvfdev->bus->number >= pdev->bus->number))
 			vfs_found++;
 		vf_devfn += vf_stride;
 		pvfdev = pci_get_device(hw->vendor_id,
-- 
1.7.7.6

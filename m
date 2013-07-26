From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] igb: fix vlan filtering in promisc mode when not in VT mode
Date: Fri, 26 Jul 2013 05:46:36 -0700
Message-ID: <1374842796-28445-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13871 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232Ab3GZMrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 08:47:03 -0400
In-Reply-To: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes a VT mode check to make sure VLAN filters are disabled when
in promisc mode and VT is not enabled.

The problem with the previous check was that:
E1000_MRQC_ENABLE_VMDQ is defined as 0x00000003

but when not in VT mode:
mrqc |= E1000_MRQC_ENABLE_RSS_4Q (0x00000002)

So the above check will trigger regardless if VT mode is being used or not.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..c1d72c0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3739,9 +3739,8 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE | E1000_RCTL_VFE);
 
 	if (netdev->flags & IFF_PROMISC) {
-		u32 mrqc = rd32(E1000_MRQC);
 		/* retain VLAN HW filtering if in VT mode */
-		if (mrqc & E1000_MRQC_ENABLE_VMDQ)
+		if (adapter->vfs_allocated_count)
 			rctl |= E1000_RCTL_VFE;
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 		vmolr |= (E1000_VMOLR_ROPE | E1000_VMOLR_MPME);
-- 
1.7.11.7

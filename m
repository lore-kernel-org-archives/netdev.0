From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: DCB and SR-IOV can not co-exist and will cause hangs
Date: Wed,  4 Jul 2012 05:00:25 -0700
Message-ID: <1341403225-1326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22121 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab2GDMAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2012 08:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

DCB and SR-IOV cannot currently be enabled at the same time as the queueing
schemes are incompatible.  If they are both enabled it will result in Tx
hangs since only the first Tx queue will be able to transmit any traffic.

This simple fix for this is to block us from enabling TCs in ixgbe_setup_tc
if SR-IOV is enabled.  This change will be reverted once we can support
SR-IOV and DCB coexistence.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18ca3bc..e242104 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6647,6 +6647,11 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		return -EINVAL;
 	}
 
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		e_err(drv, "Enable failed, SR-IOV enabled\n");
+		return -EINVAL;
+	}
+
 	/* Hardware supports up to 8 traffic classes */
 	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs ||
 	    (hw->mac.type == ixgbe_mac_82598EB &&
-- 
1.7.10.4

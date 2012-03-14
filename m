From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] ixgbe: dcb: use DCB config values for FCoE traffic class on open
Date: Wed, 14 Mar 2012 00:55:26 -0700
Message-ID: <1331711726-9439-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7812 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab2CNHzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:33 -0400
In-Reply-To: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Disabling and enabling DCB can cause FCoE hardware initialization to
occur on the incorrect traffic class when the up2tc mapping has not
yet been reconfigured.

Fix this by using the DCB configuration maps that are correct
and will be pushed at mqprio after DCB driver setup completes
successfully.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e1444bd..167e898 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4391,11 +4391,13 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 	 * configuration later.
 	 */
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+		u8 prio_tc[MAX_USER_PRIORITY] = {0};
 		int tc;
 		struct ixgbe_ring_feature *f =
 					&adapter->ring_feature[RING_F_FCOE];
 
-		tc = netdev_get_prio_tc_map(dev, adapter->fcoe.up);
+		ixgbe_dcb_unpack_map(&adapter->dcb_cfg, DCB_TX_CONFIG, prio_tc);
+		tc = prio_tc[adapter->fcoe.up];
 		f->indices = dev->tc_to_txq[tc].count;
 		f->mask = dev->tc_to_txq[tc].offset;
 	}
-- 
1.7.7.6

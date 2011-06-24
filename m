From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] ixgbe: fix ring assignment issues for SR-IOV and drop cases
Date: Thu, 23 Jun 2011 23:03:16 -0700
Message-ID: <1308895397-23133-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9660 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab1FXGDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:37 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes the fact that we would trigger a null pointer dereference
or specify the wrong ring if the rings were restored.  This change makes
certain that the DROP queue is a static value, and all other rings are
based on the ring offsets for the PF.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 ++
 drivers/net/ixgbe/ixgbe_main.c    |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 596d794..074e9ba 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2677,6 +2677,8 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	/* program filters to filter memory */
 	err = ixgbe_fdir_write_perfect_filter_82599(hw,
 				&input->filter, input->sw_idx,
+				(input->action == IXGBE_FDIR_DROP_QUEUE) ?
+				IXGBE_FDIR_DROP_QUEUE :
 				adapter->rx_ring[input->action]->reg_idx);
 	if (err)
 		goto err_out_w_lock;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2886dae..916a2b6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3755,9 +3755,11 @@ static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
 	hlist_for_each_entry_safe(filter, node, node2,
 				  &adapter->fdir_filter_list, fdir_node) {
 		ixgbe_fdir_write_perfect_filter_82599(hw,
-						      &filter->filter,
-						      filter->sw_idx,
-						      filter->action);
+				&filter->filter,
+				filter->sw_idx,
+				(filter->action == IXGBE_FDIR_DROP_QUEUE) ?
+				IXGBE_FDIR_DROP_QUEUE :
+				adapter->rx_ring[filter->action]->reg_idx);
 	}
 
 	spin_unlock(&adapter->fdir_perfect_lock);
-- 
1.7.5.4


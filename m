From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: Allow flow director to use entire queue space
Date: Thu, 28 May 2015 04:25:27 -0700
Message-ID: <1432812339-17129-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Alex Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbbE1LZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:42 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Flow director is exported to user space using the ethtool ntuple
support. However, currently it only supports steering traffic to a
subset of the queues in use by the hardware. This change allows
flow director to specify queues that have been assigned to virtual
functions by partitioning the ring_cookie into a 8bit VF specifier
followed by 32bit queue index. At the moment we don't have any
ethernet drivers with more than 2^32 queues on a single function
as best I can tell and nor do I expect this to happen anytime
soon. This way the ring_cookie's normal use for specifying a queue
on a specific PCI function continues to work as expected.

CC: Alex Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 34 +++++++++++++++++-------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 9f6fb19..9a1d0f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2594,18 +2594,35 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_fdir_filter *input;
 	union ixgbe_atr_input mask;
+	u8 queue;
 	int err;
 
 	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 		return -EOPNOTSUPP;
 
-	/*
-	 * Don't allow programming if the action is a queue greater than
-	 * the number of online Rx queues.
+	/* ring_cookie is a masked into a set of queues and ixgbe pools or
+	 * we use the drop index.
 	 */
-	if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
-	    (fsp->ring_cookie >= adapter->num_rx_queues))
-		return -EINVAL;
+	if (fsp->ring_cookie == RX_CLS_FLOW_DISC) {
+		queue = IXGBE_FDIR_DROP_QUEUE;
+	} else {
+		u32 ring = ethtool_get_flow_spec_ring(fsp->ring_cookie);
+		u8 vf = ethtool_get_flow_spec_ring_vf(fsp->ring_cookie);
+
+		if (!vf && (ring >= adapter->num_rx_queues))
+			return -EINVAL;
+		else if (vf &&
+			 ((vf > adapter->num_vfs) ||
+			   ring >= adapter->num_rx_queues_per_pool))
+			return -EINVAL;
+
+		/* Map the ring onto the absolute queue index */
+		if (!vf)
+			queue = adapter->rx_ring[ring]->reg_idx;
+		else
+			queue = ((vf - 1) *
+				adapter->num_rx_queues_per_pool) + ring;
+	}
 
 	/* Don't allow indexes to exist outside of available space */
 	if (fsp->location >= ((1024 << adapter->fdir_pballoc) - 2)) {
@@ -2683,10 +2700,7 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 
 	/* program filters to filter memory */
 	err = ixgbe_fdir_write_perfect_filter_82599(hw,
-				&input->filter, input->sw_idx,
-				(input->action == IXGBE_FDIR_DROP_QUEUE) ?
-				IXGBE_FDIR_DROP_QUEUE :
-				adapter->rx_ring[input->action]->reg_idx);
+				&input->filter, input->sw_idx, queue);
 	if (err)
 		goto err_out_w_lock;
 
-- 
2.1.0

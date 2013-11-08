From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/2] ixgbe: fix build err,
 num_rx_queues is only available with CONFIG_RPS
Date: Fri, 08 Nov 2013 00:50:32 -0800
Message-ID: <20131108085031.6935.61765.stgit@nitbit.x32>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:43282 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab3KHIvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 03:51:03 -0500
Received: by mail-oa0-f41.google.com with SMTP id g12so558573oah.14
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 00:51:02 -0800 (PST)
In-Reply-To: <20131108084654.6935.36501.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the recent support for layer 2 hardware acceleration, I added a
few references to real_num_rx_queues and num_rx_queues which are
only available with CONFIG_RPS.

The fix is first to remove unnecessary references to num_rx_queues.
Because the hardware offload case is limited to cases where RX queues
and TX queues are equal we only need a single check. Then wrap the
single case in an ifdef.

The patch that introduce this is here,

commit a6cc0cfa72e0b6d9f2c8fd858aacc32313c4f272
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Wed Nov 6 09:54:46 2013 -0800

    net: Add layer 2 hardware acceleration operations for macvlan devices

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 607275d..2e17c30 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4164,7 +4164,7 @@ static void ixgbe_add_mac_filter(struct ixgbe_adapter *adapter,
 static void ixgbe_fwd_psrtype(struct ixgbe_fwd_adapter *vadapter)
 {
 	struct ixgbe_adapter *adapter = vadapter->real_adapter;
-	int rss_i = vadapter->netdev->real_num_rx_queues;
+	int rss_i = adapter->num_rx_queues_per_pool;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u16 pool = vadapter->pool;
 	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
@@ -4315,8 +4315,6 @@ static int ixgbe_fwd_ring_up(struct net_device *vdev,
 	if (err)
 		goto fwd_queue_err;
 
-	queues = min_t(unsigned int,
-		       adapter->num_rx_queues_per_pool, vdev->num_rx_queues);
 	err = netif_set_real_num_rx_queues(vdev, queues);
 	if (err)
 		goto fwd_queue_err;
@@ -7540,9 +7538,15 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	struct ixgbe_adapter *adapter = netdev_priv(pdev);
 	int pool, err;
 
+#ifdef CONFIG_RPS
+	if (vdev->num_rx_queues != vdev->num_tx_queues) {
+		netdev_info(pdev, "%s: Only supports a single queue count for TX and RX\n",
+			    vdev->name);
+		return ERR_PTR(-EINVAL);
+	}
+#endif
 	/* Check for hardware restriction on number of rx/tx queues */
-	if (vdev->num_rx_queues != vdev->num_tx_queues ||
-	    vdev->num_tx_queues > IXGBE_MAX_L2A_QUEUES ||
+	if (vdev->num_tx_queues > IXGBE_MAX_L2A_QUEUES ||
 	    vdev->num_tx_queues == IXGBE_BAD_L2A_QUEUE) {
 		netdev_info(pdev,
 			    "%s: Supports RX/TX Queue counts 1,2, and 4\n",
@@ -7566,7 +7570,7 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	/* Enable VMDq flag so device will be set in VM mode */
 	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_SRIOV_ENABLED;
 	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
-	adapter->ring_feature[RING_F_RSS].limit = vdev->num_rx_queues;
+	adapter->ring_feature[RING_F_RSS].limit = vdev->num_tx_queues;
 
 	/* Force reinit of ring allocation with VMDQ enabled */
 	err = ixgbe_setup_tc(pdev, netdev_get_num_tc(pdev));

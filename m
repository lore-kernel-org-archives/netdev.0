From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 07/10] ixgbe: Add function for setting XPS queue mapping
Date: Fri, 29 Jun 2012 17:16:49 -0700
Message-ID: <20120630001649.29939.725.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26111 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693Ab2F3AQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:30 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds support for ixgbe to configure the XPS queue mapping on
load.  The result of this change is that on open we will now be resetting
the number of Tx queues, and then setting the default configuration for XPS
based on if ATR is enabled or disabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 72386fb..a43dae0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -797,8 +797,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	/* setup affinity mask and node */
 	if (cpu != -1)
 		cpumask_set_cpu(cpu, &q_vector->affinity_mask);
-	else
-		cpumask_copy(&q_vector->affinity_mask, cpu_online_mask);
+
 	q_vector->numa_node = node;
 
 	/* initialize CPU for DCA */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dedb412..06641ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4848,6 +4848,22 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+static void ixgbe_set_xps_mapping(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_q_vector *q_vector;
+	u16 i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		q_vector = adapter->tx_ring[i]->q_vector;
+
+		if (!q_vector)
+			continue;
+
+		netif_set_xps_queue(netdev, &q_vector->affinity_mask, i);
+	}
+}
+
 /**
  * ixgbe_open - Called when a network interface is made active
  * @netdev: network interface device structure
@@ -4894,6 +4910,8 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
+	/* update the Tx mapping */
+	ixgbe_set_xps_mapping(netdev);
 
 	err = netif_set_real_num_rx_queues(netdev,
 					   adapter->num_rx_pools > 1 ? 1 :

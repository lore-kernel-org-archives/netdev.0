From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2 1/2] ixgbe: Allocate driver resources per NUMA
	node
Date: Wed, 03 Feb 2010 16:18:50 -0800
Message-ID: <20100204001804.15798.98344.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:39120 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758000Ab0BDATK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 19:19:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The default policy for the current driver is to do all its memory
allocation on whatever processor is running insmod/modprobe.  This
is less than optimal.

This driver's default mode of operation will be to use each node for each
subsequent transmit/receive queue.  The most efficient allocation will be
to then have the interrupts bound in such a way as to match up the
interrupt of the queue to the cpu where its memory was allocated.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   37 ++++++++++++++++++++++++++++++++++---
 2 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e576fb4..f34512e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -400,6 +400,8 @@ struct ixgbe_adapter {
 	u32 wol;
 	u16 eeprom_version;
 
+	int node;
+
 	/* SR-IOV */
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
 	unsigned int num_vfs;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6369852..315369f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3946,7 +3946,11 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 	}
 
 	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
-		q_vector = kzalloc(sizeof(struct ixgbe_q_vector), GFP_KERNEL);
+		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
+		                        GFP_KERNEL, adapter->node);
+		if (!q_vector)
+			q_vector = kzalloc(sizeof(struct ixgbe_q_vector),
+			                   GFP_KERNEL);
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
@@ -4246,6 +4250,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	/* enable rx csum by default */
 	adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
 
+	/* get assigned NUMA node */
+	adapter->node = dev_to_node(&pdev->dev);
+
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -4265,7 +4272,9 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vmalloc(size);
+	tx_ring->tx_buffer_info = vmalloc_node(size, adapter->node);
+	if (!tx_ring->tx_buffer_info)
+		tx_ring->tx_buffer_info = vmalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 	memset(tx_ring->tx_buffer_info, 0, size);
@@ -4305,8 +4314,15 @@ err:
 static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 {
 	int i, err = 0;
+	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
 		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
 		if (!err)
 			continue;
@@ -4314,6 +4330,9 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 		break;
 	}
 
+	/* reset the node back to its starting value */
+	adapter->node = orig_node;
+
 	return err;
 }
 
@@ -4331,7 +4350,9 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc(size);
+	rx_ring->rx_buffer_info = vmalloc_node(size, adapter->node);
+	if (!rx_ring->rx_buffer_info)
+		rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 		        "vmalloc allocation failed for the rx desc ring\n");
@@ -4375,8 +4396,15 @@ alloc_failed:
 static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 {
 	int i, err = 0;
+	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
 		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
 		if (!err)
 			continue;
@@ -4384,6 +4412,9 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 		break;
 	}
 
+	/* reset the node back to its starting value */
+	adapter->node = orig_node;
+
 	return err;
 }
 


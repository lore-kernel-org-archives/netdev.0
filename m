From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] vmxnet3: adjust ring sizes when interface is down
Date: Fri, 13 Jun 2014 10:03:21 -0400
Message-ID: <1402668201-26628-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33842 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbaFMODu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 10:03:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ethtool is used to update ring sizes on a vmxnet3 interface that isn't
running, the change isn't stored, meaning the ring update is effectively is
ignored and lost without any indication to the user.

Other network drivers store the ring size update so that ring allocation uses
the new sizes next time the interface is brought up.  This patch modifies
vmxnet3 to behave this way as well

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |  7 +++++--
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 12 ++++++++----
 drivers/net/vmxnet3/vmxnet3_int.h     |  5 +++++
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 9739434..b76f7dc 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2589,8 +2589,8 @@ vmxnet3_open(struct net_device *netdev)
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		spin_lock_init(&adapter->tx_queue[i].tx_lock);
 
-	err = vmxnet3_create_queues(adapter, VMXNET3_DEF_TX_RING_SIZE,
-				    VMXNET3_DEF_RX_RING_SIZE,
+	err = vmxnet3_create_queues(adapter, adapter->tx_ring_size,
+				    adapter->rx_ring_size,
 				    VMXNET3_DEF_RX_RING_SIZE);
 	if (err)
 		goto queue_err;
@@ -2968,6 +2968,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 
+	adapter->tx_ring_size = VMXNET3_DEF_TX_RING_SIZE;
+	adapter->rx_ring_size = VMXNET3_DEF_RX_RING_SIZE;
+
 	spin_lock_init(&adapter->cmd_lock);
 	adapter->adapter_pa = dma_map_single(&adapter->pdev->dev, adapter,
 					     sizeof(struct vmxnet3_adapter),
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 40c1c7b..b725fd9 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -449,8 +449,8 @@ vmxnet3_get_ringparam(struct net_device *netdev,
 	param->rx_mini_max_pending = 0;
 	param->rx_jumbo_max_pending = 0;
 
-	param->rx_pending = adapter->rx_queue[0].rx_ring[0].size;
-	param->tx_pending = adapter->tx_queue[0].tx_ring.size;
+	param->rx_pending = adapter->rx_ring_size;
+	param->tx_pending = adapter->tx_ring_size;
 	param->rx_mini_pending = 0;
 	param->rx_jumbo_pending = 0;
 }
@@ -529,9 +529,11 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 			 * size */
 			netdev_err(netdev, "failed to apply new sizes, "
 				   "try the default ones\n");
+			new_rx_ring_size = VMXNET3_DEF_RX_RING_SIZE;
+			new_tx_ring_size = VMXNET3_DEF_TX_RING_SIZE;
 			err = vmxnet3_create_queues(adapter,
-						    VMXNET3_DEF_TX_RING_SIZE,
-						    VMXNET3_DEF_RX_RING_SIZE,
+						    new_tx_ring_size,
+						    new_rx_ring_size,
 						    VMXNET3_DEF_RX_RING_SIZE);
 			if (err) {
 				netdev_err(netdev, "failed to create queues "
@@ -545,6 +547,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 			netdev_err(netdev, "failed to re-activate, error %d."
 				   " Closing it\n", err);
 	}
+	adapter->tx_ring_size = new_tx_ring_size;
+	adapter->rx_ring_size = new_rx_ring_size;
 
 out:
 	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 190569d..29ee77f2 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -349,6 +349,11 @@ struct vmxnet3_adapter {
 	u32     link_speed; /* in mbps */
 
 	u64     tx_timeout_count;
+
+	/* Ring sizes */
+	u32 tx_ring_size;
+	u32 rx_ring_size;
+
 	struct work_struct work;
 
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
-- 
1.8.3.1

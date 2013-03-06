From: Bhavesh Davda <bhavesh@vmware.com>
Subject: [PATCH net-next] vmxnet3: prevent div-by-zero panic when ring resizing uninitialized dev
Date: Wed,  6 Mar 2013 14:04:53 -0800
Message-ID: <1362607493-5634-1-git-send-email-bhavesh@vmware.com>
References: <1362591984-16587-1-git-send-email-bhavesh@vmware.com>
Cc: pv-drivers@vmware.com, Bhavesh Davda <bhavesh@vmware.com>,
	Shreyas N Bhatewara <sbhatewara@vmware.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362591984-16587-1-git-send-email-bhavesh@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux is free to call ethtool ops as soon as a netdev exists when probe
finishes. However, we only allocate vmxnet3 tx/rx queues and initialize the
rx_buf_per_pkt field in struct vmxnet3_adapter when the interface is
opened (UP).

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |    1 +
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    6 ++++++
 drivers/net/vmxnet3/vmxnet3_int.h     |    4 ++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 4aad350..eae7a03 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2958,6 +2958,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 
 	adapter->num_rx_queues = num_rx_queues;
 	adapter->num_tx_queues = num_tx_queues;
+	adapter->rx_buf_per_pkt = 1;
 
 	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
 	size += sizeof(struct Vmxnet3_RxQueueDesc) * adapter->num_rx_queues;
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index a0feb17..63a1243 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -472,6 +472,12 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 						VMXNET3_RX_RING_MAX_SIZE)
 		return -EINVAL;
 
+	/* if adapter not yet initialized, do nothing */
+	if (adapter->rx_buf_per_pkt == 0) {
+		netdev_err(netdev, "adapter not completely initialized, "
+			   "ring size cannot be changed yet\n");
+		return -EOPNOTSUPP;
+	}
 
 	/* round it up to a multiple of VMXNET3_RING_SIZE_ALIGN */
 	new_tx_ring_size = (param->tx_pending + VMXNET3_RING_SIZE_MASK) &
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 3198384..3541814 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -70,10 +70,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.29.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.30.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01011D00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01011E00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.7.1

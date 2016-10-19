From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 5/6] net: use core MTU range checking in virt drivers
Date: Tue, 18 Oct 2016 22:33:32 -0400
Message-ID: <20161019023333.15760-6-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hyperv_net:
- set min/max_mtu

virtio_net:
- set min/max_mtu
- remove virtnet_change_mtu

vmxnet3:
- set min/max_mtu

CC: netdev@vger.kernel.org
CC: virtualization@lists.linux-foundation.org
CC: "K. Y. Srinivasan" <kys@microsoft.com>
CC: Haiyang Zhang <haiyangz@microsoft.com>
CC: "Michael S. Tsirkin" <mst@redhat.com>
CC: Shrikrishna Khare <skhare@vmware.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/hyperv/hyperv_net.h   |  4 ++--
 drivers/net/hyperv/netvsc_drv.c   | 14 +++++++-------
 drivers/net/virtio_net.c          | 23 ++++++++++-------------
 drivers/net/vmxnet3/vmxnet3_drv.c |  7 ++++---
 4 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f4fbcb5..3958ada 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -606,8 +606,8 @@ struct nvsp_message {
 } __packed;
 
 
-#define NETVSC_MTU 65536
-#define NETVSC_MTU_MIN 68
+#define NETVSC_MTU 65535
+#define NETVSC_MTU_MIN ETH_MIN_MTU
 
 #define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*16)	/* 16MB */
 #define NETVSC_RECEIVE_BUFFER_SIZE_LEGACY	(1024*1024*15)  /* 15MB */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f0919bd..3dc9679 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -872,19 +872,12 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct netvsc_device *nvdev = ndevctx->nvdev;
 	struct hv_device *hdev = ndevctx->device_ctx;
 	struct netvsc_device_info device_info;
-	int limit = ETH_DATA_LEN;
 	u32 num_chn;
 	int ret = 0;
 
 	if (ndevctx->start_remove || !nvdev || nvdev->destroy)
 		return -ENODEV;
 
-	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
-		limit = NETVSC_MTU - ETH_HLEN;
-
-	if (mtu < NETVSC_MTU_MIN || mtu > limit)
-		return -EINVAL;
-
 	ret = netvsc_close(ndev);
 	if (ret)
 		goto out;
@@ -1343,6 +1336,13 @@ static int netvsc_probe(struct hv_device *dev,
 
 	netif_carrier_off(net);
 
+	/* MTU range: 68 - 1500 or 65521 */
+	net->min_mtu = NETVSC_MTU_MIN;
+	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
+		net->max_mtu = NETVSC_MTU - ETH_HLEN;
+	else
+		net->max_mtu = ETH_DATA_LEN;
+
 	netvsc_init_settings(net);
 
 	net_device_ctx = netdev_priv(net);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fad84f3..4885a42 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1419,17 +1419,6 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_settings = virtnet_set_settings,
 };
 
-#define MIN_MTU 68
-#define MAX_MTU 65535
-
-static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1437,7 +1426,6 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
-	.ndo_change_mtu	     = virtnet_change_mtu,
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
@@ -1748,6 +1736,9 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
 	return true;
 }
 
+#define MIN_MTU ETH_MIN_MTU
+#define MAX_MTU 65535
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
@@ -1821,6 +1812,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	dev->vlan_features = dev->features;
 
+	/* MTU range: 68 - 65535 */
+	dev->min_mtu = MIN_MTU;
+	dev->max_mtu = MAX_MTU;
+
 	/* Configuration may specify what MAC to use.  Otherwise random. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
 		virtio_cread_bytes(vdev,
@@ -1875,8 +1870,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 		mtu = virtio_cread16(vdev,
 				     offsetof(struct virtio_net_config,
 					      mtu));
-		if (virtnet_change_mtu(dev, mtu))
+		if (mtu >= dev->min_mtu && mtu <= dev->max_mtu) {
+			dev->mtu = mtu;
 			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
+		}
 	}
 
 	if (vi->any_header_sg)
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b5554f2..0c36de1 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2969,9 +2969,6 @@ vmxnet3_change_mtu(struct net_device *netdev, int new_mtu)
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
 
-	if (new_mtu < VMXNET3_MIN_MTU || new_mtu > VMXNET3_MAX_MTU)
-		return -EINVAL;
-
 	netdev->mtu = new_mtu;
 
 	/*
@@ -3428,6 +3425,10 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	vmxnet3_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
 
+	/* MTU range: 60 - 9000 */
+	netdev->min_mtu = VMXNET3_MIN_MTU;
+	netdev->max_mtu = VMXNET3_MAX_MTU;
+
 	INIT_WORK(&adapter->work, vmxnet3_reset_work);
 	set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
 
-- 
2.10.0

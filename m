From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [RFC PATCH net-next] enable virtio_net to return bus_info in ethtool -i consistent with emulated NICs
Date: Mon, 14 Nov 2011 13:52:41 -0800 (PST)
Message-ID: <20111114215241.5B8BF2900307@tardy>
To: <netdev@vger.kernel.org>, "Rusty Russell" <rusty@rustcorp.com.au>,
	"Michael Tsirkin" <mst@redhat.com>,
	<virtualization@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:28191 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303Ab1KNVwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 16:52:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Add a new .bus_name to virtio_config_ops then modify virtio_net to 
call through to it in an ethtool .get_drvinfo routine to report
bus_info in ethtool -i output which is consistent with other
emulated NICs and the output of lspci.  

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

The changes to drivers/lguest/lguest_device.c, drivers/s390/kvm/kvm_virtio.c,
and drivers/virtio/virtio_mmio.c code inspected only, not compiled.

raj@raj-ubuntu-guest:~$ ethtool -i eth0
driver: virtio_net
version: 1.0.0
firmware-version: 
bus-info: 0000:00:03.0
raj@raj-ubuntu-guest:~$ lspci | grep Ether
00:03.0 Ethernet controller: Red Hat, Inc Virtio network device

 drivers/lguest/lguest_device.c |    6 ++++++
 drivers/net/virtio_net.c       |   15 +++++++++++++++
 drivers/s390/kvm/kvm_virtio.c  |    6 ++++++
 drivers/virtio/virtio_mmio.c   |    6 ++++++
 drivers/virtio/virtio_pci.c    |    8 ++++++++
 include/linux/virtio_config.h  |   14 ++++++++++++++
 6 files changed, 55 insertions(+), 0 deletions(-)


diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
index 0dc30ff..3724d45 100644
--- a/drivers/lguest/lguest_device.c
+++ b/drivers/lguest/lguest_device.c
@@ -381,6 +381,11 @@ error:
 	return PTR_ERR(vqs[i]);
 }
 
+static const char *lg_bus_name(struct virtio_device *vdev)
+{
+	return "Not Implemented";
+}
+
 /* The ops structure which hooks everything together. */
 static struct virtio_config_ops lguest_config_ops = {
 	.get_features = lg_get_features,
@@ -392,6 +397,7 @@ static struct virtio_config_ops lguest_config_ops = {
 	.reset = lg_reset,
 	.find_vqs = lg_find_vqs,
 	.del_vqs = lg_del_vqs,
+	.bus_name = lg_bus_name,
 };
 
 /*
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 6ee8410..4dc9d84 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -39,6 +39,7 @@ module_param(gso, bool, 0444);
 #define GOOD_COPY_LEN	128
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
+#define VIRTNET_DRIVER_VERSION "1.0.0"
 
 struct virtnet_stats {
 	struct u64_stats_sync syncp;
@@ -889,7 +890,21 @@ static void virtnet_get_ringparam(struct net_device *dev,
 
 }
 
+
+static void virtnet_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *info)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->version, VIRTNET_DRIVER_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, virtio_bus_name(vdev), sizeof(info->bus_info));
+
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_drvinfo = virtnet_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = virtnet_get_ringparam,
 };
diff --git a/drivers/s390/kvm/kvm_virtio.c b/drivers/s390/kvm/kvm_virtio.c
index 94f49ff..725d90e 100644
--- a/drivers/s390/kvm/kvm_virtio.c
+++ b/drivers/s390/kvm/kvm_virtio.c
@@ -263,6 +263,11 @@ error:
 	return PTR_ERR(vqs[i]);
 }
 
+static const char *kvm_bus_name(struct virtio_device *vdev)
+{
+	return "Not Implemented";
+}
+
 /*
  * The config ops structure as defined by virtio config
  */
@@ -276,6 +281,7 @@ static struct virtio_config_ops kvm_vq_configspace_ops = {
 	.reset = kvm_reset,
 	.find_vqs = kvm_find_vqs,
 	.del_vqs = kvm_del_vqs,
+	.bus_name = kvm_bus_name,
 };
 
 /*
diff --git a/drivers/virtio/virtio_mmio.c b/drivers/virtio/virtio_mmio.c
index acc5e43..2f57380 100644
--- a/drivers/virtio/virtio_mmio.c
+++ b/drivers/virtio/virtio_mmio.c
@@ -361,7 +361,12 @@ static int vm_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 	return 0;
 }
 
+static const char *vm_bus_name(struct virtio_device *vdev)
+{
+	struct virtio_mmio_device *vm_dev = to_virtio_mmio_device(vdev);
 
+	return vm_dev->pdev->name;
+}
 
 static struct virtio_config_ops virtio_mmio_config_ops = {
 	.get		= vm_get,
@@ -373,6 +378,7 @@ static struct virtio_config_ops virtio_mmio_config_ops = {
 	.del_vqs	= vm_del_vqs,
 	.get_features	= vm_get_features,
 	.finalize_features = vm_finalize_features,
+	.bus_name	= vm_bus_name,
 };
 
 
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 79a31e5..764ec05 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -580,6 +580,13 @@ static int vp_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 				  false, false);
 }
 
+static const char *vp_bus_name(struct virtio_device *vdev)
+{
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+
+	return pci_name(vp_dev->pci_dev);
+}
+
 static struct virtio_config_ops virtio_pci_config_ops = {
 	.get		= vp_get,
 	.set		= vp_set,
@@ -590,6 +597,7 @@ static struct virtio_config_ops virtio_pci_config_ops = {
 	.del_vqs	= vp_del_vqs,
 	.get_features	= vp_get_features,
 	.finalize_features = vp_finalize_features,
+	.bus_name	= vp_bus_name,
 };
 
 static void virtio_pci_release_dev(struct device *_d)
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index add4790..63f98d0 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -100,6 +100,10 @@
  *	vdev: the virtio_device
  *	This gives the final feature bits for the device: it can change
  *	the dev->feature bits if it wants.
+ * @bus_name: return the bus name associated with the device
+ *	vdev: the virtio_device
+ *      This returns a pointer to the bus name a la pci_name from which
+ *      the caller can then copy.
  */
 typedef void vq_callback_t(struct virtqueue *);
 struct virtio_config_ops {
@@ -117,6 +121,7 @@ struct virtio_config_ops {
 	void (*del_vqs)(struct virtio_device *);
 	u32 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
+	const char *(*bus_name)(struct virtio_device *vdev);
 };
 
 /* If driver didn't advertise the feature, it will never appear. */
@@ -182,5 +187,14 @@ struct virtqueue *virtio_find_single_vq(struct virtio_device *vdev,
 		return ERR_PTR(err);
 	return vq;
 }
+
+static inline
+const char *virtio_bus_name(struct virtio_device *vdev)
+{
+	if (!vdev->config->bus_name)
+		return "virtio";
+	return vdev->config->bus_name(vdev);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_VIRTIO_CONFIG_H */

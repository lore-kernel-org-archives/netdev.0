From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH net-next 1/3] virtio_pci: Introduce one new config api vp_get_vq_irq()
Date: Wed, 15 Jan 2014 22:20:52 +0800
Message-ID: <1389795654-28381-2-git-send-email-zwu.kernel@gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Cc: therbert@google.com, edumazet@google.com, davem@davemloft.net,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49074 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbaAOOVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 09:21:14 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 15 Jan 2014 09:21:13 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B10EBC9004A
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 09:21:06 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0FEL8id8978694
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 14:21:08 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0FEL7Wo004561
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 09:21:08 -0500
In-Reply-To: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

This config api is used to get irq number of the given virtqueue.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/virtio/virtio_pci.c   |   11 +++++++++++
 include/linux/virtio_config.h |   12 ++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index a37c699..85f1aa6 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -654,6 +654,16 @@ static int vp_set_vq_affinity(struct virtqueue *vq, int cpu)
 	return 0;
 }
 
+static int vp_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	struct virtio_pci_vq_info *info = vq->priv;
+
+	if (vp_dev->msix_enabled)
+		return vp_dev->msix_entries[info->msix_vector].vector;
+	return -1;
+}
+
 static const struct virtio_config_ops virtio_pci_config_ops = {
 	.get		= vp_get,
 	.set		= vp_set,
@@ -666,6 +676,7 @@ static const struct virtio_config_ops virtio_pci_config_ops = {
 	.finalize_features = vp_finalize_features,
 	.bus_name	= vp_bus_name,
 	.set_vq_affinity = vp_set_vq_affinity,
+	.get_vq_irq	= vp_get_vq_irq,
 };
 
 static void virtio_pci_release_dev(struct device *_d)
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index e8f8f71..b70fc47 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -51,6 +51,9 @@
  *      This returns a pointer to the bus name a la pci_name from which
  *      the caller can then copy.
  * @set_vq_affinity: set the affinity for a virtqueue.
+ * @get_vq_irq: get irq of the given virtqueue
+ *	vdev: the virtio_device
+ *	vq: the virtqueue
  */
 typedef void vq_callback_t(struct virtqueue *);
 struct virtio_config_ops {
@@ -70,6 +73,7 @@ struct virtio_config_ops {
 	void (*finalize_features)(struct virtio_device *vdev);
 	const char *(*bus_name)(struct virtio_device *vdev);
 	int (*set_vq_affinity)(struct virtqueue *vq, int cpu);
+	int (*get_vq_irq)(struct virtio_device *vdev, struct virtqueue *vq);
 };
 
 /* If driver didn't advertise the feature, it will never appear. */
@@ -135,6 +139,14 @@ int virtqueue_set_affinity(struct virtqueue *vq, int cpu)
 	return 0;
 }
 
+static inline
+int virtqueue_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	if (vdev->config->get_vq_irq)
+		return vdev->config->get_vq_irq(vdev, vq);
+	return -1;
+}
+
 /* Config space accessors. */
 #define virtio_cread(vdev, structname, member, ptr)			\
 	do {								\
-- 
1.7.6.5

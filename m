From: Ravi Kerur <rkerur@gmail.com>
Subject: [PATCH v1 2/3] virtio: vp_find_vqs accept channel setting params
Date: Mon, 26 Oct 2015 10:52:48 -0700
Message-ID: <1445881969-24663-2-git-send-email-rkerur@gmail.com>
References: <1445881969-24663-1-git-send-email-rkerur@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com, rusty@rustcorp.com.au,
	Ravi Kerur <rkerur@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33112 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbbJZRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:52:39 -0400
Received: by pabla5 with SMTP id la5so1606396pab.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 10:52:38 -0700 (PDT)
In-Reply-To: <1445881969-24663-1-git-send-email-rkerur@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port earlier patch from Jason Wang (dated 12/26/2014).

This patch lets vp_find_vqs function accept channel parameters.
For the transports that do not support channel currently, all
the parameters are ignored. For the device that does not use channel,
it can simply pass NULL to transport.

Signed-off-by: Ravi Kerur <rkerur@gmail.com>
---
 drivers/block/virtio_blk.c             |  3 ++-
 drivers/char/virtio_console.c          |  3 ++-
 drivers/gpu/drm/virtio/virtgpu_kms.c   |  3 ++-
 drivers/misc/mic/card/mic_virtio.c     |  5 ++++-
 drivers/net/caif/caif_virtio.c         |  3 ++-
 drivers/remoteproc/remoteproc_virtio.c |  9 ++++++---
 drivers/rpmsg/virtio_rpmsg_bus.c       |  3 ++-
 drivers/s390/virtio/kvm_virtio.c       |  5 ++++-
 drivers/s390/virtio/virtio_ccw.c       |  5 ++++-
 drivers/scsi/virtio_scsi.c             |  3 ++-
 drivers/virtio/virtio_balloon.c        |  3 ++-
 drivers/virtio/virtio_input.c          |  3 ++-
 drivers/virtio/virtio_mmio.c           |  9 ++++++---
 drivers/virtio/virtio_pci_modern.c     |  8 ++++++--
 include/linux/virtio_config.h          | 11 +++++++++--
 15 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index e93899c..7fb70b3 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -418,7 +418,8 @@ static int init_vq(struct virtio_blk *vblk)
 	}
 
 	/* Discover virtqueues and write information to configuration.  */
-	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names);
+	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names,
+				     NULL, NULL, 0);
 	if (err)
 		goto err_find_vqs;
 
diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index d2406fe..b316820 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -1923,7 +1923,8 @@ static int init_vqs(struct ports_device *portdev)
 	/* Find the queues. */
 	err = portdev->vdev->config->find_vqs(portdev->vdev, nr_queues, vqs,
 					      io_callbacks,
-					      (const char **)io_names);
+					      (const char **)io_names,
+					      NULL, NULL, 0);
 	if (err)
 		goto free;
 
diff --git a/drivers/gpu/drm/virtio/virtgpu_kms.c b/drivers/gpu/drm/virtio/virtgpu_kms.c
index 782766c..4e521c2f 100644
--- a/drivers/gpu/drm/virtio/virtgpu_kms.c
+++ b/drivers/gpu/drm/virtio/virtgpu_kms.c
@@ -100,7 +100,8 @@ int virtio_gpu_driver_load(struct drm_device *dev, unsigned long flags)
 		  virtio_gpu_config_changed_work_func);
 
 	ret = vgdev->vdev->config->find_vqs(vgdev->vdev, 2, vqs,
-					    callbacks, names);
+					    callbacks, names,
+					    NULL, NULL, 0);
 	if (ret) {
 		DRM_ERROR("failed to find virt queues\n");
 		goto err_vqs;
diff --git a/drivers/misc/mic/card/mic_virtio.c b/drivers/misc/mic/card/mic_virtio.c
index e486a0c..09c3f85 100644
--- a/drivers/misc/mic/card/mic_virtio.c
+++ b/drivers/misc/mic/card/mic_virtio.c
@@ -311,7 +311,10 @@ unmap:
 static int mic_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			struct virtqueue *vqs[],
 			vq_callback_t *callbacks[],
-			const char *names[])
+			const char *names[],
+			unsigned channels[],
+			const char *channel_names[],
+			unsigned nchannels)
 {
 	struct mic_vdev *mvdev = to_micvdev(vdev);
 	struct mic_device_ctrl __iomem *dc = mvdev->dc;
diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index b306210..150809d 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -679,7 +679,8 @@ static int cfv_probe(struct virtio_device *vdev)
 		goto err;
 
 	/* Get the TX virtio ring. This is a "guest side vring". */
-	err = vdev->config->find_vqs(vdev, 1, &cfv->vq_tx, &vq_cbs, &names);
+	err = vdev->config->find_vqs(vdev, 1, &cfv->vq_tx, &vq_cbs, &names,
+				     NULL, NULL, 0);
 	if (err)
 		goto err;
 
diff --git a/drivers/remoteproc/remoteproc_virtio.c b/drivers/remoteproc/remoteproc_virtio.c
index e1a1023..16b3532 100644
--- a/drivers/remoteproc/remoteproc_virtio.c
+++ b/drivers/remoteproc/remoteproc_virtio.c
@@ -145,9 +145,12 @@ static void rproc_virtio_del_vqs(struct virtio_device *vdev)
 }
 
 static int rproc_virtio_find_vqs(struct virtio_device *vdev, unsigned nvqs,
-		       struct virtqueue *vqs[],
-		       vq_callback_t *callbacks[],
-		       const char *names[])
+				 struct virtqueue *vqs[],
+				 vq_callback_t *callbacks[],
+				 const char *names[],
+				 unsigned channels[],
+				 const char *channel_names,
+				 unsigned nchannels)
 {
 	struct rproc *rproc = vdev_to_rproc(vdev);
 	int i, ret;
diff --git a/drivers/rpmsg/virtio_rpmsg_bus.c b/drivers/rpmsg/virtio_rpmsg_bus.c
index 73354ee..8421666 100644
--- a/drivers/rpmsg/virtio_rpmsg_bus.c
+++ b/drivers/rpmsg/virtio_rpmsg_bus.c
@@ -965,7 +965,8 @@ static int rpmsg_probe(struct virtio_device *vdev)
 	init_waitqueue_head(&vrp->sendq);
 
 	/* We expect two virtqueues, rx and tx (and in this order) */
-	err = vdev->config->find_vqs(vdev, 2, vqs, vq_cbs, names);
+	err = vdev->config->find_vqs(vdev, 2, vqs, vq_cbs, names,
+				     NULL, NULL, 0);
 	if (err)
 		goto free_vrp;
 
diff --git a/drivers/s390/virtio/kvm_virtio.c b/drivers/s390/virtio/kvm_virtio.c
index 53fb975..a60d5ae 100644
--- a/drivers/s390/virtio/kvm_virtio.c
+++ b/drivers/s390/virtio/kvm_virtio.c
@@ -255,7 +255,10 @@ static void kvm_del_vqs(struct virtio_device *vdev)
 static int kvm_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			struct virtqueue *vqs[],
 			vq_callback_t *callbacks[],
-			const char *names[])
+			const char *names[],
+			unsigned channels[],
+			const char *channel_names[],
+			unsigned nchannels)
 {
 	struct kvm_device *kdev = to_kvmdev(vdev);
 	int i;
diff --git a/drivers/s390/virtio/virtio_ccw.c b/drivers/s390/virtio/virtio_ccw.c
index e9fae30..4ed0463 100644
--- a/drivers/s390/virtio/virtio_ccw.c
+++ b/drivers/s390/virtio/virtio_ccw.c
@@ -626,7 +626,10 @@ out:
 static int virtio_ccw_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			       struct virtqueue *vqs[],
 			       vq_callback_t *callbacks[],
-			       const char *names[])
+			       const char *names[],
+			       unsigned channels[],
+			       const char *channel_names[],
+			       unsigned nchannels)
 {
 	struct virtio_ccw_device *vcdev = to_vc_device(vdev);
 	unsigned long *indicatorp = NULL;
diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 7dbbb29..06b54f6 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -919,7 +919,8 @@ static int virtscsi_init(struct virtio_device *vdev,
 	}
 
 	/* Discover virtqueues and write information to configuration.  */
-	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names);
+	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names,
+				     NULL, NULL, 0);
 	if (err)
 		goto out;
 
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 7efc329..a1a5dbc 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -396,7 +396,8 @@ static int init_vqs(struct virtio_balloon *vb)
 	 * optionally stat.
 	 */
 	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
+	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
+					 NULL, NULL, 0);
 	if (err)
 		return err;
 
diff --git a/drivers/virtio/virtio_input.c b/drivers/virtio/virtio_input.c
index c96944b..5493235 100644
--- a/drivers/virtio/virtio_input.c
+++ b/drivers/virtio/virtio_input.c
@@ -173,7 +173,8 @@ static int virtinput_init_vqs(struct virtio_input *vi)
 	static const char *names[] = { "events", "status" };
 	int err;
 
-	err = vi->vdev->config->find_vqs(vi->vdev, 2, vqs, cbs, names);
+	err = vi->vdev->config->find_vqs(vi->vdev, 2, vqs, cbs, names,
+					 NULL, NULL, 0);
 	if (err)
 		return err;
 	vi->evt = vqs[0];
diff --git a/drivers/virtio/virtio_mmio.c b/drivers/virtio/virtio_mmio.c
index f499d9d..8c9be80 100644
--- a/drivers/virtio/virtio_mmio.c
+++ b/drivers/virtio/virtio_mmio.c
@@ -480,9 +480,12 @@ error_available:
 }
 
 static int vm_find_vqs(struct virtio_device *vdev, unsigned nvqs,
-		       struct virtqueue *vqs[],
-		       vq_callback_t *callbacks[],
-		       const char *names[])
+			struct virtqueue *vqs[],
+			vq_callback_t *callbacks[],
+			const char *names[],
+			unsigned channels[],
+			const char *channel_names[],
+			unsigned nchannels)
 {
 	struct virtio_mmio_device *vm_dev = to_virtio_mmio_device(vdev);
 	unsigned int irq = platform_get_irq(vm_dev->pdev, 0);
diff --git a/drivers/virtio/virtio_pci_modern.c b/drivers/virtio/virtio_pci_modern.c
index 8e5cf19..c308983 100644
--- a/drivers/virtio/virtio_pci_modern.c
+++ b/drivers/virtio/virtio_pci_modern.c
@@ -418,11 +418,15 @@ err_new_queue:
 static int vp_modern_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			      struct virtqueue *vqs[],
 			      vq_callback_t *callbacks[],
-			      const char *names[])
+			      const char *names[],
+			      unsigned channels[],
+			      const char *channel_names[],
+			      unsigned nchannels)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	struct virtqueue *vq;
-	int rc = vp_find_vqs(vdev, nvqs, vqs, callbacks, names);
+	int rc = vp_find_vqs(vdev, nvqs, vqs, callbacks, names,
+			     NULL, NULL, 0);
 
 	if (rc)
 		return rc;
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index e5ce8ab..9c94a2f 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -41,6 +41,9 @@
  *		include a NULL entry for vqs that do not need a callback
  *	names: array of virtqueue names (mainly for debugging)
  *		include a NULL entry for vqs unused by driver
+ *	channels: array of channels each vq belong to
+ *	channel_names: names of channels
+ *	nchannels: number of channels
  *	Returns 0 on success or error status
  * @del_vqs: free virtqueues found by find_vqs().
  * @get_features: get the array of feature bits for this device.
@@ -70,7 +73,10 @@ struct virtio_config_ops {
 	int (*find_vqs)(struct virtio_device *, unsigned nvqs,
 			struct virtqueue *vqs[],
 			vq_callback_t *callbacks[],
-			const char *names[]);
+			const char *names[],
+			unsigned int channels[],
+			const char *channel_names,
+			unsigned nchannels);
 	void (*del_vqs)(struct virtio_device *);
 	u64 (*get_features)(struct virtio_device *vdev);
 	int (*finalize_features)(struct virtio_device *vdev);
@@ -156,7 +162,8 @@ struct virtqueue *virtio_find_single_vq(struct virtio_device *vdev,
 	vq_callback_t *callbacks[] = { c };
 	const char *names[] = { n };
 	struct virtqueue *vq;
-	int err = vdev->config->find_vqs(vdev, 1, &vq, callbacks, names);
+	int err = vdev->config->find_vqs(vdev, 1, &vq, callbacks, names,
+					 NULL, NULL, 0);
 	if (err < 0)
 		return ERR_PTR(err);
 	return vq;
-- 
1.9.1

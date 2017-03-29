From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/6] virtio: wrap find_vqs
Date: Wed, 29 Mar 2017 23:48:44 +0300
Message-ID: <1490820507-8005-2-git-send-email-mst@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>, kvm@vger.kernel.org,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, linux-scsi@vger.kernel.org,
	John Fastabend <john.fastabend@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>, Amit Shah <amit@kernel.org>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490820507-8005-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We are going to add more parameters to find_vqs, let's wrap the call so
we don't need to tweak all drivers every time.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/block/virtio_blk.c                 | 3 +--
 drivers/char/virtio_console.c              | 6 +++---
 drivers/crypto/virtio/virtio_crypto_core.c | 3 +--
 drivers/gpu/drm/virtio/virtgpu_kms.c       | 3 +--
 drivers/net/caif/caif_virtio.c             | 3 +--
 drivers/net/virtio_net.c                   | 3 +--
 drivers/rpmsg/virtio_rpmsg_bus.c           | 2 +-
 drivers/scsi/virtio_scsi.c                 | 3 +--
 drivers/virtio/virtio_balloon.c            | 3 +--
 drivers/virtio/virtio_input.c              | 3 +--
 include/linux/virtio_config.h              | 9 +++++++++
 net/vmw_vsock/virtio_transport.c           | 6 +++---
 12 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 1d4c9f8..c08c30c 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -455,8 +455,7 @@ static int init_vq(struct virtio_blk *vblk)
 	}
 
 	/* Discover virtqueues and write information to configuration.  */
-	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names,
-			&desc);
+	err = virtio_find_vqs(vdev, num_vqs, vqs, callbacks, names, &desc);
 	if (err)
 		goto out;
 
diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index e9b7e0b..5da4c8e 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -1945,9 +1945,9 @@ static int init_vqs(struct ports_device *portdev)
 		}
 	}
 	/* Find the queues. */
-	err = portdev->vdev->config->find_vqs(portdev->vdev, nr_queues, vqs,
-					      io_callbacks,
-					      (const char **)io_names, NULL);
+	err = virtio_find_vqs(portdev->vdev, nr_queues, vqs,
+			      io_callbacks,
+			      (const char **)io_names, NULL);
 	if (err)
 		goto free;
 
diff --git a/drivers/crypto/virtio/virtio_crypto_core.c b/drivers/crypto/virtio/virtio_crypto_core.c
index 21472e4..a111cd72 100644
--- a/drivers/crypto/virtio/virtio_crypto_core.c
+++ b/drivers/crypto/virtio/virtio_crypto_core.c
@@ -119,8 +119,7 @@ static int virtcrypto_find_vqs(struct virtio_crypto *vi)
 		names[i] = vi->data_vq[i].name;
 	}
 
-	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
-					 names, NULL);
+	ret = virtio_find_vqs(vi->vdev, total_vqs, vqs, callbacks, names, NULL);
 	if (ret)
 		goto err_find;
 
diff --git a/drivers/gpu/drm/virtio/virtgpu_kms.c b/drivers/gpu/drm/virtio/virtgpu_kms.c
index 4918668..1e1c90b 100644
--- a/drivers/gpu/drm/virtio/virtgpu_kms.c
+++ b/drivers/gpu/drm/virtio/virtgpu_kms.c
@@ -175,8 +175,7 @@ int virtio_gpu_driver_load(struct drm_device *dev, unsigned long flags)
 	DRM_INFO("virgl 3d acceleration not supported by guest\n");
 #endif
 
-	ret = vgdev->vdev->config->find_vqs(vgdev->vdev, 2, vqs,
-					    callbacks, names, NULL);
+	ret = virtio_find_vqs(vgdev->vdev, 2, vqs, callbacks, names, NULL);
 	if (ret) {
 		DRM_ERROR("failed to find virt queues\n");
 		goto err_vqs;
diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index bc0eb47..6122768 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -679,8 +679,7 @@ static int cfv_probe(struct virtio_device *vdev)
 		goto err;
 
 	/* Get the TX virtio ring. This is a "guest side vring". */
-	err = vdev->config->find_vqs(vdev, 1, &cfv->vq_tx, &vq_cbs, &names,
-			NULL);
+	err = virtio_find_vqs(vdev, 1, &cfv->vq_tx, &vq_cbs, &names, NULL);
 	if (err)
 		goto err;
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ea9890d..6802169 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2079,8 +2079,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 		names[txq2vq(i)] = vi->sq[i].name;
 	}
 
-	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
-					 names, NULL);
+	ret = virtio_find_vqs(vi->vdev, total_vqs, vqs, callbacks, names, NULL);
 	if (ret)
 		goto err_find;
 
diff --git a/drivers/rpmsg/virtio_rpmsg_bus.c b/drivers/rpmsg/virtio_rpmsg_bus.c
index 5e66e08..f7cade0 100644
--- a/drivers/rpmsg/virtio_rpmsg_bus.c
+++ b/drivers/rpmsg/virtio_rpmsg_bus.c
@@ -869,7 +869,7 @@ static int rpmsg_probe(struct virtio_device *vdev)
 	init_waitqueue_head(&vrp->sendq);
 
 	/* We expect two virtqueues, rx and tx (and in this order) */
-	err = vdev->config->find_vqs(vdev, 2, vqs, vq_cbs, names, NULL);
+	err = virtio_find_vqs(vdev, 2, vqs, vq_cbs, names, NULL);
 	if (err)
 		goto free_vrp;
 
diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 939c47d..e9222dc 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -870,8 +870,7 @@ static int virtscsi_init(struct virtio_device *vdev,
 	}
 
 	/* Discover virtqueues and write information to configuration.  */
-	err = vdev->config->find_vqs(vdev, num_vqs, vqs, callbacks, names,
-			&desc);
+	err = virtio_find_vqs(vdev, num_vqs, vqs, callbacks, names, &desc);
 	if (err)
 		goto out;
 
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 34adf9b..408c174 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -418,8 +418,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	 * optionally stat.
 	 */
 	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
-			NULL);
+	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/virtio/virtio_input.c b/drivers/virtio/virtio_input.c
index 79f1293..3a0468f 100644
--- a/drivers/virtio/virtio_input.c
+++ b/drivers/virtio/virtio_input.c
@@ -173,8 +173,7 @@ static int virtinput_init_vqs(struct virtio_input *vi)
 	static const char * const names[] = { "events", "status" };
 	int err;
 
-	err = vi->vdev->config->find_vqs(vi->vdev, 2, vqs, cbs, names,
-			NULL);
+	err = virtio_find_vqs(vi->vdev, 2, vqs, cbs, names, NULL);
 	if (err)
 		return err;
 	vi->evt = vqs[0];
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index 8355bab..47f3d80 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -179,6 +179,15 @@ struct virtqueue *virtio_find_single_vq(struct virtio_device *vdev,
 	return vq;
 }
 
+static inline
+int virtio_find_vqs(struct virtio_device *vdev, unsigned nvqs,
+			struct virtqueue *vqs[], vq_callback_t *callbacks[],
+			const char * const names[],
+			struct irq_affinity *desc)
+{
+	return vdev->config->find_vqs(vdev, nvqs, vqs, callbacks, names, desc);
+}
+
 /**
  * virtio_device_ready - enable vq use in probe function
  * @vdev: the device
diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 68675a1..97e26e2 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -573,9 +573,9 @@ static int virtio_vsock_probe(struct virtio_device *vdev)
 
 	vsock->vdev = vdev;
 
-	ret = vsock->vdev->config->find_vqs(vsock->vdev, VSOCK_VQ_MAX,
-					    vsock->vqs, callbacks, names,
-					    NULL);
+	ret = virtio_find_vqs(vsock->vdev, VSOCK_VQ_MAX,
+			      vsock->vqs, callbacks, names,
+			      NULL);
 	if (ret < 0)
 		goto out;
 
-- 
MST

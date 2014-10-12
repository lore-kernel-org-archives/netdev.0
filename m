From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 01/25] virtio_pci: fix virtio spec compliance on restore
Date: Sun, 12 Oct 2014 14:46:28 +0300
Message-ID: <1413114332-626-2-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
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

On restore, virtio pci does the following:
+ set features
+ init vqs etc - device can be used at this point!
+ set ACKNOWLEDGE,DRIVER and DRIVER_OK status bits

This is in violation of the virtio spec, which
requires the following order:
- ACKNOWLEDGE
- DRIVER
- init vqs
- DRIVER_OK

This behaviour will break with hypervisors that assume spec compliant
behaviour.  It seems like a good idea to have this patch applied to
stable branches to reduce the support butden for the hypervisors.

Cc: stable@vger.kernel.org
Cc: Amit Shah <amit.shah@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_pci.c | 33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 3d1463c..add40d0 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -789,6 +789,7 @@ static int virtio_pci_restore(struct device *dev)
 	struct pci_dev *pci_dev = to_pci_dev(dev);
 	struct virtio_pci_device *vp_dev = pci_get_drvdata(pci_dev);
 	struct virtio_driver *drv;
+	unsigned status = 0;
 	int ret;
 
 	drv = container_of(vp_dev->vdev.dev.driver,
@@ -799,14 +800,40 @@ static int virtio_pci_restore(struct device *dev)
 		return ret;
 
 	pci_set_master(pci_dev);
+	/* We always start by resetting the device, in case a previous
+	 * driver messed it up. */
+	vp_reset(&vp_dev->vdev);
+
+	/* Acknowledge that we've seen the device. */
+	status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
+	vp_set_status(&vp_dev->vdev, status);
+
+	/* Maybe driver failed before freeze.
+	 * Restore the failed status, for debugging. */
+	status |= vp_dev->saved_status & VIRTIO_CONFIG_S_FAILED;
+	vp_set_status(&vp_dev->vdev, status);
+
+	if (!drv)
+		return 0;
+
+	/* We have a driver! */
+	status |= VIRTIO_CONFIG_S_DRIVER;
+	vp_set_status(&vp_dev->vdev, status);
+
 	vp_finalize_features(&vp_dev->vdev);
 
-	if (drv && drv->restore)
+	if (drv->restore) {
 		ret = drv->restore(&vp_dev->vdev);
+		if (ret) {
+			status |= VIRTIO_CONFIG_S_FAILED;
+			vp_set_status(&vp_dev->vdev, status);
+			return ret;
+		}
+	}
 
 	/* Finally, tell the device we're all set */
-	if (!ret)
-		vp_set_status(&vp_dev->vdev, vp_dev->saved_status);
+	status |= VIRTIO_CONFIG_S_DRIVER_OK;
+	vp_set_status(&vp_dev->vdev, status);
 
 	return ret;
 }
-- 
MST

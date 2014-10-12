From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 24/25] virtio_scsi: drop scan callback
Date: Sun, 12 Oct 2014 14:48:33 +0300
Message-ID: <1413114332-626-25-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable VQs early like we do for restore.
This makes it possible to drop the scan callback,
moving scanning into the probe function, and making
code simpler.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/scsi/virtio_scsi.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 327eba0..5f022ff 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -860,17 +860,6 @@ static void virtscsi_init_vq(struct virtio_scsi_vq *virtscsi_vq,
 	virtscsi_vq->vq = vq;
 }
 
-static void virtscsi_scan(struct virtio_device *vdev)
-{
-	struct Scsi_Host *shost = virtio_scsi_host(vdev);
-	struct virtio_scsi *vscsi = shost_priv(shost);
-
-	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
-		virtscsi_kick_event_all(vscsi);
-
-	scsi_scan_host(shost);
-}
-
 static void virtscsi_remove_vqs(struct virtio_device *vdev)
 {
 	struct Scsi_Host *sh = virtio_scsi_host(vdev);
@@ -1007,10 +996,13 @@ static int virtscsi_probe(struct virtio_device *vdev)
 	err = scsi_add_host(shost, &vdev->dev);
 	if (err)
 		goto scsi_add_host_failed;
-	/*
-	 * scsi_scan_host() happens in virtscsi_scan() via virtio_driver->scan()
-	 * after VIRTIO_CONFIG_S_DRIVER_OK has been set..
-	 */
+
+	virtio_enable_vqs_early(vdev);
+
+	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
+		virtscsi_kick_event_all(vscsi);
+
+	scsi_scan_host(shost);
 	return 0;
 
 scsi_add_host_failed:
@@ -1090,7 +1082,6 @@ static struct virtio_driver virtio_scsi_driver = {
 	.driver.owner = THIS_MODULE,
 	.id_table = id_table,
 	.probe = virtscsi_probe,
-	.scan = virtscsi_scan,
 #ifdef CONFIG_PM_SLEEP
 	.freeze = virtscsi_freeze,
 	.restore = virtscsi_restore,
-- 
MST


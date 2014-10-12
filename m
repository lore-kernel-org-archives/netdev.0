From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 16/25] virtio_scsi: move kick event out from virtscsi_init
Date: Sun, 12 Oct 2014 14:47:50 +0300
Message-ID: <1413114332-626-17-git-send-email-mst@redhat.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031AbaJLLom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2014 07:44:42 -0400
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently kick event within virtscsi_init,
before host is fully initialized.

This can in theory confuse guest if device
consumes the buffers immediately.

To fix,  move virtscsi_kick_event_all out to scan/restore.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/scsi/virtio_scsi.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index eee1bc0..0642ce3 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -853,7 +853,11 @@ static void virtscsi_init_vq(struct virtio_scsi_vq *virtscsi_vq,
 
 static void virtscsi_scan(struct virtio_device *vdev)
 {
-	struct Scsi_Host *shost = (struct Scsi_Host *)vdev->priv;
+	struct Scsi_Host *shost = virtio_scsi_host(vdev);
+	struct virtio_scsi *vscsi = shost_priv(shost);
+
+	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
+		virtscsi_kick_event_all(vscsi);
 
 	scsi_scan_host(shost);
 }
@@ -916,9 +920,6 @@ static int virtscsi_init(struct virtio_device *vdev,
 	virtscsi_config_set(vdev, cdb_size, VIRTIO_SCSI_CDB_SIZE);
 	virtscsi_config_set(vdev, sense_size, VIRTIO_SCSI_SENSE_SIZE);
 
-	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
-		virtscsi_kick_event_all(vscsi);
-
 	err = 0;
 
 out:
@@ -1048,8 +1049,13 @@ static int virtscsi_restore(struct virtio_device *vdev)
 		return err;
 
 	err = register_hotcpu_notifier(&vscsi->nb);
-	if (err)
+	if (err) {
 		vdev->config->del_vqs(vdev);
+		return err;
+	}
+
+	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
+		virtscsi_kick_event_all(vscsi);
 
 	return err;
 }
-- 
MST

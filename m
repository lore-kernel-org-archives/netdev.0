From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 17/25] virtio_blk: enable VQs early on restore
Date: Mon, 13 Oct 2014 10:51:09 +0300
Message-ID: <1413114332-626-18-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
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
	Paolo Bonzini <pbonzini@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after restore returns, virtio block violated
this rule on restore by restarting queues, which might in theory
cause the VQ to be used directly within restore.

To fix, call virtio_device_ready before using starting queues.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/block/virtio_blk.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 46b04bf..1c95af5 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -804,10 +804,13 @@ static int virtblk_restore(struct virtio_device *vdev)
 	int ret;
 
 	ret = init_vq(vdev->priv);
-	if (!ret)
-		blk_mq_start_stopped_hw_queues(vblk->disk->queue, true);
+	if (ret)
+		return ret;
+
+	virtio_device_ready(vdev);
 
-	return ret;
+	blk_mq_start_stopped_hw_queues(vblk->disk->queue, true);
+	return 0;
 }
 #endif
 
-- 
MST



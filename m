From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 05/25] virtio_blk: drop config_enable
Date: Mon, 13 Oct 2014 10:50:09 +0300
Message-ID: <1413114332-626-6-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
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

Now that virtio core ensures config changes don't
arrive during probing, drop config_enable flag
in virtio blk.
On removal, flush is now sufficient to guarantee that
no change work is queued.

This help simplify the driver, and will allow
setting DRIVER_OK earlier without losing config
change notifications.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/block/virtio_blk.c | 23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 0a58140..91272f1a 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -44,9 +44,6 @@ struct virtio_blk
 	/* Lock for config space updates */
 	struct mutex config_lock;
 
-	/* enable config space updates */
-	bool config_enable;
-
 	/* What host tells us, plus 2 for header & tailer. */
 	unsigned int sg_elems;
 
@@ -348,8 +345,6 @@ static void virtblk_config_changed_work(struct work_struct *work)
 	u64 capacity, size;
 
 	mutex_lock(&vblk->config_lock);
-	if (!vblk->config_enable)
-		goto done;
 
 	/* Host must always specify the capacity. */
 	virtio_cread(vdev, struct virtio_blk_config, capacity, &capacity);
@@ -374,7 +369,7 @@ static void virtblk_config_changed_work(struct work_struct *work)
 	set_capacity(vblk->disk, capacity);
 	revalidate_disk(vblk->disk);
 	kobject_uevent_env(&disk_to_dev(vblk->disk)->kobj, KOBJ_CHANGE, envp);
-done:
+
 	mutex_unlock(&vblk->config_lock);
 }
 
@@ -609,7 +604,6 @@ static int virtblk_probe(struct virtio_device *vdev)
 	mutex_init(&vblk->config_lock);
 
 	INIT_WORK(&vblk->config_work, virtblk_config_changed_work);
-	vblk->config_enable = true;
 
 	err = init_vq(vblk);
 	if (err)
@@ -771,10 +765,8 @@ static void virtblk_remove(struct virtio_device *vdev)
 	int index = vblk->index;
 	int refc;
 
-	/* Prevent config work handler from accessing the device. */
-	mutex_lock(&vblk->config_lock);
-	vblk->config_enable = false;
-	mutex_unlock(&vblk->config_lock);
+	/* Make sure no work handler is accessing the device. */
+	flush_work(&vblk->config_work);
 
 	del_gendisk(vblk->disk);
 	blk_cleanup_queue(vblk->disk->queue);
@@ -784,8 +776,6 @@ static void virtblk_remove(struct virtio_device *vdev)
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-	flush_work(&vblk->config_work);
-
 	refc = atomic_read(&disk_to_dev(vblk->disk)->kobj.kref.refcount);
 	put_disk(vblk->disk);
 	vdev->config->del_vqs(vdev);
@@ -805,11 +795,7 @@ static int virtblk_freeze(struct virtio_device *vdev)
 	/* Ensure we don't receive any more interrupts */
 	vdev->config->reset(vdev);
 
-	/* Prevent config work handler from accessing the device. */
-	mutex_lock(&vblk->config_lock);
-	vblk->config_enable = false;
-	mutex_unlock(&vblk->config_lock);
-
+	/* Make sure no work handler is accessing the device. */
 	flush_work(&vblk->config_work);
 
 	blk_mq_stop_hw_queues(vblk->disk->queue);
@@ -823,7 +809,6 @@ static int virtblk_restore(struct virtio_device *vdev)
 	struct virtio_blk *vblk = vdev->priv;
 	int ret;
 
-	vblk->config_enable = true;
 	ret = init_vq(vdev->priv);
 	if (!ret)
 		blk_mq_start_stopped_hw_queues(vblk->disk->queue, true);
-- 
MST

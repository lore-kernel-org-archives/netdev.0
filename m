From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 06/25] virtio-blk: drop config_mutex
Date: Mon, 13 Oct 2014 10:50:14 +0300
Message-ID: <1413114332-626-7-git-send-email-mst-v4@redhat.com>
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

config_mutex served two purposes: prevent multiple concurrent config
change handlers, and synchronize access to config_enable flag.

Since commit dbf2576e37da0fcc7aacbfbb9fd5d3de7888a3c1
    workqueue: make all workqueues non-reentrant
all workqueues are non-reentrant, and config_enable
is now gone.

Get rid of the unnecessary lock.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/block/virtio_blk.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 91272f1a..89ba8d6 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -41,9 +41,6 @@ struct virtio_blk
 	/* Process context for config space updates */
 	struct work_struct config_work;
 
-	/* Lock for config space updates */
-	struct mutex config_lock;
-
 	/* What host tells us, plus 2 for header & tailer. */
 	unsigned int sg_elems;
 
@@ -344,8 +341,6 @@ static void virtblk_config_changed_work(struct work_struct *work)
 	char *envp[] = { "RESIZE=1", NULL };
 	u64 capacity, size;
 
-	mutex_lock(&vblk->config_lock);
-
 	/* Host must always specify the capacity. */
 	virtio_cread(vdev, struct virtio_blk_config, capacity, &capacity);
 
@@ -369,8 +364,6 @@ static void virtblk_config_changed_work(struct work_struct *work)
 	set_capacity(vblk->disk, capacity);
 	revalidate_disk(vblk->disk);
 	kobject_uevent_env(&disk_to_dev(vblk->disk)->kobj, KOBJ_CHANGE, envp);
-
-	mutex_unlock(&vblk->config_lock);
 }
 
 static void virtblk_config_changed(struct virtio_device *vdev)
@@ -601,7 +594,6 @@ static int virtblk_probe(struct virtio_device *vdev)
 
 	vblk->vdev = vdev;
 	vblk->sg_elems = sg_elems;
-	mutex_init(&vblk->config_lock);
 
 	INIT_WORK(&vblk->config_work, virtblk_config_changed_work);
 
-- 
MST

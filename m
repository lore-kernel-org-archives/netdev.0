From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 22/25] virtio_scsi: fix race on device removal
Date: Mon, 13 Oct 2014 10:51:34 +0300
Message-ID: <1413114332-626-23-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
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

We cancel event work on device removal, but an interrupt
could trigger immediately after this, and queue it
again.

To fix, set a flag.

Loosely based on patch by Paolo Bonzini

Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/scsi/virtio_scsi.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 501838d..327eba0 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -110,6 +110,9 @@ struct virtio_scsi {
 	/* CPU hotplug notifier */
 	struct notifier_block nb;
 
+	/* Protected by event_vq lock */
+	bool stop_events;
+
 	struct virtio_scsi_vq ctrl_vq;
 	struct virtio_scsi_vq event_vq;
 	struct virtio_scsi_vq req_vqs[];
@@ -303,6 +306,11 @@ static void virtscsi_cancel_event_work(struct virtio_scsi *vscsi)
 {
 	int i;
 
+	/* Stop scheduling work before calling cancel_work_sync.  */
+	spin_lock_irq(&vscsi->event_vq.vq_lock);
+	vscsi->stop_events = true;
+	spin_unlock_irq(&vscsi->event_vq.vq_lock);
+
 	for (i = 0; i < VIRTIO_SCSI_EVENT_LEN; i++)
 		cancel_work_sync(&vscsi->event_list[i].work);
 }
@@ -390,7 +398,8 @@ static void virtscsi_complete_event(struct virtio_scsi *vscsi, void *buf)
 {
 	struct virtio_scsi_event_node *event_node = buf;
 
-	queue_work(system_freezable_wq, &event_node->work);
+	if (!vscsi->stop_events)
+		queue_work(system_freezable_wq, &event_node->work);
 }
 
 static void virtscsi_event_done(struct virtqueue *vq)
-- 
MST

From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 04/18] virtio: don't delay avail index update
Date: Wed, 4 May 2011 23:51:01 +0300
Message-ID: <6306caf796b0ebe38bb9acf9b54d18b1effbfc8f.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update avail index immediately instead of upon kick:
for virtio-net RX this helps parallelism with the host.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 059e02d..507d6eb 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -86,8 +86,6 @@ struct vring_virtqueue
 	unsigned int num_free;
 	/* Head of free buffer list. */
 	unsigned int free_head;
-	/* Number we've added since last sync. */
-	unsigned int num_added;
 
 	/* Last used index we've seen. */
 	u16 last_used_idx;
@@ -224,8 +222,12 @@ add_head:
 
 	/* Put entry in available array (but don't update avail->idx until they
 	 * do sync).  FIXME: avoid modulus here? */
-	avail = (vq->vring.avail->idx + vq->num_added++) % vq->vring.num;
+	avail = vq->vring.avail->idx % vq->vring.num;
 	vq->vring.avail->ring[avail] = head;
+	/* Descriptors and available array need to be set before we expose the
+	 * new available array entries. */
+	virtio_wmb();
+	vq->vring.avail->idx++;
 
 	pr_debug("Added buffer head %i to %p\n", head, vq);
 	END_USE(vq);
@@ -238,12 +240,6 @@ void virtqueue_kick(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	START_USE(vq);
-	/* Descriptors and available array need to be set before we expose the
-	 * new available array entries. */
-	virtio_wmb();
-
-	vq->vring.avail->idx += vq->num_added;
-	vq->num_added = 0;
 
 	/* Need to update avail index before checking if we should notify */
 	virtio_mb();
@@ -430,7 +426,6 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->notify = notify;
 	vq->broken = false;
 	vq->last_used_idx = 0;
-	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
 	vq->in_use = false;
-- 
1.7.5.53.gc233e

From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] virtio: correct the memory barrier in
	virtqueue_kick_prepare()
Date: Fri, 20 Jan 2012 16:17:08 +0800
Message-ID: <20120120081708.50747.60241.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

Use virtio_mb() to make sure the available index to be exposed before
checking the the avail event. Otherwise we may get stale value of
avail event in guest and never kick the host after.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 78428a8..07d9360 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -308,9 +308,9 @@ bool virtqueue_kick_prepare(struct virtqueue *_vq)
 	bool needs_kick;
 
 	START_USE(vq);
-	/* Descriptors and available array need to be set before we expose the
-	 * new available array entries. */
-	virtio_wmb(vq);
+	/* We need expose available array entries before checking avail
+	 * event. */
+	virtio_mb(vq);
 
 	old = vq->vring.avail->idx - vq->num_added;
 	new = vq->vring.avail->idx;

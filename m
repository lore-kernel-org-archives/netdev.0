From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost-net: switch to smp barriers
Date: Mon, 1 Feb 2010 19:21:02 +0200
Message-ID: <20100201172101.GA10900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vhost-net only uses memory barriers to control SMP effects
(communication with userspace potentially running on a different CPU),
so it should use SMP barriers and not mandatory barriers for memory
access ordering, as suggested by Documentation/memory-barriers.txt

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

The above applies on top of net-next-2.6. Does not seem to give any
measureable performance gain, but seems to generate less code
and I think it's better to use correct APIs.

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c8c25db..6eb1525 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -685,7 +685,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 	int i, r;
 
 	/* Make sure data written is seen before log. */
-	wmb();
+	smp_wmb();
 	for (i = 0; i < log_num; ++i) {
 		u64 l = min(log[i].len, len);
 		r = log_write(vq->log_base, log[i].addr, l);
@@ -884,7 +884,7 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 		return vq->num;
 
 	/* Only get avail ring entries after they have been exposed by guest. */
-	rmb();
+	smp_rmb();
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
@@ -996,14 +996,14 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 		return -EFAULT;
 	}
 	/* Make sure buffer is written before we update index. */
-	wmb();
+	smp_wmb();
 	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
 		vq_err(vq, "Failed to increment used idx");
 		return -EFAULT;
 	}
 	if (unlikely(vq->log_used)) {
 		/* Make sure data is seen before log. */
-		wmb();
+		smp_wmb();
 		log_write(vq->log_base, vq->log_addr + sizeof *vq->used->ring *
 			  (vq->last_used_idx % vq->num),
 			  sizeof *vq->used->ring);
@@ -1060,7 +1060,7 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 	}
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
-	mb();
+	smp_mb();
 	r = get_user(avail_idx, &vq->avail->idx);
 	if (r) {
 		vq_err(vq, "Failed to check avail idx at %p: %d\n",
-- 
1.6.6.144.g5c3af

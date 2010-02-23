From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/3] vhost: logging math fix
Date: Tue, 23 Feb 2010 18:57:43 +0200
Message-ID: <51e0f786b06c198ab355abab19f0bd11ac6a167b.1266943453.git.mst@redhat.com>
References: <cover.1266943453.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	ma
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1266943453.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vhost was dong some complex math to get
offset to log at, and got it wrong by a couple of bytes,
while in fact it's simple: get address where we write,
subtract start of buffer, add log base.

Do it this way.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 6eb1525..c767279 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1004,10 +1004,12 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 	if (unlikely(vq->log_used)) {
 		/* Make sure data is seen before log. */
 		smp_wmb();
-		log_write(vq->log_base, vq->log_addr + sizeof *vq->used->ring *
-			  (vq->last_used_idx % vq->num),
-			  sizeof *vq->used->ring);
-		log_write(vq->log_base, vq->log_addr, sizeof *vq->used->ring);
+		log_write(vq->log_base,
+			  vq->log_addr + ((void *)used - (void *)vq->used),
+			  sizeof *used);
+		log_write(vq->log_base,
+			  vq->log_addr + offsetof(struct vring_used, idx),
+			  sizeof vq->used->idx);
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
-- 
1.7.0.18.g0d53a5

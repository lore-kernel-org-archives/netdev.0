From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: fix barrier pairing
Date: Tue, 11 May 2010 20:26:33 +0300
Message-ID: <20100511172633.GA9091@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932195Ab0EKRak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 13:30:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to memory-barriers.txt, an smp memory barrier
should always be paired with another smp memory barrier,
and I quote "a lack of appropriate pairing is almost certainly an
error".

In case of vhost, failure to flush out used index
update before looking at the interrupt disable flag
could result in missed interrupts, resulting in
networking hang under stress.

This might happen when flags read bypasses used index write.
So we see interrupts disabled and do not interrupt, at the
same time guest writes flags value to enable interrupt,
reads an old used index value, thinks that
used ring is empty and waits for interrupt.

Note: the barrier we pair with here is in
drivers/virtio/virtio_ring.c, function
vring_enable_cb.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, I think this is needed in 2.6.34, I'll send a pull
request after doing some more testing.

Rusty, Juan, could you take a look as well please?
Thanks!

 drivers/vhost/vhost.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e69d238..14fa2f5 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1035,7 +1035,10 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 /* This actually signals the guest, using eventfd. */
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
-	__u16 flags = 0;
+	__u16 flags;
+	/* Flush out used index updates. */
+	smp_mb();
+
 	if (get_user(flags, &vq->avail->flags)) {
 		vq_err(vq, "Failed to get flags");
 		return;
-- 
1.7.1.12.g42b7f

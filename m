From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] VSOCK: fix vhost virtio_vsock_pkt use-after-free
Date: Thu,  4 Aug 2016 14:52:53 +0100
Message-ID: <1470318773-10414-1-git-send-email-stefanha@redhat.com>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stash the packet length in a local variable before handing over
ownership of the packet to virtio_transport_recv_pkt() or
virtio_transport_free_pkt().

This patch solves the use-after-free since pkt is no longer guaranteed
to be alive.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/vsock.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 0ddf3a2..e3b30ea 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -307,6 +307,8 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 
 	vhost_disable_notify(&vsock->dev, vq);
 	for (;;) {
+		u32 len;
+
 		if (!vhost_vsock_more_replies(vsock)) {
 			/* Stop tx until the device processes already
 			 * pending replies.  Leave tx virtqueue
@@ -334,13 +336,15 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 			continue;
 		}
 
+		len = pkt->len;
+
 		/* Only accept correctly addressed packets */
 		if (le64_to_cpu(pkt->hdr.src_cid) == vsock->guest_cid)
 			virtio_transport_recv_pkt(pkt);
 		else
 			virtio_transport_free_pkt(pkt);
 
-		vhost_add_used(vq, head, sizeof(pkt->hdr) + pkt->len);
+		vhost_add_used(vq, head, sizeof(pkt->hdr) + len);
 		added = true;
 	}
 
-- 
2.7.4


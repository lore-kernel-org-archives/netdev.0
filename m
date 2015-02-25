From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: cleanup iterator update logic
Date: Wed, 25 Feb 2015 15:19:28 +0100
Message-ID: <1424873954-16631-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent iterator-related changes in vhost made it
harder to follow the logic fixing up the header.
In fact, the fixup always happens at the same
offset: sizeof(virtio_net_hdr): sometimes the
fixup iterator is updated by copy_to_iter,
sometimes-by iov_iter_advance.

Rearrange code to make this obvious.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index afa06d2..ca70434 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -591,11 +591,6 @@ static void handle_rx(struct vhost_net *net)
 			 * TODO: support TSO.
 			 */
 			iov_iter_advance(&msg.msg_iter, vhost_hlen);
-		} else {
-			/* It'll come from socket; we'll need to patch
-			 * ->num_buffers over if VIRTIO_NET_F_MRG_RXBUF
-			 */
-			iov_iter_advance(&fixup, sizeof(hdr));
 		}
 		err = sock->ops->recvmsg(NULL, sock, &msg,
 					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
@@ -609,11 +604,18 @@ static void handle_rx(struct vhost_net *net)
 			continue;
 		}
 		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
-		if (unlikely(vhost_hlen) &&
-		    copy_to_iter(&hdr, sizeof(hdr), &fixup) != sizeof(hdr)) {
-			vq_err(vq, "Unable to write vnet_hdr at addr %p\n",
-			       vq->iov->iov_base);
-			break;
+		if (unlikely(vhost_hlen)) {
+			if (copy_to_iter(&hdr, sizeof(hdr),
+					 &fixup) != sizeof(hdr)) {
+				vq_err(vq, "Unable to write vnet_hdr "
+				       "at addr %p\n", vq->iov->iov_base);
+				break;
+			}
+		} else {
+			/* Header came from socket; we'll need to patch
+			 * ->num_buffers over if VIRTIO_NET_F_MRG_RXBUF
+			 */
+			iov_iter_advance(&fixup, sizeof(hdr));
 		}
 		/* TODO: Should check and handle checksum. */
 
-- 
MST

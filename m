From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] vhost_net: fix wrong iter offset when setting number of buffers
Date: Sun, 15 Feb 2015 16:35:17 +0800
Message-ID: <1423989317-16038-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit ba7438aed924 ("vhost: don't bother copying iovecs in
handle_rx(), kill memcpy_toiovecend()"), we advance iov iter fixup
sizeof(struct virtio_net_hdr) bytes and fill the number of buffers
after doing the socket recvmsg(). This work well but was broken after
commit 6e03f896b52c ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") which tries
to advance sizeof(struct virtio_net_hdr_mrg_rxbuf). It will fill the
number of buffers at the wrong place. This patch fixes this.

Fixes 6e03f896b52c
("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
Cc: David S. Miller <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8dccca9..afa06d2 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -528,9 +528,9 @@ static void handle_rx(struct vhost_net *net)
 		.msg_controllen = 0,
 		.msg_flags = MSG_DONTWAIT,
 	};
-	struct virtio_net_hdr_mrg_rxbuf hdr = {
-		.hdr.flags = 0,
-		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	struct virtio_net_hdr hdr = {
+		.flags = 0,
+		.gso_type = VIRTIO_NET_HDR_GSO_NONE
 	};
 	size_t total_len = 0;
 	int err, mergeable;
@@ -539,6 +539,7 @@ static void handle_rx(struct vhost_net *net)
 	size_t vhost_len, sock_len;
 	struct socket *sock;
 	struct iov_iter fixup;
+	__virtio16 num_buffers;
 
 	mutex_lock(&vq->mutex);
 	sock = vq->private_data;
@@ -616,9 +617,9 @@ static void handle_rx(struct vhost_net *net)
 		}
 		/* TODO: Should check and handle checksum. */
 
-		hdr.num_buffers = cpu_to_vhost16(vq, headcount);
+		num_buffers = cpu_to_vhost16(vq, headcount);
 		if (likely(mergeable) &&
-		    copy_to_iter(&hdr.num_buffers, 2, &fixup) != 2) {
+		    copy_to_iter(&num_buffers, 2, &fixup) != 2) {
 			vq_err(vq, "Failed num_buffers write");
 			vhost_discard_vq_desc(vq, headcount);
 			break;
-- 
1.9.1

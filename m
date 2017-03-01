From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH-v4-RESEND 3/4] vsock: add pkt cancel capability
Date: Wed,  1 Mar 2017 11:56:26 +0800
Message-ID: <1488340587-32416-4-git-send-email-bergwolf@gmail.com>
References: <1488340587-32416-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>, Jorgen Hansen <jhansen@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1488340587-32416-1-git-send-email-bergwolf@gmail.com>
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

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 net/vmw_vsock/virtio_transport.c | 42 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 6788264..f5c44b5 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -213,6 +213,47 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 	return len;
 }
 
+static int
+virtio_transport_cancel_pkt(struct vsock_sock *vsk)
+{
+	struct virtio_vsock *vsock;
+	struct virtio_vsock_pkt *pkt, *n;
+	int cnt = 0;
+	LIST_HEAD(freeme);
+
+	vsock = virtio_vsock_get();
+	if (!vsock) {
+		return -ENODEV;
+	}
+
+	spin_lock_bh(&vsock->send_pkt_list_lock);
+	list_for_each_entry_safe(pkt, n, &vsock->send_pkt_list, list) {
+		if (pkt->cancel_token != vsk)
+			continue;
+		list_move(&pkt->list, &freeme);
+	}
+	spin_unlock_bh(&vsock->send_pkt_list_lock);
+
+	list_for_each_entry_safe(pkt, n, &freeme, list) {
+		if (pkt->reply)
+			cnt++;
+		list_del(&pkt->list);
+		virtio_transport_free_pkt(pkt);
+	}
+
+	if (cnt) {
+		struct virtqueue *rx_vq = vsock->vqs[VSOCK_VQ_RX];
+		int new_cnt;
+
+		new_cnt = atomic_sub_return(cnt, &vsock->queued_replies);
+		if (new_cnt + cnt >= virtqueue_get_vring_size(rx_vq) &&
+		    new_cnt < virtqueue_get_vring_size(rx_vq))
+			queue_work(virtio_vsock_workqueue, &vsock->rx_work);
+	}
+
+	return 0;
+}
+
 static void virtio_vsock_rx_fill(struct virtio_vsock *vsock)
 {
 	int buf_len = VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE;
@@ -462,6 +503,7 @@ static struct virtio_transport virtio_transport = {
 		.release                  = virtio_transport_release,
 		.connect                  = virtio_transport_connect,
 		.shutdown                 = virtio_transport_shutdown,
+		.cancel_pkt               = virtio_transport_cancel_pkt,
 
 		.dgram_bind               = virtio_transport_dgram_bind,
 		.dgram_dequeue            = virtio_transport_dgram_dequeue,
-- 
2.7.4

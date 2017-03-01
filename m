From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH-v4-RESEND 2/4] vhost-vsock: add pkt cancel capability
Date: Wed,  1 Mar 2017 11:56:25 +0800
Message-ID: <1488340587-32416-3-git-send-email-bergwolf@gmail.com>
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

To allow canceling all packets of a connection.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 drivers/vhost/vsock.c  | 41 +++++++++++++++++++++++++++++++++++++++++
 include/net/af_vsock.h |  3 +++
 2 files changed, 44 insertions(+)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index ce5e63d..57babce 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -223,6 +223,46 @@ vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 	return len;
 }
 
+static int
+vhost_transport_cancel_pkt(struct vsock_sock *vsk)
+{
+	struct vhost_vsock *vsock;
+	struct virtio_vsock_pkt *pkt, *n;
+	int cnt = 0;
+	LIST_HEAD(freeme);
+
+	/* Find the vhost_vsock according to guest context id  */
+	vsock = vhost_vsock_get(vsk->remote_addr.svm_cid);
+	if (!vsock)
+		return -ENODEV;
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
+		struct vhost_virtqueue *tx_vq = &vsock->vqs[VSOCK_VQ_TX];
+		int new_cnt;
+
+		new_cnt = atomic_sub_return(cnt, &vsock->queued_replies);
+		if (new_cnt + cnt >= tx_vq->num && new_cnt < tx_vq->num)
+			vhost_poll_queue(&tx_vq->poll);
+	}
+
+	return 0;
+}
+
 static struct virtio_vsock_pkt *
 vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 		      unsigned int out, unsigned int in)
@@ -675,6 +715,7 @@ static struct virtio_transport vhost_transport = {
 		.release                  = virtio_transport_release,
 		.connect                  = virtio_transport_connect,
 		.shutdown                 = virtio_transport_shutdown,
+		.cancel_pkt               = vhost_transport_cancel_pkt,
 
 		.dgram_enqueue            = virtio_transport_dgram_enqueue,
 		.dgram_dequeue            = virtio_transport_dgram_dequeue,
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index f275896..f32ed9a 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -100,6 +100,9 @@ struct vsock_transport {
 	void (*destruct)(struct vsock_sock *);
 	void (*release)(struct vsock_sock *);
 
+	/* Cancel all pending packets sent on vsock. */
+	int (*cancel_pkt)(struct vsock_sock *vsk);
+
 	/* Connections. */
 	int (*connect)(struct vsock_sock *);
 
-- 
2.7.4

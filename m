From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH v3 2/4] vhost-vsock: add pkt cancel capability
Date: Fri,  9 Dec 2016 01:12:34 +0800
Message-ID: <1481217156-7160-3-git-send-email-bergwolf@gmail.com>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-2-git-send-email-bergwolf@gmail.com>
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        Jorgen Hansen <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34636 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753822AbcLHRNX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:13:23 -0500
In-Reply-To: <1481217156-7160-2-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow canceling all packets of a connection.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 drivers/vhost/vsock.c  | 41 +++++++++++++++++++++++++++++++++++++++++
 include/net/af_vsock.h |  3 +++
 2 files changed, 44 insertions(+)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index a504e2e0..db64d51 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -218,6 +218,46 @@ vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
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
+		if (pkt->cancel_token != (void *)vsk)
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
@@ -664,6 +704,7 @@ static struct virtio_transport vhost_transport = {
 		.release                  = virtio_transport_release,
 		.connect                  = virtio_transport_connect,
 		.shutdown                 = virtio_transport_shutdown,
+		.cancel_pkt               = vhost_transport_cancel_pkt,
 
 		.dgram_enqueue            = virtio_transport_dgram_enqueue,
 		.dgram_dequeue            = virtio_transport_dgram_dequeue,
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index f275896..ce5f100 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -100,6 +100,9 @@ struct vsock_transport {
 	void (*destruct)(struct vsock_sock *);
 	void (*release)(struct vsock_sock *);
 
+	/* Cancel packets belonging the same vsock */
+	int (*cancel_pkt)(struct vsock_sock *vsk);
+
 	/* Connections. */
 	int (*connect)(struct vsock_sock *);
 
-- 
2.7.4

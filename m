From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH-v4-RESEND 1/4] vsock: track pkt owner vsock
Date: Wed,  1 Mar 2017 11:56:24 +0800
Message-ID: <1488340587-32416-2-git-send-email-bergwolf@gmail.com>
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

So that we can cancel a queued pkt later if necessary.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 include/linux/virtio_vsock.h            | 2 ++
 net/vmw_vsock/virtio_transport_common.c | 7 +++++++
 2 files changed, 9 insertions(+)

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index 9638bfe..193ad3a 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
 	struct virtio_vsock_hdr	hdr;
 	struct work_struct work;
 	struct list_head list;
+	void *cancel_token; /* only used for cancellation */
 	void *buf;
 	u32 len;
 	u32 off;
@@ -56,6 +57,7 @@ struct virtio_vsock_pkt {
 
 struct virtio_vsock_pkt_info {
 	u32 remote_cid, remote_port;
+	struct vsock_sock *vsk;
 	struct msghdr *msg;
 	u32 pkt_len;
 	u16 type;
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 849c4ad..ab505f1 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -57,6 +57,7 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 	pkt->len		= len;
 	pkt->hdr.len		= cpu_to_le32(len);
 	pkt->reply		= info->reply;
+	pkt->cancel_token	= info->vsk;
 
 	if (info->msg && len > 0) {
 		pkt->buf = kmalloc(len, GFP_KERNEL);
@@ -179,6 +180,7 @@ static int virtio_transport_send_credit_update(struct vsock_sock *vsk,
 	struct virtio_vsock_pkt_info info = {
 		.op = VIRTIO_VSOCK_OP_CREDIT_UPDATE,
 		.type = type,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -518,6 +520,7 @@ int virtio_transport_connect(struct vsock_sock *vsk)
 	struct virtio_vsock_pkt_info info = {
 		.op = VIRTIO_VSOCK_OP_REQUEST,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -533,6 +536,7 @@ int virtio_transport_shutdown(struct vsock_sock *vsk, int mode)
 			  VIRTIO_VSOCK_SHUTDOWN_RCV : 0) |
 			 (mode & SEND_SHUTDOWN ?
 			  VIRTIO_VSOCK_SHUTDOWN_SEND : 0),
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -559,6 +563,7 @@ virtio_transport_stream_enqueue(struct vsock_sock *vsk,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
 		.msg = msg,
 		.pkt_len = len,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -580,6 +585,7 @@ static int virtio_transport_reset(struct vsock_sock *vsk,
 		.op = VIRTIO_VSOCK_OP_RST,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
 		.reply = !!pkt,
+		.vsk = vsk,
 	};
 
 	/* Send RST only if the original pkt is not a RST pkt */
@@ -825,6 +831,7 @@ virtio_transport_send_response(struct vsock_sock *vsk,
 		.remote_cid = le64_to_cpu(pkt->hdr.src_cid),
 		.remote_port = le32_to_cpu(pkt->hdr.src_port),
 		.reply = true,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
-- 
2.7.4

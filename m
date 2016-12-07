From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH v2 1/4] vsock: track pkt owner vsock
Date: Wed,  7 Dec 2016 23:14:09 +0800
Message-ID: <1481123652-80603-2-git-send-email-bergwolf@gmail.com>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36644 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932272AbcLGPOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:14:38 -0500
In-Reply-To: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that we can cancel a queued pkt later if necessary.

Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 include/linux/virtio_vsock.h            | 2 ++
 net/vmw_vsock/virtio_transport_common.c | 7 +++++++
 2 files changed, 9 insertions(+)

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index 9638bfe..6dd3242 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
 	struct virtio_vsock_hdr	hdr;
 	struct work_struct work;
 	struct list_head list;
+	struct vsock_sock *vsk;
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
index a53b3a1..cc1eeb5 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -57,6 +57,7 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 	pkt->len		= len;
 	pkt->hdr.len		= cpu_to_le32(len);
 	pkt->reply		= info->reply;
+	pkt->vsk		= info->vsk;
 
 	if (info->msg && len > 0) {
 		pkt->buf = kmalloc(len, GFP_KERNEL);
@@ -180,6 +181,7 @@ static int virtio_transport_send_credit_update(struct vsock_sock *vsk,
 	struct virtio_vsock_pkt_info info = {
 		.op = VIRTIO_VSOCK_OP_CREDIT_UPDATE,
 		.type = type,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -519,6 +521,7 @@ int virtio_transport_connect(struct vsock_sock *vsk)
 	struct virtio_vsock_pkt_info info = {
 		.op = VIRTIO_VSOCK_OP_REQUEST,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -534,6 +537,7 @@ int virtio_transport_shutdown(struct vsock_sock *vsk, int mode)
 			  VIRTIO_VSOCK_SHUTDOWN_RCV : 0) |
 			 (mode & SEND_SHUTDOWN ?
 			  VIRTIO_VSOCK_SHUTDOWN_SEND : 0),
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -560,6 +564,7 @@ virtio_transport_stream_enqueue(struct vsock_sock *vsk,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
 		.msg = msg,
 		.pkt_len = len,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
@@ -581,6 +586,7 @@ static int virtio_transport_reset(struct vsock_sock *vsk,
 		.op = VIRTIO_VSOCK_OP_RST,
 		.type = VIRTIO_VSOCK_TYPE_STREAM,
 		.reply = !!pkt,
+		.vsk = vsk,
 	};
 
 	/* Send RST only if the original pkt is not a RST pkt */
@@ -826,6 +832,7 @@ virtio_transport_send_response(struct vsock_sock *vsk,
 		.remote_cid = le32_to_cpu(pkt->hdr.src_cid),
 		.remote_port = le32_to_cpu(pkt->hdr.src_port),
 		.reply = true,
+		.vsk = vsk,
 	};
 
 	return virtio_transport_send_pkt_info(vsk, &info);
-- 
2.7.4

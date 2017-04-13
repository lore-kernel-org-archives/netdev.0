From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v4 3/3] VSOCK: Add virtio vsock vsockmon hooks
Date: Thu, 13 Apr 2017 17:18:11 +0100
Message-ID: <20170413161811.8953-4-stefanha@redhat.com>
References: <20170413161811.8953-1-stefanha@redhat.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751573AbdDMQSq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 12:18:46 -0400
In-Reply-To: <20170413161811.8953-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

The virtio drivers deal with struct virtio_vsock_pkt.  Add
virtio_transport_deliver_tap_pkt(pkt) for handing packets to the
vsockmon device.

We call virtio_transport_deliver_tap_pkt(pkt) from
net/vmw_vsock/virtio_transport.c and drivers/vhost/vsock.c instead of
common code.  This is because the drivers may drop packets before
handing them to common code - we still want to capture them.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
v3:
 * Hook virtio_transport.c (guest driver), not just
   drivers/vhost/vsock.c (host driver)
---
 include/linux/virtio_vsock.h            |  1 +
 drivers/vhost/vsock.c                   |  8 +++++
 net/vmw_vsock/virtio_transport.c        |  3 ++
 net/vmw_vsock/virtio_transport_common.c | 58 +++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+)

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index 584f9a6..ab13f07 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -153,5 +153,6 @@ void virtio_transport_free_pkt(struct virtio_vsock_pkt *pkt);
 void virtio_transport_inc_tx_pkt(struct virtio_vsock_sock *vvs, struct virtio_vsock_pkt *pkt);
 u32 virtio_transport_get_credit(struct virtio_vsock_sock *vvs, u32 wanted);
 void virtio_transport_put_credit(struct virtio_vsock_sock *vvs, u32 credit);
+void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt);
 
 #endif /* _LINUX_VIRTIO_VSOCK_H */
diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 44eed8e..d939ac1 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -176,6 +176,11 @@ vhost_transport_do_send_pkt(struct vhost_vsock *vsock,
 				restart_tx = true;
 		}
 
+		/* Deliver to monitoring devices all correctly transmitted
+		 * packets.
+		 */
+		virtio_transport_deliver_tap_pkt(pkt);
+
 		virtio_transport_free_pkt(pkt);
 	}
 	if (added)
@@ -383,6 +388,9 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 
 		len = pkt->len;
 
+		/* Deliver to monitoring devices all received packets */
+		virtio_transport_deliver_tap_pkt(pkt);
+
 		/* Only accept correctly addressed packets */
 		if (le64_to_cpu(pkt->hdr.src_cid) == vsock->guest_cid)
 			virtio_transport_recv_pkt(pkt);
diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 68675a1..9dffe02 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -144,6 +144,8 @@ virtio_transport_send_pkt_work(struct work_struct *work)
 		list_del_init(&pkt->list);
 		spin_unlock_bh(&vsock->send_pkt_list_lock);
 
+		virtio_transport_deliver_tap_pkt(pkt);
+
 		reply = pkt->reply;
 
 		sg_init_one(&hdr, &pkt->hdr, sizeof(pkt->hdr));
@@ -370,6 +372,7 @@ static void virtio_transport_rx_work(struct work_struct *work)
 			}
 
 			pkt->len = len - sizeof(pkt->hdr);
+			virtio_transport_deliver_tap_pkt(pkt);
 			virtio_transport_recv_pkt(pkt);
 		}
 	} while (!virtqueue_enable_cb(vq));
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index af087b4..aae60c1 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -16,6 +16,7 @@
 #include <linux/virtio_ids.h>
 #include <linux/virtio_config.h>
 #include <linux/virtio_vsock.h>
+#include <uapi/linux/vsockmon.h>
 
 #include <net/sock.h>
 #include <net/af_vsock.h>
@@ -85,6 +86,63 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 	return NULL;
 }
 
+/* Packet capture */
+void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
+{
+	struct sk_buff *skb;
+	struct af_vsockmon_hdr *hdr;
+	unsigned char *t_hdr, *payload;
+
+	skb = alloc_skb(sizeof(*hdr) + sizeof(pkt->hdr) + pkt->len,
+			GFP_ATOMIC);
+	if (!skb)
+		return; /* nevermind if we cannot capture the packet */
+
+	hdr = (struct af_vsockmon_hdr *)skb_put(skb, sizeof(*hdr));
+
+	/* pkt->hdr is little-endian so no need to byteswap here */
+	hdr->src_cid = pkt->hdr.src_cid;
+	hdr->src_port = pkt->hdr.src_port;
+	hdr->dst_cid = pkt->hdr.dst_cid;
+	hdr->dst_port = pkt->hdr.dst_port;
+
+	hdr->transport = cpu_to_le16(AF_VSOCK_TRANSPORT_VIRTIO);
+	hdr->len = cpu_to_le16(sizeof(pkt->hdr));
+	hdr->reserved[0] = hdr->reserved[1] = 0;
+
+	switch(cpu_to_le16(pkt->hdr.op)) {
+	case VIRTIO_VSOCK_OP_REQUEST:
+	case VIRTIO_VSOCK_OP_RESPONSE:
+		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONNECT);
+		break;
+	case VIRTIO_VSOCK_OP_RST:
+	case VIRTIO_VSOCK_OP_SHUTDOWN:
+		hdr->op = cpu_to_le16(AF_VSOCK_OP_DISCONNECT);
+		break;
+	case VIRTIO_VSOCK_OP_RW:
+		hdr->op = cpu_to_le16(AF_VSOCK_OP_PAYLOAD);
+		break;
+	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
+	case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
+		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONTROL);
+		break;
+	default:
+		hdr->op = cpu_to_le16(AF_VSOCK_OP_UNKNOWN);
+		break;
+	}
+
+	t_hdr = skb_put(skb, sizeof(pkt->hdr));
+	memcpy(t_hdr, &pkt->hdr, sizeof(pkt->hdr));
+
+	if (pkt->len) {
+		payload = skb_put(skb, pkt->len);
+		memcpy(payload, pkt->buf, pkt->len);
+	}
+
+	vsock_deliver_tap(skb);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_deliver_tap_pkt);
+
 static int virtio_transport_send_pkt_info(struct vsock_sock *vsk,
 					  struct virtio_vsock_pkt_info *info)
 {
-- 
2.9.3

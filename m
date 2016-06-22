From: ggarcia@abra.uab.cat
Subject: [RFC v2 3/3] vsockmon: Add vsock hooks
Date: Wed, 22 Jun 2016 18:11:02 +0200
Message-ID: <20160622161102.8250-4-ggarcia@deic.uab.cat>
References: <20160622161102.8250-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: jhansen@vmware.com, stefanha@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:53228 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbcFVQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:12:18 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O9600AQ3L0ESX10@damascus.uab.es> for
 netdev@vger.kernel.org; Wed, 22 Jun 2016 18:12:14 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O9600B26L0EHY00@damascus.uab.es> for
 netdev@vger.kernel.org; Wed, 22 Jun 2016 18:12:14 +0200 (CEST)
In-reply-to: <20160622161102.8250-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
---
 drivers/vhost/vsock.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 17bfe4e..e8621cc 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -14,8 +14,10 @@
 #include <net/sock.h>
 #include <linux/virtio_vsock.h>
 #include <linux/vhost.h>
+#include <linux/skbuff.h>
 
 #include <net/af_vsock.h>
+#include <uapi/linux/vsockmon.h>
 #include "vhost.h"
 
 #define VHOST_VSOCK_DEFAULT_HOST_CID	2
@@ -45,6 +47,69 @@ struct vhost_vsock {
 	u32 guest_cid;
 };
 
+static struct sk_buff *
+virtio_vsock_pkt_to_skb(struct virtio_vsock_pkt *pkt)
+{
+	struct sk_buff *skb;
+	struct af_vsockmon_hdr *hdr;
+	void *payload;
+
+	u32 skb_len = sizeof(struct af_vsockmon_hdr) + pkt->len;
+
+	skb = alloc_skb(skb_len, GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, sizeof(struct af_vsockmon_hdr));
+
+	if (pkt->len) {
+		payload = skb_put(skb, pkt->len);
+		memcpy(payload, pkt->buf, pkt->len);
+	}
+
+	hdr = (struct af_vsockmon_hdr *) skb_push(skb, sizeof(*hdr));
+
+	hdr->src_cid = pkt->hdr.src_cid;
+	hdr->src_port = pkt->hdr.src_port;
+	hdr->dst_cid = pkt->hdr.dst_cid;
+	hdr->dst_port = pkt->hdr.dst_port;
+	hdr->t = AF_VSOCK_T_VIRTIO;
+
+	switch(pkt->hdr.op) {
+		case VIRTIO_VSOCK_OP_REQUEST:
+		case VIRTIO_VSOCK_OP_RESPONSE:
+			hdr->op = AF_VSOCK_OP_CONNECT;
+			break;
+		case VIRTIO_VSOCK_OP_RST:
+		case VIRTIO_VSOCK_OP_SHUTDOWN:
+			hdr->op = AF_VSOCK_OP_DISCONNECT;
+			break;
+		case VIRTIO_VSOCK_OP_RW:
+			hdr->op = AF_VSOCK_OP_PAYLOAD;
+			break;
+		case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
+		case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
+			hdr->op = AF_VSOCK_OP_CONTROL;
+			break;
+		default:
+			hdr->op = AF_VSOCK_OP_UNKNOWN;
+			break;
+	}
+
+	hdr->t_hdr.virtio_hdr = pkt->hdr;
+
+	return skb;
+}
+
+static void vsock_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
+{
+	struct sk_buff *skb = virtio_vsock_pkt_to_skb(pkt);
+	if (skb) {
+		vsock_deliver_tap(skb);
+		kfree_skb(skb);
+	}
+}
+
 static u32 vhost_transport_get_local_cid(void)
 {
 	return VHOST_VSOCK_DEFAULT_HOST_CID;
@@ -147,6 +212,11 @@ vhost_transport_do_send_pkt(struct vhost_vsock *vsock,
 
 		vsock->total_tx_buf -= pkt->len;
 
+		/* Deliver to monitoring devices all correctly transmitted
+		 * packets.
+		 */
+		vsock_deliver_tap_pkt(pkt);
+
 		virtio_transport_free_pkt(pkt);
 	}
 	if (added)
@@ -367,6 +437,9 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 			continue;
 		}
 
+		/* Deliver to monitoring devices all received packets */
+		vsock_deliver_tap_pkt(pkt);
+
 		/* Only accept correctly addressed packets */
 		if (le64_to_cpu(pkt->hdr.src_cid) == vsock->guest_cid)
 			virtio_transport_recv_pkt(pkt);
-- 
2.9.0

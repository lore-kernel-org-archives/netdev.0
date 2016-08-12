From: ggarcia@abra.uab.cat
Subject: [PATCH v3] virtio-vsock: Fix unbound rx buffer
Date: Fri, 12 Aug 2016 16:02:43 +0200
Message-ID: <20160812140243.17170-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, mst@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:14630 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbcHLOCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 10:02:49 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBS00K2NV0NHN00@damascus.uab.es> for
 netdev@vger.kernel.org; Fri, 12 Aug 2016 16:02:47 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBS007A5V0NE850@damascus.uab.es> for
 netdev@vger.kernel.org; Fri, 12 Aug 2016 16:02:47 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Reset connection and close rx socket when the sender is ignoring our announced
available buffer.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
Acked-by: Stefan Hajnoczi <stefanha@redhat.com>

---
Applies over mst/vhost: http://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git

v3:
 * Add subsystem prefix.

v2:
 * Get vvs->rx_lock lock before checking if next packet is going to
    overflow the rx buffer.

 net/vmw_vsock/virtio_transport_common.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index a53b3a1..8d4abb6 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -774,12 +774,22 @@ virtio_transport_recv_connected(struct sock *sk,
 		pkt->off = 0;
 
 		spin_lock_bh(&vvs->rx_lock);
-		virtio_transport_inc_rx_pkt(vvs, pkt);
-		list_add_tail(&pkt->list, &vvs->rx_queue);
-		spin_unlock_bh(&vvs->rx_lock);
+		if (vvs->rx_bytes + pkt->len <= vvs->buf_size) {
+			virtio_transport_inc_rx_pkt(vvs, pkt);
+			list_add_tail(&pkt->list, &vvs->rx_queue);
+			spin_unlock_bh(&vvs->rx_lock);
+
+			sk->sk_data_ready(sk);
+			return err;
+		} else {
+			/* Sender is ignoring our buf_alloc */
+			spin_unlock_bh(&vvs->rx_lock);
+
+			virtio_transport_reset(vsk, pkt);
+			virtio_transport_do_close(vsk, true);
+			break;
+		}
 
-		sk->sk_data_ready(sk);
-		return err;
 	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
 		sk->sk_write_space(sk);
 		break;
-- 
2.9.1

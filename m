From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 5/5] virtio-net: keep tx interrupts disabled unless kick
Date: Tue, 18 Apr 2017 16:21:08 -0400
Message-ID: <20170418202108.61920-6-willemdebruijn.kernel@gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36629 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752809AbdDRUVO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 16:21:14 -0400
Received: by mail-qt0-f195.google.com with SMTP id t52so598531qtb.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 13:21:14 -0700 (PDT)
In-Reply-To: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Tx napi mode increases the rate of transmit interrupts. Suppress some
by masking interrupts while more packets are expected. The interrupts
will be reenabled before the last packet is sent.

This optimization reduces the througput drop with tx napi for
unidirectional flows such as UDP_STREAM that do not benefit from
cleaning tx completions in the the receive napi handler.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b14c82ce0032..b107ae011632 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1196,8 +1196,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool use_napi = sq->napi.weight;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	if (!use_napi)
+	if (use_napi) {
+		if (kick)
+			virtqueue_enable_cb_delayed(sq->vq);
+		else
+			virtqueue_disable_cb(sq->vq);
+	} else {
 		free_old_xmit_skbs(sq);
+	}
 
 	/* timestamp packet in software */
 	skb_tx_timestamp(skb);
-- 
2.12.2.816.g2cccc81164-goog

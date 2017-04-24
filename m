From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v3 5/5] virtio-net: keep tx interrupts disabled unless kick
Date: Mon, 24 Apr 2017 13:49:30 -0400
Message-ID: <20170424174930.82623-6-willemdebruijn.kernel@gmail.com>
References: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34986 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S976273AbdDXRth (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:49:37 -0400
Received: by mail-qk0-f196.google.com with SMTP id a19so4072210qkg.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 10:49:37 -0700 (PDT)
In-Reply-To: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
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
 drivers/net/virtio_net.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9dd978f34c1f..003143835766 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1200,6 +1200,9 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(sq);
 
+	if (use_napi && kick)
+		virtqueue_enable_cb_delayed(sq->vq);
+
 	/* timestamp packet in software */
 	skb_tx_timestamp(skb);
 
-- 
2.12.2.816.g2cccc81164-goog

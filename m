From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] virtio-net: add a missing synchronize_net()
Date: Tue, 15 Nov 2016 22:24:12 -0800
Message-ID: <1479277452.8455.156.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34704 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752475AbcKPGYQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 01:24:16 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so9250007pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 22:24:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems many drivers do not respect napi_hash_del() contract.

When napi_hash_del() is used before netif_napi_del(), an RCU grace
period is needed before freeing NAPI object.

Fixes: 91815639d880 ("virtio-net: rx busy polling support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fd8b1e62301f..7276d5a95bd0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1497,6 +1497,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 		netif_napi_del(&vi->rq[i].napi);
 	}
 
+	/* We called napi_hash_del() before netif_napi_del(),
+	 * we need to respect an RCU grace period before freeing vi->rq
+	 */
+	synchronize_net();
+
 	kfree(vi->rq);
 	kfree(vi->sq);
 }

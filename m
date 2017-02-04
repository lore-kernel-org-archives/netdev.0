From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] virtio_net: exploit napi_complete_done() return
 value
Date: Sat, 04 Feb 2017 07:49:21 -0800
Message-ID: <1486223361.21871.136.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33574 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdBDPtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 10:49:24 -0500
Received: by mail-it0-f66.google.com with SMTP id e137so4248884itc.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 07:49:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since commit 364b6055738b ("net: busy-poll: return busypolling status to
drivers"), napi_complete_done() returns a boolean that can be used
by drivers to conditionally rearm interrupts.

This patch changes virtio_net to use this boolean to avoid a bit of
overhead for busy-poll users.

Jason reports about 1.1% improvement for 1 byte TCP_RR (burst 100).

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Jason Wang <jasowang@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0382827829d90b1d25d059609bae6d1c5ad2b6d9..29982c7f6080ae99f4753052dc80ff5310f1134b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1012,11 +1012,12 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	/* Out of packets? */
 	if (received < budget) {
 		r = virtqueue_enable_cb_prepare(rq->vq);
-		napi_complete_done(napi, received);
-		if (unlikely(virtqueue_poll(rq->vq, r)) &&
-		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(rq->vq);
-			__napi_schedule(napi);
+		if (napi_complete_done(napi, received)) {
+			if (unlikely(virtqueue_poll(rq->vq, r)) &&
+			    napi_schedule_prep(napi)) {
+				virtqueue_disable_cb(rq->vq);
+				__napi_schedule(napi);
+			}
 		}
 	}
 

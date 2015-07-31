From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] virtio_net: add gro capability
Date: Fri, 31 Jul 2015 18:25:17 +0200
Message-ID: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35904 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbbGaQZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 12:25:21 -0400
Received: by wicgj17 with SMTP id gj17so24846419wic.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 09:25:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Straightforward patch to add GRO processing to virtio_net.

napi_complete_done() usage allows more aggressive aggregation,
opted-in by setting /sys/class/net/xxx/gro_flush_timeout

Tested:

Setting /sys/class/net/xxx/gro_flush_timeout to 1000 nsec,
Rick Jones reported following results.

One VM of each on a pair of OpenStack compute nodes with E5-2650Lv3 CPUs
and Intel 82599ES-based NICs. So, two "before" and two "after" VMs.
The OpenStack compute nodes were running OpenStack Kilo, with VxLAN
encapsulation being used through OVS so no GRO coming-up the host
stack.  The compute nodes themselves were running a 3.14-based kernel.

Single-stream netperf, CPU utilizations and thus service demands are
based on intra-guest reported CPU.

Throughput Mbit/s, bigger is better                     
        Min     Median  Average Max
4.2.0-rc3+      1364    1686    1678    1938
4.2.0-rc3+flush1k       1824    2269    2275    2647

Send Service Demand, smaller is better                  
        Min     Median  Average Max
4.2.0-rc3+      0.236   0.558   0.524   0.802
4.2.0-rc3+flush1k       0.176   0.503   0.471   0.738

Receive Service Demand, smaller is better.      
        Min     Median  Average Max
4.2.0-rc3+      1.906   2.188   2.191   2.531
4.2.0-rc3+flush1k       0.448   0.529   0.533   0.692


Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Rick Jones <rick.jones2@hp.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
---
 drivers/net/virtio_net.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7fbca37a1adf..66f08f622dc6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -518,7 +518,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 
 	skb_mark_napi_id(skb, &rq->napi);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&rq->napi, skb);
 	return;
 
 frame_err:
@@ -756,7 +756,7 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	/* Out of packets? */
 	if (received < budget) {
 		r = virtqueue_enable_cb_prepare(rq->vq);
-		napi_complete(napi);
+		napi_complete_done(napi, received);
 		if (unlikely(virtqueue_poll(rq->vq, r)) &&
 		    napi_schedule_prep(napi)) {
 			virtqueue_disable_cb(rq->vq);

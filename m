From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Tue, 08 Dec 2009 14:50:05 -0800
Message-ID: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54350 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966427AbZLHWuC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 17:50:02 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nB8MjaOv009176
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 17:45:36 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB8Mo8b1132412
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 17:50:08 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB8Mo7BC009759
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 17:50:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing vhost-net patches with a guest running linux 2.6.32, i am
running into "Unexpected full queue" warning messages from start_xmit() in
virtio_net.c causing a lot of requeues and a drastic reduction in throughput.

With a guest running 2.6.31, i get guest to host throughput around 7000Mb/s,
but it drops to around 3200Mb/s with 2.6.32.

I don't see this problem with usermode virtio in qemu, but i get a thruput of
only 2700Mb/s with both 2.6.31 and 2.6.32.

The following patch fixes this problem by dropping the skb and not requeuing
to qdisc when it cannot be added to ring buffer. With this patch, i see
similar performance as 2.6.31 with vhost-net.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b9e002f..307cfd6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -528,7 +528,11 @@ again:
 			netif_start_queue(dev);
 			goto again;
 		}
-		return NETDEV_TX_BUSY;
+
+		/* drop the skb under stress. */ 
+ 		vi->dev->stats.tx_dropped++;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 	vi->svq->vq_ops->kick(vi->svq);
 

Thanks
Sridhar






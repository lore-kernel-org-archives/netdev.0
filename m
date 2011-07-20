From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Fix panic in virtnet_remove
Date: Wed, 20 Jul 2011 13:13:39 +0530
Message-ID: <20110720074339.7842.72593.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:52017 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab1GUD2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 23:28:07 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p6K7Nr72015877
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 12:53:53 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6K7heI61421388
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 13:13:40 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6K7hdhF004674
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 17:43:40 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a panic in virtnet_remove. unregister_netdev has already
freed up the netdev (and virtnet_info) due to dev->destructor
being set, while virtnet_info is still required. Remove
virtnet_free altogether, and move the freeing of the per-cpu
statistics from virtnet_free to virtnet_remove.

Tested patch below.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-07-18 09:14:02.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-07-18 09:16:35.000000000 +0530
@@ -705,14 +705,6 @@ static void virtnet_netpoll(struct net_d
 }
 #endif
 
-static void virtnet_free(struct net_device *dev)
-{
-	struct virtnet_info *vi = netdev_priv(dev);
-
-	free_percpu(vi->stats);
-	free_netdev(dev);
-}
-
 static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -959,7 +951,6 @@ static int virtnet_probe(struct virtio_d
 	/* Set up network device as normal. */
 	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
-	dev->destructor = virtnet_free;
 
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
@@ -1122,6 +1113,7 @@ static void __devexit virtnet_remove(str
 	while (vi->pages)
 		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
 
+	free_percpu(vi->stats);
 	free_netdev(vi->dev);
 }
 

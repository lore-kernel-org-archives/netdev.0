From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Wed, 15 Jan 2014 22:20:54 +0800
Message-ID: <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Cc: therbert@google.com, edumazet@google.com, davem@davemloft.net,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34732 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaAOOVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:21:21 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 15 Jan 2014 07:21:20 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9770719D803E
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:21:08 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0FELHE03473844
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 15:21:17 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0FELG3H008819
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:21:17 -0700
In-Reply-To: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Accelerated RFS is used to select the RX queue.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c |   56 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 55 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 046421c..9f4cfa7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -26,6 +26,7 @@
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/cpu_rmap.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -1554,6 +1555,49 @@ err:
 	return ret;
 }
 
+static void virtnet_free_irq_cpu_rmap(struct virtnet_info *vi)
+{
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(vi->dev->rx_cpu_rmap);
+	vi->dev->rx_cpu_rmap = NULL;
+#endif
+}
+
+static int virtnet_init_rx_cpu_rmap(struct virtnet_info *vi)
+{
+	int rc = 0;
+
+#ifdef CONFIG_RFS_ACCEL
+	struct virtio_device *vdev = vi->vdev;
+	unsigned int irq;
+	int i;
+
+	if (!vi->affinity_hint_set)
+		goto out;
+
+	vi->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(vi->max_queue_pairs);
+	if (!vi->dev->rx_cpu_rmap) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		irq = virtqueue_get_vq_irq(vdev, vi->rq[i].vq);
+		if (irq == -1)
+			goto failed;
+
+		rc = irq_cpu_rmap_add(vi->dev->rx_cpu_rmap, irq);
+		if (rc) {
+failed:
+			virtnet_free_irq_cpu_rmap(vi);
+			goto out;
+		}
+	}
+out:
+#endif
+	return rc;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
@@ -1671,10 +1715,16 @@ static int virtnet_probe(struct virtio_device *vdev)
 	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
 	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
 
+	err = virtnet_init_rx_cpu_rmap(vi);
+	if (err) {
+		pr_debug("virtio_net: initializing rx cpu rmap failed\n");
+		goto free_vqs;
+	}
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-		goto free_vqs;
+		goto free_cpu_rmap;
 	}
 
 	/* Last of all, set up some receive buffers. */
@@ -1714,6 +1764,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 free_recv_bufs:
 	free_receive_bufs(vi);
 	unregister_netdev(dev);
+free_cpu_rmap:
+	virtnet_free_irq_cpu_rmap(vi);
 free_vqs:
 	cancel_delayed_work_sync(&vi->refill);
 	virtnet_del_vqs(vi);
@@ -1751,6 +1803,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	unregister_netdev(vi->dev);
 
+	virtnet_free_irq_cpu_rmap(vi);
+
 	remove_vq_common(vi);
 	if (vi->alloc_frag.page)
 		put_page(vi->alloc_frag.page);
-- 
1.7.6.5

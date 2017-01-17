From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v5 2/6] virtio_net: wrap rtnl_lock in test for calling
 with lock already held
Date: Tue, 17 Jan 2017 14:20:30 -0800
Message-ID: <20170117222030.20280.5962.stgit@john-Precision-Tower-5810>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34968 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdAQWVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 17:21:01 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so8981966pge.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 14:21:01 -0800 (PST)
In-Reply-To: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For XDP use case and to allow ethtool reset tests it is useful to be
able to use reset paths from contexts where rtnl lock is already
held.

This requries updating virtnet_set_queues and free_receive_bufs the
two places where rtnl_lock is taken in virtio_net. To do this we
use the following pattern,

	_foo(...) { do stuff }
	foo(...) { rtnl_lock(); _foo(...); rtnl_unlock()};

this allows us to use freeze()/restore() flow from both contexts.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d97bb71..ba0efee 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1331,7 +1331,7 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
 	rtnl_unlock();
 }
 
-static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
+static int _virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
 {
 	struct scatterlist sg;
 	struct net_device *dev = vi->dev;
@@ -1357,6 +1357,16 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
 	return 0;
 }
 
+static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
+{
+	int err;
+
+	rtnl_lock();
+	err = _virtnet_set_queues(vi, queue_pairs);
+	rtnl_unlock();
+	return err;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -1609,7 +1619,7 @@ static int virtnet_set_channels(struct net_device *dev,
 		return -EINVAL;
 
 	get_online_cpus();
-	err = virtnet_set_queues(vi, queue_pairs);
+	err = _virtnet_set_queues(vi, queue_pairs);
 	if (!err) {
 		netif_set_real_num_tx_queues(dev, queue_pairs);
 		netif_set_real_num_rx_queues(dev, queue_pairs);
@@ -1736,7 +1746,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -ENOMEM;
 	}
 
-	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
+	err = _virtnet_set_queues(vi, curr_qp + xdp_qp);
 	if (err) {
 		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
 		return err;
@@ -1745,7 +1755,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	if (prog) {
 		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
 		if (IS_ERR(prog)) {
-			virtnet_set_queues(vi, curr_qp);
+			_virtnet_set_queues(vi, curr_qp);
 			return PTR_ERR(prog);
 		}
 	}
@@ -1864,12 +1874,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 	kfree(vi->sq);
 }
 
-static void free_receive_bufs(struct virtnet_info *vi)
+static void _free_receive_bufs(struct virtnet_info *vi)
 {
 	struct bpf_prog *old_prog;
 	int i;
 
-	rtnl_lock();
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		while (vi->rq[i].pages)
 			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
@@ -1879,6 +1888,12 @@ static void free_receive_bufs(struct virtnet_info *vi)
 		if (old_prog)
 			bpf_prog_put(old_prog);
 	}
+}
+
+static void free_receive_bufs(struct virtnet_info *vi)
+{
+	rtnl_lock();
+	_free_receive_bufs(vi);
 	rtnl_unlock();
 }
 
@@ -2317,9 +2332,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_unregister_netdev;
 	}
 
-	rtnl_lock();
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
-	rtnl_unlock();
 
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
@@ -2428,9 +2441,7 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	netif_device_attach(vi->dev);
 
-	rtnl_lock();
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
-	rtnl_unlock();
 
 	err = virtnet_cpu_notif_add(vi);
 	if (err)

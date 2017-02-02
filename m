From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/5] virtio_net: wrap rtnl_lock in test for calling
 with lock already held
Date: Thu, 02 Feb 2017 15:20:31 -0800
Message-ID: <20170202232031.14366.69142.stgit@john-Precision-Tower-5810>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36409 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdBBXUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:20:47 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so231811pgf.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 15:20:47 -0800 (PST)
In-Reply-To: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
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
index bd22cf3..f8ba586 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1342,7 +1342,7 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
 	rtnl_unlock();
 }
 
-static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
+static int _virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
 {
 	struct scatterlist sg;
 	struct net_device *dev = vi->dev;
@@ -1368,6 +1368,16 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
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
@@ -1620,7 +1630,7 @@ static int virtnet_set_channels(struct net_device *dev,
 		return -EINVAL;
 
 	get_online_cpus();
-	err = virtnet_set_queues(vi, queue_pairs);
+	err = _virtnet_set_queues(vi, queue_pairs);
 	if (!err) {
 		netif_set_real_num_tx_queues(dev, queue_pairs);
 		netif_set_real_num_rx_queues(dev, queue_pairs);
@@ -1752,7 +1762,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -ENOMEM;
 	}
 
-	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
+	err = _virtnet_set_queues(vi, curr_qp + xdp_qp);
 	if (err) {
 		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
 		return err;
@@ -1761,7 +1771,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	if (prog) {
 		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
 		if (IS_ERR(prog)) {
-			virtnet_set_queues(vi, curr_qp);
+			_virtnet_set_queues(vi, curr_qp);
 			return PTR_ERR(prog);
 		}
 	}
@@ -1880,12 +1890,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
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
@@ -1895,6 +1904,12 @@ static void free_receive_bufs(struct virtnet_info *vi)
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
 
@@ -2333,9 +2348,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_unregister_netdev;
 	}
 
-	rtnl_lock();
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
-	rtnl_unlock();
 
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
@@ -2444,9 +2457,7 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	netif_device_attach(vi->dev);
 
-	rtnl_lock();
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
-	rtnl_unlock();
 
 	err = virtnet_cpu_notif_add(vi);
 	if (err)

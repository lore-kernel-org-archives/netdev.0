From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v6 3/5] virtio_net: add dedicated XDP transmit
 queues
Date: Thu, 15 Dec 2016 12:13:49 -0800
Message-ID: <20161215201349.23639.15713.stgit@john-Precision-Tower-5810>
References: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch, davem@davemloft.net
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33083 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752340AbcLOUbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:31:16 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so7217631pgd.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:30:39 -0800 (PST)
In-Reply-To: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP requires using isolated transmit queues to avoid interference
with normal networking stack (BQL, NETDEV_TX_BUSY, etc). This patch
adds a XDP queue per cpu when a XDP program is loaded and does not
expose the queues to the OS via the normal API call to
netif_set_real_num_tx_queues(). This way the stack will never push
an skb to these queues.

However virtio/vhost/qemu implementation only allows for creating
TX/RX queue pairs at this time so creating only TX queues was not
possible. And because the associated RX queues are being created I
went ahead and exposed these to the stack and let the backend use
them. This creates more RX queues visible to the network stack than
TX queues which is worth mentioning but does not cause any issues as
far as I can tell.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 93075da..992ec5f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -114,6 +114,9 @@ struct virtnet_info {
 	/* # of queue pairs currently used by the driver */
 	u16 curr_queue_pairs;
 
+	/* # of XDP queue pairs currently used by the driver */
+	u16 xdp_queue_pairs;
+
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
@@ -1526,7 +1529,8 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct bpf_prog *old_prog;
-	int i;
+	u16 xdp_qp = 0, curr_qp;
+	int i, err;
 
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
@@ -1544,12 +1548,34 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -EINVAL;
 	}
 
+	curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
+	if (prog)
+		xdp_qp = nr_cpu_ids;
+
+	/* XDP requires extra queues for XDP_TX */
+	if (curr_qp + xdp_qp > vi->max_queue_pairs) {
+		netdev_warn(dev, "request %i queues but max is %i\n",
+			    curr_qp + xdp_qp, vi->max_queue_pairs);
+		return -ENOMEM;
+	}
+
+	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
+	if (err) {
+		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
+		return err;
+	}
+
 	if (prog) {
 		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
-		if (IS_ERR(prog))
+		if (IS_ERR(prog)) {
+			virtnet_set_queues(vi, curr_qp);
 			return PTR_ERR(prog);
+		}
 	}
 
+	vi->xdp_queue_pairs = xdp_qp;
+	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
+
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
 		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);

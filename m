From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 4/4] virtio_net: make use of extended ack message reporting
Date: Tue, 25 Apr 2017 01:06:44 -0700
Message-ID: <20170425080644.122536-5-jakub.kicinski@netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36742 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1176421AbdDYIIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:08:17 -0400
Received: by mail-pg0-f45.google.com with SMTP id g2so24741669pge.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 01:08:17 -0700 (PDT)
In-Reply-To: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to carry error messages to the user via the netlink extended
ack message attribute.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/virtio_net.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 666ada6130ab..96c5bb31f0af 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1788,7 +1788,8 @@ static int virtnet_reset(struct virtnet_info *vi, int curr_qp, int xdp_qp)
 	return ret;
 }
 
-static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
+			   struct netlink_ext_ack *extack)
 {
 	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -1800,16 +1801,17 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
-		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
+		NL_SET_ERR_MSG(extack, "can't set XDP while host is implementing LRO, disable LRO first");
 		return -EOPNOTSUPP;
 	}
 
 	if (vi->mergeable_rx_bufs && !vi->any_header_sg) {
-		netdev_warn(dev, "XDP expects header/data in single page, any_header_sg required\n");
+		NL_SET_ERR_MSG(extack, "XDP expects header/data in single page, any_header_sg required");
 		return -EINVAL;
 	}
 
 	if (dev->mtu > max_sz) {
+		NL_SET_ERR_MSG(extack, "MTU too large to enable XDP");
 		netdev_warn(dev, "XDP requires MTU less than %lu\n", max_sz);
 		return -EINVAL;
 	}
@@ -1820,6 +1822,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 
 	/* XDP requires extra queues for XDP_TX */
 	if (curr_qp + xdp_qp > vi->max_queue_pairs) {
+		NL_SET_ERR_MSG(extack, "Too few free TX rings available");
 		netdev_warn(dev, "request %i queues but max is %i\n",
 			    curr_qp + xdp_qp, vi->max_queue_pairs);
 		return -ENOMEM;
@@ -1881,7 +1884,7 @@ static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
-		return virtnet_xdp_set(dev, xdp->prog);
+		return virtnet_xdp_set(dev, xdp->prog, xdp->extack);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = virtnet_xdp_query(dev);
 		return 0;
-- 
2.11.0

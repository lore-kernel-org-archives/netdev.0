From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 1/2] virtio_net: cap mtu when XDP programs are running
Date: Wed, 04 Jan 2017 19:11:18 -0800
Message-ID: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34150 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932115AbdAEDLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 22:11:55 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so39121334pgc.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 19:11:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP programs can not consume multiple pages so we cap the MTU to
avoid this case. Virtio-net however only checks the MTU at XDP
program load and does not block MTU changes after the program
has loaded.

This patch sets/clears the max_mtu value at XDP load/unload time.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4a10500..261103d9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1699,11 +1699,28 @@ static void virtnet_init_settings(struct net_device *dev)
 	.set_settings = virtnet_set_settings,
 };
 
+#define MIN_MTU ETH_MIN_MTU
+#define MAX_MTU ETH_MAX_MTU
+
+static unsigned long int virtnet_xdp_mtu(struct bpf_prog *prog,
+					 struct virtnet_info *vi)
+{
+	if (!prog && virtio_has_feature(vi->vdev, VIRTIO_NET_F_MTU))
+		return virtio_cread16(vi->vdev,
+				      offsetof(struct virtio_net_config, mtu));
+	else if (!prog)
+		return ETH_MAX_MTU;
+	else if (vi->mergeable_rx_bufs)
+		return PAGE_SIZE - sizeof(struct padded_vnet_hdr);
+	else
+		return GOOD_PACKET_LEN;
+}
+
 static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
-	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct bpf_prog *old_prog;
+	unsigned long int max_sz;
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
 
@@ -1720,6 +1737,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -EINVAL;
 	}
 
+	max_sz = virtnet_xdp_mtu(prog, vi);
 	if (dev->mtu > max_sz) {
 		netdev_warn(dev, "XDP requires MTU less than %lu\n", max_sz);
 		return -EINVAL;
@@ -1748,6 +1766,9 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 			virtnet_set_queues(vi, curr_qp);
 			return PTR_ERR(prog);
 		}
+		dev->max_mtu = max_sz;
+	} else {
+		dev->max_mtu = ETH_MAX_MTU;
 	}
 
 	vi->xdp_queue_pairs = xdp_qp;
@@ -2133,9 +2154,6 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
 	return true;
 }
 
-#define MIN_MTU ETH_MIN_MTU
-#define MAX_MTU ETH_MAX_MTU
-
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;

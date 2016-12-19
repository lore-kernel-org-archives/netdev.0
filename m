From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] virtio_net: reject XDP programs using header adjustment
Date: Mon, 19 Dec 2016 15:05:00 +0000
Message-ID: <20161219150500.2600-1-jakub.kicinski@netronome.com>
Cc: john.fastabend@gmail.com, kafai@fb.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, mst@redhat.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35056 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932852AbcLSPGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 10:06:00 -0500
Received: by mail-wm0-f48.google.com with SMTP id a197so95657408wmd.0
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 07:05:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
added a new XDP helper to prepend and remove data from a frame.
Make virtio_net reject programs making use of this helper until
proper support is added.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/virtio_net.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 08327e005ccc..db761f37783e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1677,6 +1677,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
 
+	if (prog && prog->xdp_adjust_head) {
+		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
 		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
-- 
2.11.0

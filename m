From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 16/16] virtio_net: fix use after free on allocation failure
Date: Sun, 5 Oct 2014 19:07:38 +0300
Message-ID: <1412525038-15871-17-git-send-email-mst@redhat.com>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbaJEQEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 12:04:10 -0400
Content-Disposition: inline
In-Reply-To: <1412525038-15871-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the extremely unlikely event that driver initialization fails after
RX buffers are added, virtio net frees RX buffers while VQs are
still active, potentially causing device to use a freed buffer.

To fix, reset device first - same as we do on device removal.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7afc990..85e6098 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1830,6 +1830,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	return 0;
 
 free_recv_bufs:
+	vi->vdev->config->reset(vdev);
+
 	free_receive_bufs(vi);
 	unregister_netdev(dev);
 free_vqs:
-- 
MST

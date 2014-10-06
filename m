From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 15/15] virtio_net: fix use after free on allocation failure
Date: Mon, 6 Oct 2014 18:11:35 +0300
Message-ID: <1412608214-31944-16-git-send-email-mst@redhat.com>
References: <1412608214-31944-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412608214-31944-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the extremely unlikely event that driver initialization fails after
RX buffers are added, virtio net frees RX buffers while VQs are
still active, potentially causing device to use a freed buffer.

To fix, reset device first - same as we do on device removal.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 430f3ae..3551417 100644
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

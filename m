From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 4/6] virtio_net: allow specifying context for rx
Date: Wed, 29 Mar 2017 23:48:54 +0300
Message-ID: <1490820507-8005-5-git-send-email-mst@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490820507-8005-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

With mergeable buffers we never use s/g for rx,
so allow specifying context in that case.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 6802169..340f737 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2044,6 +2044,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	int ret = -ENOMEM;
 	int i, total_vqs;
 	const char **names;
+	const bool *ctx;
 
 	/* We expect 1 RX virtqueue followed by 1 TX virtqueue, followed by
 	 * possible N-1 RX/TX queue pairs used in multiqueue mode, followed by
@@ -2062,6 +2063,13 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
 	if (!names)
 		goto err_names;
+	if (vi->mergeable_rx_bufs) {
+		ctx = kzalloc(total_vqs * sizeof(*ctx), GFP_KERNEL);
+		if (!ctx)
+			goto err_ctx;
+	} else {
+		ctx = NULL;
+	}
 
 	/* Parameters for control virtqueue, if any */
 	if (vi->has_cvq) {
@@ -2077,9 +2085,12 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 		sprintf(vi->sq[i].name, "output.%d", i);
 		names[rxq2vq(i)] = vi->rq[i].name;
 		names[txq2vq(i)] = vi->sq[i].name;
+		if (ctx)
+			ctx[rxq2vq(i)] = true;
 	}
 
-	ret = virtio_find_vqs(vi->vdev, total_vqs, vqs, callbacks, names, NULL);
+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
+					 names, ctx, NULL);
 	if (ret)
 		goto err_find;
 
@@ -2101,6 +2112,8 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	return 0;
 
 err_find:
+	kfree(ctx);
+err_ctx:
 	kfree(names);
 err_names:
 	kfree(callbacks);
-- 
MST

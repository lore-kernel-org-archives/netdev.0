From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 5/6] vhost_net: poll vhost queue after marking DMA is done
Date: Mon,  2 Sep 2013 16:41:00 +0800
Message-ID: <1378111261-14826-6-git-send-email-jasowang@redhat.com>
References: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We used to poll vhost queue before making DMA is done, this is racy if vhost
thread were waked up before marking DMA is done which can result the signal to
be missed. Fix this by always polling the vhost thread before DMA is done.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
- The patch is needed for stable 3.4+
---
 drivers/vhost/net.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 3f89dea..8e9dc55 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -308,6 +308,11 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	struct vhost_virtqueue *vq = ubufs->vq;
 	int cnt = atomic_read(&ubufs->kref.refcount);
 
+	/* set len to mark this desc buffers done DMA */
+	vq->heads[ubuf->desc].len = success ?
+		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
+	vhost_net_ubuf_put(ubufs);
+
 	/*
 	 * Trigger polling thread if guest stopped submitting new buffers:
 	 * in this case, the refcount after decrement will eventually reach 1
@@ -318,10 +323,6 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	 */
 	if (cnt <= 2 || !(cnt % 16))
 		vhost_poll_queue(&vq->poll);
-	/* set len to mark this desc buffers done DMA */
-	vq->heads[ubuf->desc].len = success ?
-		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
-	vhost_net_ubuf_put(ubufs);
 }
 
 /* Expects to be always run from workqueue - which acts as
-- 
1.7.1

From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH for 3.4 1/2] vhost: zerocopy: poll vq in zerocopy callback
Date: Tue,  6 Aug 2013 17:29:18 +0800
Message-ID: <1375781359-5764-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755385Ab3HFJkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c70aa540c7a9f67add11ad3161096fb95233aa2e upstream.

We add used and signal guest in worker thread but did not poll the virtqueue
during the zero copy callback. This may lead the missing of adding and
signalling during zerocopy. Solve this by polling the virtqueue and let it
wakeup the worker during callback.

Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 1a9e2a9..a50cb9c 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1603,6 +1603,7 @@ void vhost_zerocopy_callback(struct ubuf_info *ubuf)
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
 
+	vhost_poll_queue(&vq->poll);
 	/* set len = 1 to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
-- 
1.7.1

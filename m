From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v3 2/5] net: virtio: wrap rtnl_lock in test for calling
 with lock already held
Date: Thu, 12 Jan 2017 18:51:00 -0800
Message-ID: <20170113025100.4535.35887.stgit@john-Precision-Tower-5810>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36113 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdAMCvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 21:51:18 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so6032584pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 18:51:18 -0800 (PST)
In-Reply-To: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For XDP use case and to allow ethtool reset tests it is useful to be
able to use reset routines from contexts where rtnl lock is already
held.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d97bb71..43cb2e0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1864,12 +1864,13 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 	kfree(vi->sq);
 }
 
-static void free_receive_bufs(struct virtnet_info *vi)
+static void free_receive_bufs(struct virtnet_info *vi, bool need_lock)
 {
 	struct bpf_prog *old_prog;
 	int i;
 
-	rtnl_lock();
+	if (need_lock)
+		rtnl_lock();
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		while (vi->rq[i].pages)
 			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
@@ -1879,7 +1880,8 @@ static void free_receive_bufs(struct virtnet_info *vi)
 		if (old_prog)
 			bpf_prog_put(old_prog);
 	}
-	rtnl_unlock();
+	if (need_lock)
+		rtnl_unlock();
 }
 
 static void free_receive_page_frags(struct virtnet_info *vi)
@@ -2351,14 +2353,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 	return err;
 }
 
-static void remove_vq_common(struct virtnet_info *vi)
+static void remove_vq_common(struct virtnet_info *vi, bool lock)
 {
 	vi->vdev->config->reset(vi->vdev);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
-	free_receive_bufs(vi);
+	free_receive_bufs(vi, lock);
 
 	free_receive_page_frags(vi);
 
@@ -2376,7 +2378,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	unregister_netdev(vi->dev);
 
-	remove_vq_common(vi);
+	remove_vq_common(vi, true);
 
 	free_percpu(vi->stats);
 	free_netdev(vi->dev);
@@ -2401,7 +2403,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
 			napi_disable(&vi->rq[i].napi);
 	}
 
-	remove_vq_common(vi);
+	remove_vq_common(vi, true);
 
 	return 0;
 }

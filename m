From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 3/3] vhost_net: support tun zerocopy stats
Date: Fri,  6 Oct 2017 18:25:16 -0400
Message-ID: <20171006222516.90654-4-willemdebruijn.kernel@gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:49816 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752899AbdJFWZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:25:22 -0400
Received: by mail-qt0-f196.google.com with SMTP id o3so34113629qte.6
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:25:22 -0700 (PDT)
In-Reply-To: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Allow the tun device to intercept zerocopy completions to increment
its counters.

Pass an array of two struct ubuf_info to the device. The first is
initialized as usual and used to notify vhost_net. The second is
granted to the tun device for its callback.

Use the existing per-device ubuf_info pool, but take out two
elements at a time, so double the size.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/vhost/net.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 58585ec8699e..22988a7df656 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -47,6 +47,7 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 /* MAX number of TX used buffers for outstanding zerocopy */
 #define VHOST_MAX_PEND 128
 #define VHOST_GOODCOPY_LEN 256
+#define UBUFLEN 2	/* Number of consecutive ubuf_info passed to tun */
 
 /*
  * For transmit, used buffer len is unused; we override it to track buffer
@@ -254,7 +255,7 @@ static int vhost_net_set_ubuf_info(struct vhost_net *n)
 		if (!zcopy)
 			continue;
 		n->vqs[i].ubuf_info = kmalloc(sizeof(*n->vqs[i].ubuf_info) *
-					      UIO_MAXIOV, GFP_KERNEL);
+					      UIO_MAXIOV * UBUFLEN, GFP_KERNEL);
 		if  (!n->vqs[i].ubuf_info)
 			goto err;
 	}
@@ -526,7 +527,7 @@ static void handle_tx(struct vhost_net *net)
 		/* use msg_control to pass vhost zerocopy ubuf info to skb */
 		if (zcopy_used) {
 			struct ubuf_info *ubuf;
-			ubuf = nvq->ubuf_info + nvq->upend_idx;
+			ubuf = nvq->ubuf_info + (nvq->upend_idx * UBUFLEN);
 
 			vq->heads[nvq->upend_idx].id = cpu_to_vhost32(vq, head);
 			vq->heads[nvq->upend_idx].len = VHOST_DMA_IN_PROGRESS;
@@ -535,7 +536,7 @@ static void handle_tx(struct vhost_net *net)
 			ubuf->desc = nvq->upend_idx;
 			refcount_set(&ubuf->refcnt, 1);
 			msg.msg_control = ubuf;
-			msg.msg_controllen = sizeof(ubuf);
+			msg.msg_controllen = sizeof(*ubuf) * UBUFLEN;
 			ubufs = nvq->ubufs;
 			atomic_inc(&ubufs->refcount);
 			nvq->upend_idx = (nvq->upend_idx + 1) % UIO_MAXIOV;
-- 
2.14.2.920.gcf0c67979c-goog

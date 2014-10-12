From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 25/25] virtio-rng: refactor probe error handling
Date: Sun, 12 Oct 2014 14:48:38 +0300
Message-ID: <1413114332-626-26-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Matt Mackall <mpm@selenic.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Amos Kong <akong@redhat.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbaJLLqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2014 07:46:22 -0400
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code like
	vi->vq = NULL;
	kfree(vi)
does not make sense.

Clean it up, use goto error labels for cleanup.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/char/hw_random/virtio-rng.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/char/hw_random/virtio-rng.c b/drivers/char/hw_random/virtio-rng.c
index 132c9cc..72295ea 100644
--- a/drivers/char/hw_random/virtio-rng.c
+++ b/drivers/char/hw_random/virtio-rng.c
@@ -109,8 +109,8 @@ static int probe_common(struct virtio_device *vdev)
 
 	vi->index = index = ida_simple_get(&rng_index_ida, 0, 0, GFP_KERNEL);
 	if (index < 0) {
-		kfree(vi);
-		return index;
+		err = index;
+		goto err_ida;
 	}
 	sprintf(vi->name, "virtio_rng.%d", index);
 	init_completion(&vi->have_data);
@@ -128,13 +128,16 @@ static int probe_common(struct virtio_device *vdev)
 	vi->vq = virtio_find_single_vq(vdev, random_recv_done, "input");
 	if (IS_ERR(vi->vq)) {
 		err = PTR_ERR(vi->vq);
-		vi->vq = NULL;
-		kfree(vi);
-		ida_simple_remove(&rng_index_ida, index);
-		return err;
+		goto err_find;
 	}
 
 	return 0;
+
+err_find:
+	ida_simple_remove(&rng_index_ida, index);
+err_ida:
+	kfree(vi);
+	return err;
 }
 
 static void remove_common(struct virtio_device *vdev)
-- 
MST

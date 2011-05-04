From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/4] [RFC] virtio: Introduce new API to get free space
Date: Wed, 04 May 2011 19:33:19 +0530
Message-ID: <20110504140319.14817.23145.sendpatchset@krkumar2.in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:40527 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab1EDOD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 10:03:26 -0400
In-Reply-To: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce virtqueue_get_capacity() to help bail out of transmit
path early. Also remove notification when we run out of space (I
am not sure if this should be under a feature bit).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/virtio/virtio_ring.c |   13 ++++++++-----
 include/linux/virtio.h       |    5 +++++
 2 files changed, 13 insertions(+), 5 deletions(-)

diff -ruNp org/include/linux/virtio.h new/include/linux/virtio.h
--- org/include/linux/virtio.h	2011-05-04 18:57:06.000000000 +0530
+++ new/include/linux/virtio.h	2011-05-04 18:57:09.000000000 +0530
@@ -27,6 +27,9 @@ struct virtqueue {
 
 /**
  * operations for virtqueue
+ * virtqueue_get_capacity: Get vq capacity
+ *	vq: the struct virtqueue we're talking about.
+ *	Returns remaining capacity of queue
  * virtqueue_add_buf: expose buffer to other end
  *	vq: the struct virtqueue we're talking about.
  *	sg: the description of the buffer(s).
@@ -62,6 +65,8 @@ struct virtqueue {
  * All operations can be called in any context.
  */
 
+int virtqueue_get_capacity(struct virtqueue *vq);
+
 int virtqueue_add_buf_gfp(struct virtqueue *vq,
 			  struct scatterlist sg[],
 			  unsigned int out_num,
diff -ruNp org/drivers/virtio/virtio_ring.c new/drivers/virtio/virtio_ring.c
--- org/drivers/virtio/virtio_ring.c	2011-05-04 18:57:06.000000000 +0530
+++ new/drivers/virtio/virtio_ring.c	2011-05-04 18:57:09.000000000 +0530
@@ -156,6 +156,14 @@ static int vring_add_indirect(struct vri
 	return head;
 }
 
+int virtqueue_get_capacity(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+
+	return vq->num_free;
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_capacity);
+
 int virtqueue_add_buf_gfp(struct virtqueue *_vq,
 			  struct scatterlist sg[],
 			  unsigned int out,
@@ -185,11 +193,6 @@ int virtqueue_add_buf_gfp(struct virtque
 	if (vq->num_free < out + in) {
 		pr_debug("Can't add buf len %i - avail = %i\n",
 			 out + in, vq->num_free);
-		/* FIXME: for historical reasons, we force a notify here if
-		 * there are outgoing parts to the buffer.  Presumably the
-		 * host should service the ring ASAP. */
-		if (out)
-			vq->notify(&vq->vq);
 		END_USE(vq);
 		return -ENOSPC;
 	}

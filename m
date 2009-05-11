From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 3/3] lguest: add support for indirect ring entries
Date: Mon, 11 May 2009 18:11:46 +0100
Message-ID: <1242061906-16226-3-git-send-email-markmc@redhat.com>
References: <1242061838.25337.8.camel@blaa>
 <1242061906-16226-1-git-send-email-markmc@redhat.com>
 <1242061906-16226-2-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	Avi Kivity <avi@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail10.svc.cra.dublin.eircom.net ([159.134.118.26]:39159 "HELO
	mail10.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753161AbZEKRMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 13:12:02 -0400
In-Reply-To: <1242061906-16226-2-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the VIRTIO_RING_F_INDIRECT_DESC feature.

This is a simple matter of changing the descriptor walking
code to operate on a struct vring_desc* and supplying it
with an indirect table if detected.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 Documentation/lguest/lguest.c |   41 +++++++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/Documentation/lguest/lguest.c b/Documentation/lguest/lguest.c
index d36fcc0..010c8bc 100644
--- a/Documentation/lguest/lguest.c
+++ b/Documentation/lguest/lguest.c
@@ -623,20 +623,21 @@ static void *_check_pointer(unsigned long addr, unsigned int size,
 /* Each buffer in the virtqueues is actually a chain of descriptors.  This
  * function returns the next descriptor in the chain, or vq->vring.num if we're
  * at the end. */
-static unsigned next_desc(struct virtqueue *vq, unsigned int i)
+static unsigned next_desc(struct vring_desc *desc,
+			  unsigned int i, unsigned int max)
 {
 	unsigned int next;
 
 	/* If this descriptor says it doesn't chain, we're done. */
-	if (!(vq->vring.desc[i].flags & VRING_DESC_F_NEXT))
-		return vq->vring.num;
+	if (!(desc[i].flags & VRING_DESC_F_NEXT))
+		return max;
 
 	/* Check they're not leading us off end of descriptors. */
-	next = vq->vring.desc[i].next;
+	next = desc[i].next;
 	/* Make sure compiler knows to grab that: we don't want it changing! */
 	wmb();
 
-	if (next >= vq->vring.num)
+	if (next >= max)
 		errx(1, "Desc next is %u", next);
 
 	return next;
@@ -653,7 +654,8 @@ static unsigned get_vq_desc(struct virtqueue *vq,
 			    struct iovec iov[],
 			    unsigned int *out_num, unsigned int *in_num)
 {
-	unsigned int i, head;
+	struct vring_desc *desc;
+	unsigned int i, head, max;
 	u16 last_avail;
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
@@ -678,15 +680,28 @@ static unsigned get_vq_desc(struct virtqueue *vq,
 	/* When we start there are none of either input nor output. */
 	*out_num = *in_num = 0;
 
+	max = vq->vring.num;
+	desc = vq->vring.desc;
 	i = head;
+
+	/* If this is an indirect entry, then this buffer contains a descriptor
+	 * table which we handle as if it's any normal descriptor chain. */
+	if (desc[i].flags & VRING_DESC_F_INDIRECT) {
+		if (desc[i].len % sizeof(struct vring_desc))
+			errx(1, "Invalid size for indirect buffer table");
+
+		max = desc[i].len / sizeof(struct vring_desc);
+		desc = check_pointer(desc[i].addr, desc[i].len);
+		i = 0;
+	}
+
 	do {
 		/* Grab the first descriptor, and check it's OK. */
-		iov[*out_num + *in_num].iov_len = vq->vring.desc[i].len;
+		iov[*out_num + *in_num].iov_len = desc[i].len;
 		iov[*out_num + *in_num].iov_base
-			= check_pointer(vq->vring.desc[i].addr,
-					vq->vring.desc[i].len);
+			= check_pointer(desc[i].addr, desc[i].len);
 		/* If this is an input descriptor, increment that count. */
-		if (vq->vring.desc[i].flags & VRING_DESC_F_WRITE)
+		if (desc[i].flags & VRING_DESC_F_WRITE)
 			(*in_num)++;
 		else {
 			/* If it's an output descriptor, they're all supposed
@@ -697,9 +712,9 @@ static unsigned get_vq_desc(struct virtqueue *vq,
 		}
 
 		/* If we've got too many, that implies a descriptor loop. */
-		if (*out_num + *in_num > vq->vring.num)
+		if (*out_num + *in_num > max)
 			errx(1, "Looped descriptor");
-	} while ((i = next_desc(vq, i)) != vq->vring.num);
+	} while ((i = next_desc(desc, i, max)) != max);
 
 	vq->inflight++;
 	return head;
@@ -1502,6 +1517,8 @@ static void setup_tun_net(char *arg)
 	add_feature(dev, VIRTIO_NET_F_HOST_TSO4);
 	add_feature(dev, VIRTIO_NET_F_HOST_TSO6);
 	add_feature(dev, VIRTIO_NET_F_HOST_ECN);
+	/* we handle indirect ring entries */
+	add_feature(dev, VIRTIO_RING_F_INDIRECT_DESC);
 	set_config(dev, sizeof(conf), &conf);
 
 	/* We don't need the socket any more; setup is done. */
-- 
1.6.0.6


From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 5/5] virtio_net: Recycle unused recv buffer pages for large skbs in net driver
Date: Mon, 14 Jul 2008 22:42:46 -0500
Message-ID: <200807151342.46283.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44457 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbYGODpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:45:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we hack the virtio_net driver to always allocate full-sized (64k+)
skbuffs, the driver slows down (lguest numbers):

  Time to receive 1GB (small buffers): 10.85 seconds
  Time to receive 1GB (64k+ buffers): 24.75 seconds

Of course, large buffers use up more space in the ring, so we increase
that from 128 to 2048:

  Time to receive 1GB (64k+ buffers, 2k ring): 16.61 seconds

If we recycle pages rather than using alloc_page/free_page:

  Time to receive 1GB (64k+ buffers, 2k ring, recycle pages): 10.81 seconds

This demonstrates that with efficient allocation, we don't need to
have a separate "small buffer" queue.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff -r 4cef5ad6fd51 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Tue May 27 16:07:56 2008 +1000
+++ b/drivers/net/virtio_net.c	Tue May 27 16:08:23 2008 +1000
@@ -58,6 +58,9 @@ struct virtnet_info
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
+
+	/* Chain pages by the private ptr. */
+	struct page *pages;
 };
 
 static inline struct virtio_net_hdr *skb_vnet_hdr(struct sk_buff *skb)
@@ -68,6 +71,23 @@ static inline void vnet_hdr_to_sg(struct
 static inline void vnet_hdr_to_sg(struct scatterlist *sg, struct sk_buff 
*skb)
 {
 	sg_init_one(sg, skb_vnet_hdr(skb), sizeof(struct virtio_net_hdr));
+}
+
+static void give_a_page(struct virtnet_info *vi, struct page *page)
+{
+	page->private = (unsigned long)vi->pages;
+	vi->pages = page;
+}
+
+static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
+{
+	struct page *p = vi->pages;
+
+	if (p)
+		vi->pages = (struct page *)p->private;
+	else
+		p = alloc_page(gfp_mask);
+	return p;
 }
 
 static void skb_xmit_done(struct virtqueue *svq)
@@ -97,6 +117,15 @@ static void receive_skb(struct net_devic
 		goto drop;
 	}
 	len -= sizeof(struct virtio_net_hdr);
+
+	if (len <= MAX_PACKET_LEN) {
+		unsigned int i;
+
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+			give_a_page(dev->priv, skb_shinfo(skb)->frags[i].page);
+		skb->data_len = 0;
+		skb_shinfo(skb)->nr_frags = 0;
+	}
 
 	err = pskb_trim(skb, len);
 	if (err) {
@@ -180,7 +209,7 @@ static void try_fill_recv(struct virtnet
 		if (vi->dev->features & NETIF_F_LRO) {
 			for (i = 0; i < MAX_SKB_FRAGS; i++) {
 				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-				f->page = alloc_page(GFP_ATOMIC);
+				f->page = get_a_page(vi, GFP_ATOMIC);
 				if (!f->page)
 					break;
 
@@ -509,6 +538,7 @@ static int virtnet_probe(struct virtio_d
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
+	vi->pages = NULL;
 
 	/* If they give us a callback when all buffers are done, we don't need
 	 * the timer. */
@@ -588,6 +618,10 @@ static void virtnet_remove(struct virtio
 	vdev->config->del_vq(vi->svq);
 	vdev->config->del_vq(vi->rvq);
 	unregister_netdev(vi->dev);
+
+	while (vi->pages)
+		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
+
 	free_netdev(vi->dev);
 }
 


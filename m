From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/5] virtio net: Allow receiving SG packets
Date: Tue, 15 Jul 2008 18:25:04 +1000
Message-ID: <200807151825.04627.rusty@rustcorp.com.au>
References: <200807151341.39337.rusty@rustcorp.com.au> <20080715035209.GB2657@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59386 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbYGOIZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 04:25:08 -0400
In-Reply-To: <20080715035209.GB2657@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 July 2008 13:52:09 Herbert Xu wrote:
> On Mon, Jul 14, 2008 at 10:41:38PM -0500, Rusty Russell wrote:
> > +	/* If we can receive ANY GSO packets, we must allocate large ones. */
> > +	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
> > +	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
> > +	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
> > +		dev->features |= NETIF_F_LRO;
>
> We don't want to do this because LRO implies joining packets
> together in an irreversible way which is not what this is about.
>
> Case in point we're now disabling LRO for devices that are
> forwarding packets which is totally unnecessary for virtio.

Oops.  I grepped for LRO when I did this and found nothing.

How's this one?

Subject: virtio net: Allow receiving SG packets
Date: Fri, 18 Apr 2008 11:24:27 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>

Finally this patch lets virtio_net receive GSO packets in addition
to sending them.  This can definitely be optimised for the non-GSO
case.  For comparison the Xen approach stores one page in each skb
and uses subsequent skb's pages to construct an SG skb instead of
preallocating the maximum amount of pages per skb.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added feature bits)
---
 drivers/net/virtio_net.c |   41 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -55,6 +55,9 @@ struct virtnet_info
 	struct tasklet_struct tasklet;
 	bool free_in_tasklet;
 
+	/* I like... big packets and I cannot lie! */
+	bool big_packets;
+
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
@@ -89,6 +92,7 @@ static void receive_skb(struct net_devic
 			unsigned len)
 {
 	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
+	int err;
 
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
@@ -96,10 +100,14 @@ static void receive_skb(struct net_devic
 		goto drop;
 	}
 	len -= sizeof(struct virtio_net_hdr);
-	BUG_ON(len > MAX_PACKET_LEN);
 
-	skb_trim(skb, len);
-
+	err = pskb_trim(skb, len);
+	if (err) {
+		pr_debug("%s: pskb_trim failed %i %d\n", dev->name, len, err);
+		dev->stats.rx_dropped++;
+		goto drop;
+	}
+	skb->truesize += skb->data_len;
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
 
@@ -161,7 +169,7 @@ static void try_fill_recv(struct virtnet
 {
 	struct sk_buff *skb;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
-	int num, err;
+	int num, err, i;
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 	for (;;) {
@@ -171,6 +179,24 @@ static void try_fill_recv(struct virtnet
 
 		skb_put(skb, MAX_PACKET_LEN);
 		vnet_hdr_to_sg(sg, skb);
+
+		if (vi->big_packets) {
+			for (i = 0; i < MAX_SKB_FRAGS; i++) {
+				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+				f->page = alloc_page(GFP_ATOMIC);
+				if (!f->page)
+					break;
+
+				f->page_offset = 0;
+				f->size = PAGE_SIZE;
+
+				skb->data_len += PAGE_SIZE;
+				skb->len += PAGE_SIZE;
+
+				skb_shinfo(skb)->nr_frags++;
+			}
+		}
+
 		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 		skb_queue_head(&vi->recv, skb);
 
@@ -485,6 +511,12 @@ static int virtnet_probe(struct virtio_d
 	 * the timer. */
 	vi->free_in_tasklet = virtio_has_feature(vdev,VIRTIO_F_NOTIFY_ON_EMPTY);
 
+	/* If we can receive ANY GSO packets, we must allocate large ones. */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
+	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
+	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
+		vi->big_packets = true;
+
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
 	if (IS_ERR(vi->rvq)) {
@@ -571,7 +603,9 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
-	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
+	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
+	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
+	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
 static struct virtio_driver virtio_net = {

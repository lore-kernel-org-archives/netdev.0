From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 4/4] virtio: net: Allow receiving SG packets
Date: Tue, 29 Apr 2008 01:21:03 +1000
Message-ID: <200804290121.04384.rusty@rustcorp.com.au>
References: <200804290116.05951.rusty@rustcorp.com.au> <200804290117.45010.rusty@rustcorp.com.au> <200804290119.17180.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60044 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932306AbYD1PYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 11:24:09 -0400
In-Reply-To: <200804290119.17180.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Fri, 18 Apr 2008 11:24:27 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>

Finally this patch lets virtio_net receive GSO packets in addition
to sending them.  This can definitely be optimised for the non-GSO
case.  For comparison the Xen approach stores one page in each skb
and uses subsequent skb's pages to construct an SG skb instead of
preallocating the maximum amount of pages per skb.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added feature bits)
---
 drivers/net/virtio_net.c |   40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -77,6 +77,7 @@ static void receive_skb(struct net_devic
 			unsigned len)
 {
 	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
+	int err;
 
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
@@ -84,9 +85,15 @@ static void receive_skb(struct net_devic
 		goto drop;
 	}
 	len -= sizeof(struct virtio_net_hdr);
-	BUG_ON(len > MAX_PACKET_LEN);
 
-	skb_trim(skb, len);
+	err = pskb_trim(skb, len);
+	if (err) {
+		pr_debug("%s: pskb_trim failed %i %d\n", dev->name, len, err);
+		dev->stats.rx_dropped++;
+		goto drop;
+	}
+	skb->truesize += skb->data_len;
+
 	skb->protocol = eth_type_trans(skb, dev);
 	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
@@ -147,7 +154,7 @@ static void try_fill_recv(struct virtnet
 {
 	struct sk_buff *skb;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
-	int num, err;
+	int num, err, i;
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 	for (;;) {
@@ -157,6 +164,24 @@ static void try_fill_recv(struct virtnet
 
 		skb_put(skb, MAX_PACKET_LEN);
 		vnet_hdr_to_sg(sg, skb);
+
+		if (vi->dev->features & NETIF_F_LRO) {
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
 
@@ -411,6 +436,12 @@ static int virtnet_probe(struct virtio_d
 			dev->features |= NETIF_F_UFO;
 	}
 
+	/* If we can receive ANY GSO packets, we must allocate large ones. */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
+	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
+	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
+		dev->features |= NETIF_F_LRO;
+
 	/* Configuration may specify what MAC to use.  Otherwise random. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
 		vdev->config->get(vdev,
@@ -504,7 +535,8 @@ static unsigned int features[] = {
 static unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
-	VIRTIO_NET_F_HOST_ECN,
+	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
+	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 };
 
 static struct virtio_driver virtio_net = {

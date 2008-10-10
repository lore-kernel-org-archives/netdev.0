From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation
	scheme
Date: Fri, 10 Oct 2008 13:56:55 +0100
Message-ID: <1223643415.22246.3.camel@blaa>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com>
	 <1223494499-18732-2-git-send-email-markmc@redhat.com>
	 <200810091155.59731.rusty@rustcorp.com.au>
	 <20081009153035.GA21542@gondor.apana.org.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36105 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037AbYJJM5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 08:57:52 -0400
In-Reply-To: <20081009153035.GA21542@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-09 at 23:30 +0800, Herbert Xu wrote:
> On Thu, Oct 09, 2008 at 11:55:59AM +1100, Rusty Russell wrote:

> > > The size of the logical buffer is
> > > returned to the guest rather than the size of the individual smaller
> > > buffers.
> > 
> > That's a virtio transport breakage: can you use the standard virtio mechanism, 
> > just put the extended length or number of extra buffers inside the 
> > virtio_net_hdr?
> 
> Sure that sounds reasonable.

Okay, here we go.

The new header is lamely called virtio_net_hdr2 - I've added some
padding in there so we can extend it further in future.

It gets messy for lguest because tun/tap isn't using the same header
format anymore.

Rusty - let me know if this looks reasonable and, if so, I'll merge it
back into the original patches and resend.

Cheers,
Mark.

diff --git a/Documentation/lguest/lguest.c b/Documentation/lguest/lguest.c
index da934c2..0f840f2 100644
--- a/Documentation/lguest/lguest.c
+++ b/Documentation/lguest/lguest.c
@@ -940,14 +940,21 @@ static void handle_net_output(int fd, struct virtqueue *vq, bool timeout)
 {
 	unsigned int head, out, in, num = 0;
 	int len;
-	struct iovec iov[vq->vring.num];
+	struct iovec iov[vq->vring.num + 1];
 	static int last_timeout_num;
 
 	/* Keep getting output buffers from the Guest until we run out. */
-	while ((head = get_vq_desc(vq, iov, &out, &in)) != vq->vring.num) {
+	while ((head = get_vq_desc(vq, &iov[1], &out, &in)) != vq->vring.num) {
 		if (in)
 			errx(1, "Input buffers in output queue?");
-		len = writev(vq->dev->fd, iov, out);
+
+		/* tapfd needs a virtio_net_hdr, not virtio_net_hdr2 */
+		iov[0].iov_base  = iov[1].iov_base;
+		iov[0].iov_len   = sizeof(struct virtio_net_hdr);
+		iov[1].iov_base += sizeof(struct virtio_net_hdr2);
+		iov[1].iov_len  -= sizeof(struct virtio_net_hdr2);
+
+		len = writev(vq->dev->fd, iov, out + 1);
 		if (len < 0)
 			err(1, "Writing network packet to tun");
 		add_used_and_trigger(fd, vq, head, len);
@@ -998,18 +1005,24 @@ static unsigned int get_net_recv_head(struct device *dev, struct iovec *iov,
 
 /* Here we add used recv buffers to the used queue but, also, return unused
  * buffers to the avail queue. */
-static void add_net_recv_used(struct device *dev, unsigned int *heads,
-			      int *bufsizes, int nheads, int used_len)
+static void add_net_recv_used(struct device *dev, struct virtio_net_hdr2 *hdr2,
+			      unsigned int *heads, int *bufsizes,
+			      int nheads, int used_len)
 {
 	int len, idx;
 
 	/* Add the buffers we've actually used to the used queue */
 	len = idx = 0;
 	while (len < used_len) {
-		add_used(dev->vq, heads[idx], used_len, idx);
+		if (bufsizes[idx] > (used_len - len))
+			bufsizes[idx] = used_len - len;
+		add_used(dev->vq, heads[idx], bufsizes[idx], idx);
 		len += bufsizes[idx++];
 	}
 
+	/* The guest needs to know how many buffers to fetch */
+	hdr2->num_buffers = idx;
+
 	/* Return the rest of them back to the avail queue */
 	lg_last_avail(dev->vq) -= nheads - idx;
 	dev->vq->inflight      -= nheads - idx;
@@ -1022,12 +1035,17 @@ static void add_net_recv_used(struct device *dev, unsigned int *heads,
  * Guest. */
 static bool handle_tun_input(int fd, struct device *dev)
 {
-	struct iovec iov[dev->vq->vring.num];
+	struct virtio_net_hdr hdr;
+	struct virtio_net_hdr2 *hdr2;
+	struct iovec iov[dev->vq->vring.num + 1];
 	unsigned int heads[NET_MAX_RECV_PAGES];
 	int bufsizes[NET_MAX_RECV_PAGES];
 	int nheads, len, iovcnt;
 
-	nheads = len = iovcnt = 0;
+	nheads = len = 0;
+
+	/* First iov is for the header */
+	iovcnt = 1;
 
 	/* First we need enough network buffers from the Guests's recv
 	 * virtqueue for the largest possible packet. */
@@ -1056,13 +1074,26 @@ static bool handle_tun_input(int fd, struct device *dev)
 		len += bufsizes[nheads++];
 	}
 
+	/* Read virtio_net_hdr from tapfd */
+	iov[0].iov_base = &hdr;
+	iov[0].iov_len = sizeof(hdr);
+
+	/* Read data into buffer after virtio_net_hdr2 */
+	hdr2 = iov[1].iov_base;
+	iov[1].iov_base += sizeof(*hdr2);
+	iov[1].iov_len  -= sizeof(*hdr2);
+
 	/* Read the packet from the device directly into the Guest's buffer. */
 	len = readv(dev->fd, iov, iovcnt);
 	if (len <= 0)
 		err(1, "reading network");
 
+	/* Copy the virtio_net_hdr into the virtio_net_hdr2 */
+	hdr2->hdr = hdr;
+	len += sizeof(*hdr2) - sizeof(hdr);
+
 	/* Return unused buffers to the recv queue */
-	add_net_recv_used(dev, heads, bufsizes, nheads, len);
+	add_net_recv_used(dev, hdr2, heads, bufsizes, nheads, len);
 
 	/* Fire in the hole ! */
 	trigger_irq(fd, dev->vq);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1780d6d..719e9dc 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -61,6 +61,7 @@ struct virtnet_info
 
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
+	bool use_vnet_hdr2;
 
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
@@ -70,11 +71,21 @@ struct virtnet_info
 	struct page *pages;
 };
 
+static inline struct virtio_net_hdr2 *skb_vnet_hdr2(struct sk_buff *skb)
+{
+	return (struct virtio_net_hdr2 *)skb->cb;
+}
+
 static inline struct virtio_net_hdr *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct virtio_net_hdr *)skb->cb;
 }
 
+static inline void vnet_hdr2_to_sg(struct scatterlist *sg, struct sk_buff *skb)
+{
+	sg_init_one(sg, skb_vnet_hdr2(skb), sizeof(struct virtio_net_hdr2));
+}
+
 static inline void vnet_hdr_to_sg(struct scatterlist *sg, struct sk_buff *skb)
 {
 	sg_init_one(sg, skb_vnet_hdr(skb), sizeof(struct virtio_net_hdr));
@@ -135,43 +146,40 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 		dev->stats.rx_length_errors++;
 		goto drop;
 	}
-	len -= sizeof(struct virtio_net_hdr);
 
 	if (vi->mergeable_rx_bufs) {
+		struct virtio_net_hdr2 *hdr2 = skb_vnet_hdr2(skb);
 		unsigned int copy;
-		unsigned int plen;
 		char *p = page_address(skb_shinfo(skb)->frags[0].page);
 
-		memcpy(hdr, p, sizeof(*hdr));
-		p += sizeof(*hdr);
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
+		len -= sizeof(struct virtio_net_hdr2);
 
-		plen = PAGE_SIZE - sizeof(*hdr);
-		if (plen > len)
-			plen = len;
+		memcpy(hdr2, p, sizeof(*hdr2));
+		p += sizeof(*hdr2);
 
-		copy = plen;
+		copy = len;
 		if (copy > skb_tailroom(skb))
 			copy = skb_tailroom(skb);
 
 		memcpy(skb_put(skb, copy), p, copy);
 
 		len -= copy;
-		plen -= copy;
 
-		if (!plen) {
+		if (!len) {
 			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
 			skb_shinfo(skb)->nr_frags--;
 		} else {
 			skb_shinfo(skb)->frags[0].page_offset +=
-				sizeof(*hdr) + copy;
-			skb_shinfo(skb)->frags[0].size = plen;
-			skb->data_len += plen;
-			skb->len += plen;
+				sizeof(*hdr2) + copy;
+			skb_shinfo(skb)->frags[0].size = len;
+			skb->data_len += len;
+			skb->len += len;
 		}
 
-		while ((len -= plen)) {
+		while (--hdr2->num_buffers) {
 			struct sk_buff *nskb;
-			unsigned nlen;
 
 			i = skb_shinfo(skb)->nr_frags;
 			if (i >= MAX_SKB_FRAGS) {
@@ -181,10 +189,10 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 				goto drop;
 			}
 
-			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &nlen);
+			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
 			if (!nskb) {
-				pr_debug("%s: packet length error %d < %d\n",
-					 dev->name, skb->len, len);
+				pr_debug("%s: rx error: %d buffers missing\n",
+					 dev->name, hdr2->num_buffers);
 				dev->stats.rx_length_errors++;
 				goto drop;
 			}
@@ -196,16 +204,17 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			skb_shinfo(nskb)->nr_frags = 0;
 			kfree_skb(nskb);
 
-			plen = PAGE_SIZE;
-			if (plen > len)
-				plen = len;
+			if (len > PAGE_SIZE)
+				len = PAGE_SIZE;
 
-			skb_shinfo(skb)->frags[i].size = plen;
+			skb_shinfo(skb)->frags[i].size = len;
 			skb_shinfo(skb)->nr_frags++;
-			skb->data_len += plen;
-			skb->len += plen;
+			skb->data_len += len;
+			skb->len += len;
 		}
 	} else {
+		len -= sizeof(struct virtio_net_hdr);
+
 		if (len <= MAX_PACKET_LEN)
 			trim_pages(vi, skb);
 
@@ -451,6 +460,7 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
 	int num, err;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
+	struct virtio_net_hdr2 *hdr2;
 	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 
@@ -461,7 +471,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 		 dest[3], dest[4], dest[5]);
 
 	/* Encode metadata header at front. */
-	hdr = skb_vnet_hdr(skb);
+	hdr2 = skb_vnet_hdr2(skb);
+	hdr = &hdr2->hdr;
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
 		hdr->csum_start = skb->csum_start - skb_headroom(skb);
@@ -489,7 +501,13 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 		hdr->gso_size = hdr->hdr_len = 0;
 	}
 
-	vnet_hdr_to_sg(sg, skb);
+	hdr2->num_buffers = 0;
+
+	if (vi->use_vnet_hdr2)
+		vnet_hdr2_to_sg(sg, skb);
+	else
+		vnet_hdr_to_sg(sg, skb);
+
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
 	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
@@ -678,8 +696,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
 		vi->big_packets = true;
 
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF)) {
 		vi->mergeable_rx_bufs = true;
+		vi->use_vnet_hdr2 = true;
+	}
 
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 8f376a7..59a5079 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -45,4 +45,14 @@ struct virtio_net_hdr
 	__u16 csum_start;	/* Position to start checksumming from */
 	__u16 csum_offset;	/* Offset after that to place checksum */
 };
+
+/* This is the version of the header to use when the MRG_RXBUF
+ * feature (or any later feature) has been negotiated. */
+struct virtio_net_hdr2
+{
+	struct virtio_net_hdr hdr;
+	__u8 num_buffers;	/* Number of merged rx buffers */
+	__u8 pad[21];		/* Pad to 32 bytes */
+};
+
 #endif /* _LINUX_VIRTIO_NET_H */



From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] virtio-net: move sg off stack
Date: Sun, 4 Apr 2010 16:07:41 +0300
Message-ID: <20100404130741.GA7500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	ne
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413Ab0DDNL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 09:11:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move sg structure off stack and into virtnet_info structure.
This helps remove extra sg_init_table calls as well as reduce
stack usage.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Tested-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1: fix compilation of add_recvbuf_mergeable (&rx_sg -> rx_sg)

This patch works for me. Shirley, could you find the time to test
this as well please?

 drivers/net/virtio_net.c |   52 ++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3f5be35..186dd6a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -39,8 +39,7 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 
-struct virtnet_info
-{
+struct virtnet_info {
 	struct virtio_device *vdev;
 	struct virtqueue *rvq, *svq, *cvq;
 	struct net_device *dev;
@@ -61,6 +60,10 @@ struct virtnet_info
 
 	/* Chain pages by the private ptr. */
 	struct page *pages;
+
+	/* fragments + linear part + virtio header */
+	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
+	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
 };
 
 struct skb_vnet_hdr {
@@ -323,10 +326,8 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
-	struct scatterlist sg[2];
 	int err;
 
-	sg_init_table(sg, 2);
 	skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
 	if (unlikely(!skb))
 		return -ENOMEM;
@@ -334,11 +335,11 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 	skb_put(skb, MAX_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
-	sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
+	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
 
-	skb_to_sgvec(skb, sg + 1, 0, skb->len);
+	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
 
-	err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 2, skb);
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, 2, skb);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
@@ -347,13 +348,11 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 
 static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 {
-	struct scatterlist sg[MAX_SKB_FRAGS + 2];
 	struct page *first, *list = NULL;
 	char *p;
 	int i, err, offset;
 
-	sg_init_table(sg, MAX_SKB_FRAGS + 2);
-	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
+	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
 		first = get_a_page(vi, gfp);
 		if (!first) {
@@ -361,7 +360,7 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 				give_pages(vi, list);
 			return -ENOMEM;
 		}
-		sg_set_buf(&sg[i], page_address(first), PAGE_SIZE);
+		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
 
 		/* chain new page in list head to match sg */
 		first->private = (unsigned long)list;
@@ -375,17 +374,17 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 	}
 	p = page_address(first);
 
-	/* sg[0], sg[1] share the same page */
-	/* a separated sg[0] for  virtio_net_hdr only during to QEMU bug*/
-	sg_set_buf(&sg[0], p, sizeof(struct virtio_net_hdr));
+	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
+	/* a separated vi->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
+	sg_set_buf(&vi->rx_sg[0], p, sizeof(struct virtio_net_hdr));
 
-	/* sg[1] for data packet, from offset */
+	/* vi->rx_sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
-	sg_set_buf(&sg[1], p + offset, PAGE_SIZE - offset);
+	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, MAX_SKB_FRAGS + 2,
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
 				       first);
 	if (err < 0)
 		give_pages(vi, first);
@@ -396,16 +395,15 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct page *page;
-	struct scatterlist sg;
 	int err;
 
 	page = get_a_page(vi, gfp);
 	if (!page)
 		return -ENOMEM;
 
-	sg_init_one(&sg, page_address(page), PAGE_SIZE);
+	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
 
-	err = vi->rvq->vq_ops->add_buf(vi->rvq, &sg, 0, 1, page);
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, 1, page);
 	if (err < 0)
 		give_pages(vi, page);
 
@@ -514,12 +512,9 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	struct scatterlist sg[2+MAX_SKB_FRAGS];
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 
-	sg_init_table(sg, 2+MAX_SKB_FRAGS);
-
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -553,12 +548,13 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
+		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
+		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
-	return vi->svq->vq_ops->add_buf(vi->svq, sg, hdr->num_sg, 0, skb);
+	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
+	return vi->svq->vq_ops->add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+					0, skb);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -941,6 +937,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vdev->priv = vi;
 	vi->pages = NULL;
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
+	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
-- 
1.7.0.2.280.gc6f05

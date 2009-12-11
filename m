From: Shirley Ma <mashirle@us.ibm.com>
Subject: PATCH v2 3/4] Defer skb allocation -- new recvbuf alloc & receive
 calls
Date: Fri, 11 Dec 2009 04:46:53 -0800
Message-ID: <1260535613.30371.24.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1260534506.30371.6.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
-------------

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 100b4b9..dde8060 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -203,6 +203,73 @@ static struct sk_buff *skb_goodcopy(struct virtnet_info *vi, struct page **page,
 	return skb;
 }
 
+static struct sk_buff *receive_big(struct virtnet_info *vi, struct page *page,
+				   unsigned int len)
+{
+	struct sk_buff *skb;
+
+	skb = skb_goodcopy(vi, &page, &len);
+	if (unlikely(!skb))
+		return NULL;
+
+	while (len > 0) {
+		len = skb_set_frag(skb, page, 0, len);
+		page = (struct page *)page->private;
+	}
+
+	if (page)
+		give_pages(vi, page);
+
+	return skb;
+}
+
+static struct sk_buff *receive_mergeable(struct virtnet_info *vi,
+					 struct page *page, unsigned int len)
+{
+	struct sk_buff *skb;
+	struct skb_vnet_hdr *hdr;
+	int num_buf, i;
+
+	if (len > PAGE_SIZE)
+		len = PAGE_SIZE;
+
+	skb = skb_goodcopy(vi, &page, &len);
+
+	if (unlikely(!skb))
+		return NULL;
+
+	hdr = skb_vnet_hdr(skb);
+	num_buf = hdr->mhdr.num_buffers;
+	while (--num_buf) {
+		struct page *page;
+
+		i = skb_shinfo(skb)->nr_frags;
+		if (i >= MAX_SKB_FRAGS) {
+			pr_debug("%s: packet too long %d\n", skb->dev->name,
+				 len);
+			skb->dev->stats.rx_length_errors++;
+			return skb;
+		}
+
+		page = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
+		if (!page) {
+			pr_debug("%s: rx error: %d buffers missing\n",
+				 skb->dev->name, hdr->mhdr.num_buffers);
+			skb->dev->stats.rx_length_errors++;
+			return skb;
+		}
+
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
+
+		skb_set_frag(skb, page, 0, len);
+
+		vi->num--;
+	}
+
+	return skb;
+}
+
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			unsigned len)
 {
@@ -356,6 +423,103 @@ drop:
 	dev_kfree_skb(skb);
 }
 
+static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp, bool *oom)
+{
+	struct sk_buff *skb;
+	struct skb_vnet_hdr *hdr;
+	struct scatterlist sg[2];
+	int err = 0;
+
+	skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
+	if (unlikely(!skb)) {
+		*oom = true;
+		return err;
+	}
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb_put(skb, MAX_PACKET_LEN);
+
+	hdr = skb_vnet_hdr(skb);
+	sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
+
+	skb_to_sgvec(skb, sg+1, 0, skb->len);
+
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 2, skb);
+	if (err < 0)
+		kfree_skb(skb);
+	else
+		skb_queue_head(&vi->recv, skb);
+
+	return err;
+}
+
+static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp, bool *oom)
+{
+	struct scatterlist sg[2 + MAX_SKB_FRAGS];
+	int total = MAX_SKB_FRAGS + 2;
+	char *p;
+	int err = 0;
+	int i, offset;
+	struct page *first = NULL;
+	struct page *page;
+	/* share one page between virtio_net header and data */
+	struct padded_vnet_hdr {
+		struct virtio_net_hdr hdr;
+		/* This padding makes our data 16 byte aligned */
+		char padding[6];
+	};
+
+	offset = sizeof(struct padded_vnet_hdr);
+
+	for (i = total - 1; i > 0; i--) {
+		page = get_a_page(vi, gfp);
+		if (!page) {
+			if (first)
+				give_pages(vi, first);
+			*oom = true;
+			break;
+		}
+
+		p = page_address(page);
+		page->private = (unsigned long)first;
+		first = page;
+
+		/* allocate MAX_SKB_FRAGS + 1 pages for big packets */
+		if (i == 1) {
+			sg_set_buf(&sg[i-1], p, sizeof(struct virtio_net_hdr));
+			sg_set_buf(&sg[i], p + offset, PAGE_SIZE - offset);
+			err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, total,
+						       first);
+			if (err < 0)
+				give_pages(vi, first);
+		} else
+			sg_set_buf(&sg[i], p, PAGE_SIZE);
+	}
+
+	return err;
+}
+
+static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp, bool *oom)
+{
+	struct page *page;
+	struct scatterlist sg;
+	int err = 0;
+
+	page = get_a_page(vi, gfp);
+	if (!page) {
+		*oom = true;
+		return err;
+	}
+
+	sg_init_one(&sg, page_address(page), PAGE_SIZE);
+
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, &sg, 0, 1, page);
+	if (err < 0)
+		give_pages(vi, page);
+
+	return err;
+}
+
 static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;



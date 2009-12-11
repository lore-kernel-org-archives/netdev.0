From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH v2 2/4] Defer skb allocation -- new skb_set calls & chain
 pages in virtio_net
Date: Fri, 11 Dec 2009 04:43:02 -0800
Message-ID: <1260535382.30371.20.camel@localhost.localdomain>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755361AbZLKMnM@vger.kernel.org>
In-Reply-To: <1260534506.30371.6.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
--------------

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bb5eb7b..100b4b9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -80,29 +80,25 @@ static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 	return (struct skb_vnet_hdr *)skb->cb;
 }
 
-static void give_a_page(struct virtnet_info *vi, struct page *page)
+static void give_pages(struct virtnet_info *vi, struct page *page)
 {
-	page->private = (unsigned long)vi->pages;
-	vi->pages = page;
-}
+	struct page *end;
 
-static void trim_pages(struct virtnet_info *vi, struct sk_buff *skb)
-{
-	unsigned int i;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		give_a_page(vi, skb_shinfo(skb)->frags[i].page);
-	skb_shinfo(skb)->nr_frags = 0;
-	skb->data_len = 0;
+	/* Find end of list, sew whole thing into vi->pages. */
+	for (end = page; end->private; end = (struct page *)end->private);
+	end->private = (unsigned long)vi->pages;
+	vi->pages = page;
 }
 
 static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 {
 	struct page *p = vi->pages;
 
-	if (p)
+	if (p) {
 		vi->pages = (struct page *)p->private;
-	else
+		/* use private to chain pages for big packets */
+		p->private = 0;
+	} else
 		p = alloc_page(gfp_mask);
 	return p;
 }
@@ -128,6 +124,85 @@ static void skb_xmit_done(struct virtqueue *svq)
 	netif_wake_queue(vi->dev);
 }
 
+static int skb_set_frag(struct sk_buff *skb, struct page *page,
+				int offset, int len)
+{
+	int i = skb_shinfo(skb)->nr_frags;
+	skb_frag_t *f;
+
+	i = skb_shinfo(skb)->nr_frags;
+	f = &skb_shinfo(skb)->frags[i];
+	f->page = page;
+	f->page_offset = offset;
+
+	if (len > PAGE_SIZE - f->page_offset)
+		f->size = PAGE_SIZE - f->page_offset;
+	else
+		f->size = len;
+
+	skb_shinfo(skb)->nr_frags++;
+	skb->data_len += f->size;
+	skb->len += f->size;
+
+	len -= f->size;
+	return len;
+}
+
+static struct sk_buff *skb_goodcopy(struct virtnet_info *vi, struct page **page,
+				    unsigned int *len)
+{
+	struct sk_buff *skb;
+	struct skb_vnet_hdr *hdr;
+	int copy, hdr_len, offset;
+	char *p;
+
+	p = page_address(*page);
+
+	skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
+	if (unlikely(!skb))
+		return NULL;
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	hdr = skb_vnet_hdr(skb);
+
+	if (vi->mergeable_rx_bufs) {
+		hdr_len = sizeof(hdr->mhdr);
+		offset = hdr_len;
+	} else {
+		/* share one page between virtio_net header and data */
+		struct padded_vnet_hdr {
+			struct virtio_net_hdr hdr;
+			/* This padding makes our data 16 byte aligned */
+			char padding[6];
+		};
+		hdr_len = sizeof(hdr->hdr);
+		offset = sizeof(struct padded_vnet_hdr);
+	}
+
+	memcpy(hdr, p, hdr_len);
+
+	*len -= hdr_len;
+	p += offset;
+
+	copy = *len;
+	if (copy > skb_tailroom(skb))
+		copy = skb_tailroom(skb);
+	memcpy(skb_put(skb, copy), p, copy);
+
+	*len -= copy;
+	offset += copy;
+
+	if (*len) {
+		*len = skb_set_frag(skb, *page, offset, *len);
+		*page = (struct page *)(*page)->private;
+	} else {
+		give_pages(vi, *page);
+		*page = NULL;
+	}
+
+	return skb;
+}
+
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			unsigned len)
 {
@@ -162,7 +237,7 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 		len -= copy;
 
 		if (!len) {
-			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
+			give_pages(vi, skb_shinfo(skb)->frags[0].page);
 			skb_shinfo(skb)->nr_frags--;
 		} else {
 			skb_shinfo(skb)->frags[0].page_offset +=

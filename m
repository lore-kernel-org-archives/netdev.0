From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] virtio_net: Clean up set_skb_frag()
Date: Thu, 20 Oct 2011 13:47:27 +0530
Message-ID: <20111020081727.509.83122.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>,
	virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove manual initialization in set_skb_frag, and instead
use __skb_fill_page_desc() to do the same. Patch tested
on net-next.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-10-20 08:34:31.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-10-20 08:43:57.000000000 +0530
@@ -143,18 +143,15 @@ static void skb_xmit_done(struct virtque
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
 			 unsigned int offset, unsigned int *len)
 {
+	int size = min((unsigned)PAGE_SIZE - offset, *len);
 	int i = skb_shinfo(skb)->nr_frags;
-	skb_frag_t *f;
 
-	f = &skb_shinfo(skb)->frags[i];
-	skb_frag_size_set(f, min((unsigned)PAGE_SIZE - offset, *len));
-	f->page_offset = offset;
-	__skb_frag_set_page(f, page);
+	__skb_fill_page_desc(skb, i, page, offset, size);
 
-	skb->data_len += skb_frag_size(f);
-	skb->len += skb_frag_size(f);
+	skb->data_len += size;
+	skb->len += size;
 	skb_shinfo(skb)->nr_frags++;
-	*len -= skb_frag_size(f);
+	*len -= size;
 }
 
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,

From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Mon, 17 Nov 2008 17:35:43 +1030
Message-ID: <200811171735.44025.rusty@rustcorp.com.au>
References: <200811171344.57410.rusty@rustcorp.com.au> <20081116.194505.140648013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53693 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbYKQHFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 02:05:50 -0500
In-Reply-To: <20081116.194505.140648013.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 November 2008 14:15:05 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Mon, 17 Nov 2008 13:44:57 +1030
>
> > @@ -82,6 +82,16 @@ static void give_a_page(struct virtnet_info *vi,
> > struct page *page)
>
> -E_EMAIL_CLIENT_NEWLINES

From: Mark McLoughlin <markmc@redhat.com>

Each time we re-fill the recv queue with buffers, we allocate
one too many skbs and free it again when adding fails. We should
recycle the pages allocated in this case.

A previous version of this patch made trim_pages() trim trailing
unused pages from skbs with some paged data, but this actually
caused a barely measurable slowdown.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (use netdev_priv)
---
 drivers/net/virtio_net.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..985271a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -82,6 +82,16 @@ static void give_a_page(struct virtnet_info *vi, struct page *page)
 	vi->pages = page;
 }
 
+static void trim_pages(struct virtnet_info *vi, struct sk_buff *skb)
+{
+	unsigned int i;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		give_a_page(vi, skb_shinfo(skb)->frags[i].page);
+	skb_shinfo(skb)->nr_frags = 0;
+	skb->data_len = 0;
+}
+
 static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 {
 	struct page *p = vi->pages;
@@ -121,14 +131,8 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 	}
 	len -= sizeof(struct virtio_net_hdr);
 
-	if (len <= MAX_PACKET_LEN) {
-		unsigned int i;
-
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-			give_a_page(dev->priv, skb_shinfo(skb)->frags[i].page);
-		skb->data_len = 0;
-		skb_shinfo(skb)->nr_frags = 0;
-	}
+	if (len <= MAX_PACKET_LEN)
+		trim_pages(netdev_priv(dev), skb);
 
 	err = pskb_trim(skb, len);
 	if (err) {
@@ -232,6 +236,7 @@ static void try_fill_recv(struct virtnet_info *vi)
 		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, num, skb);
 		if (err) {
 			skb_unlink(skb, &vi->recv);
+			trim_pages(vi, skb);
 			kfree_skb(skb);
 			break;
 		}


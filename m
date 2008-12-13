From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/8] net: Add skb_gro_receive
Date: Sat, 13 Dec 2008 12:35:23 +1100
Message-ID: <E1LBJPf-0003Yr-H2@gondolin.me.apana.org.au>
References: <20081213013420.GA13549@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53841 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753717AbYLMBf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 20:35:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Add skb_gro_receive

This patch adds the helper skb_gro_receive to merge packets for
GRO.  The current method is to allocate a new header skb and then
chain the original packets to its frag_list.  This is done to
make it easier to integrate into the existing GSO framework.

In future as GSO is moved into the drivers, we can undo this and
simply chain the original packets together.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    2 +
 net/core/skbuff.c      |   57 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2725f4e..2bdb539 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1649,6 +1649,8 @@ extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 
 extern struct sk_buff *skb_segment(struct sk_buff *skb, int features);
+extern int	       skb_gro_receive(struct sk_buff **head,
+				       struct sk_buff *skb);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cf05a8c..8ea648e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2439,6 +2439,63 @@ err:
 
 EXPORT_SYMBOL_GPL(skb_segment);
 
+int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct sk_buff *p = *head;
+	struct sk_buff *nskb;
+	unsigned int headroom;
+	unsigned int hlen;
+
+	if (skb_shinfo(p)->frag_list)
+		goto merge;
+
+	headroom = skb_headroom(p);
+	nskb = netdev_alloc_skb(p->dev, headroom);
+	if (unlikely(!nskb))
+		return -ENOMEM;
+
+	__copy_skb_header(nskb, p);
+	nskb->mac_len = p->mac_len;
+
+	skb_reserve(nskb, headroom);
+
+	hlen = p->data - skb_mac_header(p);
+	skb_set_mac_header(nskb, -hlen);
+	skb_set_network_header(nskb, skb_network_offset(p));
+	skb_set_transport_header(nskb, skb_transport_offset(p));
+
+	memcpy(skb_mac_header(nskb), skb_mac_header(p), hlen);
+
+	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
+	skb_shinfo(nskb)->frag_list = p;
+	skb_header_release(p);
+	nskb->prev = p;
+
+	nskb->data_len += p->len;
+	nskb->truesize += p->len;
+	nskb->len += p->len;
+
+	*head = nskb;
+	nskb->next = p->next;
+	p->next = NULL;
+
+	p = nskb;
+
+merge:
+	NAPI_GRO_CB(p)->count++;
+	p->prev->next = skb;
+	p->prev = skb;
+	skb_header_release(skb);
+
+	p->data_len += skb->len;
+	p->truesize += skb->len;
+	p->len += skb->len;
+
+	NAPI_GRO_CB(skb)->same_flow = 1;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(skb_gro_receive);
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",

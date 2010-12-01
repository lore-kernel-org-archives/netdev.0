From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 1/2] af_packet: use vmalloc_to_page() instead for the addresss returned by vmalloc()
Date: Wed,  1 Dec 2010 20:52:20 +0800
Message-ID: <1291207940-17140-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55243 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab0LAMwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 07:52:50 -0500
Received: by ywl5 with SMTP id 5so3350562ywl.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 04:52:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit causes the pgv->buffer may point to the memory
returned by vmalloc(). And we can't use virt_to_page() for the vmalloc
address.

This patch introduces a new inline function pgv_to_page(), which calls
vmalloc_to_page() for the vmalloc address, and virt_to_page() for the
__get_free_pages address.

We used to increase page pointer to get the next page at the next page
address, after Neil's patch, it is wrong, as the physical address may
be not continuous. This patch also fixes this issue.

    commit 0e3125c755445664f00ad036e4fc2cd32fd52877
    Author: Neil Horman <nhorman@tuxdriver.com>
    Date:   Tue Nov 16 10:26:47 2010 -0800

    packet: Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v4)

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: fix the page incremental issue
 net/packet/af_packet.c |   36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 422705d..26fbeb1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -224,6 +224,13 @@ struct packet_skb_cb {
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
+static inline struct page *pgv_to_page(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		return vmalloc_to_page(addr);
+	return virt_to_page(addr);
+}
+
 static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 {
 	union {
@@ -236,11 +243,11 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 	switch (po->tp_version) {
 	case TPACKET_V1:
 		h.h1->tp_status = status;
-		flush_dcache_page(virt_to_page(&h.h1->tp_status));
+		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
 		break;
 	case TPACKET_V2:
 		h.h2->tp_status = status;
-		flush_dcache_page(virt_to_page(&h.h2->tp_status));
+		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		break;
 	default:
 		pr_err("TPACKET version not supported\n");
@@ -263,10 +270,10 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 	h.raw = frame;
 	switch (po->tp_version) {
 	case TPACKET_V1:
-		flush_dcache_page(virt_to_page(&h.h1->tp_status));
+		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
 		return h.h1->tp_status;
 	case TPACKET_V2:
-		flush_dcache_page(virt_to_page(&h.h2->tp_status));
+		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		return h.h2->tp_status;
 	default:
 		pr_err("TPACKET version not supported\n");
@@ -800,15 +807,11 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	__packet_set_status(po, h.raw, status);
 	smp_mb();
 	{
-		struct page *p_start, *p_end;
-		u8 *h_end = h.raw + macoff + snaplen - 1;
-
-		p_start = virt_to_page(h.raw);
-		p_end = virt_to_page(h_end);
-		while (p_start <= p_end) {
-			flush_dcache_page(p_start);
-			p_start++;
-		}
+		u8 *start, *end;
+
+		end = (u8 *)PAGE_ALIGN((unsigned long)h.raw + macoff + snaplen);
+		for (start = h.raw; start < end; start += PAGE_SIZE)
+			flush_dcache_page(pgv_to_page(start));
 	}
 
 	sk->sk_data_ready(sk, 0);
@@ -915,7 +918,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	}
 
 	err = -EFAULT;
-	page = virt_to_page(data);
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);
@@ -934,11 +936,11 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 			return -EFAULT;
 		}
 
+		page = pgv_to_page(data);
+		data += len;
 		flush_dcache_page(page);
 		get_page(page);
-		skb_fill_page_desc(skb,
-				nr_frags,
-				page++, offset, len);
+		skb_fill_page_desc(skb, nr_frags, page, offset, len);
 		to_write -= len;
 		offset = 0;
 		len_max = PAGE_SIZE;

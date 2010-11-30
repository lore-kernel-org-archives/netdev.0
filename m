From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the addresss returned by vmalloc()
Date: Tue, 30 Nov 2010 21:56:48 +0800
Message-ID: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45502 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931Ab0K3N5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 08:57:22 -0500
Received: by gwj20 with SMTP id 20so2691741gwj.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 05:57:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit causes the pgv->buffer may point to the memory
returned by vmalloc(). And we can't use virt_to_page() for the vmalloc
address.

This patch introduces a new inline function pgv_to_page(), which calls
vmalloc_to_page() for the vmalloc address, and virt_to_page() for the
__get_free_pages address.

    commit 0e3125c755445664f00ad036e4fc2cd32fd52877
    Author: Neil Horman <nhorman@tuxdriver.com>
    Date:   Tue Nov 16 10:26:47 2010 -0800

    packet: Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v4)

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/packet/af_packet.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 422705d..0171b20 100644
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
@@ -803,8 +810,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		struct page *p_start, *p_end;
 		u8 *h_end = h.raw + macoff + snaplen - 1;
 
-		p_start = virt_to_page(h.raw);
-		p_end = virt_to_page(h_end);
+		p_start = pgv_to_page(h.raw);
+		p_end = pgv_to_page(h_end);
 		while (p_start <= p_end) {
 			flush_dcache_page(p_start);
 			p_start++;
@@ -915,7 +922,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	}
 
 	err = -EFAULT;
-	page = virt_to_page(data);
+	page = pgv_to_page(data);
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);

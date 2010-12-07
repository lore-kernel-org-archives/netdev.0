From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] af_packet: eliminate pgv_to_page on some arches
Date: Tue,  7 Dec 2010 22:26:16 +0800
Message-ID: <1291731976-15793-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:48965 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab0LGO0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 09:26:33 -0500
Received: by gxk19 with SMTP id 19so7592971gxk.11
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 06:26:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some arches don't need flush_dcache_page(), and don't implement it, so
we can eliminate pgv_to_page() calls on those arches.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/packet/af_packet.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a11c731..0e152b1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -223,7 +223,7 @@ struct packet_skb_cb {
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
-static inline struct page *pgv_to_page(void *addr)
+static inline __pure struct page *pgv_to_page(void *addr)
 {
 	if (is_vmalloc_addr(addr))
 		return vmalloc_to_page(addr);
@@ -805,6 +805,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	__packet_set_status(po, h.raw, status);
 	smp_mb();
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
 	{
 		u8 *start, *end;
 
@@ -812,6 +813,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		for (start = h.raw; start < end; start += PAGE_SIZE)
 			flush_dcache_page(pgv_to_page(start));
 	}
+#endif
 
 	sk->sk_data_ready(sk, 0);
 

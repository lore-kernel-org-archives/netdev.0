From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: fix a couple of cppcheck warnings
Date: Sun, 19 Jan 2014 11:46:53 +0100
Message-ID: <1390128413-7075-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbaASKq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 05:46:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesn't bring much, but also doesn't hurt us to fix 'em:

1) In tpacket_rcv() flush dcache page we can restirct the scope
   for start and end and remove one layer of indent.

2) In tpacket_destruct_skb() we can restirct the scope for ph.

3) In alloc_one_pg_vec_page() we can remove the NULL assignment
   and change spacing a bit.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 37 +++++++++++++++----------------------
 1 file changed, 15 insertions(+), 22 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 12f2f72..aecae1b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2009,19 +2009,20 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		sll->sll_ifindex = dev->ifindex;
 
 	smp_mb();
+
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
-	{
+	if (po->tp_version <= TPACKET_V2) {
 		u8 *start, *end;
 
-		if (po->tp_version <= TPACKET_V2) {
-			end = (u8 *)PAGE_ALIGN((unsigned long)h.raw
-				+ macoff + snaplen);
-			for (start = h.raw; start < end; start += PAGE_SIZE)
-				flush_dcache_page(pgv_to_page(start));
-		}
-		smp_wmb();
+		end = (u8 *) PAGE_ALIGN((unsigned long) h.raw +
+					macoff + snaplen);
+
+		for (start = h.raw; start < end; start += PAGE_SIZE)
+			flush_dcache_page(pgv_to_page(start));
 	}
+	smp_wmb();
 #endif
+
 	if (po->tp_version <= TPACKET_V2)
 		__packet_set_status(po, h.raw, status);
 	else
@@ -2050,9 +2051,9 @@ ring_is_full:
 static void tpacket_destruct_skb(struct sk_buff *skb)
 {
 	struct packet_sock *po = pkt_sk(skb->sk);
-	void *ph;
 
 	if (likely(po->tx_ring.pg_vec)) {
+		void *ph;
 		__u32 ts;
 
 		ph = skb_shinfo(skb)->destructor_arg;
@@ -3648,34 +3649,26 @@ static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
 
 static char *alloc_one_pg_vec_page(unsigned long order)
 {
-	char *buffer = NULL;
+	char *buffer;
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP |
 			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
 
 	buffer = (char *) __get_free_pages(gfp_flags, order);
-
 	if (buffer)
 		return buffer;
 
-	/*
-	 * __get_free_pages failed, fall back to vmalloc
-	 */
+	/* __get_free_pages failed, fall back to vmalloc */
 	buffer = vzalloc((1 << order) * PAGE_SIZE);
-
 	if (buffer)
 		return buffer;
 
-	/*
-	 * vmalloc failed, lets dig into swap here
-	 */
+	/* vmalloc failed, lets dig into swap here */
 	gfp_flags &= ~__GFP_NORETRY;
-	buffer = (char *)__get_free_pages(gfp_flags, order);
+	buffer = (char *) __get_free_pages(gfp_flags, order);
 	if (buffer)
 		return buffer;
 
-	/*
-	 * complete and utter failure
-	 */
+	/* complete and utter failure */
 	return NULL;
 }
 
-- 
1.7.11.7
